/// View de catálogo validada na API Airtable para:
/// app_lista_doenca, app_lista_doenca_gato, app_lista_tracos, app_lista_tracos_gato.
const kAirtableCatalogView = 'SITE_NAO_USAR';

Map<String, dynamic> airtableCatalogParams([
  Map<String, dynamic>? extra,
]) {
  return {
    'view': kAirtableCatalogView,
    ...?extra,
  };
}
