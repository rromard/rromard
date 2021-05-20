library(tidyverse)
library(here)
library(extrafont)
library(showtext)

# themes, fonts, colours
theme_rr_min <- function(base_size = 16, family = "Libre Franklin", legend = 'none') {
  theme_minimal() %+replace% 
    theme(
      text = element_text(size = base_size, family = family),
      axis.text = element_text(size = base_size - 1.5),
      panel.grid.minor = element_blank(),
      legend.position = legend)
}

palette_a <- c("#b7a4d6","#8f1f3f","#c73200","#de860b","#d4ae0b")
palette_b <-  c("#ff2a00","#ba4e38","#fa684b","#ad1d00","#7a1400")

extrafont::loadfonts(device="win", quiet = TRUE)
font_add(family = "Libre Franklin", regular = "C:/Users/Ryan/Documents/Fonts/Libre_Franklin/static/LibreFranklin-Regular.ttf")
