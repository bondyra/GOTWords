reactiveBar <- function (outputId) 
{
  HTML(paste("<div id=\"", outputId, "\" class=\"shiny-network-output\"><svg /></div>", sep=""))
}


shinyUI(fluidPage(
  headerPanel(HTML("Sample based on https://github.com/timelyportfolio/shiny-d3-plot")),
  sidebarPanel(HTML('<input type="text" id="inputText" value="JON"/>
               <button id="newCloud">Generate</button>')),
  mainPanel(
    HTML('<button id="goBack">Go Back</button>
         <div id="contextLabel"/>'),
    includeHTML("graph.js"),
    reactiveBar(outputId = "perfbarplot")    
  )
))

?textInput
