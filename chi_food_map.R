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
chi_tracts_palette <- colorQuantile(
  palette = "PuBuGn",
  domain = chi_tracts$STORES_PER,
  n = 6)
chi_tracts_popup <- paste0(
  "GEOID: ", chi_tracts$GEOID, "<br>",
  "Total Stores: ", chi_tracts$counts, "<br>",
  "Stores Per 1000: ", round(chi_tracts$STORES_PER, 2))

chi_points_popup <- paste0(
  chi_points$names, "<br>",
  chi_points$address)

# Generate a leaflet map using the helpers
chi_map <- leaflet() %>%
  addProviderTiles("CartoDB.Positron", group = "CartoDB") %>%
  addPolygons(
    data = chi_tracts,
    fillColor = ~chi_tracts_palette(STORES_PER),
    popup = chi_tracts_popup,
    color = "#e2e2e2",
    fillOpacity = 0.6,
    weight = 1,
    smoothFactor = 0.2,
    group = "Store Density") %>%
  addLegend(
    pal = chi_tracts_palette,
    values = chi_tracts$STORES_PER,
    labFormat = function(type, cuts, p) {
      n = length(cuts)
      paste0(round(cuts[-n], 2), " &ndash; ", round(cuts[-1], 2))},
    position = "topright",
    title = "Grocery Stores<br>Per 1000 People") %>%
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
  addLayersControl(
    baseGroups = c("CartoDB"),
    overlayGroups = c("Store Density", "Store Locations"),
    position = "bottomright",
    options = layersControlOptions(collapsed = FALSE))

# Save the leaflet map as an html file
saveWidget(chi_map, file="chi_food_map.html", title = "Chicago Food Density Map")
