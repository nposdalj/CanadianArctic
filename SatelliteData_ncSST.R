library(ncdf4)
library(httr)
library(sf)
library(dplyr)
library(raster)
library(rgeos)
library(ggplot2)
library("rnaturalearth")
library("rnaturalearthdata")

#load files
SST = nc_open("erdMH1sstdmday_de64_cee5_6ab0.nc")
names(SST$var)
v1=SST$var[[1]]
SSTvar=ncvar_get(SST,v1)
SST_lon=v1$dim[[1]]$vals
SST_lat=v1$dim[[2]]$vals
dates=as.POSIXlt(v1$dim[[3]]$vals,origin='1970-01-01',tz='GMT')

#loading the world
world <- ne_countries(scale = "medium", returnclass = "sf")
class(world)

#setting color breaks
h=hist(SSTvar[,,1],100,plot=FALSE)
breaks=h$breaks
n=length(breaks)-1
jet.colors <-colorRampPalette(c("blue", "#007FFF", "cyan","#7FFF7F", "yellow", "#FF7F00", "red", "#7F0000"))
c=jet.colors(n)

#plotting in base R
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
r = raster(t(SSTvar[,,1]),xmn = min(SST_lon),xmx = max(SST_lon),ymn=min(SST_lat),ymx=max(SST_lat))
image(r,col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xlim = c(min(SST_lon),max(SST_lon)),xaxs='i',asp=0, main=paste("Monthly SST", dates[1]))
points(-66.35, rep(41.06165),pch=20,cex=2)
points(-76, rep(33.6699),pch=20,cex=2)
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#plotting in ggplot
r = raster(t(SSTvar[,,1]),xmn = min(SST_lon),xmx = max(SST_lon),ymn=min(SST_lat),ymx=max(SST_lat))
points = rasterToPoints(r, spatial = TRUE)
df = data.frame(points)
names(df)[names(df)=="layer"]="SST"
mid = mean(df$SST)
ggplot(data=world) +  geom_sf()+coord_sf(xlim= c(-80.,-75),ylim=c(72,73.5),expand=FALSE)+
  geom_tile(data = df , aes(x = x, y = y, fill = SST)) + 
  ggtitle(paste("SST", dates[1]))+geom_point(x = 76.23, y = -72.72, color = "black",size=3)+
  xlab("Latitude")+ylab("Longitude")+
  scale_fill_gradient2(midpoint = mid, low="blue", mid = "yellow",high="red")

#plotting time series HZ 
I=which(SST_lon>=-70.72 & SST_lon<=--74.72) #change lon to SST_lon values to match ours, use max and min function
J=which(SST_lat>=76.23 & SST_lat<=79.23) #change ""
sst2=SSTvar[I,J,]

n=dim(sst2)[3] 

res=rep(NA,n) 
for (i in 1:n) 
  res[i]=mean(sst2[,,i],na.rm=TRUE) 

plot(1:n,res,axes=FALSE,type='o',pch=20,xlab='',ylab='SST (ºC)') 
axis(2) 
axis(1,1:n,format(dates,'%m')) 
box()

#plotting time series GS 
I=which(SST_lon>=-76.25 & SST_lon<=-75.75) #change lon to SST_lon values to match ours, use max and min function
J=which(SST_lat>=33.41991667 & SST_lat<=33.91991667) #change ""
sst2=SSTvar[I,J,] 

n=dim(sst2)[3] 

res=rep(NA,n) 
for (i in 1:n) 
  res[i]=mean(sst2[,,i],na.rm=TRUE) 

plot(1:n,res,axes=FALSE,type='o',pch=20,xlab='',ylab='SST (ºC)') 
axis(2) 
axis(1,1:n,format(dates,'%m')) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,2],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[2]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,3],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[3]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[4]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[5]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[6]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[7]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[8]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[9]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[10]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[11]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[12]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()

#begin plot
layout(matrix(c(1,2,3,0,4,0), nrow=1, ncol=2), widths=c(5,1), heights=4) 
layout.show(2) 
par(mar=c(3,3,3,1))
image(SST_lon,rev(SST_lat),SSTvar[,,1],col=c,breaks=breaks,xlab='',ylab='',axes=TRUE,xaxs='i',yaxs='i',asp=1, main=paste("Monthly SST", dates[13]))
#adding color scale
par(mar=c(3,1,3,3))
source('scale.R') 
image.scale(sst[,,1], col=c, breaks=breaks, horiz=FALSE, yaxt="n",xlab='',ylab='',main='SST') 
axis(4, las=1) 
box()
