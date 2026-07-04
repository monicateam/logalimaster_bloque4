@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'root projection view'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZC_TRAVEL_0341 
    provider contract transactional_query
as projection on ZI_TRAVEL_0341
{
    key TravelID,
    @ObjectModel.text.element: ['AgencyName']
    AgencyID,
    AgencyName,
    @ObjectModel.text.element: ['CustomerName']
    CustomerID,
    CustomerName,
    BeginDate,
    EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    TotalPrice,
    CurrencyCode,
    Description,
    @ObjectModel.text.element: ['TextOverallStatus']
    OverallStatus,
    _OverallStatus._Text.Text as TextOverallStatus : localized, 
    OverallStatusCriticality,
    CreatedBy,
    CreatedAt,
    LastChangedBy,
    LastChangedAt,
    /* Associations */
    _Agency,
    _Booking: redirected to composition child ZC_BOOKING_0341,
    _Currency,
    _Customer,
    _Logs: redirected to composition child zc_log_0341,
    _OverallStatus
}
