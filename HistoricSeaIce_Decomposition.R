library(ggplot2)
library(xts)
library(forecast)
library(dplyr)
library(broom)
library(ggpubr)
library(tidyr)
library(lmtest)
library(data.table)
library(tidyr)
library(ggbreak)
library(patchwork)

#Load Sea Ice Data from Matlab (Averaged by source)
SeaIce = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Avg.csv')
Min = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Zero.csv')

#Create timeseries with 1979 and beyond
SeaIce_1979 = SeaIce[which(SeaIce$yr >= 1979),]

## FULL DATA
#Create ts for full data
SeaIceTS = subset(SeaIce,select = c(date,concentration))
SeaIceTS = ts(SeaIce$concentration,frequency = 12, start = c(SeaIce$concentration[1],1)) #Convert it to a ts

#Decompose and plot
decomposedRes <- decompose(SeaIceTS,"additive") # use type = "additive" for additive components
plot(decomposedRes)
stlRes <- stl(SeaIceTS, s.window = "periodic")

#Plot only the decomposed trend
t <- melt(decomposedRes$trend)
t <- t%>% drop_na(value)
t$time<-c(1:nrow(t)) 
linear<-lm(value ~time, data=t)
coeftest(linear)
cor(t$value,predict(linear))

trModel <- lm(SeaIce$concentration ~ c(1:length(SeaIce$concentration)))
plot(resid(trModel), type="l")  # resid(trModel) contains the de-trended series.

ts.stl <- stl(SeaIceTS,"periodic")  # decompose the TS
ts.sa <- seasadj(ts.stl)  # de-seasonalize
plot(SeaIceTS, type="l")  # original series
plot(ts.sa, type="l")  # seasonal adjusted
seasonplot(ts.sa, 12, col=rainbow(12), year.labels=TRUE, main="Seasonal plot: SIC") # seasonal frequency set as 12 for monthly data.

## SATELLITE DATA ONLY
#Create ts for 1979 data
SeaIceTS = subset(SeaIce_1979,select = c(date,concentration))
SeaIceTS = ts(SeaIce_1979$concentration,frequency = 12, start = c(SeaIce_1979$concentration[1],1)) #Convert it to a ts

#Decompose and plot
decomposedRes <- decompose(SeaIceTS,"additive") # use type = "additive" for additive components
plot(decomposedRes)
stlRes <- stl(SeaIceTS, s.window = "periodic")

#Plot only the decomposed trend
t <- melt(decomposedRes$trend)
t <- t%>% drop_na(value)
t$time<-c(1:nrow(t)) 
linear<-lm(value ~time, data=t)
coeftest(linear)
cor(t$value,predict(linear))

trModel <- lm(SeaIce$concentration ~ c(1:length(SeaIce$concentration)))
plot(resid(trModel), type="l")  # resid(trModel) contains the de-trended series.

ts.stl <- stl(SeaIceTS,"periodic")  # decompose the TS
ts.sa <- seasadj(ts.stl)  # de-seasonalize
plot(SeaIceTS, type="l")  # original series
plot(ts.sa, type="l")  # seasonal adjusted
seasonplot(ts.sa, 12, col=rainbow(12), year.labels=TRUE, main="Seasonal plot: SIC") # seasonal frequency set as 12 for monthly data.

###################################
#Load Median SIC data from Matlab (averaged by source)
SeaIceMed = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Median.csv')

## FULL DATA
plot(SeaIceMed$yr,SeaIceMed$concentration)

#Linear Model
trModel <- lm(SeaIceMed$concentration ~ c(1:length(SeaIceMed$concentration)))
plot(resid(trModel), type="l")  # resid(trModel) contains the de-trended series.

#### FOR PUBLICATION #######
#Linear Model
LM_SIC = lm(formula = concentration~yr,data = SeaIceMed)
ggplot(SeaIceMed, aes(x=yr, y=concentration))+
  geom_point() + geom_smooth(method="lm", col="black") + 
  stat_regline_equation(label.x = 1985, label.y = 84) + theme_bw() +
  labs(title = "Yearly Median Sea Ice Concentration",
       x = "Year",
       y = "Median Sea Ice Concentration")+ theme(axis.text=element_text(size=15),
                                                           axis.title=element_text(size=16,face="bold"))

#Histogram of minimum
MinPlot = ggplot(Min, aes(x=yr)) + geom_histogram(binwidth = 10)
MinPlot

## 1901 AND BEYOND
SeaIceMed_1901 = SeaIceMed[which(SeaIceMed$yr >= 1901),]
Min_1901 = Min[which(Min$yr >= 1901),]
#Linear Model
LM_SIC = lm(formula = concentration~yr,data = SeaIceMed_1901)
summary(LM_SIC)

#### PLOTS FOR PUBLICATION #######
ggplot(SeaIceMed_1901, aes(x=yr, y=concentration))+
  geom_point() + geom_smooth(method="lm", col="black") + theme_bw()+
  stat_regline_equation(label.x = 1990, label.y = 92)+
  labs(x = "Year",
       y = "Median Sea Ice Concentration (%)")+ theme(axis.text=element_text(size=15),
                                                  axis.title=element_text(size=16,face="bold"))+
  ggtitle("Yearly Median Mid-Month Day Sea Ice Concentration") +
  theme(plot.title = element_text(hjust = 0.5,size=16,face="bold"))

#histogram
decades = c("1910","1930","1950","1970","1990","2010")
decbreaks = c(7,9,11,13,15,17)
ggplot(Min_1901, aes(x=group)) + geom_histogram() + geom_bar(width = 0.9) + theme_bw()+scale_x_continuous(breaks=decbreaks, labels=decades)+
  labs(x = "Decades",
       y = "Number of Months")+ theme(axis.text=element_text(size=15),
                                                      axis.title=element_text(size=16,face="bold"))+
  ggtitle("Number of Months with a Mid-Month Day \n Average Sea Ice Concentration of Zero") +
  theme(plot.title = element_text(hjust = 0.5,size=16,face="bold"))

