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

#Load Sea Ice Data from Matlab (Averaged by source)
SeaIce = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Avg.csv')
Min = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Zero.csv')
SeaIce = subset(SeaIce,select = c(Var1,concentration))

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

#Load Median SIC data from Matlab
SeaIceMed = read.csv('H:/My Drive/Manuscripts/CANARC/data/Sea Ice/SeaIce_Range_Median.csv')
SeaIceMed_Comp = na.omit(SeaIceMed)
plot(SeaIceMed_Comp$Yr,SeaIceMed_Comp$concentration)

#Linear Model
trModel <- lm(SeaIceMed_Comp$concentration ~ c(1:length(SeaIceMed_Comp$concentration)))
plot(resid(trModel), type="l")  # resid(trModel) contains the de-trended series.

#### FOR PUBLICATION #######

#Linear Model
LM_SIC = lm(formula = concentration~Yr,data = SeaIceMed)
ggplot(SeaIceMed, aes(x=Yr, y=concentration))+
  geom_point() + geom_smooth(method="lm", col="black") + 
  stat_regline_equation(label.x = 1985, label.y = 84) + theme_bw() +
  labs(title = "Yearly Median Sea Ice Concentration",
       x = "Year",
       y = "Median Sea Ice Concentration")+ theme(axis.text=element_text(size=15),
                                                           axis.title=element_text(size=16,face="bold"))

#Histogram of minimum
Min = ggplot(Min, aes(x=Yr)) + geom_histogram(binwidth = 10)
Min
