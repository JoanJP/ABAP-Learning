*&---------------------------------------------------------------------*
*& Report ZGM_JOAN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZRW2_EXAM_GM_47829.
TABLES: MKPF, MSEG, MAKT, T001W.

DATA: GS_FINAL TYPE ZSGM_JOAN,
      GT_FINAL TYPE TABLE OF ZSGM_JOAN.

DATA: GS_LOG TYPE ZGMLOG_JOAN.

DATA: GT_FCAT TYPE LVC_T_FCAT.

DATA: GS_LAYOUT TYPE LVC_S_LAYO.

PARAMETERS: P_WERKS TYPE MSEG-WERKS OBLIGATORY DEFAULT 1710.
SELECT-OPTIONS: S_BUDAT FOR MKPF-BUDAT,
S_LGORT FOR MSEG-LGORT,
S_MATNR FOR MSEG-MATNR.

INITIALIZATION.
  S_BUDAT-LOW = '20200101'.
  S_BUDAT-HIGH = SY-DATUM.
  S_BUDAT-OPTION = 'BT'.
  S_BUDAT-SIGN = 'I'.
  APPEND S_BUDAT.

AT SELECTION-SCREEN.
  PERFORM FRM_CHECK_EXIST.

START-OF-SELECTION.
  PERFORM FRM_DATA_COLLECT.
  PERFORM FRM_SET_LAYOUT.
  PERFORM FRM_FIELDCAT.
  PERFORM FRM_SHOWALV.


*&---------------------------------------------------------------------*
*& Form FRM_CHECK_EXIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_CHECK_EXIST .
  SELECT COUNT(*)
      FROM T001W
      WHERE WERKS = P_WERKS.
  IF SY-SUBRC <> 0.
    MESSAGE |NO DATA| TYPE 'E'.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form FRM_DATA_COLLECT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_DATA_COLLECT .
  SELECT
    MSEG~WERKS,
    T001W~NAME1,
    MSEG~LGORT,
    MSEG~MATNR,
    MAKT~MAKTX,
    MSEG~MEINS,
    MSEG~WAERS,
    SUM( CASE
         WHEN MSEG~SHKZG = 'S' THEN MSEG~MENGE
         END ) AS QTY_IN,
    SUM( CASE
         WHEN MSEG~SHKZG = 'H' THEN MSEG~MENGE
         END ) AS QTY_OUT,
    SUM( CASE
         WHEN MSEG~SHKZG = 'S' THEN MSEG~DMBTR
         END ) AS AMOUNT_IN,
    SUM( CASE
         WHEN MSEG~SHKZG = 'H' THEN MSEG~DMBTR
         END ) AS AMOUNT_OUT
    FROM MKPF
    INNER JOIN MSEG ON MKPF~MBLNR = MSEG~MBLNR AND MKPF~MJAHR = MSEG~MJAHR
    INNER JOIN T001W ON MSEG~WERKS = T001W~WERKS
    INNER JOIN MAKT ON MSEG~MATNR = MAKT~MATNR
    WHERE MSEG~WERKS = @P_WERKS AND MKPF~BUDAT IN @S_BUDAT AND MSEG~LGORT IN @S_LGORT
      AND MSEG~MATNR IN @S_MATNR AND MAKT~SPRAS = @SY-LANGU
    GROUP BY MSEG~WERKS,
             T001W~NAME1,
             MSEG~LGORT,
             MSEG~MATNR,
             MAKT~MAKTX,
             MSEG~MEINS,
             MSEG~WAERS
    INTO CORRESPONDING FIELDS OF TABLE @GT_FINAL.

  LOOP AT GT_FINAL INTO GS_FINAL.
    GS_FINAL-QTY_BAL = GS_FINAL-QTY_IN - GS_FINAL-QTY_OUT.
    GS_FINAL-AMOUNT_BAL = GS_FINAL-AMOUNT_IN - GS_FINAL-AMOUNT_OUT.
    MODIFY GT_FINAL FROM GS_FINAL.
  ENDLOOP.

  DATA LS_CELL_COLOR TYPE LVC_S_SCOL.
  LOOP AT GT_FINAL INTO GS_FINAL.
    IF GS_FINAL-QTY_BAL > 50 AND GS_FINAL-QTY_BAL < 100.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'QTY_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '3'.
      GS_FINAL-ZICON  = '@1A@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ELSEIF GS_FINAL-AMOUNT_BAL > 0 AND GS_FINAL-AMOUNT_BAL < 100.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'AMOUNT_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '3'.
      GS_FINAL-ZICON  = '@1A@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ELSEIF GS_FINAL-QTY_BAL > 100.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'QTY_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '3'.
      GS_FINAL-ZICON  = '@01@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ELSEIF GS_FINAL-AMOUNT_BAL > 100.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'AMOUNT_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '5'.
      GS_FINAL-ZICON  = '@01@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ELSEIF GS_FINAL-AMOUNT_BAL = 0.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'AMOUNT_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '7'.
      GS_FINAL-ZICON  = '@02@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ELSEIF GS_FINAL-AMOUNT_BAL = 0.
      CLEAR: LS_CELL_COLOR.
      LS_CELL_COLOR-FNAME = 'AMOUNT_BAL'.
      LS_CELL_COLOR-COLOR-COL   = '6'.
      GS_FINAL-ZICON  = '@02@'.
      APPEND LS_CELL_COLOR TO GS_FINAL-CELL_COLOR.
    ENDIF.
    MODIFY GT_FINAL FROM GS_FINAL.
    CLEAR GS_FINAL.
  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form FRM_SET_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SET_LAYOUT .
  GS_LAYOUT-ZEBRA = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
  GS_LAYOUT-CTAB_FNAME = 'CELL_COLOR'.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form FRM_FIELDCAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_FIELDCAT .
  CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
    EXPORTING
      I_STRUCTURE_NAME       = 'ZSGM_JOAN'
    CHANGING
      CT_FIELDCAT            = GT_FCAT
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.
  LOOP AT GT_FCAT ASSIGNING FIELD-SYMBOL(<FS_FCAT>).
    CASE <FS_FCAT>-FIELDNAME.
      WHEN 'MATNR'.
        <FS_FCAT>-HOTSPOT = 'X'.
    ENDCASE.
  ENDLOOP.
ENDFORM.


*&---------------------------------------------------------------------*
*& Form FRM_SHOWALV
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM FRM_SHOWALV.
  DATA LT_EVENTS TYPE SLIS_T_EVENT.
  DATA LS_EVENTS LIKE LINE OF LT_EVENTS.

  LS_EVENTS-NAME = SLIS_EV_PF_STATUS_SET.
  LS_EVENTS-FORM = 'FRM_SET_PF_STATUS'.
  APPEND LS_EVENTS TO LT_EVENTS.

  LS_EVENTS-NAME = SLIS_EV_USER_COMMAND.
  LS_EVENTS-FORM = 'FRM_USER_COMMAND'.
  APPEND LS_EVENTS TO LT_EVENTS.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      IS_LAYOUT_LVC      = GS_LAYOUT
      IT_FIELDCAT_LVC    = GT_FCAT
      I_CALLBACK_PROGRAM = SY-REPID
      IT_EVENTS          = LT_EVENTS
      I_SAVE             = 'A'
    TABLES
      T_OUTTAB           = GT_FINAL
    EXCEPTIONS
      PROGRAM_ERROR      = 1
      OTHERS             = 2.
ENDFORM.


FORM FRM_SET_PF_STATUS USING PV_EXCL_TAB TYPE KKBLO_T_EXTAB.
  SET TITLEBAR 'TITLE' WITH 'Goods Movement' 'Report' 'for :' 'Joan Jalu Pangestu'.
  SET PF-STATUS 'STANDARD_FULLSCREEN'.
ENDFORM.

FORM FRM_USER_COMMAND USING PV_UCOMM       LIKE SY-UCOMM
                            PS_FIELD_INFO  TYPE SLIS_SELFIELD.

  TYPES: BEGIN OF TY_TEMP,
           MBLNR TYPE MSEG-MBLNR,
           MJAHR TYPE MSEG-MJAHR,
           ZEILE TYPE MSEG-ZEILE,
           MATNR TYPE MSEG-MATNR,
           WERKS TYPE MSEG-WERKS,
           LGORT TYPE MSEG-LGORT,
           SHKZG TYPE MSEG-SHKZG,
           WAERS TYPE MSEG-WAERS,
           DMBTR TYPE MSEG-DMBTR,
           MENGE TYPE MSEG-MENGE,
           MEINS TYPE MSEG-MEINS,
         END OF TY_TEMP.

  DATA: LS_TEMP TYPE TY_TEMP,
        LT_TEMP TYPE TABLE OF TY_TEMP.
  DATA: LT_FCAT_1 TYPE LVC_T_FCAT.

  CASE PV_UCOMM.
    WHEN '&ZLOG'.
      READ TABLE GT_FINAL ASSIGNING FIELD-SYMBOL(<FS_COMBINE1>) INDEX PS_FIELD_INFO-TABINDEX.
      IF SY-SUBRC = 0.
        GS_LOG-PLANT            = <FS_COMBINE1>-WERKS.
        GS_LOG-NAME1            = <FS_COMBINE1>-NAME1.
        GS_LOG-LGORT            = <FS_COMBINE1>-LGORT.
        GS_LOG-MATNR            = <FS_COMBINE1>-MATNR.
        GS_LOG-MAKTX            = <FS_COMBINE1>-MAKTX.
        GS_LOG-MEINS            = <FS_COMBINE1>-MEINS.
        GS_LOG-WAERS            = <FS_COMBINE1>-WAERS.
        GS_LOG-QTY_IN           = <FS_COMBINE1>-QTY_IN.
        GS_LOG-QTY_OUT          = <FS_COMBINE1>-QTY_OUT.
        GS_LOG-QTY_BAL          = <FS_COMBINE1>-QTY_BAL.
        GS_LOG-AMOUNT_IN        = <FS_COMBINE1>-AMOUNT_IN.
        GS_LOG-AMOUNT_OUT       = <FS_COMBINE1>-AMOUNT_OUT.
        GS_LOG-AMOUNT_BAL       = <FS_COMBINE1>-AMOUNT_BAL.
        MODIFY ZGMLOG_JOAN FROM GS_LOG.
        CLEAR GS_LOG.
      ENDIF.

    WHEN '&IC1'.
      READ TABLE GT_FINAL ASSIGNING FIELD-SYMBOL(<FS_COMBINE2>) INDEX PS_FIELD_INFO-TABINDEX.
      IF PS_FIELD_INFO-FIELDNAME = 'MATNR'.
        SET PARAMETER ID 'MAT' FIELD <FS_COMBINE2>-MATNR.
        CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
      ELSE.
        READ TABLE GT_FINAL ASSIGNING FIELD-SYMBOL(<FS_COMBINE3>) INDEX PS_FIELD_INFO-TABINDEX.
        SELECT
          MBLNR,
               MJAHR,
               ZEILE,
               MATNR,
               WERKS,
               LGORT,
               SHKZG,
               WAERS,
               DMBTR,
               MENGE,
               MEINS
          FROM MSEG
          INTO CORRESPONDING FIELDS OF TABLE @LT_TEMP WHERE WERKS = @<FS_COMBINE3>-WERKS
          AND MATNR = @<FS_COMBINE3>-MATNR AND LGORT = @<FS_COMBINE3>-LGORT AND WAERS = @<FS_COMBINE3>-WAERS
          AND MEINS = @<FS_COMBINE3>-MEINS.

        APPEND VALUE #( FIELDNAME = 'MBLNR' REF_FIELD = 'MBLNR' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'MJAHR' REF_FIELD = 'MJAHR' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'ZEILE' REF_FIELD = 'ZEILE' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'MATNR' REF_FIELD = 'MATNR' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'WERKS' REF_FIELD = 'WERKS' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'LGORT' REF_FIELD = 'LGORT' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'SHKZG' REF_FIELD = 'SHKZG' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'WAERS' REF_FIELD = 'WAERS' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'DMBTR' REF_FIELD = 'DMBTR' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'MENGE' REF_FIELD = 'MENGE' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.
        APPEND VALUE #( FIELDNAME = 'MEINS' REF_FIELD = 'MEINS' REF_TABLE = 'MSEG' ) TO LT_FCAT_1.

        CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
          EXPORTING
            IS_LAYOUT_LVC   = GS_LAYOUT
            IT_FIELDCAT_LVC = LT_FCAT_1
          TABLES
            T_OUTTAB        = LT_TEMP
          EXCEPTIONS
            PROGRAM_ERROR   = 1
            OTHERS          = 2.
      ENDIF.
  ENDCASE.
ENDFORM.