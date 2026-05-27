FUNCTION zv360fm_get_code_objects.
*"----------------------------------------------------------------------
*"*"Interface local:
*"  IMPORTING
*"     REFERENCE(IV_OBJECT) TYPE  STRING OPTIONAL
*"  EXPORTING
*"     VALUE(EV_TYPE) TYPE  STRING
*"  TABLES
*"      ET_SOURCE STRUCTURE  ZV360S_SOURCE OPTIONAL
*"----------------------------------------------------------------------
*------------------------------------------------------------------------*
*                         ATTENTION PLEASE                               *
*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
* DISCLAIMER FOR UNAUTHORIZED USE OF SOURCE CODE:                        *
*                                                                        *
* This source code is provided solely for authorized use and distribution*
* in accordance with the terms of its licensing agreement with V360. Any *
* unauthorized use, reproduction, modification, or distribution of this  *
* whether in part or in whole, is STRICTLY PROHIBITED                    *
*                                                                        *
* V360 and its affiliates kindly request that you avoid from unauthorized*
* use of this source code. We cannot accept responsibility for any       *
* consequences, legal or otherwise, resulting from such unauthorized use.*
*                                                                        *
* Unauthorized access, copying, or modification of this source code may  *
* result in legal action to protect the intellectual property rights of  *
* V360.                                                                  *
* By accessing, copying, or using this source code without proper autho- *
* rization, you acknowledge and agree to hold harmless V360 and its affi-*
* liates from any claims, damages, or liabilities that may arise.        *
*                                                                        *
* If you are uncertain about whether your use of this source code is     *
* authorized, please reach out to V360 for clarification and obtain the  *
* necessary permissions beforeproceeding.                                *
*------------------------------------------------------------------------*
*------------------------------------------------------------------------*
* DESCRIPTION: Create RFC function in SAP to read objects                *
*                                                                        *
* AUTHOR: guilherme.mota <META>                                          *
* DATE : <20/02/2026>                                                    *
*------------------------------------------------------------------------*
  DATA: lv_name      TYPE progname,
        lv_prog      TYPE progname,
        lv_cp        TYPE progname,
        lv_line      TYPE string,
        ls_out       TYPE zv360s_source,
        lv_exist     TYPE seoclsname,
        lv_classpool TYPE progname,
        lv_upper     TYPE string,
        lv_mainprog  TYPE progname,
        lv_capture   TYPE abap_bool.

  DATA: lt_code TYPE STANDARD TABLE OF string,
        lt_inc  TYPE TABLE OF d010inc,
        ls_inc  TYPE d010inc.

  CLEAR: ev_type.
  REFRESH et_source.

  lv_name = iv_object.

*---------------------------------------------------------------------*
* SE24
*---------------------------------------------------------------------*
  CLEAR: lt_code,
  lv_classpool.

  "Verifica se classe existe
  SELECT SINGLE clsname
    INTO lv_exist
    FROM seoclass
    WHERE clsname = lv_name.

  IF sy-subrc = 0.

    "Monta nome real do class pool
    lv_classpool = lv_name && '================CP'.

    READ REPORT lv_classpool INTO lt_code.

    IF sy-subrc = 0 AND lt_code IS NOT INITIAL.

      LOOP AT lt_code INTO lv_line.
        CLEAR ls_out.
        ls_out-object  = lv_name.
        ls_out-part    = 'CLASS'.
        ls_out-include = lv_classpool.
        ls_out-line    = lv_line.
        APPEND ls_out TO et_source.
      ENDLOOP.

      ev_type = 'CLASS'.
      RETURN.

    ENDIF.

  ENDIF.

*---------------------------------------------------------------------*
* SE37
*---------------------------------------------------------------------*
  CLEAR: lt_code, lv_capture.

  "Descobre programa principal do function group
  SELECT SINGLE pname
    INTO lv_mainprog
    FROM tfdir
    WHERE funcname = lv_name.

  IF sy-subrc = 0.

    "Busca todos includes do grupo
    SELECT *
      INTO TABLE lt_inc
      FROM d010inc
      WHERE master = lv_mainprog.

    LOOP AT lt_inc INTO ls_inc.

      CLEAR lt_code.
      READ REPORT ls_inc-include INTO lt_code.

      LOOP AT lt_code INTO lv_line.

        lv_upper = lv_line.
        TRANSLATE lv_upper TO UPPER CASE.

        IF lv_upper CP 'FUNCTION *' AND lv_upper CS lv_name.
          lv_capture = abap_true.
        ENDIF.

        IF lv_capture = abap_true.
          CLEAR ls_out.
          ls_out-object  = lv_name.
          ls_out-part    = 'FUNCTION_MODULE'.
          ls_out-include = ls_inc-include.
          ls_out-line    = lv_line.
          APPEND ls_out TO et_source.
        ENDIF.

        IF lv_upper CP 'ENDFUNCTION*' AND lv_capture = abap_true.
          ev_type = 'FUNCTION_MODULE'.
          RETURN.
        ENDIF.

      ENDLOOP.

    ENDLOOP.

  ENDIF.

*---------------------------------------------------------------------*
* SE38
*---------------------------------------------------------------------*
  SELECT SINGLE name
    INTO lv_prog
    FROM trdir
    WHERE name = lv_name.

  IF sy-subrc = 0.

    REFRESH lt_code.
    READ REPORT lv_name INTO lt_code.

    LOOP AT lt_code INTO lv_line.
      CLEAR ls_out.
      ls_out-object  = lv_name.
      ls_out-part    = 'PROGRAM'.
      ls_out-include = lv_name.
      ls_out-line    = lv_line.
      APPEND ls_out TO et_source.
    ENDLOOP.

    ev_type = 'PROGRAM'.
    RETURN.

  ENDIF.

*---------------------------------------------------------------------*
* NOT FOUND
*---------------------------------------------------------------------*
  ev_type = 'OBJECT_NOT_FOUND'.

ENDFUNCTION.
