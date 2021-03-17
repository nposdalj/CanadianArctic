#loading libraries
library(ggplot2)
library(dplyr)
library(forcats)
library(ggpubr)
library(plyr)
library(anytime)
library(fANCOVA)
library(tweedie)
library(car)
library(locfit)
library(MuMIn)
library(tidyverse)
library(mgcv)
library(ggpubr)
library(mgcViz)
library(cplm)
library(statmod)
library(gee)
library(geepack)
library(TSA)
library(epitools)
library(lubridate)
library(survival)

#load data
filename = paste('DailyIceTable.csv',sep="")
DayIce = read.csv(filename)
head(DayIce)
str(DayIce)
DayIce$tbin = anytime(as.factor(DayIce$tbin))

#plot data as box plot for years
DayIce$YearF = as.factor(DayIce$Year) #change season from an integer to a factor
title2 = paste("Average Daily Presence Per Year")
ggplot(DayIce, aes(x=YearF, y=DutyBin))+
  geom_boxplot()+
  ggtitle(title2)+
  labs(y="Average # of 5 min bins per day")

#GAM to identify seasonal pattern
gamTw = gam(DutyBin ~ s(day, bs = 'cc', k = 15)+s(Ice)+s(Year, k = 5), data = DayIce, family = tw, method = "REML")
plot(gamTw, pages = 1)
summary(gamTw)

#Better GAM plots
#pattern only
viz = getViz(gamTw)
print(plot(viz,allTerms=T),pages=1)

#first way to plot GAM
vizGG = plot(viz,allTerms = T) +
  l_points() +
  labs(title = 'Sperm whales (GAM)')+
  l_fitLine(linetype = 3)  +
  l_fitContour()+
  l_ciLine(mul = 5, colour = "blue", linetype = 2) +
  l_ciBar() +
  l_points(shape = 19, size = 1, alpha = 0.1) +
  l_rug() +
  theme_get() 
print(vizGG,pages =1)
fig6 =paste("G:/My Drive/GofAK_TPWS_metadataReduced/SeasonalityAnalysis/",site,'/',site,"GAM1.png",sep="")
ggsave(fig6)

#second way to plot GAM
vizGG2 = plot(viz, allTerms = T) +
  l_fitLine(colour = "red") + l_rug(mapping = aes(x=x,y=y), alpha=0.8) +
  labs(title = 'Sperm whales (GAM)')+
  l_ciLine(mul = 5, colour = "blue", linetype = 2)+
  l_points(shape = 19, size = 1, alpha = 0.1) + theme_classic()
print(vizGG2,pages =1)
fig7 =paste("G:/My Drive/GofAK_TPWS_metadataReduced/SeasonalityAnalysis/",site,'/',site,"GAM2.png",sep="")
ggsave(fig7)

###load all data and run GAM
filename = paste("G:/My Drive/GofAK_TPWS_metadataReduced/SeasonalityAnalysis/All_Data.csv",sep="")
AllTAB = read.csv(filename) #no effort days deleted
head(AllTAB)
str(AllTAB)
AllTAB$Season = as.factor(AllTAB$Season) #change season from an integer to a factor
levels(AllTAB$Season)
AllTAB$Season = revalue(AllTAB$Season, c("1"="Summer", "2"="Fall", "3"="Winter", "4"="Spring")) #change the numbers in actual seasons
AllTAB$tbin = anytime(as.factor(AllTAB$tbin))

#remove NaNs
AllTable = na.omit(AllTAB)
AllTable$Site = as.character(AllTable$Site)

#table with only CB, QN, PT
Central_GOA = subset(AllTable, Site!="BD" & Site!="KS" & Site!="KOA" & Site!="AB")

gamALL = gam(HoursProp ~ s(day, bs = 'cc', k = 47), data = AllTable, family = tw, method = "REML")
plot(gamALL, pages =1)
summary(gamALL)

#Better GAM plots
#pattern only
viz = getViz(gamALL)
print(plot(viz,allTerms=T),pages=1)

#first way to plot GAM
vizGG = plot(viz,allTerms = T) +
  labs(title = 'Sperm whales (GAM)')+
  l_fitLine(linetype = 3)  +
  l_fitContour()+
  l_ciLine(mul = 5, colour = "blue", linetype = 2) +
  l_ciBar() +
  l_rug() +
  theme(axis.text=element_text(size=18),
        axis.title=element_text(size=20,face="bold"))
print(vizGG,pages =1)
fig6 =paste("G:/My Drive/GofAK_TPWS_metadataReduced/SeasonalityAnalysis/GAM1.png",sep="")
ggsave(fig6)

#second way to plot GAM
vizGG2 = plot(viz, allTerms = T) +
  l_fitLine(colour = "red") + l_rug(mapping = aes(x=x,y=y), alpha=0.8) +
  labs(title = 'Sperm whales (GAM)')+
  l_ciLine(mul = 5, colour = "blue", linetype = 2)+
  l_points(shape = 19, size = 1, alpha = 0.1) + theme_classic()
print(vizGG2,pages =1)
fig7 =paste("G:/My Drive/GofAK_TPWS_metadataReduced/SeasonalityAnalysis/GAM2.png",sep="")
ggsave(fig7)