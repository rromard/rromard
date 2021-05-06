# Installation
install.packages('blogdown')
remotes::install_github("rstudio/blogdown")
install.packages("rstudioapi")
# Library loading
library(rstudioapi)
library(blogdown)
library(here)

# # Workaround to create new page, set WD to empty temp directory
# setwd(here('temp_folder'))
# setwd('C:/Users/Ryan/Documents/rromard_website')
# new_site(theme = "wowchemy/starter", force = TRUE)

# will save settings, opens if exists, creates if new
blogdown::config_Rprofile()

# Change base URL
rstudioapi::navigateToFile("config.yaml", line = 3)

# Configs
config_netlify()

# Checks
check_content()
check_netlify()
check_hugo()

# Change to author/bio section
navigateToFile("content/authors/admin/_index.md")
# Changes to active widgets
navigateToFile("content/home/accomplishments.md")
