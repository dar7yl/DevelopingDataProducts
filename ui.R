library(shiny)

shinyUI( fluidPage(
	titlePanel("Volcano CO² Explorer"),

	
	sidebarLayout(
		sidebarPanel(
			p("We can examine one of the eruptions more closely.  Look for increased CO2 activity in the residuals after the volcano"),
			uiOutput("eruptionSelector"),
			p("To get more information about the data, look at the data exploration: ", 
			  a(href="https://github.com/dar7yl/DevelopingDataProducts/blob/master/VolcanoCO2.md", target="_blank", "VolcanoCO2.md"))
		),
		mainPanel(
			plotOutput("eruption"),
			div(plotOutput("theFirst", width="100%")),
			div(plotOutput("theSecond", width="100%"))
		)
	)
))
