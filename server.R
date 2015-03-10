library(shiny)
library(scales)
library(lubridate)

#load up the CO2 dataset
co2 <- read.table("./data/co2_mm_mlo.txt", header=TRUE, quote="\"", na.strings = "-99.99")
names(co2)<-c("year", "month", "decimal_date", "average", "interpolated", "trend", "numdays")

#fixup the NA/s in average by using the interpolated values
co2.na<-is.na(co2$average)
co2$average[co2.na] <- co2$interpolated[co2.na]
rm(co2.na)

#load up the Volcanos dataset
vol.Classes <- c( "factor", "Date", "Date", "numeric")
vol <- read.csv("./data/Volcanos.csv", na.strings = "NA", colClasses=vol.Classes)

vol.na<-is.na(vol$EndEruption_date)
vol$EndEruption_date[vol.na] = vol$Eruption_date[vol.na]

vol$erupted <- decimal_date(as.Date(vol$Eruption_date))
vol$duration <- decimal_date(as.Date(vol$EndEruption_date)) - vol$erupted
vol$duration[vol$duration==0] = .01 #if no duration set, default to one percent of a year (about 3.5 days)

# do some heavy VAR - Vector Auto Regression on the trend

library(vars)

var.co2 <- VAR(co2[,c("decimal_date", "trend")], p = 2, type = "const", )

trend.date <- var.co2$varresult$decimal_date$fitted.values
trend.res <- var.co2$varresult$trend$residuals
trend.q<-quantile(trend.res)

# Set up plot functions.
abline.volcanos<- function(vol.col="green",...) 
# adds a line at the volcano location
{ 
	abline(v=vol$erupted, col=vol.col)
}

plot.co2<- function(x=co2$decimal_date,...) {
	plot(x, xlab="Date", ...); 
	abline.volcanos(...)
}
lines.co2<- function(...) {lines(x=co2$decimal_date, ...)}

# Initial plot
plot.theFirst<- function() {
	plot.co2(y=co2$average, type="l",  main="Average Monthly CO2 at Mauna Loa", 
			ylab="CO2 (ppm)", col="blue")
	lines.co2(y=co2$trend, type="l", col="black")
}

plot.eruption <- function(eruption, prior=0.5, after=2.0)
# plots the trend residuals from the period prior to and after the event
{
	date.erupted = vol$erupted[eruption]
	start.date = date.erupted-prior
	end.date = date.erupted+after
	range = (trend.date>=start.date) & (trend.date<=end.date)
	
	plot( main= paste("Trend Residuals - ",vol$Name[eruption]), ylab="CO2 Res (ppm)",
			x=trend.date[range], y=trend.res[range], type="l",
			xlim=c(start.date, end.date) )
	
	rect( date.erupted, -1, date.erupted+vol$duration[eruption], 1,
			col=alpha("cyan", .1), border="green")
	
	abline(h=trend.q[c(2,4)]); # plot the 25% and 75% quantiles
}

nurf.names <- function(vect) {
	setNames( seq(1, length(vect)), vect)
}

eruptionSelector.widget <- function(name="eruption") {
	renderUI({
		selectInput(name, "Choose a Volcanic Eruption", 
						nurf.names(vol$Name), selected = 1, 
						multiple = FALSE, selectize = FALSE)
	})
}
#############
# Server logic
shinyServer(function(input, output) {
	
# 	output$co2_summary <- renderTable({ 
# 		summary(co2)
# 	})
	
	output$eruptionSelector <- eruptionSelector.widget();
	
	output$theFirst <- renderPlot({
		plot.theFirst()
	})
	
	output$e <- renderText(input$eruption) 

#	e <- input$eruption
	output$eruption <- renderPlot({
		e <- as.numeric(input$eruption)
		plot.eruption(e)
	})
	
})
