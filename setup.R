# Installation
install.packages('blogdown')
remotes::install_github("rstudio/blogdown")
install.packages("rstudioapi")
# Library loading
library(rstudioapi)
library(blogdown)
library(here)

# Workaround to create new page, set WD to empty temp directory
setwd(here('temp_folder'))
setwd('C:/Users/Ryan/Documents/rromard_website')
new_site(theme = "wowchemy/starter-academic", force = TRUE)

# will save settings, opens if exists, creates if new
blogdown::config_Rprofile()



blogdown::new_post(title = "Hi Hugo", 
                   ext = '.Rmarkdown', 
                   subdir = "post")
stop_server()
serve_site()
