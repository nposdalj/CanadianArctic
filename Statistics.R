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
  labs(title = 'Sperm whales (GAM)')+
  l_fitLine(linetype = 3)  +
  l_fitContour()+
  l_ciLine(mul = 5, colour = "blue", linetype = 2) +
  l_ciBar() +
  l_rug() +
  theme_get() 
print(vizGG,pages =1)
fig6 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAM1_Allyears.png",sep="")
ggsave(fig6)

#second way to plot GAM
vizGG2 = plot(viz, allTerms = T) +
  l_fitLine(colour = "red") +
  labs(title = 'Sperm whales (GAM)')+
  l_ciLine(mul = 5, colour = "blue", linetype = 2)+
  theme_classic()
print(vizGG2,pages =1)
fig7 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAM2_Allyears.png",sep="")
ggsave(fig7)

#GAMs without 2015
DayIceHARP = subset(DayIce, Year!="2015")

#GAM to identify seasonal pattern
gamTw = gam(DutyBin ~ s(day, bs = 'cc', k = 15)+s(Ice)+s(Year, k = 4), data = DayIceHARP, family = tw, method = "REML")
plot(gamTw, pages = 1)
summary(gamTw)

#Better GAM plots
#pattern only
viz = getViz(gamTw)
print(plot(viz,allTerms=T),pages=1)

#first way to plot GAM
vizGG = plot(viz,allTerms = T) +
  labs(title = 'Sperm whales (GAM)')+
  l_fitLine(linetype = 3)  +
  l_fitContour()+
  l_ciLine(mul = 5, colour = "blue", linetype = 2) +
  l_ciBar() +
  l_rug() +
  theme_get() 
print(vizGG,pages =1)
fig6 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAM1_HARPyears.png",sep="")
ggsave(fig6)

#second way to plot GAM
vizGG2 = plot(viz, allTerms = T) +
  l_fitLine(colour = "red") +
  labs(title = 'Sperm whales (GAM)')+
  l_ciLine(mul = 5, colour = "blue", linetype = 2)+
  theme_classic()
print(vizGG2,pages =1)
fig7 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAM2_HARPyears.png",sep="")
ggsave(fig7)

## Generalized Additive Mixed Models
#All years
gam.ME = gamm(DutyBin ~ s(day, bs = 'cc', k = 15)+s(Ice)+s(Year, k = 4), data = DayIce, family = tw, method = "REML")
plot(gam.ME[[2]], pages = 1)
summary(gam.ME[[1]])  
summary(gam.ME[[2]])  

viz = getViz(gam.ME[[2]])
print(plot(viz,allTerms=T),pages=1)
fig7 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAMM_AllYears.png",sep="")
ggsave(fig7)

#HARP years
gam.ME = gamm(DutyBin ~ s(day, bs = 'cc', k = 15)+s(Ice)+s(Year, k = 4), data = DayIceHARP, family = tw, method = "REML")
plot(gam.ME[[2]], pages = 1)
summary(gam.ME[[1]])  
summary(gam.ME[[2]]) 

viz = getViz(gam.ME[[2]])
print(plot(viz,allTerms=T),pages=1)
fig7 =paste("G:/.shortcut-targets-by-id/1lwxYjZ-5ScY65o65OfWCtYU-FpMLIpXS/Arctic_Sperm whales/figures/GAMM_HARPYears.png",sep="")
ggsave(fig7)