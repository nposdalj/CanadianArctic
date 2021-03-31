#set working directory
saveDir = setwd('C:/Users/nposd/Documents/GitHub/CanadianArctic')

#load libraries
library(robis)
library(devtools)
library(leaflet)

#Query OBIS for species within that polygon
PM = occurrence("Physeter macrocephalus")
write.csv(PM,paste(saveDir,'/OBIS.csv', sep=""))