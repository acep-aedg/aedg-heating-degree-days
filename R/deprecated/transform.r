hdd_json_to_csv <- function(hdd_json, out_csv) {

  tryCatch({  
    js <- fromJSON(hdd_file, simplifyDataFrame = F)
  
    df <- map_dfr(names(js), function(fips){
      baseline <- js[[fips]]$modeled_baseline
      projected <- js[[fips]]$projected

      tibble(
        fips_code = fips,
        ddmax_modeled_baseline = baseline$ddmax,
        ddmax_projected = projected$ddmax,
        ddmean_modeled_baseline = baseline$ddmean,
        ddmean_projected = projected$ddmean,
        ddmin_modeled_baseline = baseline$ddmin,
        ddmin_projected = projected$ddmin
      )
    })

    write.csv(df, out_csv, row.names = F)

  })
}