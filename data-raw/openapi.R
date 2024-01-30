# ClickUp API Postman Collection: https://www.postman.com/clickup-api/workspace/clickup-public-api/collection/24088335-e26d3542-ac2f-4f82-89ab-2cff14a54e9a?action=share&creator=13973767
# Converted to clickup.yaml via https://joolfe.github.io/postman-to-openapi/
clickup_list <- yaml::read_yaml("data-raw/clickup.yaml", handlers = list(int = as.character))
clickup_rapid <- clickup_list |>
  rapid::as_rapid()

clickup_rapid@components@security_schemes <- rapid::class_security_schemes(
  name = "apikeyAuth",
  details = rapid::class_security_scheme_details(
    rapid::class_api_key_security_scheme(
      parameter_name = "Authorization",
      location = "header"
    )
  )
)

clickup_rapid |>
  beekeeper::use_beekeeper(api_abbr = "cu")

beekeeper::generate_pkg()

# Manually parse path data toward an eventual full parsing.
# This is currently just a scratchpad/exploration.
clickup_list$paths |>
  tibble::enframe(name = "path") |>
  tidyr::unnest_longer(value, indices_to = "method") |>
  tidyr::unnest_wider(value) |>
  # One path has a non-empty "security" field, but it's the same as the generic
  # security.
  dplyr::select(-security) |>
  # Start with cases that don't have requestBody
  # dplyr::filter(lengths(requestBody) == 0) |>
  dplyr::select(-requestBody) |>
  # responses currently don't hold useful info. All are application/json.
  dplyr::select(-responses) |>
  # Every path begins with "/api/v2/". Building that into the call.
  dplyr::mutate(
    path = stringr::str_remove(path, "^/api/v2/"),
    operation_id = snakecase::to_snake_case(summary),
    parameters = purrr::map(
      parameters,
      \(parameters) {
        if (length(parameters)) {
          tibble::tibble(parameter = parameters) |>
            tidyr::unnest_wider(parameter, names_sep = "_")
        } else {
          NULL
        }
      }
    )
  ) |>
  # dplyr::filter(lengths(parameters) > 0) |>
  # tidyr::unnest_longer(parameters) |>
  # tidyr::unnest_wider(parameters, names_sep = "_") |>
  # dplyr::count(parameters_parameter_in)
  # dplyr::slice(5) |>
  # dplyr::filter(has_path)
  # dplyr::slice(2) |>
  # dplyr::pull(parameters)
  dplyr::glimpse()

clickup_json <- jsonlite::fromJSON("data-raw/clickup.postman_collection.json")
clickup_json$item |>
  tidyr::unnest_longer(item) |>
  tidyr::unnest_wider(item, names_sep = "_") |>
  tidyr::unnest_wider(item_request, names_sep = "_")
