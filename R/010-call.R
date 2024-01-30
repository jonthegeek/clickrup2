#' Call the ClickUp Public API API
#'
#' Generate a request to an ClickUp Public API endpoint.
#'
#' @inheritParams nectar::call_api
#' @param cu_api_key An API key provided by the API provider. This key is not
#'   clearly documented in the API description. Check the API documentation for
#'   details.
#'
#' @return The response from the endpoint.
#' @export
cu_call_api <- function(path,
                        query = NULL,
                        body = NULL,
                        method = NULL,
                        cu_api_key = Sys.getenv("CU_API_KEY")) {
  nectar::call_api(
    base_url = "https://api.clickup.com/api/v2/",
    path = path,
    query = query,
    body = body,
    method = method,
    user_agent = "clickrup (https://github.com/jonthegeek/clickrup)",
    security_fn = cu_security_apikey_auth,
    security_args = list(cu_api_key = cu_api_key)
  )
}
