library(rstudioapi)
library(blogdown)

# Checks
check_config()
check_content()
check_netlify()
check_hugo()
blogdown::check_site()

# Set up live serve
serve_site()

# Create new post rmd
blogdown::new_post(title = "Here is a test post", 
                   ext = '.Rmarkdown', 
                   subdir = "post")