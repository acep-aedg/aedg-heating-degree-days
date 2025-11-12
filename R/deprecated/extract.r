download_file <- function(url, dest_dir, overwrite = TRUE) {
  filename <- basename(url)
  destfile <- file.path(dest_dir, filename)

  if (overwrite && file.exists(destfile)) {
    unlink(destfile, force = TRUE)
    message(yellow(paste("Deleted existing file:", destfile)))
  }

  if (!dir.exists(dest_dir)) {
    dir.create(dest_dir, recursive = TRUE)
  }

  tryCatch({
    download.file(url, destfile = destfile, mode = "wb")
  }, error = function(e) {
    message(red(paste("Failed to download:", e$message)))
  })

  return(destfile)
}


unzip_file <- function(zip_path, exdir, remove_zip = FALSE) {
  tryCatch({
    unzip(zip_path, exdir = exdir)
    message(green(paste("Unzipped contents to:", exdir)))

    if (remove_zip) {
      unlink(zip_path)
      message(blue(paste("Removed ZIP file:", zip_path)))
    }
  }, error = function(e) {
    message(red(paste("Failed to unzip:", e$message)))
  })
}


download_and_save_degree_days <- function(coordinates_file, out_file, base_url, start_year, end_year, summarized = T) {

  start_time <- Sys.time()

  sf_data <- st_read(coordinates_file)

  summarized_tag <- ''
  if (summarized) {
    summarized_tag <- '?summarize=mmm'
  }

  results <- list()

  for (i in seq_len(nrow(sf_data))) {
    fips <- sf_data$fips_code[i]
    message(sprintf("[%d/%d] Downloading data for FIPS: %s", i, nrow(sf_data), fips))

    # Extract coordinates from geometry
    coords <- st_coordinates(sf_data[i, ])
    lat <- coords[2]
    lon <- coords[1]

    # Construct the URL
    url <- sprintf("%s/%.4f/%.4f/%s/%s%s", base_url, lat, lon, start_year, end_year, summarized_tag)

    # Try to download the JSON data
    tryCatch({
      response <- httr::GET(url)

      if (response$status_code == 200) {
        json_data <- content(response, as = "parsed", type = "application/json")
        results[[fips]] <- json_data
      } else {
        warning(sprintf("Failed to get data for FIPS: %s (status: %d)", fips, response$status_code))
      }
    }, error = function(e) {
      warning(sprintf("Error for FIPS %s: %s", fips, e$message))
    })
  }

  # Write the entire list to a JSON file
  write_json(results, out_file, pretty = TRUE, auto_unbox = TRUE)

  end_time <- Sys.time()
  elapsed <- end_time - start_time

  message(sprintf("Results written in %.2f seconds", as.numeric(elapsed, units = "secs")))
  return(invisible(results))
}