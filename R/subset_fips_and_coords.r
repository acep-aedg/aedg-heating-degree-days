subset_fips_and_coords <- function(in_file, out_file, overwrite = TRUE) {

  if (overwrite && file.exists(out_file)) {
    unlink(out_file, force = TRUE)
    message(yellow(paste("Deleted existing file:", out_file)))
  }

  tryCatch({
    df <- st_read(in_file)
    df <- df[ , c('fips_code', 'geometry')]
    st_write(df, out_file, driver = 'GeoJSON')
  }, error = function(e) {
    message(red(paste("Error:", e$message)))
  })

}