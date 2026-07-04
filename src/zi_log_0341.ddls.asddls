@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'LogG 0341'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity ZI_LOG_0341 as select from ztb_log_0341
    association to parent ZI_TRAVEL_0341 as _TravelHeader on $projection.TravelID = _TravelHeader.TravelID
{
    key change_id as ChangeID,
    travel_id as TravelID,
    changing_operation as ChangingOperation,
    changed_field_name as ChangedFieldName,
    changed_value as ChangedValue,
    created_at as CreatedAt,
    user_mod as UserMod,
    _TravelHeader
}
