
#usage: 
# SET ROPTS=--no-save --no-environ --no-init-file --no-restore --no-Rconsole 
# "C:\Program Files\R\R-3.1.2\bin\x64\Rscript.exe" %ROPTS% runShinyApp.R 1> ShinyApp.log 2>&1

library(shiny)
library(scales)
library(lubridate)
#library(jsonlite)
#cat("Starting up\n")

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

## fix up the severity
vol$Severity[is.na(vol$Severity)] = 1

# merge volcano events into co2 table
co2$volcano.events <- rep(0, nrow(co2))
for (c in 1:(nrow(co2)-1))
{
	for ( v in 1:nrow(vol) )
	{
		if ( vol$erupted[v] >= co2$decimal_date[c]
			  && vol$erupted[v] < co2$decimal_date[c+1] )
			co2$volcano.events[c] = co2$volcano.events[c]  + vol$Severity[v]
	}
}
# do some heavy VAR - Vector Auto Regression on the trend

library(vars)
co2.var.subset <- co2[,c("decimal_date", "month", "volcano.events", "trend")]

co2.var.type <- c("const", "trend", "both", "none")
co2.var.select <- VARselect(co2.var.subset, type="both")
#co2.var.select

var.co2 <- VAR(co2.var.subset, p = co2.var.select$selection["AIC(n)"], type = "both" )

trend.date <- var.co2$varresult$decimal_date$fitted.values
trend.fitted <- var.co2$varresult$trend$fitted.values
trend.res <- var.co2$varresult$trend$residuals
trend.q<-quantile(trend.res)

# Set up plot functions.
plot.volcanos<- function(vol.col="green", ..., text.y=0) 
# adds a line at the volcano location
{ 
	abline(v=vol$erupted, col=vol.col)
	text(vol$erupted, text.y, vol$Name, cex=0.86, pos=3, srt=45)
}

plot.co2<- function(x=co2$decimal_date, ..., text.y=0) {
	plot(x, xlab="Date", ...); 
	plot.volcanos(..., text.y=text.y)
}
lines.co2<- function(...) {lines(x=co2$decimal_date, ...)}

# Initial plot
plot.theFirst<- function() {
	plot.co2(y=co2$average, type="l",  main="Average Monthly CO2 at Mauna Loa", 
			ylab="CO2 (ppm)", col="blue", text.y=315)
	lines.co2(y=co2$trend, type="l", col="black")
	lines(x=trend.date, y=trend.fitted, type="l", col="red")
}

plot.residuals <- function(log.y, offset=0) {
	op<-par(mfrow=c(1,1))
	
	if (!log.y) {
		plot.co2( main="Trend Residuals",  ylab="CO2 Res",
					 x=trend.date, y=trend.res, type="l", text.y=-0.8)
		abline(h=trend.q[c(2,4)]);
	}
	else {
		plot.co2( main="Trend Residuals",  ylab=paste("log(CO2 Res+",offset,")"),
					 x=trend.date, y=log(trend.res+offset), type="l", text.y=-0.8)
		abline(h=log(trend.q+offset)[c(2,4)]);
	}
	par(op)
}

plot.eruption <- function(eruption, prior=0.5, after=2.0)
# plots the trend residuals from the period prior to and after the event
{
	cat("plot.eruption( e=", eruption, "prior=", prior, "after=", after)
	op<-par(mfrow=c(3,1), mar=c(2,4,1.4,0.5))
	date.erupted = vol$erupted[eruption]
	start.date = date.erupted+prior
	end.date = date.erupted+after
	
	co2.range = (co2$decimal_date>=start.date) & (co2$decimal_date<=end.date)
	trend.range = (trend.date>=start.date) & (trend.date<=end.date)
	
	plot( main=paste("Trend - ",vol$Name[eruption]), ylab="CO2 (ppm)",
			x=co2$decimal_date[co2.range], y=co2$trend[co2.range], type="l", col="blue" )
	
	rect( vol$erupted[eruption], 300, vol$erupted[eruption]+vol$duration[eruption], 400, 
			col=alpha("cyan", .1), border="green")
	
	lines( x=trend.date[trend.range], y=trend.fitted[trend.range], col="red")
	
	legend("bottomright", inset=.05, title="trend lines", lty = 1, cex=1,
			 legend = c("actual","fitted"), col=c("blue", "red") )
	
	plot( main= paste("Volcano events fit - ",vol$Name[eruption]), ylab="Severity",
			x=trend.date[trend.range], 
			y=var.co2$varresult$volcano.events$fitted.values[trend.range], 
			type="l", xlim=c(start.date, end.date) )
	
	rect( vol$erupted[eruption], -1, vol$erupted[eruption]+vol$duration[eruption], 1,
			col=alpha("cyan", .1), border="green")
	
	plot( main= paste("Residuals - ",vol$Name[eruption]), ylab="CO2 Res",
			x=trend.date[trend.range], y=trend.res[trend.range], type="l",
			xlim=c(start.date, end.date) )
	
	rect( vol$erupted[eruption], -1, vol$erupted[eruption]+vol$duration[eruption], 1,
			col=alpha("cyan", .1), border="green")

	plot.volcanos(x=trend.date[trend.range],)	
	
	abline(h=trend.q[c(2,4)]);

	par(op)
}

nurf.names <- function(vect) { setNames( seq(1, length(vect)), vect) }

eruptionSelector.widget <- function(name="Eruption") {
	named<-function(tag) {n=paste(name,'.',tag, sep=""); cat("Widget",n, "\n"); n}
	renderUI({
		selectInput(named("choose"), "Choose a Volcanic Eruption", 
						nurf.names(vol$Name), selected = 1, 
						multiple = FALSE, selectize = FALSE)
	})
}
dateSelector.widget <- function(name="Eruption", prior, after) {
	named<-function(tag) {n=paste(name,'.',tag, sep=""); cat("Widget",n, "\n"); n}
	renderUI({
		sliderInput(named("plot.range"), "Select Plot Range (months)",
					min=-25, max = 100, value = c(prior, after))
	})
}

#cat("Server Logic\n")
#############
# Server logic
shinyServer(function(input, output, session) {
	
	var.co2 <- var.co2  # each session gets a copy of the initial variance.
	
	updateSelectInput(session, "Eruption.choose", choices = nurf.names(vol$Name))
	
	doRegression <- function(p=2, type= "trend") 
	{
		cat("doing regression, p= ", p)
		var.co2 <<- VAR(co2[,c("decimal_date", "trend")], p = p, type = "const", )
		
		trend.date <- var.co2$varresult$decimal_date$fitted.values
		trend.res <- var.co2$varresult$trend$residuals
		trend.q<-quantile(trend.res)
	}
#	output$EruptionSelector <- eruptionSelector.widget()
#	output$DateSelector <- dateSelector.widget("Eruption", date.range[1], date.range[2]);
	
#	output$volcanoNames <- renderText(toJSON(vol$Name))
	
	output$eruption <- renderPlot({
		cat("starting render plot\n")
		
		e <- input$Eruption.choose
		range <- input$Eruption.plot.range

		tryCatch(T, error = function(err) err, if (is.null(e)) e="1", e="1")
		tryCatch(T, error = function(err) err, if (is.null(range)) range = c(-6, 24), range = c(-6, 24) )

		cat("range:"); str(range)
		eruption = plot.eruption(as.integer(e), range[1]/12, range[2]/12)
	})

	output$regressionResults <- renderText({
		input$doRegression
		isolate({
			doRegression()
		})
	})
	
	output$theFirst <- renderPlot({
#		cat("Plot the first\n")
		plot.theFirst()
	})
	
	output$residualsPlot <- renderPlot({
#		cat("Plot the second\n")
		plot.residuals(input$residualLog, input$residualOffset)
	})
})
