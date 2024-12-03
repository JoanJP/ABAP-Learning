# Background Overview
The customer wants a report program that displays Goods Movement information and provides **advanced ALV functionalities**. The program will also require a custom table to store additional information for historical reporting. The user will input parameters for query restrictions:
- Posting Date: `MKPF-BUDAT`
- Plant: `MSEG-WERKS`
- Storage Location: `MSEG-LGORT`
- Material Number: `MSEG-MATNR`

# Report Requirements
The report should display:
- `ICON`
- Plant: `MSEG-WERKS`
- Plant Name: `T001W-NAME1`
- Storage Location: `MSEG-LGORT`
- Material Number: `MSEG-MATNR` (Set Hotspot click)
- Material Description: `MAKT-MAKTX`
- Base Unit of Measure: `MSEG-MEINS`
- Currency: `MSEG-WAERS`
- Quantity In: `MSEG-MENGE` (QTY_IN), SHKZG = 'S'
- Quantity Out: `MSEG-MENGE` (QTY_OUT), SHKZG = 'H'
- Quantity Balance: `MSEG-MENGE` (QTY_BAL) = QTY_IN - QTY_OUT
- Amount In: `MSEG-DMBTR` (AMOUNT_IN), SHKZG = 'S'
- Amount Out: `MSEG-DMBTR` (AMOUNT_OUT), SHKZG = 'H'
- Amount Balance: `MSEG-DMBTR` (AMOUNT_BAL) = AMOUNT_IN - AMOUNT_OUT

# Objectives:
**Create a Custom Table** in DDIC 
  - Fields in the table is same as on the ALV display without the `ICON`.
  - Create your own data element and domain for your Ztable.
  - Add a transparent table with a primary key on `WERKS`.
  - Generate table maintenance for this table (SM30).

**Selection Screen Setup** 
  * Input fields:
    - Posting Date `MKPF-BUDAT` required, in range set default from 2020/01/01 to today's date
    - Plant: `MSEG-WERKS` required, set default '1710'.
    - Storage Location: `MSEG-LGORT` in range.
    - Material Number: `MSEG-MATNR` in range.
  * Existence Check 
    - Validate that the plant exists in table `T001W`. Provide a proper error message if not found.

**Data Retrieval and Manipulation** 
  * Retrieve data from `MKPF` and `MSEG` tables based on the selection screen inputs.
  * Accumulate from `MSEG` for the corresponding fields for each row:
    - Quantity In: SUM(`MSEG-MENGE`) (QTY_IN), when the `SHKZG` = 'S'
    - Quantity Out: SUM(`MSEG-MENGE`) (QTY_OUT),when the `SHKZG` = 'H'
    - Quantity Balance: `MSEG-MENGE` (QTY_BAL) = QTY_IN - QTY_OUT
    - Amount In: SUM(`MSEG-DMBTR`) (AMOUNT_IN), when the `SHKZG` = 'S'
    - Amount Out: SUM(`MSEG-DMBTR`) (AMOUNT_OUT), when the `SHKZG` = 'H'
    - Amount Balance: `MSEG-DMBTR` (AMOUNT_BAL) = AMOUNT_IN - AMOUNT_OUT
  * Fetch the remaining fields for plant name (`T001W-NAME1`) and material description (`MAKT-MAKTX`) in the system's language.

**ALV Grid Display with Event Handling** 
  * Display the final data in an ALV grid with the following advanced features:
    - ADD LAYOUT: Zebra, and optimize the colum of the ALV display.
    - PF-STATUS: Use Standard Fullscreen, and Add toolbar buttons for "Send Log" With Icon Insert.
    - PF-STATUS: Title with placeholder : "Goods Movement" "Report" "for: " "[FULL NAME]"
    - Row Coloring & ICON : Highlight column of the amount and Quantity, where Quantity and amount (`MENGE` & `DMBTR`) between 50 - 100 in Yellow And set the Icon Warning, when the quantity and amount is > 100 set Green And set the Icon With Green Checkmark, equal to zero set color to RED And set the ICON to 'X' red mark.

**Event Handling** 
  * Single-click actions:
    - On selected row, take `MSEG-MATNR`: Jump to transaction MM03 to display MATERIAL details.
  * Double-click actions:
    - Open a second ALV grid displaying detailed raw data from MSEG for the selected line.
  * Button "Send Log" Click:
    - Insert data from the selected row to your own created Ztable (LOG).

**Second ALV Grid Requirements**
* Fields to display in the second ALV grid:
  - Material Document Number: `MSEG-MBLNR` (Set Hotspot click)
  - Material Document Year: `MSEG-MJAHR`
  - Document Item: `MSEG-ZEILE`
  - Material Number: `MSEG-MATNR` (Set Hotspot click)
  - Plant: `MSEG-WERKS`
  - Storage Location: `MSEG-LGORT`
  - Debit/Credit Indicator: `MSEG-SHKZG`
  - Currency: `MSEG-WAERS`
  - Amount: `MSEG-DMBTR`
  - Quantity: `MSEG-MENGE`
  - Base Unit of Measure: `MSEG-MEINS`

# Specification
**DDIC Table Requirements**:
- Ensure the Z-created table has the proper key definition.
- Maintain consistency checks on input through domain-level validation.
Code Standards:
- Follow variable naming conventions.
- Use text elements instead of hardcoded values for descriptions.
- Use constants for fixed values whenever possible.
- Add meaningful comments explaining core logic.
- Use the Modularization Technique

**Error Handling**:
- Handle empty or invalid input gracefully.
- Validate all database operations and provide meaningful error messages.

**Customizations**:
- Implement user commands (USER_COMMAND) for toolbar buttons.
- Use event DOUBLE_CLICK for the secondary ALV grid.
Performance Considerations:
- Select only required fields from tables (Don't SELECT * ).
- Use field symbols or work areas for efficient data processing.