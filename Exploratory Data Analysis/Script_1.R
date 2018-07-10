### Exploratory Data Analysis
## dataset: https://aqs.epa.gov/aqsweb/airdata/download_files.html  hourly_44201_2014.zip

## packages
library(readr)


## read data
ozone <- read_csv("C:/Users/tony.p/Downloads/hourly_44201_2014/hourly_44201_2014.csv",col_types = "ccccinnccccccncnncccccc")
# col_types argument specifies the class of each column in the dataset
head(ozone)
names(ozone)
# rewrite the names of the columns to remove any spaces
names(ozone) <- make.names(names(ozone))

## check the packaging
nrow(ozone)
ncol(ozone)
# check structure
str(ozone)
head(ozone[,c(6:7,10)])
tail(ozone[,c(6:7,10)])
table(ozone$Time.Local)
head(ozone$Time.Local)
select(ozone, State.Name) %>% unique %>% nrow
unique(ozone$State.Name) # Washington, D.C. (District of Columbia) and Puerto Rico are the "extra" states included in the dataset
ranking <- group_by(ozone, State.Name, County.Name) %>%
         summarize(ozone = mean(Sample.Measurement)) %>%
         as.data.frame %>%
         arrange(desc(ozone))
head(ranking,10)
tail(ranking,10)

