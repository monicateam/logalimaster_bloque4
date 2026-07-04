@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKING_0341 as projection on ZI_BOOKING_0341
{
    key TravelID,
    key BookingID,
    BookingDate,
    CustomerID,
    CarrierID,
    ConnectionID,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangedAt,
    /* Associations */
    _BookingStatus,
    _BookingSupplement: redirected to composition child ZC_BOOKSUPL_0341,
    _Carrier,
    _Connection,
    _Currency,
    _Customer,
    _TravelHeader: redirected to parent ZC_TRAVEL_0341
}
