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
    METHODS setTravelNumber FOR DETERMINE ON SAVE
      IMPORTING keys FOR Travel~setTravelNumber.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.
    read ENTITIES of zi_travel_0341 in local mode
     entity Travel
     fields ( TravelID OverallStatus )
     with corresponding #(  keys )
     RESULT DATa(lt_travels)
     FAILED failed.

     result = VALUE #(  for ls_travel IN lt_travels (
        %tky = ls_travel-%tky
        %field-TravelID = if_abap_behv=>fc-f-read_only
         %field-OverallStatus = if_abap_behv=>fc-f-read_only
         %action-acceptTravel = cond #(  WHEN ls_travel-OverallStatus = 'A'
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )
         %action-rejectTravel = cond #(  WHEN ls_travel-OverallStatus = 'X'
                                    THEN if_abap_behv=>fc-o-disabled
                                    ELSE if_abap_behv=>fc-o-enabled )
     ) ).


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

    READ ENTITIES of zi_travel_0341 IN LOCAL MODE
        ENTITY Travel
        FIELDS ( TravelID AgencyID CustomerID BookingFee TotalPrice CurrencyCode )
        with value #( for row_key in keys ( %key = row_key-%key ) )
        RESULT data(lt_read_entity_travel)
        FAILED failed
        REPORTED reported.

        check failed is INITIAL.

    DATA lt_create_travel type table for create zi_travel_0341\\Travel.

    SELECT max( travel_id ) from ztb_travel_0341
    INTO @DATA(lv_travel_id).

    data(lv_today) = cl_abap_context_info=>get_system_date( ).

    lt_create_travel = value #( FOR ls_create_row IN lt_read_entity_travel index into idx (
        %cid = |{ lv_travel_id + idx }|
        travelid = lv_travel_id + idx
        AgencyID = ls_create_row-AgencyID
        customerID = ls_create_row-CustomerID
        begindate = lv_today
        enddate = lv_today + 30
        bookingfee = ls_create_row-BookingFee
        totalprice = ls_create_row-TotalPrice
        CurrencyCode = ls_create_row-CurrencyCode
        description = 'MSC 0341'
        OverallStatus = 'O'
    ) ).

    MODIFY ENTITIES OF zi_travel_0341 IN LOCAL MODE
        ENTITY travel
        create fields (
            travelid
            AgencyID
            customerID
            begindate
            enddate
            BookingFee
            totalprice
            currencycode
            description
            overallstatus
        )
        with lt_create_travel
        mapped mapped
        failed failed
        reported reported.

    result = value #( for ls_result_row in lt_create_travel INDEX into idx
    (
        %cid_ref = keys[ idx ]-%cid_ref
        %tky = keys[ idx ]-%tky
        %param = CORRESPONDING #( ls_result_row )
     ) ).

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

  METHOD setTravelNumber.
    READ ENTITIES OF zi_travel_0341 IN LOCAL MODE
        ENTITY travel
        FIELDS (  TravelId )
        with corresponding #(  keys )
        RESULT DATA(lt_travels).
        DELETE lt_travels WHERE TravelID is not initial.
        CHECK lt_travels IS NOT INITIAL.

        SELECT SINGLE FROM ztb_travel_0341
            FIELDS max( travel_id ) INTO @DATA(lv_max_travelid).

        MODIFY entities of zi_travel_0341 IN LOCAL MODE
            ENTITY Travel
            UPDATE FIELDS ( TravelID )
            WITH VALUE #( FOR ls_travels IN lt_travels INDEX INTO i (
                %tky = ls_travels-%tky
                Travelid = lv_max_travelid + i
            ) ).
  ENDMETHOD.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_0341 DEFINITION INHERITING FROM cl_abap_behavior_saver.

ENDCLASS.

CLASS lsc_ZI_TRAVEL_0341 IMPLEMENTATION.


ENDCLASS.
