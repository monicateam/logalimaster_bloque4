@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'View entity travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity ZI_TRAVEL_0341 as select from ztb_travel_0341
  composition [0..*] of ZI_BOOKING_0341 as _Booking
  composition [0..*] of ZI_LOG_0341 as _Logs
  association [0..1] to /DMO/I_Customer as _Customer on $projection.CustomerID = _Customer.CustomerID
  association [0..1] to /DMO/I_Agency as _Agency on $projection.AgencyID = _Agency.AgencyID
  association [0..1] to I_Currency as _Currency on $projection.CurrencyCode = _Currency.Currency
  association [0..1] to /DMO/I_Overall_Status_VH as _OverallStatus on $projection.OverallStatus = _OverallStatus.OverallStatus
{
    key travel_id as TravelID,
    agency_id as AgencyID,
    _Agency.Name as AgencyName,
    customer_id as CustomerID,
    concat_with_space(_Customer.FirstName, _Customer.LastName, 1) as CustomerName, 
    begin_date as BeginDate,
    end_date as EndDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    booking_fee as BookingFee,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    total_price as TotalPrice,
    currency_code as CurrencyCode,
    description as Description,
    overall_status as OverallStatus,
    case overall_status
        when 'O' then 5
        when 'A' then 3
        when 'X' then 1
        else 0
    end as OverallStatusCriticality,
    created_by as CreatedBy,
    @Semantics.systemDateTime.createdAt: true
    created_at as CreatedAt,
    last_changed_by as LastChangedBy,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    last_changed_at as LastChangedAt,
    _Booking,
    _Customer,
    _Agency,
    _Currency,
    _OverallStatus,
    _Logs
}
