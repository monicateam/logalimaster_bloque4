@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Log travel projection view 0341'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZC_LOG_0341 as projection on ZI_LOG_0341
{
    key ChangeID,
    TravelID,
    ChangingOperation,
    ChangedFieldName,
    ChangedValue,
    CreatedAt,
    UserMod,
    /* Associations */
    _TravelHeader
}
