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

# Post 1: CEWS: A scandalous gift to capital; 15-05-2021
blogdown::new_post(title = "Canada Emergency Wage Subsidy: A scandalous gift to capital", 
                   ext = '.Rmarkdown', 
                   subdir = "post")

## Post 1: Index file
navigateToFile("content/post/2021-05-15-canada-emergency-wage-subsidy-a-scandalous-gift-to-capital/index.Rmarkdown")

# Post 2: Canadian Mining in Africa: A case study in imperialist exploitation 
blogdown::new_post(title = "Excavating the Truth on Canadian Mining in Africa", 
                   ext = '.Rmarkdown', 
                   subdir = "post")

## Post 2: Index file
navigateToFile("content/post/2021-05-30-canadian-mining-in-africa-a-case-study-in-imperialist-exploitation/index.Rmarkdown")