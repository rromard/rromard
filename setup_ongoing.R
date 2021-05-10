# Library loading
library(rstudioapi)
library(blogdown)
library(here)

### RStudio API links

# Change base URL
rstudioapi::navigateToFile("config.yaml", line = 3)

### Rstudio API links

## Config

# Main config file
navigateToFile("config.yaml")
# Authors
navigateToFile("content/authors/admin/_index.md")
# Languages
navigateToFile("config/_default/languages.yaml")
# Menus
navigateToFile("config/_default/menus.yaml")
# Parameters
navigateToFile("config/_default/params.yaml")

## Home page

# About
navigateToFile("content/home/about.md")
# Contact
navigateToFile("content/home/contact.md")
# Hero
navigateToFile("content/home/hero.md")
# Posts
navigateToFile("content/home/posts.md")
# Projects
navigateToFile("content/home/projects.md")

## Widget pages

# About
navigateToFile("content/about/index.md")
navigateToFile("content/about/about.md")

# Contact
navigateToFile("content/about/index.md")
navigateToFile("content/about/about.md")

# Posts
navigateToFile("content/post/index.md")
navigateToFile("content/post/post.md")

# Projects
navigateToFile("content/project/index.md")
navigateToFile("content/project/project.md")

## Custom CSS


### Checks
check_content()
check_netlify()
check_hugo()

### Stop and serve
stop_server()
serve_site()
