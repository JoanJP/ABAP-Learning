# Background Overview
The customer requires a program to display sales order details. The user will input parameters for query restrictions:
- Sales Order Type: `VBAK-AUART`
- Sales Organization: `VBAK-VKORG`
- Distribution Channel: `VBAK-VTWEG`
- Sales Document: `VBAK-VBELN`
- Material Number: `VBAP-MATNR`

# Report Requirements
The final table should show:
- Sales Document Number: `VBAP-VBELN`
- Item Number: `VBAP-POSNR`
- Sales Organization: `VBAK-VKORG`
- Customer Number: `VBAK-KUNNR`
- Customer Name: `KNA1-NAME1`
- Material Number: `VBAP-MATNR`
- Material Description: `MAKT-MAKTX`
- Order Quantity: `VBAP-KWMENG`
- Order Unit: `VBAP-VRKME`
- Net Price: `VBAP-NETPR`
- Currency: `VBAK-WAERK`

# Objectives:
**Create a selection screen** with the following requirements:
  - Sales Organization is required.
  - Sales Document as a range with default value "20000002".
  - Material Number as a range.
  - Sales Order Type and Distribution Channel can hold multiple value input but not in range.

**Check the existence** of the sales document in the `VBAK` table and provide an error message if not found.

**Check Sales document input field** cannot be empty using the AT SELECTION SCREEN event.

**Get data** from `VBAK` and `VBAP` tables based on user input.

**Populate the remaining fields `KNA1-NAME1`** based on customer data found on the previous step and `MAKT-MAKTX` based on material data found on the previous step and for `MAKTX` get the material description which language is = system language.

**DISPLAY** your final ITAB result.