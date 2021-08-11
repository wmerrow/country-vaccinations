rm(list = ls(all = TRUE))

library(dplyr)

cov <- read.csv(file = "data/source/owid-covid-data-latest_people_vaxed.csv", header = TRUE, stringsAsFactors = FALSE)
str(cov)

# filter to only dates that have latest data for number of people vaccinated
cov <- cov %>% filter(is_max_date == TRUE)

# list of countries to include (does not include territories)
countries <- read.csv(file = "data/source/countries.csv", header = TRUE, stringsAsFactors = FALSE)
str(countries)
countries <- countries %>% select(iso_code)

# join with countries, using left join to filter to only rows in countries list
cov <- left_join(countries, cov)
str(cov)

# col for people not fully vaccinated and people vaccinated per hundred (overwrite)
cov$people_not_vaccinated <- cov$population - cov$people_vaccinated
cov$people_vaccinated_per_hundred <- cov$people_vaccinated / cov$population * 100

# select desired columns
cov <- cov %>% select(iso_code,
                      continent,
                      location,
                      #date,
                      people_vaccinated_per_hundred,
                      people_not_vaccinated,
                      people_vaccinated,
                      population
)
str(cov)

# change NAs to 0
cov$people_vaccinated_per_hundred[is.na(cov$people_vaccinated_per_hundred)] <- 0
cov$people_vaccinated[is.na(cov$people_vaccinated)] <- 0
cov$people_not_vaccinated[is.na(cov$people_not_vaccinated)] <- 0
cov$population[is.na(cov$population)] <- 0

# rename DRC
cov$location[cov$location == "Democratic Republic of Congo"] <- "DRC"

# output
write.csv(cov, "data/output/vaccinations.csv", row.names = FALSE)
