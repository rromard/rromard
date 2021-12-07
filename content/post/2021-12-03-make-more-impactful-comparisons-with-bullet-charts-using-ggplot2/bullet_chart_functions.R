#####

# DS4CS Learning: Visualizing Corporate Plunder of the Canada Emergency Wage Subsidy with Bullet Charts
# 
# Make more impactful comparisons with bullet charts using R and ggplot2

#####

# Function 1: Base bullet chart
#
# df - dataframe with two columns for comparison, plus third categorical variable
# pivot_by - index of dataframe columns to pivot to longer form
# ... - takes inputs to aes() as unquoted variable names
# scale - controls the scaling factor on y axis
# widths - controls the variable width of outer and inner bars respectively

ds4cs_bullet_chart <- function(df, 
                               pivot_by,
                               ...,
                               scale = 6, 
                               widths = c(.9, .5)) {
  
  require(dplyr)
  require(ggplot2)
  require(scales)
  
  df <- df %>% 
    pivot_longer(cols = all_of(pivot_by)) %>% 
    mutate(width = rep(widths, nrow(df)))
  
  ggplot(data = df, aes(...)) +
    geom_col(width = df$width) +
    coord_flip() +
    scale_fill_manual(values = c("#de860b", "#8f1f3f")) +
    scale_x_discrete() +
    scale_y_continuous(labels = scales::unit_format(unit = "B", prefix = "$", scale = 10^-scale)) + 
    labs(x = NULL, y = NULL)
}

# Function 2: Adding inner-bar value labels to bullet chart
#
# plot - ggplot object to extract values from and add text to
# filter_var - unquoted variable, converted to string filter the data with
# label_var - unquoted variable to pull the value labels from 


ds4cs_bullet_text <- function(plot, filter_var, label_var, text_size = 6) {
  
  filter_var <- deparse(substitute(filter_var))
  label_var <- enquo(label_var)
  
  df <- plot$data
  
  plot +
    geom_text(
      data = df %>% filter(name == filter_var),
      aes(label = scales::percent(!!label_var, accuracy = 1L)),
      hjust = -0.25, fontface = 'bold', color = "#8f1f3f", family = 'Libre Franklin', size = text_size) 
}

# Custom theme

theme_custom <- function(base_size = 18,
                         family = "Libre Franklin",
                         legend = 'none') {
  
  theme_minimal() %+replace%
    theme(
      text = element_text(size = base_size),
      axis.text = element_text(size = base_size - 1.5),
      panel.grid.minor = element_blank(),
      legend.position = legend,
    )
}

##### Example use
# 
# covid_size_bars <- ds4cs_bullet_chart(
#  df = cews_data$size,
#  pivot_by = 5:6,
#  x = fct_rev(size_of_applicant), y = value, fill = name,
#  widths = c(.7, .3)) %>% 
#  ds4cs_bullet_text(pct_total_subsidy, value) +
#  theme_custom()