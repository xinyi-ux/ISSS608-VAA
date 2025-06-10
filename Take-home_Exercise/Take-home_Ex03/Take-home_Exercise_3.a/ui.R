ui <- fluidPage(
  titlePanel("Oceanus Folk Network Explorer"),
  sidebarLayout(
    sidebarPanel(
      textInput("artist", "Artist Name:", value = "Sailor Shift"),
      sliderInput("depth", "Network Depth (hops):", min = 1, max = 5, value = 2),
      sliderInput("year", "Release Year Range:", min = 2000, max = 2040, value = c(2010, 2040))
    ),
    mainPanel(
      plotOutput("networkPlot"),
      dataTableOutput("centralityTable")
    )
  )
)
