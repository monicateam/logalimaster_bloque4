@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Booking entity view 0341 MSC'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_BOOKING_0341 as select from ztb_booking_0341
    association to parent ZI_TRAVEL_0341 as _TravelHeader on $projection.TravelID = _TravelHeader.TravelID
    composition [0..*] of ZI_BOOKING_SUPPL_0341 as _BookingSupplement
    association [1..1] to /DMO/I_Customer as _Customer on $projection.CustomerID = _Customer.CustomerID
    association [1..1] to /DMO/I_Carrier as _Carrier on $projection.CarrierID = _Carrier.AirlineID
    association [1..1] to /DMO/I_Connection as _Connection on $projection.CarrierID = _Connection.AirlineID and
                                                              $projection.ConnectionID = _Connection.ConnectionID
    association [1..1] to /DMO/I_Booking_Status_VH as _BookingStatus on $projection.BookingStatus = _BookingStatus.BookingStatus
    association [1..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
{
    key travel_id as TravelID,
    key booking_id as BookingID,
    booking_date as BookingDate,
    customer_id as CustomerID,
    carrier_id as CarrierID,
    connection_id as ConnectionID,
    flight_date as FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    flight_price as FlightPrice,
    currency_code as CurrencyCode,
    booking_status as BookingStatus,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    _TravelHeader,
    _Customer,
    _Carrier,
    _Connection,
    _BookingStatus,
    _Currency,
    _BookingSupplement
}
