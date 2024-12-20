*&---------------------------------------------------------------------*
*& Report ZSO_JOAN
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT ZSO_JOAN.

"DECLARE TABLE AND TYPE
TABLES: VBAK, VBAP, KNA1, MAKT, ZEMPID.
TYPES: BEGIN OF TY_FINAL,
         VBELN  TYPE VBAP-VBELN,
         POSNR  TYPE VBAP-POSNR,
         VKORG  TYPE VBAK-VKORG,
         KUNNR  TYPE VBAK-KUNNR,
         NAME1  TYPE KNA1-NAME1,
         MATNR  TYPE VBAP-MATNR,
         MAKTX  TYPE MAKT-MAKTX,
         KWMENG TYPE VBAP-KWMENG,
         VRKME  TYPE VBAP-VRKME,
         NETPR  TYPE VBAP-NETPR,
         WAERK  TYPE VBAK-WAERK,
       END OF TY_FINAL.
DATA: GT_FINAL TYPE STANDARD TABLE OF TY_FINAL.

"SET SELECTION SCREEN
PARAMETERS: P_SALORG TYPE VBAK-VKORG OBLIGATORY.
SELECT-OPTIONS: S_SALDOC FOR VBAP-VBELN, 
                S_MATNR FOR VBAP-MATNR,
                S_SALORD FOR VBAK-AUART NO INTERVALS,
                S_DISCHN FOR VBAK-VTWEG NO INTERVALS.

INITIALIZATION.
  "SET DEFAULT VALUE
  S_SALDOC-LOW = 20000002.
  S_SALDOC-OPTION = 'BT'.
  APPEND S_SALDOC.

AT SELECTION-SCREEN.
  "CHECK EXISTENCE
  SELECT SINGLE VBELN
      FROM VBAK
      WHERE VBELN IN @S_SALDOC
      INTO @DATA(GV_TEMP).
  IF SY-SUBRC <> 0.
    MESSAGE | DATA DOESN'T EXIST | TYPE 'E'.
  ENDIF.
  IF S_SALDOC IS INITIAL.
    MESSAGE | DATA CAN'T BE EMPTY | TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.

START-OF-SELECTION.
  "POPULATE DATA
  SELECT VBAP~VBELN,
         VBAP~POSNR,
         VBAK~VKORG,
         VBAK~KUNNR,
         KNA1~NAME1 AS NAME1,
         VBAP~MATNR,
         MAKT~MAKTX,
         VBAP~KWMENG,
         VBAP~VRKME,
         VBAP~NETPR,
         VBAK~WAERK
    FROM VBAP
    INNER JOIN VBAK ON VBAP~VBELN = VBAK~VBELN
    INNER JOIN KNA1 ON VBAK~KUNNR = KNA1~KUNNR
    INNER JOIN MAKT ON VBAP~MATNR = MAKT~MATNR
    WHERE VBAK~VKORG = @P_SALORG AND VBAP~VBELN IN @S_SALDOC
    AND VBAP~MATNR IN @S_MATNR AND VBAK~AUART IN @S_SALORD
    AND VBAK~VTWEG IN @S_DISCHN AND MAKT~SPRAS = @SY-LANGU
    INTO CORRESPONDING FIELDS OF TABLE @GT_FINAL.
  "DISPLAY FINAL INTERNAL TABLE IF SUCCESS 
  IF SY-SUBRC = 0.
    CL_DEMO_OUTPUT=>DISPLAY( GT_FINAL ).
  ELSE.
    MESSAGE | DATA NOT FOUND | TYPE 'E'.
  ENDIF.
