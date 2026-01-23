/// Authentication type for Daktela V6 API requests.
///
/// Determines how the access token is transmitted to the server:
/// - [header]: Token is sent via X-AUTH-TOKEN header (default)
/// - [cookie]: Token is sent via Cookie header (c_user)
/// - [queryParam]: Token is added as a URL query parameter
enum DaktelaAuthType {
  /// Token via X-AUTH-TOKEN header (default)
  header,

  /// Token via Cookie header (c_user)
  cookie,

  /// Token in URL query parameter
  queryParam,
}
