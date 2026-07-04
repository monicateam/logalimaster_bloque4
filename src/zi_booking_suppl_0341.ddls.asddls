@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking supplview 0341 MSC master LG'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_BOOKING_SUPPL_0341 as select from ztb_booksupl0341
   
   association to parent ZI_BOOKING_0341 as _Booking on $projection.TravelID = _Booking.TravelID and
                                                              $projection.BookingID = _Booking.BookingID
   association [1..1] to ZI_TRAVEL_0341 as _TravelHeader on $projection.TravelID = _TravelHeader.TravelID
   association [1..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
   association [1..1] to /DMO/I_Supplement as _Supplement on $projection.SupplementID = _Supplement.SupplementID
   association [0..1] to /DMO/I_SupplementText as _SupplementText on $projection.SupplementID = _SupplementText.SupplementID and
                                                                     _SupplementText.LanguageCode = $session.system_language
{
    key travel_id as TravelID,
    key booking_id as BookingID,
    key booking_supplement_id as BookingSupplementID,
    supplement_id as SupplementID,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    price as Price,
    currency_code as CurrencyCode,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    _Currency,
    _Supplement,
    _Booking,
    _SupplementText,
    _TravelHeader
}
