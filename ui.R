library(shiny)
#library(jsonlite)

shinyUI( fluidPage(
	titlePanel("CO² Volcano Explorer"),
	p("For more information, see preliminary data analysis at ", 
	  a(href="https://github.com/dar7yl/DevelopingDataProducts/blob/master/VolcanoCO2.md", target="_blank", "GitHub") ),

	sidebarLayout(
		sidebarPanel(
				h3("Look at the Data"),
				p("This is the average monthly readings of CO², taken at the Mauna Loa Observatory in Hawaii between 1958 and 2015."),
				p("")
		),
		mainPanel(
			div(plotOutput("theFirst", width="95%"), height="150")
		)
	),

	sidebarLayout(
		sidebarPanel(
			h3("Examine Volcano Events"),
			p("Here, we can examine each of the eruptions more closely. Select the name of a volcano to see its eruption. Look for increased CO2 activity in the residuals after the volcano"),
			
			uiOutput("eruptionSelector"),
			
			p("You can zoom in on Volcano events to see if there is any significance in the residuals.")
		),
		mainPanel(
			plotOutput("eruption")
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
				p("Here, you can switch between linear and logarithm plots of the trend residuals, to see if there is any effect that can be observed by switching scales. (spoiler alert: no significant change)"),
				p("Click the Logarithm button to swap, and enter an offset value to shift the graph"),			
				checkboxInput("residualLog", label = "Logarithm", value = FALSE),
				numericInput("residualOffset", label="Log offset", value=1)
		),
		mainPanel(
			div(plotOutput("residualsPlot", width="90%"), height="150")
		)
	),
	hr(), p("fin.")
))
