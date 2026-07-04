CLASS lhc_BookingSupplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplimPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR BookingSupplement~calculateTotalSupplimPrice.

ENDCLASS.

CLASS lhc_BookingSupplement IMPLEMENTATION.

  METHOD calculateTotalSupplimPrice.
  ENDMETHOD.

ENDCLASS.
