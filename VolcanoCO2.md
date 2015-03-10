# VolcanoCO2
Daryl Hegyi  
Friday, March 06, 2015  
## The Contribution of Volcanoes to Global Warming.
Given a continuous long-duration record of CO2 at a single location (Mauna Loa), and a list of volcano eruptions during the monitored period, determine the amount of CO2 injected into the atmosphere by each volcano, and use that information to quantify the CO2 that can be attributed to geological (volcanic) processes.

I set out to do this because many global warming deniers were claiming that volcanic eruptions spewed so much CO2 that it completely dominated the climate, and man's influence was negligible.  I wanted to explore the impact of volcanos on the CO2 record, to see if volcanos were indeed significant.


* CO2 data: <http://www.esrl.noaa.gov/gmd/ccgg/trends/#mlo_full> copied to ./data/ on Mar 5, 2015.

  The carbon dioxide data, measured as the mole fraction in dry air, on Mauna Loa constitute the longest record of direct measurements of CO2 in the atmosphere. They were started by C. David Keeling of the Scripps Institution of Oceanography in March of 1958 at a facility of the National Oceanic and Atmospheric Administration [Keeling, 1976]. NOAA started its own CO2 measurements in May of 1974, and they have run in parallel with those made by Scripps since then [Thoning, 1989]. The trend value represents the seasonally corrected data.

Data are reported as a dry mole fraction defined as the number of molecules of carbon dioxide divided by the number of molecules of dry air multiplied by one million (ppm). 

```r
co2 <- read.table("./data/co2_mm_mlo.txt", header=TRUE, quote="\"", na.strings = "-99.99")
names(co2)<-c("year", "month", "decimal_date", "average", "interpolated", "trend", "numdays")

#fixup the NA/s in average by using the interpolated values
co2.na<-is.na(co2$average)
co2$average[co2.na] <- co2$interpolated[co2.na]
rm(co2.na)
summary(co2)
```

```
##       year          month         decimal_date     average     
##  Min.   :1958   Min.   : 1.000   Min.   :1958   Min.   :312.7  
##  1st Qu.:1972   1st Qu.: 4.000   1st Qu.:1972   1st Qu.:327.7  
##  Median :1986   Median : 7.000   Median :1987   Median :348.1  
##  Mean   :1986   Mean   : 6.505   Mean   :1987   Mean   :350.4  
##  3rd Qu.:2000   3rd Qu.: 9.500   3rd Qu.:2001   3rd Qu.:370.5  
##  Max.   :2015   Max.   :12.000   Max.   :2015   Max.   :401.8  
##   interpolated       trend          numdays     
##  Min.   :312.7   Min.   :314.7   Min.   :-1.00  
##  1st Qu.:327.7   1st Qu.:327.3   1st Qu.:-1.00  
##  Median :348.1   Median :347.7   Median :28.00  
##  Mean   :350.4   Mean   :350.4   Mean   :20.17  
##  3rd Qu.:370.5   3rd Qu.:370.3   3rd Qu.:30.00  
##  Max.   :401.8   Max.   :399.7   Max.   :31.00
```

* Loading up the Volcanos dataset

```r
vol.Classes <- c( "factor", "Date", "Date", "numeric")
vol <- read.csv("./data/Volcanos.csv", na.strings = "NA", colClasses=vol.Classes)

vol.na<-is.na(vol$EndEruption_date)
vol$EndEruption_date[vol.na] = vol$Eruption_date[vol.na]

vol$erupted <- decimal_date(as.Date(vol$Eruption_date))
vol$duration <- decimal_date(as.Date(vol$EndEruption_date)) - vol$erupted
vol$duration[vol$duration==0] = .01 #if no duration set, default to one percent of a year (about 3.5 days)
```

* Set up plot functions.

```r
plot.volcanos<- function(vol.col="green",...) 
{ 
	abline(v=vol$erupted, col=vol.col)
}

plot.co2<- function(x=co2$decimal_date,...) 
{
	plot(x, xlab="Date", ...); 
	plot.volcanos(...)
}
lines.co2<- function(...) {lines(x=co2$decimal_date, ...)}
```
# Initial plot

** blue is the monthly average
** black is the trend
** green lines are the volcano eruptions.
![](VolcanoCO2_files/figure-html/FirstPlot-1.png) 

## Using Vector Auto Regression (VAR) to extrapolate the trend and extract the residuals
After fitting a curve to the trend line, then subtracting the trend, the residuals should show some sort of activity due to the unit impulse of the volcano eruptions.  We should be able to readily visualize the magnitude of increase of CO2 due to volcano eruptions.

I've plotted the residuals with lines at the 25% and 75% quantiles, with the green volcano lines.  The logs are plotted (with an offset to avoid <= 0 and to emphasize positive trends).

```
## Loading required package: MASS
## Loading required package: strucchange
## Loading required package: zoo
## 
## Attaching package: 'zoo'
## 
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
## 
## Loading required package: sandwich
## Loading required package: urca
## Loading required package: lmtest
```

![](VolcanoCO2_files/figure-html/vars-1.png) ![](VolcanoCO2_files/figure-html/vars-2.png) ![](VolcanoCO2_files/figure-html/vars-3.png) 

## Zoom in on the volcano timeframes
Showing the CO2 Residuals from 1/2 year prior to the eruption until 2 years after the event started.

* The green-bordered cyan boxes show the estimated duration of the event.
* The 25% and 75% quantiles are shown.

```r
par(mfrow=c(1,1))
for (i in 1:length(vol$Name))
{
	date.erupted = vol$erupted[i]
	plot( main= paste("Trend Residuals - ",vol$Name[i]), ylab="CO2 Res",
		x=trend.date, y=trend.res, type="l",
		xlim=c(date.erupted-0.5, date.erupted+2) )
	
	rect( vol$erupted[i], -1, vol$erupted[i]+vol$duration[i], 1,
		   col=alpha("cyan", .1), border="green")
	
	abline(h=trend.q[c(2,4)]);
}
```

![](VolcanoCO2_files/figure-html/ZoomVolcanos-1.png) ![](VolcanoCO2_files/figure-html/ZoomVolcanos-2.png) ![](VolcanoCO2_files/figure-html/ZoomVolcanos-3.png) ![](VolcanoCO2_files/figure-html/ZoomVolcanos-4.png) 

## Summary
There does seem to be some activity due to the volcanic eruptions, but the overall effect is suble, and more research is necessary to extract some sort of quantitative information from the slight signal.  Whether it can be isolated to statistical significance remains to be discovered.
