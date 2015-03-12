library(shiny)
#library(jsonlite)

unnurf.names <- function(blob) { vect=fromJSON(blob); setNames( seq(1, length(vect)), vect) }

shinyUI( fluidPage(
	titlePanel("CO² Volcano Explorer"),

	sidebarLayout(
		sidebarPanel(
			p("Many global warming deniers are claiming that volcanic eruptions spewed so much CO2 that it completely dominated the climate, and man's influence was negligible.  
			  I wanted to explore the impact of volcanos on the CO2 record, to see if volcanos were indeed significant."
			),
#			p(" Volcanos: ", uiOutput("volcanoNames") ),
#			p(" unnerfed: ", unnerf.names(uiOutput("volcanoNames")) ),
#			p("fin."),
			p("To get more information about the data, look at the preliminary data exploration: ", 
			  a(href="https://github.com/dar7yl/DevelopingDataProducts/blob/master/VolcanoCO2.md", target="_blank", "VolcanoCO2.md")
			)
		),
		mainPanel(
			div(plotOutput("theFirst", width="90%"), height="150")
#			div(plotOutput("theSecond", width="90%"))
		)
	),

	sidebarLayout(
		sidebarPanel( h3("Perform Regression"),
						  checkboxInput("reg.1", label = "Control 1", value = FALSE),
						  numericInput("reg.2", label="Control 2", value=1),
						  actionButton("doRegression", "Do Regression")
		),
		mainPanel(
			div(plotOutput("regressionPlot", width="90%"))
		)
	),

	sidebarLayout(
		sidebarPanel( h3("Examine Residuals"),
				checkboxInput("residualLog", label = "Logarithm", value = FALSE),
				numericInput("residualOffset", label="Log offset", value=1)
		),
		mainPanel(
			div(plotOutput("residualsPlot", width="90%"), height="150")
		)
	),

	sidebarLayout(
		sidebarPanel(
			p("We can examine one of the eruptions more closely.  Look for increased CO2 activity in the residuals after the volcano"),

# 			selectInput("selectEruption", "Select a Volcanic Eruption", 
# 				choices = NULL, selected = 1, multiple = FALSE),

			uiOutput("eruptionSelector"),

			p("You can zoom in on Volcano events to see if there is any significance in the residuals.")
		),
		mainPanel(
			plotOutput("eruption")
		)
	)
))
