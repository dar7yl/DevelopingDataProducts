library(shiny)

shinyUI( fluidPage(
	titlePanel("Volcano CO² Explorer"),
	
	sidebarLayout(
		sidebarPanel(
			uiOutput("eruptionSelector")
		),
		mainPanel(
			plotOutput("eruption"),
			div(plotOutput("theFirst", width="100%")),
			div(plotOutput("theSecond", width="100%"))
		)
	)
))
