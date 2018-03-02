library(tidyverse)
library(rgdal)
library(leaflet)
library(htmlwidgets)

# Laod the necessary shapefiles
chi_tracts <- readOGR(
  dsn = '/home/dfsnow/food_deserts/shapefiles',
  layer = 'final_chi_tracts')
chi_points <- readOGR(
  dsn = '/home/dfsnow/food_deserts/shapefiles',
  layer = 'final_chi_points')

# Create various map helpers (palettes, legends, etc)
chi_tracts_1k_palette <- colorQuantile(
  palette = "PuBuGn",
  domain = chi_tracts$STORES_PER,
  n = 6)

chi_tracts_palette <- colorQuantile(
  palette = "PuBuGn",
  domain = chi_tracts$counts,
  n = 6)

chi_tract_labels <- sprintf(
  "<strong>%s</strong><br/>Total Stores: %g<br/>Stores Per 1K: %g",
  chi_tracts$PRI_NEIGH, chi_tracts$counts, round(chi_tracts$STORES_PER, 2)
) %>% lapply(htmltools::HTML)

chi_points_popup <- paste0(
  chi_points$names, "<br>",
  chi_points$address)

# Generate a leaflet map using the helpers
chi_map <- leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  
  # Point of each grocery store
  addCircles(
    chi_points$longitude.,
    chi_points$latitude.1,
    popup=chi_points_popup,
    weight = 4,
    radius=4,
    color="maroon",
    stroke = TRUE,
    fillOpacity = 0.7,
    group = "Store Locations") %>%
  
  # Raw store totals layer
  addPolygons(
    data = chi_tracts,
    fillColor = ~chi_tracts_palette(counts),
    color = "#e2e2e2",
    fillOpacity = 0.5,
    weight = 1,
    smoothFactor = 0.2,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 3,
      bringToFront = TRUE,
      fillOpacity = 1,
      sendToBack = FALSE),
    label = chi_tract_labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "12px",
      direction = "auto"),
    group = "Total Stores") %>%
  addLegend(
    pal = chi_tracts_palette,
    values = chi_tracts$counts,
    labFormat = function(type, cuts, p) {
      n = length(cuts)
      paste0(round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2))},
    position = "topright",
    opacity = 0.7,
    group = "Total Stores",
    title = "Total Stores") %>%
  
  # Stores per 1000 people layer
  addPolygons(
    data = chi_tracts,
    fillColor = ~chi_tracts_1k_palette(STORES_PER),
    color = "#e2e2e2",
    fillOpacity = 0.5,
    weight = 1,
    smoothFactor = 0.2,
    highlightOptions = highlightOptions(
      color = "white",
      weight = 3,
      bringToFront = TRUE,
      fillOpacity = 1,
      sendToBack = FALSE),
    label = chi_tract_labels,
    labelOptions = labelOptions(
      style = list("font-weight" = "normal", padding = "3px 8px"),
      textsize = "12px",
      direction = "auto"),
    group = "Stores Per 1000 People") %>%
  addLegend(
    pal = chi_tracts_1k_palette,
    values = chi_tracts$STORES_PER,
    labFormat = function(type, cuts, p) {
      n = length(cuts)
      paste0(round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2))},
    position = "topright",
    opacity = 0.7,
    group = "Stores Per 1000 People",
    title = "Grocery Stores<br>Per 1000 People") %>%
  
  # Layer controls and cleanup
  addLayersControl(
    baseGroups = c("CartoDB"),
    overlayGroups = c("Total Stores",
                      "Stores Per 1000 People",
                      "Store Locations"),
    position = "bottomright",
    options = layersControlOptions(collapsed = FALSE)) %>%
  hideGroup("Store Locations") %>%
  hideGroup("Stores Per 1000 People")

# Save the leaflet map as an html file
saveWidget(chi_map, file="chi_food_map.html", title = "Chicago Food Density Map")
