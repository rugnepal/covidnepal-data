library(tidyverse)
library(jsonlite)


# read remote json
nepal_url <- "https://nepalcorona.info/api/v1/data/nepal"
nepal_data <- jsonlite::fromJSON(nepal_url, flatten=F, simplifyDataFrame = TRUE)

View(nepal_data)
nepal_data <- nepal_data %>%
  as.data.frame(stringsAsFactors = F) %>%
  purrr::map_if(is.data.frame, list) %>%
  as_tibble() %>%
  dplyr::select_if(is.numeric) %>%
  janitor::clean_names()

nepal_data <- nepal_data %>%
  tidyr::pivot_longer(cols = 1:11,
               names_to = "description",
               values_to = "counts"
  )

saveRDS(nepal_data, "./data/nepal_data.Rds")

# covid nepal

covidnp_url <- "https://data.nepalcorona.info/api/v1/covid/summary"
covidnp_data <- jsonlite::fromJSON(covidnp_url, flatten=TRUE)

province_data <- covidnp_data$province
names(province_data$cases) <- c("infected", "province")
names(province_data$active) <- c("active", "province")
names(province_data$recovered) <- c("recovered", "province")
names(province_data$deaths) <- c("deaths", "province")

province_val <- province_data$cases %>%
  merge(province_data$active, all = T) %>%
  merge(province_data$recovered, all = T) %>%
  merge(province_data$deaths, all = T)

province_val[is.na(province_val)] <- 0

names(province_val) <- c("P_ID", "infected", "active", "recovered", "deaths")


saveRDS(province_val, "./data/province_val.Rds")
