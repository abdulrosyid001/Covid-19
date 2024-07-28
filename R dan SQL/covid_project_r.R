library(dplyr)
library(readxl)

data = read.csv("D:/Kaggle_competition/covid_project/data_covid_fix.csv", header = TRUE, sep = ',')
View(data)

unique_category = unique(data$category)
print(unique_category)

data = data.frame(data)

data$category <- gsub("people_fully_vaccinated", "People Fully Vaccinated", data$category)
data$category <- gsub("daily_vaccinations", "Daily Vaccinations", data$category)
data$category <- gsub("daily_people_vaccinated", "Daily People Vaccinated", data$category)
data$category <- gsub("new_cases", "New Cases", data$category)
data$category <- gsub("new_deaths", "New Deaths", data$category)
data$category <- gsub("total_cases", "Total Cases", data$category)
data$category <- gsub("total_deaths", "Total Deaths", data$category)
data$category <- gsub("total_vaccinations", "Total Vaccinations", data$category)
data$category <- gsub("people_vaccinated", "People Vaccinated", data$category)

unique_category = unique(data$category)
print(unique_category)

data_filtered <- data %>%
  filter(category %in% c("Daily Vaccinations", "Daily People Vaccinated", "New Cases", "New Deaths", "Total Cases", "Total Deaths"))

View(data_filtered)

new_data <- data.frame(data_filtered)
write.csv(new_data, "D:/Kaggle_competition/covid_project/data_covid_last.csv", row.names = FALSE)

data = read.csv("D:/Kaggle_competition/covid_project/data_covid_last.csv", header = TRUE, sep = ',')
unique_category = unique(data$category)
print(unique_category)