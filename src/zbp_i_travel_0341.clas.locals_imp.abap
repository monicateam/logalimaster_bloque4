CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF zi_travel_0341 IN LOCAL MODE
    ENTITY travel
    UPDATE FIELDS (  overallstatus ) WITH VALUE #(  FOR key IN keys (  %tky = key-%tky overallstatus = 'A' ) ).
    result = VALUE #(  FOR key IN keys (  %tky = key-%tky
    %param = CORRESPONDING #(  key ) ) ).


    APPEND VALUE #(  %msg = new_message_with_text(
    severity = if_abap_behv_message=>severity-success
    text = 'Se ha cambiado el estado a aceptado'
    ) )
    TO reported-travel.
  ENDMETHOD.

  METHOD createTravelByTemplate.
  ENDMETHOD.

  METHOD rejectTravel.
    MODIFY ENTITIES OF zi_travel_0341 IN LOCAL MODE
      ENTITY travel
      UPDATE FIELDS (  overallstatus ) WITH VALUE #(  FOR key IN keys (  %tky = key-%tky overallstatus = 'X' ) ).
    result = VALUE #(  FOR key IN keys (  %tky = key-%tky
    %param = CORRESPONDING #(  key ) ) ).


    APPEND VALUE #(  %msg = new_message_with_text(
    severity = if_abap_behv_message=>severity-success
    text = 'Se ha cambiado el estado a rechazado'
    ) )
    TO reported-travel.
  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF zi_travel_0341 IN LOCAL MODE
        ENTITY travel
          FIELDS (  customerid )
          WITH CORRESPONDING #(  keys )
          RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
        SELECT SINGLE CustomerID
        FROM /DMO/I_Customer
        WHERE CustomerID EQ @entity-CustomerID
        INTO @DATA(lv_customer)
        PRIVILEGED ACCESS.

        APPEND VALUE #(  %tky = entity-%tky
                         %state_area = 'VALIDATE_CUSTOMER' ) TO REPORTED-travel.

        IF lv_customer IS INITIAL.
             APPEND VALUE #(  %tky = entity-%tky ) TO failed-travel.

             APPEND VALUE #( %tky = entity-%tky
                             %state_area = 'VALIDATE_CUSTOMER'
                             %msg = me->new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = |El cliente { entity-CustomerID } no existe|
                             )
                             %element-customerid = if_abap_behv=>mk-on ) TO REPORTED-travel.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateDates.
    READ ENTITIES OF zi_travel_0341 IN LOCAL MODE
        ENTITY travel
          FIELDS (  customerid )
          WITH CORRESPONDING #(  keys )
          RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).

        APPEND VALUE #(  %tky = entity-%tky
                         %state_area = 'VALIDATE_DATES' ) TO REPORTED-travel.

        APPEND VALUE #(  %tky = entity-%tky
                         %state_area = 'OUTDATED_DATES' ) TO REPORTED-travel.

        IF entity-BeginDate IS INITIAL OR entity-enddate IS INITIAL.
             APPEND VALUE #(  %tky = entity-%tky ) TO failed-travel.

             APPEND VALUE #( %tky = entity-%tky
                             %state_area = 'VALIDATE_DATES'
                             %msg = me->new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = |Las fechas de inicio y fin no deben estar vacias|
                             )
                             %element-customerid = if_abap_behv=>mk-on ) TO REPORTED-travel.
        ELSEIF entity-BeginDate GT entity-enddate.
             APPEND VALUE #(  %tky = entity-%tky ) TO failed-travel.

             APPEND VALUE #( %tky = entity-%tky
                             %state_area = 'OUTDATES_DATES'
                             %msg = me->new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = |La fecha de inicio no puede ser mayor a al final|
                             )
                             %element-customerid = if_abap_behv=>mk-on ) TO REPORTED-travel.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validateStatus.
    READ ENTITIES OF zi_travel_0341 IN LOCAL MODE
        ENTITY travel
          FIELDS (  customerid )
          WITH CORRESPONDING #(  keys )
          RESULT DATA(entities).

    LOOP AT entities INTO DATA(entity).
        SELECT SINGLE OverallStatus
        FROM /DMO/I_Overall_Status_VH
        WHERE OverallStatus EQ @entity-OverallStatus
        INTO @DATA(lv_overallstatus)
        PRIVILEGED ACCESS.

        APPEND VALUE #(  %tky = entity-%tky
                         %state_area = 'VALIDATE_STATUS' ) TO REPORTED-travel.

        IF lv_overallstatus IS INITIAL.
             APPEND VALUE #(  %tky = entity-%tky ) TO failed-travel.

             APPEND VALUE #( %tky = entity-%tky
                             %state_area = 'VALIDATE_STATUS'
                             %msg = me->new_message_with_text(
                                severity = if_abap_behv_message=>severity-error
                                text = |El status { entity-CustomerID } no existe|
                             )
                             %element-customerid = if_abap_behv=>mk-on ) TO REPORTED-travel.
        ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_0341 DEFINITION INHERITING FROM cl_abap_behavior_saver.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_0341 IMPLEMENTATION.


ENDCLASS.
