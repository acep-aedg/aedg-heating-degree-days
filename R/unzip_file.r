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