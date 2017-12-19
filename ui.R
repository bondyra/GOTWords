library(dplyr)
if (!require("shinyjs"))
	install.packages("shinyjs")
library(shinyjs)

data = read.table("data.txt",sep=",",header=T,quote="")
characters = as.character(as.data.frame(data %>% count(name, sort = T))[1:9,]$name)

shinyUI(fluidPage(
	useShinyjs(),
  headerPanel("Gra o tron"),
  sidebarPanel(
  	tags$head(tags$script('var dimension = [0, 0];
                                $(document).on("shiny:connected", function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                                $(window).resize(function(e) {
                                    dimension[0] = window.innerWidth;
                                    dimension[1] = window.innerHeight;
                                    Shiny.onInputChange("dimension", dimension);
                                });
                            ')), #wyciagniecie rozmiaru okna
  	tags$head(tags$style("#cloud{height:90vh !important;}")), #zrobienie, zeby wykres zajmowal caly ekran
  	selectInput("character", "Postać:", characters),
  	uiOutput("nextword"),
  	actionButton("previous", "Wstecz")
  ),
  mainPanel(
    plotOutput("cloud")
  )
))

?textInput
