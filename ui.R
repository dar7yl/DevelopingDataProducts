library(shiny)

shinyUI(fluidPage(
	titlePanel("Volcano CO²"),
	
	sidebarLayout(
		sidebarPanel( 
			p("Rarin' to go..."),
			actionButton("doit_action", label = "Doit"),
			hr(),
			
			uiOutput("eruptionSelector")
			
# 			selectInput("eruption2", "Choose a Volcanic Eruption", 
# 							nurf.names(vol$Name), selected = 1, 
# 							multiple = FALSE, selectize = FALSE)
#			"You chose: ", textOutput("e")
			),
			
		mainPanel(
	#		"Co2 Table Summary:", htmlOutput("co2_summary", style="font-size:55%", class="shiny-html-output"),
			plotOutput("theFirst"),
			plotOutput("eruption")
			
			)
	)
))