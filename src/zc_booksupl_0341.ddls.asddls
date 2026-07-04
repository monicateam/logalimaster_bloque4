@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplement projection view MSC'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZC_BOOKSUPL_0341 as projection on ZI_BOOKING_SUPPL_0341
{
    key TravelID,
    key BookingID,
    key BookingSupplementID,
    SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    Price,
    CurrencyCode,
    LastChangedAt,
    /* Associations */
    _Currency,
    _Supplement,
    _SupplementText,
    _Booking: redirected to parent ZC_BOOKING_0341,
    _TravelHeader: redirected to ZC_TRAVEL_0341
}
