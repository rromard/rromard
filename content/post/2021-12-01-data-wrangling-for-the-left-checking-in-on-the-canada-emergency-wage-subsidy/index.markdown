---
title: 'Using R and Open Data to Check-in on the Canada Emergency Wage Subsidy'
author: Ryan Romard
date: '2021-12-01'
slug: data-wrangling-for-the-left-checking-in-on-the-canada-emergency-wage-subsidy
categories: []
tags: []
subtitle: 'DS4CS Learning: An introduction to finding, preparing, and using open data for data journalism'
summary: ''
authors: []
lastmod: '2021-12-01T13:09:24-05:00'
featured: no
image:
  caption: 'Photo by <a href="https://unsplash.com/@mbaumi?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Mika Baumeister</a> on <a href="https://unsplash.com/?utm_source=unsplash&utm_medium=referral&utm_content=creditCopyText">Unsplash</a>'
  focal_point: ''
  preview_only: no
projects: []
---

This is the first in an ongoing series of educational articles where I show my code and work used to produce a prior analysis. I hope that this series will serve as a useful resource to those curious about using data to advance the agendas of labour and socialism. In this inaugural entry of the DS4CS learning series, I share the code used to wrangle the data that informed my first ever [story on the Canada Emergency Wage Subsidy](https://ds4cs.netlify.app/post/cews-a-scandalous-gift-to-capital/).

Before continuing, I'm compelled to declare that my main areas of expertise are sociology, political science and applied social research. After about two years of learning, I'm an intermediate coder at best. I'm enthusiastic about data science, but feel that I am far from the level of expertise needed to call myself a proper data scientist. 

With that in mind, I hope that one of the main take aways of this series is that **data science isn't just an inscrutable domain of obscure math and fancy tech for ultra-experts**. These posts will demonstrate that when equipped with some sound knowledge of the fundamentals of statistics and the basics programming, even relative beginners can perform useful tasks and produce impactful analysis. Throw some domain knowledge into the mix and one might be surprised at what becomes possible.

{{< toc >}}

# The importance of data wrangling in data science

Given the recent announcement of [new subsidy programs](https://www.canada.ca/en/department-finance/news/2021/11/government-introduces-legislation-to-create-jobs-and-implement-targeted-covid-19-support.html) to replace the obscene corporate giveaway that was the Canada Emergency Wage Subsidy, it's an opportune time for an exercise in open data wrangling to check in on the full run of one of Canada's most expensive government programs of all time. The code provided in this post can be used to recreate my earlier analysis revealing the CEWS to be a massive corporate feast [here](https://ds4cs.netlify.app/post/cews-a-scandalous-gift-to-capital/).

Data wrangling is the process of finding, gathering, cleaning, transforming and otherwise preparing data for further tasks like analysis, modeling, and visualization. Wrangling is the [first essential step](https://www.oreilly.com/radar/the-unreasonable-importance-of-data-preparation/) to the basic data science workflow, yet it is without a doubt the least glamorous and fun phase of the process. Getting the data into a usable form will usually be the most laborious and time consuming task of a basic data science analysis or project. If any of this is new to you, I highly recommend [R for Data Science by Hadley Wickam](https://r4ds.had.co.nz/wrangle-intro.html) as one of the best free resources for beginners.

## R basics

Learning how to code is a non-negotiable part of learning how to do data science. [R is an open-source functional programming language](https://www.r-project.org/) made for statistical computing that is very popular among data scientists and many others types of data-workers. All of my work up to this point has been done using R. It's free, flexible, has a huge online community and was (to me, at least) relatively easy to pick up, at least in it's Tidyverse incarnation. 

So R is a pretty good place to start if you are looking to pick up coding and data science. In order to kick start learning R, I enrolled and completed *most* of Rafael Irizarry's [excellent course on R for data science](https://www.edx.org/professional-certificate/harvardx-data-science?index=product&queryID=c1e1aa460a48557df244e03ef8720ad3&position=2) available on EdX. You can find the [textbook for the course for free](https://rafalab.github.io/dsbook/), which is another great introductory source for beginners to both R coding and data science.  

### Using RStudio and projects

RStudio is an IDE or Integrated Development Environment for R code. If you want to start learning how to use R, it's highly recommended that you start using RStudio ASAP. The free desktop version of RStudio can be [downloaded here](https://www.rstudio.com/products/rstudio/download/). Here's a [great collection of resources on how to get both R and RStudio installed and up and running](https://support.rstudio.com/hc/en-us/articles/201141096-Getting-Started-with-R).

It's also a good idea to get used to using [projects within RStudio](https://r4ds.had.co.nz/workflow-projects.html) to keep track of your work on different things. One of the best parts of projects is that they prevent file-path and 'where's that script?' headaches that often pop up.

### The beauty of Rmarkdown and `knitr`

All of the posts on this site are written in Rmarkdown, a format that combines the capability to run R code (as well as many other languages such as Python or Julia) with writing in [Markdown](https://en.wikipedia.org/wiki/Markdown), a simple and lightweight markup language for formatting text. If you are new to data science with R, I highly recommend checking out this comprehensive [free book on Rmarkdown](https://bookdown.org/yihui/Rmarkdown/) by the package author.

Rmarkdown is a wonderful thing. It provides great flexibility, easily blends writing with code, lends itself to creating sharable, reusable, reproducible analysis, and can even be used to create websites (like this one). When writing in Rmarkdown in Rstudio, the [knitr package](https://yihui.org/knitr/) can be used to transform .Rmd documents into other formats such as html, pdf, or even Word documents. Knitr also offers much control and customization of the output of code chunks where R code is written and executed. Setting the chunk option `echo = TRUE` allows for the raw code to be included in the output document; if you don't want the raw code, hide it by setting `echo = FALSE`.


```r
knitr::opts_chunk$set(echo = TRUE)
```

### Using and keeping track of packages

Typically, the first step to the data science workflow is to install and load the software packages needed for the task at hand. If you haven't installed an R package before, take a look at this [basic introduction to the topic](http://www.sthda.com/english/wiki/installing-and-using-r-packages). Once installed, packages can be loaded by calling the library function. 

The [Tidyverse](https://www.tidyverse.org/) is an ecosystem of related packages with a similar style, grammar, and data formats. It's worth reading an introduction to [tidy data principles](https://r4ds.had.co.nz/tidy-data.html) before diving into the Tidyverse. Loading the `tidyverse` library automatically reads in several core packages that can take care of most common tasks in the data science workflow. 


```r
library(tidyverse)
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --
```

```
## v ggplot2 3.3.4     v purrr   0.3.4
## v tibble  3.1.2     v dplyr   1.0.6
## v tidyr   1.1.3     v stringr 1.4.0
## v readr   1.4.0     v forcats 0.5.0
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

Sometimes you will need to load many packages at the start of a workflow. In order to avoid re-typing a library function a dozen times, use the [pacman package](http://trinker.github.io/pacman/vignettes/Introduction_to_pacman.html) to load in all of the needed packages at the same time. The `p_load` function will load each package and by default attempt to install any package that isn't currently installed. To stop `pacman` from installing missing packages or updating out of date packages, set the `install` and `update` arguments to `FALSE`. 


```r
pacman::p_load(tidyverse, janitor, here, lubridate)
```

It's not uncommon to find that code that once worked fine will break when revisited in the future. Usually, this is caused by differences in the versions of packages as they are updated over time. So the first layer of reproducibility is keeping track of and being transparent about the version history of packages used. With the `sessionInfo` function, you can retrieve the versions of all packages used. This shouldn't be an issue for this analysis, but specific versions of most package can be found using the archived [MRAN Repository Snapshots](https://mran.microsoft.com/documents/rro/reproducibility). 


```r
sessioninfo::session_info()[[2]]
```

```
##  package     * version date (UTC) lib source
##  assertthat    0.2.1   2019-03-21 [1] CRAN (R 4.0.3)
##  backports     1.1.10  2020-09-15 [1] CRAN (R 4.0.3)
##  blob          1.2.1   2020-01-20 [1] CRAN (R 4.0.3)
##  blogdown      1.3.1   2021-05-06 [1] Github (rstudio/blogdown@20a8258)
##  bookdown      0.22    2021-04-22 [1] CRAN (R 4.0.5)
##  broom         0.7.1   2020-10-02 [1] CRAN (R 4.0.2)
##  bslib         0.2.5.1 2021-05-18 [1] CRAN (R 4.0.5)
##  cellranger    1.1.0   2016-07-27 [1] CRAN (R 4.0.3)
##  cli           3.1.0   2021-10-27 [1] CRAN (R 4.0.5)
##  colorspace    2.0-1   2021-05-04 [1] CRAN (R 4.0.5)
##  crayon        1.4.1   2021-02-08 [1] CRAN (R 4.0.5)
##  DBI           1.1.0   2019-12-15 [1] CRAN (R 4.0.3)
##  dbplyr        1.4.4   2020-05-27 [1] CRAN (R 4.0.3)
##  digest        0.6.27  2020-10-24 [1] CRAN (R 4.0.5)
##  dplyr       * 1.0.6   2021-05-05 [1] CRAN (R 4.0.5)
##  ellipsis      0.3.2   2021-04-29 [1] CRAN (R 4.0.5)
##  evaluate      0.14    2019-05-28 [1] CRAN (R 4.0.3)
##  fansi         0.5.0   2021-05-25 [1] CRAN (R 4.0.5)
##  forcats     * 0.5.0   2020-03-01 [1] CRAN (R 4.0.3)
##  fs            1.5.0   2020-07-31 [1] CRAN (R 4.0.3)
##  generics      0.1.0   2020-10-31 [1] CRAN (R 4.0.5)
##  ggplot2     * 3.3.4   2021-06-16 [1] CRAN (R 4.0.5)
##  glue          1.4.2   2020-08-27 [1] CRAN (R 4.0.3)
##  gtable        0.3.0   2019-03-25 [1] CRAN (R 4.0.3)
##  haven         2.3.1   2020-06-01 [1] CRAN (R 4.0.3)
##  here        * 1.0.1   2020-12-13 [1] CRAN (R 4.0.3)
##  hms           1.1.0   2021-05-17 [1] CRAN (R 4.0.5)
##  htmltools     0.5.1.1 2021-01-22 [1] CRAN (R 4.0.5)
##  httr          1.4.2   2020-07-20 [1] CRAN (R 4.0.3)
##  janitor     * 2.0.1   2020-04-12 [1] CRAN (R 4.0.3)
##  jquerylib     0.1.4   2021-04-26 [1] CRAN (R 4.0.5)
##  jsonlite      1.7.2   2020-12-09 [1] CRAN (R 4.0.5)
##  knitr         1.33.4  2021-05-21 [1] Github (yihui/knitr@a41ca9f)
##  lifecycle     1.0.0   2021-02-15 [1] CRAN (R 4.0.5)
##  lubridate   * 1.7.10  2021-02-26 [1] CRAN (R 4.0.5)
##  magrittr      2.0.1   2020-11-17 [1] CRAN (R 4.0.5)
##  modelr        0.1.8   2020-05-19 [1] CRAN (R 4.0.3)
##  munsell       0.5.0   2018-06-12 [1] CRAN (R 4.0.3)
##  pacman        0.5.1   2019-03-11 [1] CRAN (R 4.0.5)
##  pillar        1.6.1   2021-05-16 [1] CRAN (R 4.0.5)
##  pkgconfig     2.0.3   2019-09-22 [1] CRAN (R 4.0.3)
##  purrr       * 0.3.4   2020-04-17 [1] CRAN (R 4.0.3)
##  R6            2.5.0   2020-10-28 [1] CRAN (R 4.0.5)
##  Rcpp          1.0.7   2021-07-07 [1] CRAN (R 4.0.5)
##  readr       * 1.4.0   2020-10-05 [1] CRAN (R 4.0.3)
##  readxl        1.3.1   2019-03-13 [1] CRAN (R 4.0.3)
##  reprex        0.3.0   2019-05-16 [1] CRAN (R 4.0.3)
##  rlang         0.4.11  2021-04-30 [1] CRAN (R 4.0.5)
##  rmarkdown     2.11    2021-09-14 [1] CRAN (R 4.0.3)
##  rprojroot     2.0.2   2020-11-15 [1] CRAN (R 4.0.3)
##  rstudioapi    0.13    2020-11-12 [1] CRAN (R 4.0.5)
##  rvest         1.0.2   2021-10-16 [1] CRAN (R 4.0.5)
##  sass          0.4.0   2021-05-12 [1] CRAN (R 4.0.5)
##  scales        1.1.1   2020-05-11 [1] CRAN (R 4.0.3)
##  sessioninfo   1.2.1   2021-11-02 [1] CRAN (R 4.0.5)
##  snakecase     0.11.0  2019-05-25 [1] CRAN (R 4.0.3)
##  stringi       1.5.3   2020-09-09 [1] CRAN (R 4.0.3)
##  stringr     * 1.4.0   2019-02-10 [1] CRAN (R 4.0.3)
##  tibble      * 3.1.2   2021-05-16 [1] CRAN (R 4.0.5)
##  tidyr       * 1.1.3   2021-03-03 [1] CRAN (R 4.0.5)
##  tidyselect    1.1.1   2021-04-30 [1] CRAN (R 4.0.5)
##  tidyverse   * 1.3.0   2019-11-21 [1] CRAN (R 4.0.3)
##  utf8          1.2.1   2021-03-12 [1] CRAN (R 4.0.5)
##  vctrs         0.3.8   2021-04-29 [1] CRAN (R 4.0.5)
##  withr         2.4.2   2021-04-18 [1] CRAN (R 4.0.5)
##  xfun          0.24    2021-06-15 [1] CRAN (R 4.0.5)
##  xml2          1.3.2   2020-04-23 [1] CRAN (R 4.0.3)
##  yaml          2.2.1   2020-02-01 [1] CRAN (R 4.0.3)
## 
##  [1] C:/Users/Ryan/Documents/R/win-library/4.0
##  [2] C:/Program Files/R/R-4.0.3/library
```

## Wrangling data from Canada's National Lobbyist Registry

### Importing `.csv` files with `readr` and `here`

As of December 2021, the Federal Liberals still resist calls to release [detailed data](https://www.theglobeandmail.com/investing/personal-finance/taxes/article-when-it-comes-to-cews-its-your-money-but-none-of-your-business/) on corporate recipients of the CEWS. However, since companies registered for lobbying activities must disclose any government funding received, some of that data is available through the Office of the Commissioner of Lobbying of Data. In addition to a [searchable database](https://lobbycanada.gc.ca/app/secure/ocl/lrs/do/guest?lang=eng), a full extract of the Lobbyist Registry data can be [downloaded here](https://lobbycanada.gc.ca/en/open-data/).

The data extract archive contains one primary export and a number of additional linked data in the form of ``.csv`` or comma separated value files, one of the most commonly encountered file formats out there. After extracting the files from the `.zip` archive, they can be imported into your R session using the `read_csv()` function from the `readr` package, which is automatically loaded with the `tidyverse` library. The `read_csv` function will automatically give a message reporting on the column specifications and any problems (parsing failures) that arise in reading in the data.

Point `read_csv` to the location of the file using the `file` argument in order to read the data in. R can sometimes be fussy with file paths, which is why you should learn to love the [here package](https://github.com/jennybc/here_here). If you are using a project within RStudio as recommended above, calling the function `here()` will produce an R-friendly file path based on your project's working directory. Pretty much every time that I need to use a file path in R, I use `here` to avoid path-related woes. 

{{% callout note %}}
If you want to keep the results of your code in memory for further use, you need to assign it to an object with the `<-` operator. 

So often, the reason for code not working as expected is a forgotten or misused `<-` assignment.
{{% /callout %}}


```r
lobby_main_raw <- read_csv(file = here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'Registration_PrimaryExport.csv'))
```

```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   .default = col_character(),
##   REG_ID_ENR = col_double(),
##   REG_TYPE_ENR = col_double(),
##   RGSTRNT_NUM_DECLARANT = col_double(),
##   CLIENT_ORG_CORP_PROFIL_ID_PROFIL_CLIENT_ORG_CORP = col_double(),
##   CLIENT_ORG_CORP_NUM = col_double(),
##   EFFECTIVE_DATE_VIGUEUR = col_date(format = ""),
##   END_DATE_FIN = col_date(format = "")
## )
## i Use `spec()` for the full column specifications.
```

```
## Warning: 4591 parsing failures.
##   row          col   expected actual                                                                                                             file
## 50436 END_DATE_FIN date like    null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_PrimaryExport.csv'
## 55973 END_DATE_FIN date like    null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_PrimaryExport.csv'
## 57036 END_DATE_FIN date like    null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_PrimaryExport.csv'
## 59250 END_DATE_FIN date like    null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_PrimaryExport.csv'
## 59326 END_DATE_FIN date like    null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_PrimaryExport.csv'
## ..... ............ .......... ...... ................................................................................................................
## See problems(...) for more details.
```

### Catching and dealing with parsing errors

When finished reading in the file, `readr` will automatically print a report on the data types (if this is new to you, it's worth [reading up on R data types](https://r4ds.had.co.nz/vectors.html)) of the table columns and any parsing errors that arise during the data import. All sorts of strange things can happen to the data during the process of importing. Sometimes, the initial product of importing into R will look nothing like the original `.csv` file at all. 

It's essential ensure that the data read into R is an accurate representation of the original data. We can inspect the parsing report and the actual data to ensure that it has been imported correctly. Passing the imported data object to the `readr::problems()` function, you can see a tibble (more on tibbles below) with more information on every parsing issue. 


```r
lobby_problems <- problems(lobby_main_raw)
lobby_problems
```

```
## # A tibble: 4,591 x 5
##      row col       expected   actual file                                       
##    <int> <chr>     <chr>      <chr>  <chr>                                      
##  1 50436 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  2 55973 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  3 57036 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  4 59250 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  5 59326 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  6 59327 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  7 59330 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  8 59332 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
##  9 59346 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
## 10 59352 END_DATE~ "date lik~ null   'C:/Users/Ryan/Documents/rromard_website/d~
## # ... with 4,581 more rows
```

In this case, it looks like `readr` was expecting to find dates in the `END_DATE_FIN` column, but instead found `null` values. Inspecting the tibble of problems further, this was the only column with a parsing issue. 


```r
unique(lobby_problems$col)
```

```
## [1] "END_DATE_FIN"
```

### Dataframes and tibbles

It's wise to look at the original file using something like Excel when parsing issues arise. After looking closely at the original file, we find that the missing dates will not be relevant to the analysis, so the process can continue.

As part of the [Tidyverse](https://www.tidyverse.org/), `read_csv` will by default import the contents of the `.csv` file as a tibble, which is a tidy table, a form of dataframe. Dataframes or tibbles are probably the most common method used to store data in R. You can read more about [tibbles and how the relate to base R dataframes here](https://r4ds.had.co.nz/tibbles.html). 

Input the object's name and run the code to inspect the imported tibble. 


```r
lobby_main_raw
```

```
## # A tibble: 117,195 x 38
##    REG_ID_ENR REG_TYPE_ENR REG_NUM_ENR   VERSION_CODE EN_FIRM_NM_FIRME_AN
##         <dbl>        <dbl> <chr>         <chr>        <chr>              
##  1     484710            1 778218-6527-1 V4           propre compte      
##  2     484262            1 778218-6332-1 V4           propre compte      
##  3     501724            1 778218-6527-2 V4           propre compte      
##  4     501723            1 778218-6332-2 V4           propre compte      
##  5     502662            1 778218-6637-2 V4           propre compte      
##  6     510107            3 778219-6123-4 V4           null               
##  7     513341            3 778219-6123-5 V4           null               
##  8     515729            3 778219-6123-6 V5           null               
##  9     501577            3 778219-6123-2 V4           null               
## 10     484394            3 778219-6123-1 V4           null               
## # ... with 117,185 more rows, and 33 more variables: FR_FIRM_NM_FIRME <chr>,
## #   RGSTRNT_POS_POSTE_DCLRNT <chr>, FIRM_ADDRESS_ADRESSE_FIRME <chr>,
## #   FIRM_TEL_FIRME <chr>, FIRM_FAX_FIRME <chr>, RGSTRNT_NUM_DECLARANT <dbl>,
## #   RGSTRNT_LAST_NM_DCLRNT <chr>, RGSTRNT_1ST_NM_PRENOM_DCLRNT <chr>,
## #   RO_POS_POSTE_AR <chr>, RGSTRNT_ADDRESS_ADRESSE_DCLRNT <chr>,
## #   RGSTRNT_TEL_DCLRNT <chr>, RGSTRNT_FAX_DCLRNT <chr>,
## #   CLIENT_ORG_CORP_PROFIL_ID_PROFIL_CLIENT_ORG_CORP <dbl>,
## #   CLIENT_ORG_CORP_NUM <dbl>, EN_CLIENT_ORG_CORP_NM_AN <chr>,
## #   FR_CLIENT_ORG_CORP_NM <chr>,
## #   CLIENT_ORG_CORP_ADDRESS_ADRESSE_CLIENT_ORG_CORP <chr>,
## #   CLIENT_ORG_CORP_TEL <chr>, CLIENT_ORG_CORP_FAX <chr>,
## #   REP_LAST_NM_REP <chr>, REP_1ST_NM_PRENOM_REP <chr>,
## #   REP_POSITION_POSTE_REP <chr>, EFFECTIVE_DATE_VIGUEUR <date>,
## #   END_DATE_FIN <date>, PARENT_IND_SOC_MERE <chr>, COALITION_IND <chr>,
## #   SUBSIDIARY_IND_FILIALE <chr>, DIRECT_INT_IND_INT_DIRECT <chr>,
## #   GOVT_FUND_IND_FIN_GOUV <chr>, FY_END_DATE_FIN_EXERCICE <chr>,
## #   CONTG_FEE_IND_HON_COND <chr>, PREV_REG_ID_ENR_PRECEDNT <chr>,
## #   POSTED_DATE_PUBLICATION <chr>
```

### Preparing and cleaning the data

Now that we have the data properly imported into R, it needs to be cleaned and prepared for further use. Typically, the first step I take in prepping a dataframe is to clean the names of the columns, which are often not suitable by default. This is an important step, because the column names are also the names of the variables within the tibble, so they need to be easy to work with and keep track of.

The [amazingly useful janitor package](https://cran.r-project.org/web/packages/janitor/vignettes/janitor.html) has many convenient functions to automate typical data cleaning and prep tasks, including the `clean_names()` function, which automatically changes column names into more R and data science friendly versions. 

After cleaning the names up, the next step is to select, and rename if needed, the tibble columns required for further use. We can use `dplyr`'s `select()` function, also part of `tidyverse`, to do just that. By default, `select` will return just the columns that are used as arguments to the function, in the order that they are called. When renaming tibble columns during selecting, the format is `new variable name = old variable name`. 

{{% callout note %}}
By highlighting your code pressing Ctrl + A, RStudio will automatically format the code block into something neat and tidy like below.  
{{% /callout %}}


```r
# Clean the names
lobby_main2021 <- clean_names(dat = lobby_main_raw, case = 'snake')

# Select and re-name the columns
lobby_main2021 <- select(.data = lobby_main2021,
         id = reg_id_enr, 
         ref_date = posted_date_publication,
         corp = en_client_org_corp_nm_an,
         corp_fr = fr_client_org_corp_nm,
         client_org_corp_tel)

lobby_main2021
```

```
## # A tibble: 117,195 x 5
##        id ref_date  corp                 corp_fr                client_org_corp~
##     <dbl> <chr>     <chr>                <chr>                  <chr>           
##  1 484710 null      Régie intermunicipa~ null                   4182332766      
##  2 484262 null      P.R. Maintenance in~ null                   8005045999      
##  3 501724 null      Régie intermunicipa~ null                   4182332766      
##  4 501723 null      P.R. Maintenance in~ null                   8005045999      
##  5 502662 null      DK-SPEC Inc.         null                   4188313333      
##  6 510107 null      The Canadian Societ~ La Société canadienne~ 6046018264      
##  7 513341 null      The Canadian Societ~ La Société canadienne~ 6046018264      
##  8 515729 2008-07-~ The Canadian Societ~ La Société canadienne~ 6046018264      
##  9 501577 null      The Canadian Societ~ La Société canadienne~ 6046018264      
## 10 484394 null      The Canadian Societ~ La Société canadienne~ 6046018264      
## # ... with 117,185 more rows
```

Above, we preserve our changes to the data by overwriting the original object with each function call. In order to avoid having to code this way, we can use pipes to work much more efficiently. The pipe operator `%>%` from the `magrittr` package, automatically loaded with the `tidyverse`, carries the output of the function into the first argument of the following function. Doing so, we can chain multiple function calls together under one assignment. If you are new to coding in the Tidyverse, it's worth checking out this [short primer on using pipes](https://style.tidyverse.org/pipes.html).   

Below, the `dplyr::mutate()` is used with the base R function `as.Date()` to convert the date column from character to the date type, then extract the year from the date column using the `year()` function from the `lubridate` package. The output of that function is a dataframe with the altered or new columns, which is piped directly into the `dplyr::filter()` function (you guessed it: also part of the `tidyverse`) to select only the rows of the data according to the years 2020 and 2021. 

{{% callout note %}}
Whenever you want to check for the presence of an object in a vector or list of objects, you can use the `%in%` operator. 
{{% /callout %}}


```r
lobby_main2021 <- lobby_main2021 %>%
  mutate(
    ref_date = as.Date(ref_date, format = "%F"),
    ref_year = year(ref_date)) %>%
  filter(ref_year %in% c(2020, 2021))
```

Now, apply a similar process of importing, inspecting, selecting and renaming, and filtering to prepare the lobby registry data on government subsidy amounts to be joined to the main extract. When using `select`, columns can be chosen many ways, including by the numerical order of appearance in the data, as below. 

The parsing failure report when importing the `.csv` file tells us that there are missing values in the subsidy amount column encoded as the string "null." Since `readr` expects this column to be numeric, it automatically parses the strings as `NA`. Upon closer examination of the resulting tibble, it looks like the only rows with missing values are government ministries, crown corporations, or other public entities. Missing data makes sense, since the government cannot subsidize itself.


```r
lobby_fund <- read_csv(here('ds4cs_working','posts','l1_cews_lesson','data','Registration_GovtFundingExport.csv')) %>% 
  select(id = 1, source = 2, subsidy = 3)
```

```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   REG_ID_ENR = col_double(),
##   INSTITUTION = col_character(),
##   AMOUNT_MONTANT = col_double(),
##   FUNDS_EXP_FIN_ATTENDU = col_character(),
##   TEXT_TEXTE = col_character()
## )
```

```
## Warning: 3993 parsing failures.
##   row            col expected actual                                                                                                                 file
##  5764 AMOUNT_MONTANT a double   null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_GovtFundingExport.csv'
##  5766 AMOUNT_MONTANT a double   null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_GovtFundingExport.csv'
##  5767 AMOUNT_MONTANT a double   null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_GovtFundingExport.csv'
##  6348 AMOUNT_MONTANT a double   null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_GovtFundingExport.csv'
## 13205 AMOUNT_MONTANT a double   null 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/Registration_GovtFundingExport.csv'
## ..... .............. ........ ...... ....................................................................................................................
## See problems(...) for more details.
```

### Filtering a dataframe by a vector of strings

The next step is to filter the lobbyist funding tibble to contain only the sources of funding that we are concerned with, in this case, related to the CEWS. Inspecting the original data extract, it seems that some registrations specifically cite some variation of pandemic-related wage subsidy, e.g., "CEWS" or just "Wage subsidy", while other confirmed CEWS recipients list only the Canada Revenue Agency as their sole source of funding for the year.

Here is a simple and effective trick to filter a dataframe using a character vector of terms. Simply `paste()` the list of vectors together using the `collapse = "|"` argument, which is the regular expression logical `OR` operator. Using a regular expression denoting all characters after, `".*"`, the many different spellings/labels for the CRA, which all start the same way, are picked up in the filter.


```r
## Create a vector of funding sources to filter the dataframe by by
source_filter <- paste(c('Canada Revenue.*', 'Wage subsidy', 'CEWS', 'COVID Wage Subsidy'), collapse = "|")
source_filter
```

```
## [1] "Canada Revenue.*|Wage subsidy|CEWS|COVID Wage Subsidy"
```

The pasted vector can be used as the `pattern` argument to the function `str_detect()` from `stringr` within `filter` to keep only the rows containing terms in the filter. If you wanted to use this method to filter **out** the list of terms, simply add the `negate = TRUE` argument to the `str_detect` call.


```r
lobby_fund <- lobby_fund %>% 
    filter(str_detect(source, source_filter),
           source != "Canada Revenue Agency - Scientific Research and Experimental Development tax credit program")
```

### Joining dataframes and removing missing values

Finally, the main extract from the lobby registry can be merged with the subsidy data. Joining tables together like this is an essential and incredibly common step in the data wrangling work flow. There are many methods for joining or merging data in R, though I find myself using `dplyr::join_` functions the most frequently.

Join functions link dataframes together on the basis of one or more shared variables. Often, as is the case with the Lobby Registry extract, the tables feature a unique ID key that link all of the ``.csv`` files together. If you are new to using joins, this [brief chapter on the topic](https://rafalab.github.io/dsbook/joining-tables.html) might be useful.  

After joining the main and funding tibbles together, any rows with missing data for the source or amount of subsidy are filtered out by combining the `not` operator `!` with the base R function to detect missing values `is.na()`. So values of x that are **not** missing would be `!is.na(x)`.


```r
lobby_full <- lobby_main2021 %>% 
  left_join(lobby_fund, by = 'id') %>% 
  filter(!is.na(source), !is.na(subsidy))
```

Since joins gone awry are a common cause of problems down the road, it's worth doing some quick checks to make sure the merging went successfully. In this case, we'll just take a more detailed look at the data using the `tibble::view()` function.


```r
view(lobby_full)
```

### De-duplication of joined tables

De-duplication is yet another very common and often tedious data wrangling task, often arising when joins go wrong (or sometimes even when they work as intended). We can see by manually inspecting the data that there are many rows duplicated by company, year, and subsidy amount. The reason for this is that companies can have multiple lobbyists registered on their behalf concurrently and each registrant would report the same subsidy amount. 

First, we'll standardize the company names to title case using `str_to_title` from `stringr`. Following that, two calls to `dplyr::distinct()` will de-duplicate most of the data, giving us only one relevant row per company. The first call removes duplicate entries referring to the same companies with different names/spellings by their shared phone number. The second call removes the duplicated subsidy rows by company for each year. 

{{% callout note %}}
Usually, you will want to keep the rest of your data after de-duplicating. To do so, it's important to remember to include the `.keep_all = TRUE` argument to `distinct()`.
{{% /callout %}}


```r
lobby_full <- lobby_full %>% 
  mutate(corp = str_to_title(corp)) %>% 
  distinct(corp, ref_year, client_org_corp_tel, .keep_all = TRUE) %>% 
  distinct(corp, subsidy, .keep_all = TRUE) 
```

Finally, we'll do a bit more de-duping by creating a vector of corporation names that we didn't catch with the shared-phone number method, as well as other unwanted rows like non-profit entities, filtering those rows out using the not operator `!` and the `%in%` operator together within the call to `filter()`. We'll also remove airports using `str_detect` and `negate = TRUE`. Finally, take the top 50 companies by amount of subsidy received with `dplyr::slice_max()` and select only relavent columns.
 

```r
dupes_or_nonprof <- c('Organigram Inc.', 'Rogers Communications Canada Inc.', 'Rogers Communications Inc.', 'Rogers Communication Inc.', 'Suncor Energy Inc./Suncor Énergie Inc.', 'Toyota Canada Inc. (through Casacom)', 'Heritage Park Society', 'Great Canadian Railtour Company Ltd.', 'NAV CANADA', 'Toronto International Film Festival', 'Stratford Shakespearean Festival of Canada', 'Canada Malting Co.', "Null", "Cameco Corporation")
  
lobby_full <- lobby_full %>% 
  filter(!corp %in% dupes_or_nonprof,
        str_detect(corp, "Airport", negate = TRUE)) %>%
  slice_max(subsidy, n = 50) %>% 
  select(id, ref_date, corp, ref_year, source, subsidy)
```

Use the object's name to print and inspect the tibble before moving on.


```r
lobby_full
```

```
## # A tibble: 50 x 6
##        id ref_date   corp                   ref_year source              subsidy
##     <dbl> <date>     <chr>                     <dbl> <chr>                 <dbl>
##  1 914017 2021-07-15 Air Canada                 2021 Canada Revenue Ag~   5.86e8
##  2 911084 2021-04-15 Suncor Energy Inc.         2021 Canada Revenue Ag~   3.58e8
##  3 911062 2021-08-09 Magna International I~     2021 Canada Revenue Ag~   2.37e8
##  4 908834 2021-02-16 Canadian Natural Reso~     2021 Canada Revenue Ag~   1.93e8
##  5 909811 2021-03-15 Imperial Oil Limited       2021 Canada Revenue Ag~   1.56e8
##  6 908767 2021-02-15 Fca Canada Inc.            2021 Canada Revenue Ag~   1.41e8
##  7 912222 2021-06-02 Bce Inc.                   2021 Canada Revenue Ag~   1.23e8
##  8 913181 2021-06-15 Transat A.t. Inc.          2021 Canada Revenue Ag~   1.14e8
##  9 913576 2021-07-06 Honda Canada Inc.          2021 Canada Revenue Ag~   9.32e7
## 10 908296 2021-02-02 Ford Motor Company Of~     2021 Canada Revenue Ag~   8.70e7
## # ... with 40 more rows
```

Everything appears to be in order. Now would be a good time to save this data externally for future use. The full lobbying data tibble is written to the local disk as an R data file with the extension `.rds`, again using the `write_rds` function, which is also from `readr`.


```r
write_rds(lobby_full, here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'lobby_full.rds')) 
```

## Wrangling summary level CEWS data from the Canada Revenue Agency

It's often the case that in order to do a thorough analysis, one needs to bring together data from multiple sources. We got detailed data on corporate recipients of the CEWS from the National Lobby Registry data. [Summary level data on the CEWS is also available, this time from the Canada Revenue Agency](https://www.canada.ca/en/revenue-agency/services/subsidy/emergency-wage-subsidy/cews-statistics/stats-detailed.html). Looking through the list of tables, we can see they provide data on the disbursement of CEWS by both industry and enterprise size in two different files. 

Below, we read in the `.csv` for table [table 2](https://www.canada.ca/content/dam/cra-arc/serv-info/tax/business/topics/cews/statistics/cews_p1-p19_tbl2_ac_e`.csv`), CEWS by enterprise size, skipping the first line of the csv file to properly situate the header. Inspecting either the original file or dataframe after importing, we can see that some notes that aren't part of the table have been read in under the `claim_period` column. That's what the `readr` parsing error tells us as well, since the function didn't find any other columns when it picked up the notes under the table. Drop the notes by filtering for only rows that start with P by using `str_detect` and the regular expression `"^P"`, then filter out the total and missing rows from the `naics` column. 


```r
cews_naics <- read_csv(here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'cews_by_industry.csv'), skip = 1) %>% 
  clean_names('snake') %>%
  select(claim_period, naics = 2, cews = cews_amount_approved_since_launch) %>% 
  filter(
    str_detect(claim_period, "^P"),
    str_detect(naics, "Total|Missing", negate = TRUE))
```

```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   `Claim Period` = col_character(),
##   `Industry (Statistics Canada NAICS)` = col_character(),
##   `Applications Approved Since Launch` = col_double(),
##   `Number of Eligible Employees (Line A)` = col_character(),
##   `Number of Eligible Employees on Leave with Pay (Line AA)` = col_character(),
##   `Number of Employees Supported by the Program (Line A + Line AA)` = col_character(),
##   `CEWS Amount Approved Since Launch` = col_double(),
##   `Average CEWS Amount per Employee` = col_character(),
##   `Percent Distribution of Approved Applications for Each Claim Period` = col_double()
## )
```

```
## Warning: 13 parsing failures.
## row col  expected    actual                                                                                                   file
## 420  -- 9 columns 1 columns 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/cews_by_industry.csv'
## 421  -- 9 columns 1 columns 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/cews_by_industry.csv'
## 422  -- 9 columns 1 columns 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/cews_by_industry.csv'
## 423  -- 9 columns 1 columns 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/cews_by_industry.csv'
## 424  -- 9 columns 1 columns 'C:/Users/Ryan/Documents/rromard_website/ds4cs_working/posts/l1_cews_lesson/data/cews_by_industry.csv'
## ... ... ......... ......... ......................................................................................................
## See problems(...) for more details.
```

### Reading files directly from a URL

The `read_csv` function can also read online files directly from a URL. Just supply the URL, instead of a file path on your computer, as the path argument. Below, we download a `.csv` file containing summary data on the CEWS by industry, read it in as a tibble, clean the column names, select and rename relevant columns, then filter the data. 


```r
cews_size_url <- "https://www.canada.ca/content/dam/cra-arc/serv-info/tax/business/topics/cews/statistics/cews_p1-p19_tbl3_e.csv"

cews_size <- read_csv(cews_size_url, skip = 1) %>% 
  clean_names('snake') %>% 
  select(1:3, 
         applications = applications_approved_since_launch,
         subsidy = cews_amount_approved_since_launch,
         pct_total = last_col()) %>% 
  
  # Don't forget, R is case sensitive!
  filter(claim_period == "All Periods", 
         !size_of_applicant %in% c('All Firm Sizes', 'Not Available'))
```

```
## 
## -- Column specification --------------------------------------------------------
## cols(
##   `Claim Period` = col_character(),
##   `Size of Applicant` = col_character(),
##   `Applications Approved Since Launch` = col_character(),
##   `Number of Eligible Employees (Line A)` = col_character(),
##   `Number of Eligible Employees on Leave with Pay (Line AA)` = col_character(),
##   `Number of Employees Supported by the Program (Line A + Line AA)` = col_character(),
##   `CEWS Amount Approved Since Launch` = col_character(),
##   `Average CEWS Amount per Employee` = col_character(),
##   `Percent Distribution of Approved Applications for Each Claim Period` = col_character()
## )
```

### Using across to transform multiple columns

Combing over the resulting tibble, it looks like we have some mismatched column types, numbers stored as strings in this case. Data type mishaps are another very common source of bother in data science workflows. Both the percent of total and subsidy amount variables are converted to actual numbers using `mutate` and `as.numeric()`. Note that by using `across` within mutate, the function can be applied to any columns supplied as an argument to `across`.

Now that the subsidy amount is treated as a number, we can calculate the percent of the total subsidies received by each firm size with the simple formula `x/sum(x)`. Despite being under 2% of applications, large firms with over 250 employees took in a third of CEW subsidies.


```r
cews_size <- cews_size %>% 
  mutate(
    across(c(subsidy, pct_total), as.numeric),
    pct_total_subsidy = round(subsidy/sum(subsidy), digits = 3))
```

Write both files for safekeeping and further use.


```r
# CEWS by industry
write_rds(cews_size, here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'cews_naics.rds')) 
# CEWS by enterprise size
write_rds(cews_size, here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'cews_size.rds')) 
```

## Making creative connections across distant datasets

One step in the data wrangling process remains. This is the step that can take a basic analysis to another level: **creatively making connections between different sources of data**. Any two data sets with at least one set of common features can be joined together in some manner. In this case, we have CEWS data by industry according to [NAICS (North American Industry Classification System)](https://www23.statcan.gc.ca/imdb/p3VD.pl?Function=getVD&TVD=1181553) codes from the CRA. Due to my prior work in survey research, I was already aware that there is a fair amount of data out there tagged by NAICS code. Searching for other sources of NAICS-level data turned up StatCan tables featuring summary data on corporate quarterly balance sheets. By joining these tables, it's possible to compare CEWS received to net profits at the industry level.

### Importing Statistics Canada data with the `cansim` package

For those researching the settler colonial-capitalist entity of Canada, there is an great abundance of open data on a huge number of topics available through Statistics Canada. Using the truly excellent [cansim package](https://cran.r-project.org/web/packages/cansim/vignettes/cansim.html), it's possible to import StatCan's CANSIM tables directly into an R session with the `get_cansim()` function. Below, we read in the [industry quarterly balance sheet table](https://www150.statcan.gc.ca/t1/tbl1/en/tv.action?pid=3310022601) by providing the table number as an argument. 



```r
library(cansim)
library(zoo)
```

```
## 
## Attaching package: 'zoo'
```

```
## The following objects are masked from 'package:base':
## 
##     as.Date, as.Date.numeric
```

```r
profits_naics_raw <- get_cansim('33-10-0226-01') %>%  # major NAICS categories 
  clean_names() %>%
  select(ref_date, naics = 4, naics_code = 18, components = 5, value) 
```

```
## Accessing CANSIM NDM product 33-10-0226 from Statistics Canada
```

```
## Parsing data
```

```
## Folding in metadata
```

From there, we fix up the date by converting from a character to date type, this time using the `as.yearmon()` function from the `zoo` package, extract the year from the date object, and then use `parse_number()` to remove non-digit characters from the column containing the NAICS codes.


```r
profits_naics <- profits_naics_raw %>% 
  mutate(ref_date = as.yearmon(ref_date), 
         ref_year = year(ref_date), 
         naics_code = parse_number(naics_code)) %>%
  filter(ref_year %in% c(2020, 2021),
         components == 'Net income or loss')
```

### Joining data sets with mismatched key columns

Taking a look at the NAICS categories used in both dataframes reveals the major challenge in combining these data sets: the categories are mismatched. The CEWS data from the CRA is aggregated by the 20 major NAICS groups, while the quarterly balance sheets are disaggregated by industry with dozens of categories. As is, it's impossible for these tables to be fully combined.


```r
list(unique(cews_naics$naics), unique(profits_naics$naics))
```

```
## [[1]]
##  [1] "11 Agriculture, Forestry, Fishing & Hunting"                       
##  [2] "21 Mining, quarrying, and oil and gas extraction"                  
##  [3] "22 Utilities"                                                      
##  [4] "23 Construction"                                                   
##  [5] "31-33 Manufacturing"                                               
##  [6] "41 Wholesale Trade"                                                
##  [7] "44-45 Retail Trade"                                                
##  [8] "48-49 Transportation & Warehousing"                                
##  [9] "51 Information & Cultural Industries"                              
## [10] "52 Finance & Insurance"                                            
## [11] "53 Real Estate & Rental & Leasing"                                 
## [12] "54 Professional, Scientific & Technical Services"                  
## [13] "55 Management of Companies & Enterprises"                          
## [14] "56 Administrative Support, Waste Management & Remediation Services"
## [15] "61 Education Services"                                             
## [16] "62 Health Care & Social Assistance"                                
## [17] "71 Arts, Entertainment & Recreation"                               
## [18] "72 Accommodation & Food Services"                                  
## [19] "81 Other Services, except Public Administration"                   
## [20] "91 Public Administration"                                          
## 
## [[2]]
##  [1] "Total, all industries"                                                                                                      
##  [2] "Total, non-financial industries"                                                                                            
##  [3] "Agriculture, forestry, fishing and hunting [11]"                                                                            
##  [4] "Oil and gas extraction and support services"                                                                                
##  [5] "Mining and quarrying (except oil and gas) and support activities"                                                           
##  [6] "Utilities [22]"                                                                                                             
##  [7] "Construction [23]"                                                                                                          
##  [8] "Food and soft drink and ice manufacturing"                                                                                  
##  [9] "Alcohol beverage, tobacco and cannabis product manufacturing"                                                               
## [10] "Wood product and paper manufacturing"                                                                                       
## [11] "Petroleum and coal product manufacturing [324]"                                                                             
## [12] "Basic chemical manufacturing and resin, synthetic rubber, and artificial and synthetic fibres and filaments manufacturing"  
## [13] "Pharmaceutical and medecine manufacturing, and soap, agricultural chemicals, paint and other chemical product manufacturing"
## [14] "Plastics and rubber products manufacturing [326]"                                                                           
## [15] "Non-metallic mineral product manufacturing [327]"                                                                           
## [16] "Primary metal and fabricated metal product and machinery manufacturing"                                                     
## [17] "Computer and electronic equipment manufacturing [334]"                                                                      
## [18] "Motor vehicle and trailer manufacturing"                                                                                    
## [19] "Motor vehicle parts manufacturing [3363]"                                                                                   
## [20] "Aerospace, rail and ship products and other transportation equipment manufacturing"                                         
## [21] "Clothing, textile, leather and furniture manufacturing, and other manufacturing"                                            
## [22] "Motor vehicle and motor vehicle parts and accessories merchant wholesalers [415]"                                           
## [23] "Building material and supplies merchant wholesalers [416]"                                                                  
## [24] "Machinery, equipment and supplies merchant wholesalers [417]"                                                               
## [25] "Other wholesalers"                                                                                                          
## [26] "Motor vehicle and parts dealers [441]"                                                                                      
## [27] "Food and beverage stores [445]"                                                                                             
## [28] "Clothing, sporting goods, and general merchandise stores"                                                                   
## [29] "Other retailers"                                                                                                            
## [30] "Transportation, postal and couriers services, and support activities for transportation"                                    
## [31] "Pipelines [486]"                                                                                                            
## [32] "Warehousing [493]"                                                                                                          
## [33] "Publishing, motion picture and sound recording, broadcasting, and information services"                                     
## [34] "Telecommunications [517]"                                                                                                   
## [35] "Real estate [531]"                                                                                                          
## [36] "Rental and leasing of automotive, machinery and equipment, and other goods"                                                 
## [37] "Professional, scientific and technical services [54]"                                                                       
## [38] "Administrative and support, waste management and remediation services [56]"                                                 
## [39] "Educational, health care and social assistance services"                                                                    
## [40] "Arts, entertainment and recreation, and accommodation and food services"                                                    
## [41] "Repair, maintenance and personal services"                                                                                  
## [42] "Total, finance and insurance industries"                                                                                    
## [43] "Banking and other depository credit intermediation"                                                                         
## [44] "Local credit unions [5221130]"                                                                                              
## [45] "Credit card issuing, sales financing and consumer lending"                                                                  
## [46] "All other non-depository credit intermediation [522299]"                                                                    
## [47] "Central credit unions [522321]"                                                                                             
## [48] "Financial transactions processing, loan brokers, and other activities related to credit intermediation"                     
## [49] "Securities and commodity contracts dealing"                                                                                 
## [50] "Securities and commodity brokerage"                                                                                         
## [51] "Miscellaneous Intermediation [523910]"                                                                                      
## [52] "Securities and commodity exchanges, portfolio management and miscellaneous financial investment activity"                   
## [53] "Life, health and medical insurance carriers"                                                                                
## [54] "Property and casualty insurance carriers"                                                                                   
## [55] "Agencies, brokerages and other insurance related activities [5242]"
```

### Recoding many variable levels with `case_when`

However, using the inherent hierarchy of the NAICS numerical codes, it's possible to aggregate the many NAICS categories from the balance sheet data into the 20 major categories used in the other data. First off, looking at the balance sheet tibble, notice that several industries already have the major group numeric code in the column `naics_code`. Joining on those values should be no problem.

Aggregating the industries without the pre-existing numeric NAICS codes will be a bit trickier. If I only have to do it a few times in a project, I like to use a vector of unique values as a lookup along with `mutate` and `case_when` from `dplyr` to solve this problem. First, isolate a list of industries with missing code data.

{{% callout note %}}
If you need to extract a specific tibble column from a series of piped calls, use `.` to return the whole tibble object, then subset it (using `$` in this case) to access the column, like below.
{{% /callout %}}


```r
# Isolate a list of unique NAICS codes from the balance sheet data 
inds <- profits_naics %>% 
  filter(is.na(naics_code)) %>% 
  .$naics %>% unique()
```

By using `inds` as a look-up vector within `mutate` and `case_when`, it's possible to do complex recoding of data columns. Going down the vector of NAICS sectors sequentially, I am subsetting the vector `inds` with the base R subsetting operator `[` and using the `%in%` operator for multiple NAICS groups and using `~` to assign the corresponding NAICS major group code as the value, which is [easily looked up online](https://www23.statcan.gc.ca/imdb/p3VD.pl?Function=getVD&TVD=1181553). 

Note that it's important to include `TRUE ~ as.character(naics_code)` as the final argument to `case_when` in order to leave the rest of the data that isn't being re-coded as it is. Additionally, remember that anything that changes the order of the vector of industry names will break this, since the industries are referenced by numerical index `inds[n]` and not name. 


```r
profits_naics <- profits_naics %>% 
  mutate(
    naics_code = case_when(
      naics %in% inds[c(3, 4)] ~ '22', # oil and gas, mining and quarrying
      str_detect(naics, 'manufacturing') ~ '33', # manufacturing
      naics == inds[14] ~ '41', # whole sale trade
      naics %in% inds[c(15, 16)] ~ '44', # retail,
      naics == inds[17] ~ '48', # transportation, warehousing, by root only
      naics == inds[18] ~ '51', # arts, information
      naics == inds[19] ~ '532', # rentals of equipment
      naics == inds[20] ~ '61', # health/education, by root only
      naics == inds[21] ~ '72', # arts, entertainment, food service, by root only
      naics %in% inds[c(24:32)] ~ '52', # banking, insurance, finance
      TRUE ~ as.character(naics_code)
  ))
```

NAICS has a heirarchal structure, so the first digit is always the broad industry group, the second is always the major group, and so on. Now we can break down the NAICS codes into a root, major group, and subgroup code, using `mutate` and `stringr::substr()` to create a new column for each. 


```r
profits_naics <- profits_naics %>% 
  mutate(
    naics_root_code = substr(naics_code, 1, 1),
    naics_maj_code = substr(naics_code, 1, 2),
    naics_sub_code = substr(naics_code, 1, 3)
  )
```

Now that were joining on the numerical NAICS codes, we'll also need to touch up the CEWS summary-level data with some regular expressions. Industry codes as numbers are extracted from `naics` using `str_extract()` and the regular expression for digits, while the text description of the industry is extracted using the regular expression for letters.


```r
cews_naics <- cews_naics %>% 
  mutate(industry_code = str_extract(naics, "[:digit:]+"),
         naics = str_extract(naics, "[A-Z]+.*")) %>% 
  select(claim_period, naics, industry_code, cews)
```

### Finally: Joining the CEWS and balance sheet data

The data is almost ready for joining. Once again, `case_when` is used to create a final column of text labels to join the two tables by and also serve as the shortened industry labels in the data visualizations. Filter out any rows with a missing NAICS code.


```r
profits_naics <- profits_naics %>% 
  mutate(naics_final = case_when(
    naics_maj_code == '11' ~ 'Agriculture/forestry/fishery/hunting',
    naics_maj_code == '21' ~ 'Mining, quarrying, oil and gas',
    naics_maj_code == '22' ~ 'Utilities',
    naics_maj_code == '23' ~ 'Construction',
    naics_root_code == '3' ~ 'Manufacturing',
    naics_maj_code == '41' ~ 'Wholesale',
    naics_maj_code %in% c('44', '45') ~ 'Retail trade',
    naics_maj_code %in% c('48', '49') ~ 'Transportation/warehousing',
    naics_maj_code == '51' ~ 'Information/cultural',
    naics_maj_code == '52' ~ 'Finance/insurance',
    naics_maj_code == '53' ~ 'Real estate/rental',
    naics_maj_code == '54' ~ 'Professional/scientific/technical',
    naics_maj_code == '56' ~ 'Admin/support/waste management',
    naics_maj_code %in% c('61', '62') ~ 'Education/health/social assistance',
    naics_root_code == '7' ~ 'Arts/Acc/Food/Ent/Rec')) %>%
  filter(!is.na(naics_final))
```

Do the exact same procedure to the CEWS by industry summary data. If this was something one had to do more than twice, it would be worth writing a custom function to do this more efficiently. A topic for another day.


```r
cews_naics <- cews_naics %>% 
  mutate(naics_final = case_when(
    industry_code == '11' ~ 'Agriculture/forestry/fishery/hunting',
    industry_code == '21' ~ 'Mining, quarrying, oil and gas',
    industry_code == '22' ~ 'Utilities',
    industry_code == '23' ~ 'Construction',
    industry_code == '31' ~ 'Manufacturing',
    industry_code == '41' ~ 'Wholesale',
    industry_code %in% c('44', '45') ~ 'Retail trade',
    industry_code %in% c('48', '49') ~ 'Transportation/warehousing',
    industry_code == '51' ~ 'Information/cultural',
    industry_code == '52' ~ 'Finance/insurance',
    industry_code == '53' ~ 'Real estate/rental',
    industry_code == '54' ~ 'Professional/scientific/technical',
    industry_code == '56' ~ 'Admin/support/waste management',
    industry_code %in% c('61', '62') ~ 'Education/health/social assistance',
    industry_code %in% c('71', '72') ~ 'Arts/Acc/Food/Ent/Rec'))  %>% 
  filter(!is.na(naics_final))
```

### Grouping and summarizing data

Now, both data sets have a common column, `naics_final` that they can be joined on. Since both data are provided at different sub-yearly intervals (monthly versus quarterly), we'll have to summarize both tables by year before joining them together. Grouping and summarizing data is an essential skill required for most data science projects. Using R, data can be grouped with `dplyr::group_by()`, allowing most operations on grouped dataframes to be applied to the chosen groups. Use `dplyr::summarize()` with `group_by()` in order to aggregate data according to the specified function, in this case, using `sum(x, na.rm = TRUE)` to get the total yearly subsidy and profit amounts for each industry.


```r
cews_naics <- cews_naics %>% 
  group_by(naics_final) %>% 
  summarize(subsidy = sum(cews, na.rm = TRUE))
  
profits_naics <- profits_naics %>% 
  group_by(naics_final) %>% 
  summarize(net_profits = sum(value, na.rm = TRUE))
```

At long last, we can join the CEWS and quarterly profit data together!


```r
cews_profits <- profits_naics %>% 
  left_join(cews_naics, by = 'naics_final')
```

Last, but not least, there are a few quick calculations to make before saving the data for visualization. The dollar units of `profit` and `subsidy` are out of sync, the former is in millions of dollars, while the latter is in just dollars. We can remedy this by multiplying `net_profits` by 10 to the power of 6. We can then calculate what percent of net profits each industry took in from the CEWS by dividing the subsidy by net profits. 

Finally, convert `naics_final` to a factor, use `fct_reorder()` from `forcats` to set the factor levels in descending order of the subsidy amount (for visualization purposes), arrange the dataframe in the same order. To finish, filter out the finance and insurance sector, which took in very little of CEWS, but got a massive bailout by other means from the Canadian government. Finish by saving the object for visualization. In the next post, I will show how to turn the R data objects saved during this lesson into the [data visualizations featured in the story](http://localhost:4321/post/cews-a-scandalous-gift-to-capital/).


```r
cews_profits <- cews_profits %>% 
  mutate(
         net_profits = net_profits * 10^6,
         pct_profits = subsidy / net_profits,
         naics_final = as_factor(naics_final),
         naics_final = fct_reorder(naics_final, subsidy, .desc = T)) %>% 
  arrange(-subsidy) %>% 
  filter(naics_final != "Finance/insurance")

cews_profits
```

```
## # A tibble: 13 x 4
##    naics_final                           net_profits     subsidy pct_profits
##    <fct>                                       <dbl>       <dbl>       <dbl>
##  1 Manufacturing                         66407000000 16398789000     0.247  
##  2 Construction                          51026000000 11274636000     0.221  
##  3 Arts/Acc/Food/Ent/Rec                 -5013000000 10584779000    -2.11   
##  4 Professional/scientific/technical     12444000000  8440205000     0.678  
##  5 Retail trade                          32556000000  6898995000     0.212  
##  6 Wholesale                             48206000000  6524043000     0.135  
##  7 Education/health/social assistance    27736000000  6156076000     0.222  
##  8 Transportation/warehousing             5306000000  5933819000     1.12   
##  9 Admin/support/waste management         8466000000  4412868000     0.521  
## 10 Information/cultural                  17490000000  2346207000     0.134  
## 11 Real estate/rental                    36691000000  1633529000     0.0445 
## 12 Agriculture/forestry/fishery/hunting   6652000000  1462767000     0.220  
## 13 Utilities                            -20878000000    52907000    -0.00253
```

```r
write_rds(cews_profits, here('ds4cs_working', 'posts', 'l1_cews_lesson', 'data', 'cews_profits.rds')) 
```
