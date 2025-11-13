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
