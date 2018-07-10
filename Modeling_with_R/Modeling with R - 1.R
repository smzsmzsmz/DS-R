##### MODELING WITH R #####
### https://tutorials.iq.harvard.edu/R/Rstatistics/Rstatistics.html
install.packages("foreign")
library(foreign)
### Set working Directory ###
setwd("C:/Users/TP/Desktop/R Analaysis/")
getwd()
list.files("Modeling with R")

### Load the stats data ###
# read the stats data
states.data <- readRDS("Modeling with R/states.rds")
str(states.data)
head(states.data)
states.info <- data.frame(attributes(states.data)[c("names", "var.labels")])
states.info
