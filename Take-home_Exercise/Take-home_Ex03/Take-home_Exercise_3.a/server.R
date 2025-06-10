library(shiny)
server <- function(input, output, session) {
  
# Reactive subgraph based on user input
  subgraph_data <- reactive({
    req(input$artist)
    
# Find the artist ID
    artist_id <- nodes_tbl %>%
      filter(name == input$artist) %>%
      pull(id)
    
    if (length(artist_id) == 0) return(NULL)
# Create igraph object
    igraph_obj <- as.igraph(graph)
    artist_index <- which(V(igraph_obj)$id == artist_id)
    
# Get neighborhood up to input$depth
    nearby_nodes <- unlist(igraph::neighborhood(igraph_obj, order = input$depth, nodes = artist_index))
    sub_igraph <- igraph::induced_subgraph(igraph_obj, vids = nearby_nodes)
    subgraph <- as_tbl_graph(sub_igraph)
    
# Filter by year range
    subgraph %>%
      filter(!is.na(release_date) & year(release_date) >= input$year[1] & year(release_date) <= input$year[2])
  })
  
# Network visualization
  output$networkPlot <- renderPlot({
    g <- subgraph_data()
    if (is.null(g)) return(NULL)
    
    ggraph(g, layout = "fr") +
      geom_edge_link(alpha = 0.2) +
      geom_node_point(aes(color = genre, size = pagerank), show.legend = TRUE) +
      geom_node_text(aes(label = name), repel = TRUE, size = 3) +
      theme_void()
  })
  
  # Centrality score table
  output$centralityTable <- renderDataTable({
    g <- subgraph_data()
    if (is.null(g)) return(NULL)
    
    g %>%
      mutate(
        pagerank = centrality_pagerank(),
        betweenness = centrality_betweenness()
      ) %>%
      as_tibble() %>%
      select(name, genre, pagerank, betweenness) %>%
      arrange(desc(pagerank))
  })
}
