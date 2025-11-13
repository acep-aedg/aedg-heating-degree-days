download_daymet <- function(
  coordinates_file,
  out_file,
  base_url,
  vars,
  start_date,
  end_date,
  skip_header   # number of lines to skip before actual column headers
) {

  start_time <- Sys.time()
  message("Reading coordinates file...")
  sf_data <- st_read(coordinates_file, quiet = TRUE)

  n <- nrow(sf_data)
  results <- vector("list", n)

  for (i in seq_len(n)) {
    fips_code <- sf_data$fips_code[i]
    message(sprintf("[%d/%d] Downloading data for FIPS: %s", i, n, fips_code))

    coords <- st_coordinates(sf_data[i, ])
    lon <- coords[1]
    lat <- coords[2]

    req <- request(base_url) |>
      req_url_query(lat = lat, lon = lon, vars = vars, start = start_date, end = end_date)

    resp <- req_perform(req)

    if (resp_status(resp) == 200) {
      csv_text <- resp_body_string(resp)

      data <- tryCatch(
        read_csv(I(csv_text), skip = skip_header, show_col_types = FALSE),
        error = function(e) {
          warning(sprintf("Failed to parse CSV for FIPS %s: %s", fips_code, e$message))
          NULL
        }
      )

      if (!is.null(data)) {
        data <- data |> 
          mutate(community_fips_code = fips_code) |>
          relocate(community_fips_code, .before = 1)
      }

      results[[i]] <- data
    } else {
      warning(sprintf("Request failed for FIPS %s (HTTP %d)", fips_code, resp_status(resp)))
      results[[i]] <- NULL
    }
  }

  # combine all results into a single data frame
  combined <- bind_rows(results)

  out_dir <- dirname(out_file)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  message("Saving results...")
  write_csv(combined, out_file)

  elapsed <- Sys.time() - start_time
  message(sprintf("Finished in %.2f seconds", as.numeric(elapsed, units = "secs")))

  invisible(combined)
}