calculate_hdd <- function(
  input_data,
  output_data,
  base_temp_f = 65
) {

  df <- read_csv(input_data) %>%
    rename(
      tmax_deg_c = 'tmax (deg c)',
      tmin_deg_c = 'tmin (deg c)') %>%
    mutate(
      tmax_deg_f = celsius.to.fahrenheit(tmax_deg_c, round = 2),
      tmin_deg_f = celsius.to.fahrenheit(tmin_deg_c, round = 2)) %>%
    mutate(
      tmean_f = ((tmax_deg_f + tmin_deg_f) / 2)) %>%
    mutate(
      hdd = base_temp_f - tmean_f) %>%
    filter(# drop cooling degree days (everything above 65F)
      hdd > 0) %>% 
    group_by(
      community_fips_code, year) %>%
    summarize(
      hdd = round(sum(hdd), 0))
    
  out_dir <- dirname(output_data)
  if (!dir.exists(out_dir)) dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

  write_csv(df, output_data)

}