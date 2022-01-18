---
title: Peering into Marx's Critique of Political Economy with Text Analysis using Quanteda
author: ''
date: '2021-12-30'
slug: peering-into-marx-s-critique-of-political-economy-with-basic-text-analysis
categories: []
tags: ['Text analysis']
subtitle: ''
summary: ''
authors: []
lastmod: '2021-12-30T23:29:08-05:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
type: book
weight: 20
---
<script src="{{< blogdown/postref >}}index_files/kePrint/kePrint.js"></script>
<link href="{{< blogdown/postref >}}index_files/lightable/lightable.css" rel="stylesheet" />





Welcome to Unit 2 of *Using Text as Data with R to Advance the Cause of Socialism*! In the first unit, we covered the basics of tidy text scraping, cleaning and processing with the `tidytext` package in order to put together a machine readable text corpus of all three volumes of Marx's Capital from the Marxists Internet Archive. This unit demonstrates how to do basic manipulation and analysis of text using the [Quanteda package](https://quanteda.io/). I know that in the previous unit, I droned on about the virtues of a tidy approach to text data with `tidytext`, but `quanteda` has so many excellent tools for working with text and is relatively easy to pick up and learn how to use out of the box. Besides, as you will soon see for yourself, `quanteda` really plays well with a tidy approach to text-data.

The following tutorial demonstrates how to use `quanteda` to clean, manipulate, analyze, and visualize text-as-data, using the corpus of Marx's Capital (or CC for Capitals Corpus) as raw material. We'll cover how to analyze texts with term frequencies, measures of document distinctiveness like tf-idf or keyness, simple word scaling models, and how to see text keywords in local context. In the process, we'll also show how to clean and prepare text for use with `quanteda`, work with different types of objects used by `quanteda`, cover useful features added by `quanteda` extensions, and tidy `quanteda` output for visualization with `ggplot2`.

For now, the learning will focus on what can be done with text-as-data without using sophisticated modeling or intense machine learning tools. Think of it as a *modeling light* approach to text analysis. Don't worry, we'll get to the fancy stuff, but another day! As the lesson in text analysis unfolds, I hope that we can benefit beginners to data science and Marxism alike by uncovering at least a few *minor* insights into Marx's critique of capitalist political economy (or CPE for short).

#### Header on Quanteda

Quanteda is a one-stop-shop package for the quantitative analysis of text data developed by a team of academic experts in text analysis. Actually, rather than just one package, it's more accurate to refer to a Quanteda ecosystem of packages that share a [design philosophy](https://quanteda.io/articles/pkgdown/design.html) and consistent user interface. The [base package]((https://quanteda.io/)) provides most of the functionality, with package extensions that add more features for text-based [statistics](https://cran.r-project.org/web/packages/quanteda.textstats/index.html), [modeling and scaling](https://cran.r-project.org/web/packages/quanteda.textmodels/index.html) and [visualization](https://cran.r-project.org/web/packages/quanteda.textplots/index.html). Quanteda has [extensive documentation](https://tutorials.quanteda.io/) that anyone interested in learning the program should read. A handy cheat sheet for Quanteda functions can be [found here](https://muellerstefan.net/files/quanteda-cheatsheet.pdf).

{{< toc hide_on="xl" >}}

## Preparing a corpus from a collection of html texts

We'll start by importing an R data file containing the raw html texts containing all of Marx's major works on political economy. In the first unit, we scraped and assembled the volumes of Capital from the Marxists Internet Archive. Below, we import the corpus as raw html texts using `readr::read_rds()`, remove the link to the html webpage, and create a variable to uniquely identify each chapter of each book by pasting the title and chapter together with `glue()` form the aptly named `glue` package. The result is a tibble with one row of text for each paragraph of text on the web page, along with associated metadata on the book title and chapter number.

{{< callout note >}}

In the first unit, we assembled a corpus containing the three volumes of Capital from the Marxists Internet Archive. If you want to follow along or try your own analysis on the CC without scraping it from scratch, you can [**download the original texts right here**](html_texts.rds).

{{< /callout >}}


```r
cpe_texts <-
  read_rds(
    here(
      'ds4cs_working',
      'courses',
      'c2_text_analysis_capital',
      'data',
      'html_texts.rds')
  )
```

A corpus is just a short hand way of saying a collection of text documents. In the `quanteda` approach to text analysis, the role of the corpus is to be a safe container for the original texts. This makes it possible to easily refer back to the unaltered texts even after extensive text processing and manipulation.

Any workflow with `quanteda` begins at the ground floor by creating a [corpus object](https://tutorials.quanteda.io/basic-operations/corpus/corpus/), which is a [special class](https://quanteda.io/reference/corpus.html) designed to store an original corpus of texts along with associated document-level metadata. There are methods of producing a `quanteda` corpus from raw character vectors, data frames, and corpus objects of other [notable text analysis R packages](https://cran.r-project.org/web/packages/tm/index.html). 

The texts are stored in a dataframe, so we'll go with that method. When creating a corpus from a dataframe, one needs to provide the names of the columns with the document labels and text as strings. By default, `corpus()` expects a **one-document-per-row** format and will throw an error if it finds any duplicates in the document labels. Since we have one-row-per-paragraph, we need to set `unique_docnames = FALSE` in order to import the texts. 


```r
cpe_corpus <- corpus(cpe_texts,
                     docid_field = "book",
                     text_field = "text",
                     unique_docnames = FALSE)

summary(cpe_corpus) %>% 
  head()
```

```
##                Text Types Tokens Sentences chapter         book_chap
## 1 Capital, Vol. I.1    38     47         2       1 Capital, Vol. I_1
## 2 Capital, Vol. I.2    59     84         3       1 Capital, Vol. I_1
## 3 Capital, Vol. I.3    65    104         5       1 Capital, Vol. I_1
## 4 Capital, Vol. I.4   104    203         9       1 Capital, Vol. I_1
## 5 Capital, Vol. I.5    66     98         3       1 Capital, Vol. I_1
## 6 Capital, Vol. I.6    70    158         4       1 Capital, Vol. I_1
```

When importing a corpus without unique document names, `quanteda` treats each row in the dataframe as a sub-document of the document ID variable, appending a numerical index in order of appearance. Internally, `quanteda` knows that these number adorned sub-documents are actually parts of whole documents.


```r
docnames(cpe_corpus) %>% 
  head()
```

```
## [1] "Capital, Vol. I.1" "Capital, Vol. I.2" "Capital, Vol. I.3"
## [4] "Capital, Vol. I.4" "Capital, Vol. I.5" "Capital, Vol. I.6"
```

However, if you check the document level meta-data variables associated with each row in the dataframe using `docvars()`, the variable used to group the documents, `book` in this case, does not show up.


```r
docvars(cpe_corpus) %>% 
  head()
```

```
##   chapter         book_chap
## 1       1 Capital, Vol. I_1
## 2       1 Capital, Vol. I_1
## 3       1 Capital, Vol. I_1
## 4       1 Capital, Vol. I_1
## 5       1 Capital, Vol. I_1
## 6       1 Capital, Vol. I_1
```

The grouping variable is automatically stored as the document ID string, apart from the sub-document label tagged by index, e.g., Capital Volume I.24. To check on the document grouping variable for each row, use the `docid()` function, which will be used frequently to aggregate data by document for calculations, modeling, or plotting.


```r
docid(cpe_corpus) %>% 
  unique()
```

```
## [1] Capital, Vol. I   Capital, Vol. II  Capital, Vol. III
## Levels: Capital, Vol. I Capital, Vol. II Capital, Vol. III
```

### Changing units of text aggregation with `*_group()` functions 

Quanteda has a set of functions to operate on each of the forms of object class that the package implements. Functions made for operating on corpora begin with `corpus_`, those for operating on tokens with `tokens_` and so on. By calling `corpus_group()` on the corpus object without specifying a `groups` argument, the corpus is collapsed down to one document per for format according to the grouping variable. See below as the 10+ thousand row corpus object is condensed into just one row per each `book`.


```r
cpe_corpus %>% 
  corpus_group()
```

```
## Corpus consisting of 3 documents.
## Capital, Vol. I :
## "  The wealth of those societies in which the capitalist mode..."
## 
## Capital, Vol. II :
## "Hence the formula for the circuit of money-capital is: M — C..."
## 
## Capital, Vol. III :
## "The value of every commodity produced in the capitalist way ..."
```

The package authors [explain](https://quanteda.io/articles/pkgdown/design.html) that the only alterations to corpus objects that should be considered is changing the aggregation level of the text. Quanteda has a lot of built in flexibility for [operating at different levels](https://tutorials.quanteda.io/basic-operations/corpus/corpus_reshape/) with text-as-data. Currently, we have the option of working with the paragraph-based corpus as is or grouping the data at another level, such as by book or by book chapters. If we wanted to group the texts by the chapter of each book, we could use `interaction()` to provide both the book titles (through `docid`) and chapter.


```r
cpe_corpus %>% 
  corpus_group(groups = interaction(docid(cpe_corpus), chapter))
```

```
## Corpus consisting of 106 documents and 2 docvars.
## Capital, Vol. I.1 :
## "  The wealth of those societies in which the capitalist mode..."
## 
## Capital, Vol. II.1 :
## "Hence the formula for the circuit of money-capital is: M — C..."
## 
## Capital, Vol. III.1 :
## "The value of every commodity produced in the capitalist way ..."
## 
## Capital, Vol. I.2 :
## "It is plain that commodities cannot go to market and  make e..."
## 
## Capital, Vol. II.2 :
## "Two things are at once strikingly apparent in this form. For..."
## 
## Capital, Vol. III.2 :
## "The capitalist does not care whether it is considered that h..."
## 
## [ reached max_ndoc ... 100 more documents ]
```

Before moving on to tokenize the corpus, we're going to save some issues a few steps down the road by using `gsub()` to replace all of the hyphens in the corpus with underscores. We do this at this step because a `corpus` is just a special class of character vector, so vectorized operations like `gsub()` will work on it. If we tried this on the tokens instead, it would break them and return a normal character vector. If we used something like the `str_` functions from `stringr` it would strip the corpus attributes.


```r
cpe_corpus <- gsub("-", "_", cpe_corpus)
```

### Turning a corpus into tokens

Text needs to be [tokenized](https://nlp.stanford.edu/IR-book/html/htmledition/tokenization-1.html), which essentially means broken down into sub-units, so that it can be read and used by computers. In the first course unit on text scraping, cleaning, and processing with `tidytext`, we tokenized the text into a tidy table with `unnest_tokens()`. Using `quanteda`, we will call the `tokens()` function to transform the text dataframe into a special class of object made to represent a corpus of text tokens. 

According to the Quanteda design philosophy, functions for converting text to tokens and other forms will not remove anything from the text unless explicitly specified. There are many arguments to `tokens` that provide convenient access to functions for cleaning the text as it is tokenized. In this case, we'll remove numbers, punctuation, and symbols from the tokens. 

{{< callout note >}}

Note: Word spacing is one of the few things that `tokens()` will remove by default. It can be retained by setting `padding = TRUE`. For many purposes, it's necessary to keep the spacing between words in the token set. Padding will be needed, for example, to use tokens to create skip-gram windows or to find text keywords in context with `kwic()`.  

{{< /callout >}}


```r
cpe_tokens <- tokens(cpe_corpus, 
                     remove_numbers = TRUE,
                     remove_punct = TRUE,
                     remove_symbols = TRUE,
                     padding = TRUE
                     )

cpe_tokens
```

```
## Tokens consisting of 5,022 documents and 2 docvars.
## Capital, Vol. I.1 :
##  [1] "The"        "wealth"     "of"         "those"      "societies" 
##  [6] "in"         "which"      "the"        "capitalist" "mode"      
## [11] "of"         "production"
## [ ... and 35 more ]
## 
## Capital, Vol. I.2 :
##  [1] "A"         "commodity" "is"        ""          "in"        "the"      
##  [7] "first"     "place"     ""          "an"        "object"    "outside"  
## [ ... and 72 more ]
## 
## Capital, Vol. I.3 :
##  [1] "Every"  "useful" "thing"  ""       "as"     "iron"   ""       "paper" 
##  [9] ""       ""       "c"      ""      
## [ ... and 92 more ]
## 
## Capital, Vol. I.4 :
##  [1] "The"     "utility" "of"      "a"       "thing"   "makes"   "it"     
##  [8] "a"       "use"     "value"   ""        ""       
## [ ... and 191 more ]
## 
## Capital, Vol. I.5 :
##  [1] "Exchange"     "value"        ""             "at"           "first"       
##  [6] "sight"        ""             "presents"     "itself"       "as"          
## [11] "a"            "quantitative"
## [ ... and 86 more ]
## 
## Capital, Vol. I.6 :
##  [1] "A"         "given"     "commodity" ""          "e.g"       ""         
##  [7] ""          "a"         "quarter"   "of"        "wheat"     "is"       
## [ ... and 146 more ]
## 
## [ reached max_ndoc ... 5,016 more documents ]
```

Taking a peek at the tokens object gives an intuitive demonstration of tokenization. By default, each word, space, punctuation mark, symbol, etc. are converted into individual tokens. Quanteda offers several options for flexible tokenization of corpora. For example, the corpus could be tokenized into ngrams by calling `tokens_ngrams()` either on the corpus itself or on another `tokens` object.


```r
cpe_tokens %>% 
  tokens_ngrams() %>% 
  head()
```

```
## Tokens consisting of 6 documents and 2 docvars.
## Capital, Vol. I.1 :
##  [1] "The_wealth"          "wealth_of"           "of_those"           
##  [4] "those_societies"     "societies_in"        "in_which"           
##  [7] "which_the"           "the_capitalist"      "capitalist_mode"    
## [10] "mode_of"             "of_production"       "production_prevails"
## [ ... and 21 more ]
## 
## Capital, Vol. I.2 :
##  [1] "A_commodity"    "commodity_is"   "in_the"         "the_first"     
##  [5] "first_place"    "an_object"      "object_outside" "outside_us"    
##  [9] "a_thing"        "thing_that"     "that_by"        "by_its"        
## [ ... and 45 more ]
## 
## Capital, Vol. I.3 :
##  [1] "Every_useful" "useful_thing" "as_iron"      "may_be"       "be_looked"   
##  [6] "looked_at"    "at_from"      "from_the"     "the_two"      "two_points"  
## [11] "points_of"    "of_view"     
## [ ... and 65 more ]
## 
## Capital, Vol. I.4 :
##  [1] "The_utility"  "utility_of"   "of_a"         "a_thing"      "thing_makes" 
##  [6] "makes_it"     "it_a"         "a_use"        "use_value"    "But_this"    
## [11] "this_utility" "utility_is"  
## [ ... and 131 more ]
## 
## Capital, Vol. I.5 :
##  [1] "Exchange_value"        "at_first"              "first_sight"          
##  [4] "presents_itself"       "itself_as"             "as_a"                 
##  [7] "a_quantitative"        "quantitative_relation" "as_the"               
## [10] "the_proportion"        "proportion_in"         "in_which"             
## [ ... and 55 more ]
## 
## Capital, Vol. I.6 :
##  [1] "A_given"         "given_commodity" "a_quarter"       "quarter_of"     
##  [5] "of_wheat"        "wheat_is"        "is_exchanged"    "exchanged_for"  
##  [9] "for_x"           "x_blacking"      "y_silk"          "or_z"           
## [ ... and 70 more ]
```

The unit of text can also be changed for `tokens` objects in a similar manner to corpora. Calling `tokens_group()` without specifying any levels will by default group the tokens by the labels found in `docid()`.


```r
cpe_tokens %>% 
  tokens_group() %>% 
  head()
```

```
## Tokens consisting of 3 documents.
## Capital, Vol. I :
##  [1] "The"        "wealth"     "of"         "those"      "societies" 
##  [6] "in"         "which"      "the"        "capitalist" "mode"      
## [11] "of"         "production"
## [ ... and 243,223 more ]
## 
## Capital, Vol. II :
##  [1] "Hence"         "the"           "formula"       "for"          
##  [5] "the"           "circuit"       "of"            "money_capital"
##  [9] "is"            ""              "M"             ""             
## [ ... and 176,698 more ]
## 
## Capital, Vol. III :
##  [1] "The"         "value"       "of"          "every"       "commodity"  
##  [6] "produced"    "in"          "the"         "capitalist"  "way"        
## [11] "is"          "represented"
## [ ... and 335,105 more ]
```

### Removing stopwords from `tokens` objects

Stop words are frequently used words that do not convey much or any of the relevant information within a text. In general, there is an inverse relationship between the frequency of use of a word and the amount of information or meaning that it encodes. Stop word removal can be thought of as a crude form of dimension reduction for text data, stripping the noise (abundant superfluous text) from the data to better hear the signal (information, meaning, themes).

Some text analysis and modeling processes, like word embedding models, can actually use these words to determine the context of other words. Other techniques of text analysis are robust against the presence of stop words, like word-embedding topic modeling. 

But very many of the most common purposes in the world of text-as-data, especially those that rely on a bag-of-words representation of text, will be hindered by the presence of stop words. For example, a simple way to get an impression of the information encoded in a body of text, usually done early on in the analysis, is to look through a table of the most frequently used words. 


```r
cpe_tokens %>% 
  dfm() %>% 
  topfeatures(n = 20)
```

```
##                   the         of         in        and          a         to 
##     107247      61751      46789      18764      14284      12607      12062 
##         is         as    capital         it       that        for       this 
##      11716       8671       8108       7385       6976       6002       5961 
##         by      which production      value         on         or 
##       5693       5105       4997       4096       3984       3877
```
The problem is apparent looking at the summary of top features of the text before stop word cleaning: most of the top terms are incredibly common words that represent little to no meaning in isolation. A list of ifs, ands, and buts really tells us nothing about the corpus. Quanteda encourages users not to remove stop words from the corpus of original texts. Instead stop word removal can be done at any stage of working with a `tokens` or `dfm` object. Below, the most common English stop words are removed by accessing a built in list of English stop words using `stopwords()`.


```r
cpe_tokens <- cpe_tokens %>% 
  tokens_remove(stopwords('en'), padding = TRUE)

cpe_tokens %>% 
  dfm() %>% 
  topfeatures(n = 20)
```

```
##                     capital    production         value        labour 
##        434115          8108          4997          4096          3628 
##         money          form   commodities           one    capitalist 
##          2670          2417          2350          2278          2173 
##        profit surplus_value         means         price   circulation 
##          2080          2040          1880          1625          1557 
##          rate       process     therefore             c       product 
##          1553          1548          1531          1478          1411
```

Take a look at the list of most frequent terms now, it's much more informative! We haven't even finished preparing the texts for analysis and are already gaining information on the CC. If one had no familiarity with the Marxist critique of capitalism, it's possible to *at the very least* put a name to many key concepts on the basis of the most frequently used words.

Also take note that since padding was retained to preserve the order and spacing of words in the `tokens` object, `quanteda` is counting an empty space `" "` as the most frequent character. If extra spaces between words are created by removing stop words, `quanteda` will automatically track these changes to preserve the original word ordering. We can take care of those spaces when we convert the tokens to a document-feature matrix in a moment.

### Keeping multi-word phrases through tokenization

Many of the key terms and phrases in Marx's vocabulary are compound or complex words: *e.g.* use-value, exchange-value, surplus-value, labour-power. Therefore it's especially important for these texts to find a way to keep multi-word tokens in the token set for analysis. `tidytext::unnest_tokens()` in Unit 1, we kept compound, hyphen departed words as tokens by converting the hyphens to underscores.

When it comes to [including compound words and multi-word phrases](https://tutorials.quanteda.io/advanced-operations/compound-mutiword-expressions/) in token sets, `quanteda` shines over other packages available in R. Unlike the simple hyphen-to-underscore hack used before, we can include even multi-word phrases that are not linked by a separator by using a statistical measure of word co-allocation.

With the `textstat_collocations()` function from the `quanteda.textstats` extension package, it's easy to compute coallocations for words and get the output into a dataframe. By default, this function will use `size = 2L` to find coallocations between words that are neighbors in the text, picking up both compound phrases and also proper names as well. 


```r
library(quanteda.textstats)
cpe_coalloc <- textstat_collocations(cpe_tokens, min_count = 5)

cpe_coalloc %>% 
  filter(z > 5) %>%
  head()
```

```
##        collocation count count_nested length   lambda        z
## 1 constant capital   517            0      2 4.565202 72.53170
## 2 variable capital   624            0      2 5.553194 72.32942
## 3           let us   219            0      2 9.116529 65.19572
## 4  capitalist mode   251            0      2 6.054857 64.34447
## 5         one hand   254            0      2 4.870179 63.87986
## 6     raw material   167            0      2 7.571263 63.46569
```

The output of `textstat_` functions arrives as a dataframe, making it easy to work with directly. Phrase counts along with two measures of association strength (lambda and z) are available. Looking through the dataframe of strongly collocated words, we see lots of meaningful word pairings, some proper names, and a few pairings of common stop words that were not caught by the pre-made list. 

Below, we use the `tokens_compound()` function to combine phrases into a unified token. With the `pattern` argument, we select only strongly associated word pairings by filtering for *z* values (from Wald's Z-test) above a certain threshold, in this case 10. To unite the tokens, a joining character is chosen, which is an underscore by default.

After that, we also take an additional step of converting hyphens to underscores. The reason for doing this is that sometimes Marx uses compound words with a separator (*use-value*), while other uses have no hyphenation (*use value*). We have captured the latter as tokens, which means there will be tokens for `"use-value"` and `"use_value"` in the set, which is far from desirable. By converting existing hyphens to underscores earlier on, both sets of compound words will be merged; otherwise, we'd see both "exchange-value" and "exchange_value" showing up in the data.


```r
cpe_tokens <- tokens_compound(cpe_tokens, pattern = cpe_coalloc[cpe_coalloc$z > 5])

cpe_tokens %>% 
  dfm() %>% 
  dfm_select(pattern = "^exchange_value$|^exchange-value$", valuetype = "regex") %>% 
  colSums() 
```

```
## exchange_value 
##            108
```

This is the only method easily offered by a pre-made package, that I am aware of, for including multi-word phrases into a unigram token set.  Using `tidytext`, it's simple to include both unigrams and bigrams as tokens, but not to mix selected bigrams into a token set of unigrams. Even if you are working mostly in a tidy approach with `tidytext`, there **may** be benefits in converting the tokens to a `quanteda` friendly format, computing the coallocations, then moving back to tidy tokens. 

Whether there is value in including these phrases does depend on both the texts and the intended use of the data. Including these compound words will probably provide much more information than a token set of unigrams alone. In a topic model heading, for example, "fixed capital" tells us so much more than "fixed" and "capital" on their own. However, this also increases the number of dimensions in your corpus data and text data is already notoriously high-dimension. There are many circumstances, for example many modeling applications, where dimension expansion would be very undesirable.

### Transforming tokens into a document-feature matrix

To be read by computers, text ultimately has to be turned into a form that can be quantified, and therefore, also subjected to computations and calculations. The [document term matrix](https://en.wikipedia.org/wiki/Document-term_matrix) or DTM is a standard way of representing text as a matrix of word counts over a corpus of documents. In a DTM, the matrix rows represent documents, while the columns represent the count of each word in the corpus vocabulary.

In many text analysis packages like [`tm`](https://rpubs.com/tsholliger/301914) or [`topicmodels`](https://cran.r-project.org/web/packages/topicmodels/index.html), some form of DTM is the default form of storing and working with text. Quanteda uses a [document-feature matrix](https://quanteda.io/reference/dfm.html) or DFM in place of a traditional DTM. They're pretty much equivalent, except that a DFM is more flexible in that columns can represent general features and not just terms, for example transformed words like stems or lemmas, ngrams, word dependencies, part of speech tags,  a dictionary class, and so on.

Once the text has been tokenized, the `tokens` object can be passed to `dfm()` to create a [document-feature matrix](https://tutorials.quanteda.io/basic-operations/dfm/dfm/), which represents the corpus documents in rows and features in the columns. We add the `remove_padding = TRUE` argument to remove the space character `" "` as a feature in the matrix.


```r
cpe_dfm <- dfm(cpe_tokens,
               remove_padding = TRUE)
cpe_dfm
```

```
## Document-feature matrix of: 5,022 documents, 18,415 features (99.76% sparse) and 2 docvars.
##                    features
## docs                wealth societies capitalist_mode production prevails
##   Capital, Vol. I.1      1         1               1          1        1
##   Capital, Vol. I.2      0         0               0          1        0
##   Capital, Vol. I.3      0         0               0          0        0
##   Capital, Vol. I.4      2         0               0          0        0
##   Capital, Vol. I.5      0         0               0          0        0
##   Capital, Vol. I.6      0         0               0          0        0
##                    features
## docs                presents immense accumulation commodities unit
##   Capital, Vol. I.1        1       1            1           1    1
##   Capital, Vol. I.2        0       0            0           0    0
##   Capital, Vol. I.3        0       0            0           0    0
##   Capital, Vol. I.4        0       0            0           2    0
##   Capital, Vol. I.5        1       0            0           1    0
##   Capital, Vol. I.6        0       0            0           1    0
## [ reached max_ndoc ... 5,016 more documents, reached max_nfeat ... 18,405 more features ]
```

Quanteda plays well with packages and tools in the tidyverse in general, it's functions are written to work intuitively with the `magrittr` pipe operator `%>%` (or the new base R pipe `|>`). In general the functions for manipulating tokens and DFM work similarly to dplyr verbs.

For example, selecting words or features can be done with `dfm_select()` and passing a string to lookup to the `pattern` argument. With `dfm_select()` features of the DFM can be selected through Quanteda's `valuetype` pattern matching, which has options for glob style wildcards (like below), regular expressions, or exact string matching.  


```r
cpe_dfm %>% 
  dfm_select(pattern = "labour*|capital*") %>% 
  textstat_frequency() %>% 
  head()
```

```
##        feature frequency rank docfreq group
## 1      capital      3647    1    1661   all
## 2       labour      2458    2    1068   all
## 3 labour_power      1104    3     539   all
## 4   capitalist       958    4     592   all
## 5    labourers       553    5     353   all
## 6     labourer       547    6     355   all
```

### Removing stopwords from a document-feature matrix

With `dfm_select()`, the user can specify whether to keep or remove the selected columns with the `selection` argument. Since removing columns is a frequent task, there is a convenient wrapper to `dfm_remove(x, selection = "remove")` available through `dfm_remove`. As mentioned earlier, stop words can be removed at any point in the workflow from both `tokens` and `dfm` objects. 

We've already used Quanteda's built in stopword list to remove common English stopwords from the text. The developers of Quanteda also maintain a [package containing stop word lists](https://cran.r-project.org/web/packages/stopwords/stopwords.pdf) in different languages and formats. Since Marx was quite the polyglot and regularly borrowed phrases from French and German, let's remove those stop words as well.


```r
cpe_dfm <- dfm_remove(cpe_dfm, pattern = stopwords(language = "fr"))
cpe_dfm <- dfm_remove(cpe_dfm, pattern = stopwords(language = "de"))
```

Usually, even after using a pre-made list to remove common stop words, one will still encounter more overly-frequent, low-information words. Some of these might be common stop words that are missed on the pre-made list used to clean to data. Other words will become stop words in the specific context of the subject area of the texts, the specific structure and vocabulary of the texts, and the purposes of analyzing them in the first case. 


```r
word_remove <-
  c("aa", "ab", "ï_á", "ï_î", "ï", "î","á","â","ã","i", "i.e", "e.g",
    "part","one","therefore","etc","also","now","since","thus","etc",
    "hence","must","first","per","one","two","three","et","cited","18th",
    "quote","6d","like","soon","may","finds","tells","us","let","via",
    "in","cit","marx","edition","la","dr","mr","ed","manuscript","chapter",
    "can", "milliard", "milliards", "lbs", "ton", "tsv", "op", "thalers",
    "o.u.p", "l.c", "posit", "positing", "posits", "posited", "insofar", 
    "per_ton", "per_cent", "mac", "îµî","come", "wherever", "rather", "herr",
    "-ed")

cpe_dfm <- dfm_remove(cpe_dfm, pattern = word_remove)
```

It's also quite common need to remove terms that provide low-information because they appear so infrequently. In most bodies of natural language text, a few terms will be used many times and most terms will be used few times. Since it also depends on the context of the domain, text, and purpose, it's hard to say exactly what the cutoff for word frequency should be or if rare words (also called sparse terms) should be removed to begin with. 

In general, it's a good idea to avoid removing data from the texts until it's reasonably certain that it will not be needed or is a hindrance to further analysis or use of the data. For most frequency based uses, it's often safe to leave the sparse terms in. If you are doing something more intensive like text-based modeling, it's often not a great idea to use words with only one or two occurrences as features in the model. For demonstration purposes, we'll filter the DFM of CPE texts for only terms that appear three or more times using `dfm_trim()`.


```r
cpe_dfm <- dfm_trim(cpe_dfm, min_termfreq = 5)
```

## Conducting text analysis on Marx's critique of capitalism with `Quanteda`

### Exploratory data analysis with term frequencies and distributions

Term frequency analysis is the ground floor entry level for using text-as-data. Lots of useful analysis can and must be done here before getting into more complex techniques like classification models, topic models, word embedding models, and so on. Almost every data science project, text-as-data or not, will involve a stage of exploratory data analysis (EDA) to give the user(s) a more thorough understanding of the data. It's difficult to imagine a text-based data science project proceeding without *some* form of EDA that involves analyzing counts of text in some way. However, frequency based analysis also has major limitations in the world of text: it is therefore limited, but necessary. You'll see as we continue on.

There is often an iterative back and forth between data cleaning and EDA. Given the messy and high dimensional nature of text-as-data, this is especially true of text analysis. The process usually unfolds as one **(1)** finds more undesirable data (missed stop words or other low information words, symbols, URLs, *etc.*) in the EDA process, **(2)** updates the stop word list with new terms, then **(3)** re-cleans the text before **(4)** resuming EDA.

Since a DFM is a matrix-like representation of word counts, it's possible to do calculations directly on the rows and columns. For example, below shows how to use `dfm_select()` to select particular column terms, then calculate the total number of occurrences by adding the sums of the columns.

The first chapter of the first volume of Capital begins with discussion of the commodity form. To begin exploring the CC, for example, we could calculate the total number of times the word commodity is used. First we select features with a glob-style wildcard character `*`, so `"commodit*` will get all uses of the word commodity, even plural and within compound words, then get the word use totals by summing the columns.


```r
dfm_select(cpe_dfm, pattern = "commodit*") %>% 
  colSums() %>% 
  .[1:10]
```

```
##          commodities            commodity     commodities_must 
##                 2074                 1037                   13 
##      commodities_can commodities_produced commodity_represents 
##                   12                   69                    5 
##        commodity_may          commodity_b     commodity_owners 
##                    8                   12                   10 
##    commodities_whose 
##                    6
```

Looks like Marx wrote a lot about commodities! Given the centrality of the commodity form to the Marxist understanding of capitalism, this checks out. Though for now, we don't know how much he wrote those words from book to book and relation to the rest of the vocabulary.

The total number of terms present in any document can be found by summing the DFM rows. In this case, we can get the number of words by paragraph (the default unit of text in our DFM) in the first volume of Capital by filtering for rows with the `docid` for Volume I, then summing the rows with `rowSums()`. 


```r
cpe_dfm %>% 
dfm_subset(docid(cpe_dfm) == "Capital, Vol. I") %>% 
  rowSums() %>% 
  .[1:10]
```

```
##  Capital, Vol. I.1  Capital, Vol. I.2  Capital, Vol. I.3  Capital, Vol. I.4 
##                 16                 32                 35                 68 
##  Capital, Vol. I.5  Capital, Vol. I.6  Capital, Vol. I.7  Capital, Vol. I.8 
##                 36                 46                 38                 33 
##  Capital, Vol. I.9 Capital, Vol. I.10 
##                 34                 11
```

Using a DFM for calculations like so can often be a bit unwieldy, so `quanteda` provides many convenient functions to assist the user in doing so. Earlier, we used the `topFeatures()` function to detect stop words in our token set. It works just as well to quickly see the most frequent features in a DFM, controlling the number returned with `n`.


```r
topfeatures(cpe_dfm, n = 20)
```

```
##    production       capital         value        labour         money 
##          4225          3647          3406          2458          2332 
##   commodities          form         means        profit surplus_value 
##          2074          1765          1755          1628          1618 
##   circulation         price       process  labour_power       product 
##          1311          1248          1161          1104          1095 
##          rate     commodity          time    capitalist          case 
##          1054          1037           978           958           892
```
The text-based statistics extension, `quanteda.textstats`, provides a very useful function for getting the feature frequencies, along with other useful information like ranks and the number of documents the term is present in (`docfreq`). Using `textstat_frequency` without specifying a `pattern` to subset the data by gives the entire distribution of word counts for the DFM in a tidy dataframe, with one feature per row for each document in the corpus. 


```r
cpe_freq <- textstat_frequency(cpe_dfm)

cpe_freq %>% 
  as_tibble()
```

```
## # A tibble: 6,759 x 5
##    feature       frequency  rank docfreq group
##    <chr>             <dbl> <dbl>   <dbl> <chr>
##  1 production         4225     1    1712 all  
##  2 capital            3647     2    1661 all  
##  3 value              3406     3    1296 all  
##  4 labour             2458     4    1068 all  
##  5 money              2332     5     964 all  
##  6 commodities        2074     6    1016 all  
##  7 form               1765     7    1038 all  
##  8 means              1755     8    1004 all  
##  9 profit             1628     9     669 all  
## 10 surplus_value      1618    10     840 all  
## # ... with 6,749 more rows
```

### Plotting `quanteda` output with `ggplot2`

Getting the frequency output in a dataframe especially useful for doing further data manipulations with `tidyverse` functions or visualizing the data with `ggplot2`. A good place to start EDA based on text data is to look at the distribution of word frequencies across the corpus. 

Below, we call `ggplot` on our term frequency dataframe, mapping `x` to `frequency` to plot a histogram of the distribution of term counts across all documents. At this point, we're counting all words together rather than individual words, to see how the text is distributed across the documents. As the data we're trying to visualize has lots of very high values along with many small values on the same axis, we use a square root transformation on the Y-axis to make the tail end of the distribution visible.  It's also a good habit to make a note, both on the chart and in any accompanying text, that the axis (or original data, which often happens) has been transformed somehow.


```r
cpe_histogram <- cpe_freq %>% 
  ggplot(aes(frequency, fill = group)) +
  geom_histogram(fill = capitals_palette[1], bins = 20) +
  scale_y_sqrt() +
  theme_ds4cs() +
  labs(x = "Term count", y = "√ (# of terms counted)", caption = "Data: MIA")

cpe_histogram
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-26-1.svg" width="672" />

Now we can see that small cluster of highly used terms observed in the frequency table above, way out in front of the pack: **Capital, value, production, labour, money, commodities**. Though we have already seen these term frequencies, now we have a visual sense of how important these terms are to the body of texts: they are by far the most well used implements in Marx's linguistic tool kit, the workhorse words in the CC.

Unsurprisingly, the distribution of words in the texts is dominated by a large number of words that are infrequently used, followed by a much smaller number of terms that are used with increasing frequency. This finding makes sense because this is what the distribution of words in natural language text is supposed to look like. Language conforms more or less to [Zipf's Law](https://en.wikipedia.org/wiki/Zipf%27s_law), a mathematical power law stating that the frequency of a term's use in a text is inverse to it's frequency-ranking. Perhaps some very short texts in isolation (like tweets) might not, but aggregated together, no doubt they would.

That means that if after [adjusting the bin size](https://www.statisticshowto.com/choose-bin-sizes-statistics/) to something appropriate for the data, the frequency distribution histogram **doesn't look** similar to the ones above or below,  something may be off about your data: heavily left-skewed, with a tail that gets thinner as it approaches the end. For example, when scraping web data, it's common for lots of web and html boilerplate to stow away in the data. Since that is text, but not natural language, it could throw off the distribution in a noticeable way. 

### Grouped computations and calculations with grouped document-feature matrices

Just as we did above with the corpus object, a DFM can be grouped by book just by calling `dfm_group()` without specifying a `pattern` to group by. In this case, that aggregates the DFM at the book level, which is the `docid` variable of the matrix. By calling `textstat_frequency` and specifying a variable with the `group` argument, a dataframe of grouped frequencies can be produced. Below, the frequencies are grouped and calculated at the book level.


```r
grouped_dfm <- cpe_dfm %>% 
  dfm_group()

grouped_freq <- cpe_dfm %>% 
  textstat_frequency(group = docid(cpe_dfm))
```

With grouped frequencies, we can visualize the distribution of features across each individual book. First, here's a trick for mapping color levels to specific levels of a variable. Using a manual `scale_` function, map the values to colors and the labels to corresponding variable labels. The assigned scale can be easily applied to any chart to ensure each book has a consistent color though all visualizations.


```r
# Tibble of levels and labels
labels_colors <- tribble(
  ~ book, ~ color,
    'Capital, Vol. I', "#8f1f3f",
    'Capital, Vol. II', "#d4ae0b",
    'Capital, Vol. III', "#c73200",
  ) %>% 
  mutate(book_fact = as_factor(book))

# Save as scales for easy use
scale_color_cpe <- scale_color_manual(values = labels_colors$color, breaks = labels_colors$book)
scale_fill_cpe <- scale_fill_manual(values = labels_colors$color, breaks = labels_colors$book)
```

The process for creating a grouped histogram is basically identical to the previous chart, except we map the `fill` color to the `group` variable (the default name for the grouping variable with `textstat_` functions) and then use `facet_wrap()` to spread the charts out by group. The distribution looks consistent across each text and also with the histogram of the entire distribution. 


```r
cpe_book_histogram <- grouped_freq %>%  
  ggplot(aes(docfreq, fill = group)) +
  geom_histogram(bins = 35) +
  scale_fill_cpe +
  theme_ds4cs() +
  scale_y_sqrt() +
  facet_wrap(~group, nrow = 1, scales = "free_x") +
  labs(x = "Document frequency", y = "√ (Word count)", caption = "Data: MIA")

cpe_book_histogram
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-29-1.svg" width="1152" />

### Grouping by multiple variables using `interaction()`

When creating a corpus with the `corpus()` function, only one variable can be used initially as a document identifier. Above, we saw how easy it is to regroup the dataframe according to it's document ID variable. Below, you can see how it's possible to group `quanteda` corpus, tokens, and DFM objects by more than one variable: just pass all of the grouping variables together using `groups = interaction(group1, group2)`. 

This way, we can get book-chapter level summaries from `textstat_summary()` in order to plot the distribution of tokens across chapters in each book. Before that, a simple helper function is used to re-extract the book and chapter number from the document ID field of the summary dataframe, which can be helpful for further calculations or plotting.


```r
# Convenience function for extracting the book and chapter from the doc column
un_bookchap <- function(df, doc = document) {
  
  df %>% 
    mutate(
      chapter = str_extract({{doc}}, "[:digit:]+"),
      chapter = as.numeric(chapter),
      book = str_remove_all({{doc}}, "[\\d\\_]"),
      book = str_remove(book, "\\.$"))
}
```

We then group the DFM with `dfm_group` and specify the `interaction()` between the document ID variable and `chapter`. Now we get a dataframe of token count summaries for each chapter in each book. Since our document variable is now a combination of book + chapter, we can add both in as columns in the dataframe with the `un_bookchap()` function defined above. It isn't applicable in this case, but this summary will also contain information on non-word tokens such as emojis, numbers, or punctuation marks.


```r
cpe_summary <- cpe_dfm %>% 
  dfm_group(groups = interaction(docid(cpe_dfm), chapter)) %>% 
  textstat_summary() %>% 
  un_bookchap()

cpe_summary %>% colnames()
```

```
##  [1] "document" "chars"    "sents"    "tokens"   "types"    "puncts"  
##  [7] "numbers"  "symbols"  "urls"     "tags"     "emojis"   "chapter" 
## [13] "book"
```

Below, we'll create a box plot with `geom_boxplot()` to visualize the distribution of token counts for each chapter of each work. We'll also put some semi-transparent points there to represent the token count of each individual chapter. The main take away here is that the three books have a relatively even distribution of tokens across their chapters, with the exception of a few very long outlier chapters in Volume I.

In this case, the visual isn't exactly packed with useful information, but it could be in many instances of text analysis. If one were, perhaps, training a text classification machine learning model on a body of text, it would be important to know if the distribution of tokens across documents is balanced or unbalanced.


```r
cpe_summary %>% 
  ggplot(aes(book, tokens, fill = book)) +
  geom_boxplot(width = .5) +
  geom_point(alpha = .2) +
  scale_fill_cpe +
  theme_ds4cs() +
  labs(x = NULL, y = "Tokens per chapter")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-32-1.svg" width="672" />
### Visualizing corpus and document level word counts

The next level down in text frequency based EDA, after exploring the overall distributions of features, is to look at the actual words or features themselves. Here is what the tall end of the distribution from the first histogram looks like up close, in full detail. To make the chart, just call `slice_max()` on the frequency dataframe to extract the desired number of terms and create a bar plot with `ggplot()` and `geom_col()`, mapping the term `frequency` to both the `x` and `y`. It's also usually advisable to turn the bar chart on it's side using `coord_flip()` so that the words can be presented the way they are read, horizontally.


```r
cpe_freq %>% 
  slice_max(frequency, n = 20) %>% 
  ggplot(aes(reorder(feature, frequency), frequency)) +
  geom_col(fill = capitals_palette[1]) +
  coord_flip() +
  theme_ds4cs() +
  theme(axis.text.y = element_text(size = 18),
        panel.grid.major.x = element_line(),
        panel.grid.major.y = element_blank()) +
  labs(x = NULL, y = "Term frequency")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-33-1.svg" width="672" />
Well, we've already seen the top words in the entire corpus a few times now. What about checking the top words by frequency for each book next? When calling `textstat_frequency()` to group the data, set the number of words to return per book with `n`. Then we use `mutate` to set the factors levels for the books and words; `reorder_within` from `tidytext` is used to sort the factor levels by frequency for each book, so that the chart facets are all in order. 


```r
wordcount_bars <- cpe_dfm %>%
  textstat_frequency(group = docid(cpe_dfm), n = 10) %>%
  filter(str_detect(group, "Capital")) %>% 
  mutate(
    group = factor(group, levels = labels_colors$book),
    feature = factor(feature),
    feature = reorder_within(feature, docfreq, group)
  ) %>%
  ggplot(aes(feature, docfreq, fill = group)) +
  geom_col(width = .8) +
  scale_x_reordered() +
  scale_fill_cpe +
  coord_flip() +
  facet_wrap( ~ group, ncol = 1, scales = "free_y") +
  theme_ds4cs() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line(),
        axis.text.y = element_text(size = 10)) +
  labs(x = NULL, y = "Term frequency", caption = "Data: MIA")

wordcount_bars
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-34-1.svg" width="960" />

As mentioned previously, text frequency based analysis has some serious limitations. We are running into one of them right here. With frequencies, it's possible to get an **often vague impression** of the topical or thematic content of a document. When we break the frequencies down by book, the most frequent terms across each book are **pretty much the same**. Other than showing that these words are used more in some books and reinforcing the notion that these terms are important to Marx's CPE, we don't really gain any new insight into how each document fits into the corpus.

#### Chapter level word counts

It's possible to drill down even further, to calculate and plot the term frequencies on a chapter-by-chapter basis. We do this below, visualizing the most frequently used terms in the first 10 chapters of Capital Volume I. We switch from a bar chart to a lollipop chart to reduce the overwhelming visual weight of the multitude of bars. As with the case for the top terms across all books and each individual book, the top terms for each chapter are mostly dominated by those same few terms: capital, value, money, commodity, labour, and so on. 

Even though the frequent common terms are largely blurring the distinctions between chapters, we can see more detailed data on the distribution of those shared words across chapters. This gives us a **somewhat less vague** impression of what each chapter is about, relative to the others. We see, for example, some chapters (1, 2, 5) that seem to be heavy on discussion of the concept of value, while two others (3, 4) seem to deal with money.


```r
cpe_dfm %>% 
  textstat_frequency(groups = interaction(docid(cpe_dfm), chapter)) %>% 
  un_bookchap(group) %>% 
  filter(book == "Capital, Vol. I" & chapter %in% 1:6) %>% 
  group_by(chapter) %>% 
  slice_max(docfreq, n = 8, with_ties = FALSE) %>%
  mutate(feature = reorder_within(feature, docfreq, chapter)) %>% 
  ggplot(aes(x = feature, xend = feature, y = docfreq, yend = 0)) +
  geom_segment(color = capitals_palette[1]) +
  geom_point(size = 2.5, color = capitals_palette[1]) +
  coord_flip() +
  scale_x_reordered() +
  facet_wrap(~chapter, scales = "free_y", ncol = 2) +
  theme_ds4cs() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line()) +
  labs(x = NULL, y = "Term frequency", caption = "Data: MIA")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-35-1.svg" width="672" />

Unfortunately, that tiny increase in information comes at a price. We are taking a fine-grain look at text data, which is notoriously high dimensional already. As soon as we turn the corner, we run face first into the curse of dimensionality that plagues even moderately sized text data sets. 

Each book has dozens of chapters! Volume 3 alone has **over 50 chapters**. It's just not feasible to produce and inspect dozens of charts to get a more detailed view of the texts. And since chapters share so many common terms, the increase information gained on the texts would be minimal.

### Getting more information on document distinctiveness with TF-IDF

Thankfully, there are many ways to reduce the dimensions of text data! Counting word frequencies could perhaps be considered a rudimentary form of dimension reduction itself. We can improve on raw counts by calculating the [term frequency-inverse document frequency](https://monkeylearn.com/blog/what-is-tf-idf/) or **tf-idf** for each term in each document. Tf-idf is just a simple calculation that weights term frequency by how infrequently the term appears in other documents. It was originally intended to assist with archival information retrieval by giving a measure of how important a particular term is to a particular document, relative to other documents in the corpus.

With `quanteda` getting the tf-idf for features in a DFM is as easy as calling `dfm_tfidf()` on it, then using `convert()` to put the results in a dataframe for plotting with `ggplot2`. Converting a DFM to a dataframe produces a wide table, with one column for each word in the vocabulary. That's 8330 columns for the CC. This is what the high dimensionality of text data looks like. To get a form usable for plotting, the data is transposed from wide to long format using `dplyr::pivot_longer`. 


```r
cpe_tfidf <- dfm_group(cpe_dfm) %>%
  dfm_tfidf() %>%
  convert(to = "data.frame") %>%
  pivot_longer(cols = 2:last_col(),
               names_to = "feature",
               values_to = "tf_idf") %>%
  rename(group = doc_id)

cpe_tfidf %>% 
  head()
```

```
## # A tibble: 6 x 3
##   group           feature         tf_idf
##   <chr>           <chr>            <dbl>
## 1 Capital, Vol. I wealth           0    
## 2 Capital, Vol. I societies        0    
## 3 Capital, Vol. I capitalist_mode  0    
## 4 Capital, Vol. I production       0    
## 5 Capital, Vol. I prevails         0.352
## 6 Capital, Vol. I presents         0
```

The result is a tidy tibble with one row per term for each level of the grouping variable, which is book-level in this case. Plotting the top terms by tf-idf for each book will give an idea of what frequently used terms set each document apart from each other, which usually also infers at least some information of the topical or thematic content of each work *relative to the others*.


```r
tf_idf_lolli <- cpe_tfidf %>% 
  group_by(group) %>%
  slice_max(tf_idf, n = 10, with_ties = FALSE) %>% 
  filter(str_detect(group, "Capital")) %>% 
  mutate(group = factor(group, levels = labels_colors$book),
         feature = factor(feature), 
         feature = reorder_within(feature, tf_idf, group)) %>% 
  ggplot(aes(x=feature, xend = feature, y = tf_idf, yend = 0, color = group)) +
  geom_segment() +
  geom_point(size = 2) +
  scale_x_reordered() +
  scale_color_manual(values = labels_colors$color, breaks = labels_colors$book) +
  coord_flip() +
  facet_wrap(~group, ncol = 1, scales = "free_y") +
  theme_ds4cs() +
  theme(panel.grid.major.y = element_blank(),
        panel.grid.major.x = element_line()) +
  labs(x = NULL, y = "tf-idf", caption = "Data: MIA")

tf_idf_lolli
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-37-1.svg" width="672" />

Now we are getting somewhere! Based on the frequency analysis, we know well now that the most frequently used terms are shared between all three volumes. We can see quite a few words that correspond to fundamental concepts in Marx's critique of capitalism like labour, capital, value, money, commodity, and so on. Tf-idf indicates which frequently used words are distinctive to each book, giving more specific information on the topic content of each volume beyond the basic categories of CPE.

##### Volume I

In Capital Volume I, Marx presents the circuit of capital as a simple formula: **M-C-M1**, where money is turned into commodities which are in turn sold for a greater sum of money. The book focuses on the first part of the circuit of capital, the **M-C** part, where capitalists pay wages to workers to produce commodities for sale, reaping surplus value by the way of exploitation.

According to tf-idf, it appears that Marx is much more likely to discuss labour, workers, and the social conditions of the working class. This checks out, since the first volume is dedicated to the process of production of surplus value, which entails extensive discussion of the role of exploitation in capitalism. Is it odd to see the word children at the top of the list? Marx in Vol. I dedicated substantial attention to the egregious super-exploitation of children (385 appearances) and women (147 mentions) in capitalist production.  

##### Volume II

Volume II of Capital deals with the **C-M** part of the circuit, touching on the circulation of capital, commodities, money, and surplus value. One might see "mp" or "iic" be tempted to declare them junk text for the stop word list. However, these are actually remnants of the abundant mathematical notation and numerical tables in the book. The whole thing is rife with calculations and presentations of quantitative data. You can tell that it's a much dryer and more technical read than the previous volume just based on the top terms. 

##### Volume III

The third and final volume of Capital encompasses the system as a whole, the entire circuit of capital **M-C-M1**, emphasizing the process of realization of surplus value into profit, the roles of credit, finance, and rent, as well as the expanded reproduction of the entire process. All of those concepts are pretty well represented in the tf-idf terms.

### The Word Stack: A better alternative to word clouds

Quanteda's visualization extension, `quanteda.textplot` adds a number of functions for visualizing text data. The most commonly used is no doubt the much maligned word cloud, which projects a distribution randomly in space, with text size weighted by the word frequency or some similar measure. Given the huge increase in availability of text as data and the abundance of free tools for creating them out there, word clouds seem to be everywhere now. Much like the humble pie chart before it, many visualization experts have pointed out that the word cloud format, at least in standard incarnation, suffers from some [severe design flaws](https://getthematic.com/insights/word-clouds-harm-insights/) to say the least.

It's possible to very quickly create a word cloud from a DFM using `textplot_wordcloud()`.  I agree with said visualization exports on the problems with word clouds. I can't think of any situation where I would use them over another form of visual on something actually going to publication in some way. 

Word clouds can however, play a small but potentially quite useful role in the EDA of text data process. They are free of the spatial limitation of bar charts for displaying text frequencies, so it's possible to display far more words in a much smaller plot area. This can be useful doing EDA on text data to quickly get an overview of the term frequency in a corpus, document, or document's sub-unit such as a chapter or page. 


```r
library(quanteda.textplots)
set.seed(1917)
textplot_wordcloud(cpe_dfm, 
                   min_size = 2,
                   max_size = 4,
                   max_words = 100,
                   rotation = 0)
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-38-1.svg" width="672" />

We can get a quick glance at dozens to several hundred words from the corpus or document. This is much more informative than any of the previous term frequency based plots. It's also a good way to scan data for missed stop words or other undesirable features that might need removal. With 8 groups or fewer, `quanteda` can produce a grouped word clouds that are, at the very least, kind of neat to look at. This can be done by simply calling `textplot_wordcloud()` on a grouped DFM and setting the argument `comparison = TRUE`. 


```r
cpe_dfm %>%
  dfm_group() %>%
  textplot_wordcloud(
    min_size = .5,
    max_size = 4,
    max_words = 100,
    comparison = TRUE,
    labelsize = 1
  )
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-39-1.svg" width="672" />

It's also possible to use something like [ggwordcloud](https://cran.r-project.org/web/packages/ggwordcloud/vignettes/ggwordcloud.html) to produce word clouds within a grammar of graphics framework, then facet the chart out by document or chapter. That could be a good way of getting a simple overview of multiple frequency distributions of text at once. But we're not going to bother with that, instead we'll write a function to produce what I have called a **word stack** (I didn't invent this, but I can't find another name for it) that improves on the basic format of the word clouds: projecting text in space and weighing the size by some third variable.


```r
ds4cs_wordstack <- function(df, ..., x = docfreq, group = group, n_max = 20, overlaps = 500) {
  
  require(ggrepel)
  
  df %>% 
    group_by({{group}}) %>% 
    mutate(p = {{x}}/sum({{x}})) %>% 
    slice_max({{x}}, n = n_max, with_ties = FALSE) %>% 
    mutate(rank = rank({{x}}, ties.method = "first")) %>% 
    ggplot(aes(x = 1, ...)) +
  geom_text(fontface = "bold") +
  coord_cartesian(clip = "off") +
  scale_x_continuous(expand = expansion(2,0)) +
  scale_size_binned(range = c(2,8)) +
  facet_wrap(vars({{group}}), nrow = 1, scales = "free_x") +
  theme_ds4cs() +
  theme(axis.text = element_blank(),
        panel.grid.major.y = element_blank(),
        strip.text = element_text(size = 16, hjust = 0.5),
        plot.margin = margin(r = 10, unit = "mm")) +
  labs(x = NULL)
}
```

The word stack places words in rank ordered columns of text, which are usually faceted out by variable levels. Visualization researchers have done some [empirical work](https://people.ischool.berkeley.edu/~hearst/papers/HearstWordzonesTVCG.pdf) showing that both column-based layouts and spatial faceting improve the reader's perception and understanding compared to standard word clouds. I plan to refine the function for the visuals eventually, but you can see the basic form below. The text size is still weighted by another variable, which is for this chart the word's normalized proportion of the book's total text.


```r
freq_wordstack <- grouped_freq %>% 
  ds4cs_wordstack(y = rank, size = p, label = feature, color = group) +
  scale_color_cpe +
  labs(y = "Ranked by % of total words used", subtitle = "Size proportionate to term's % of book's total word count")

freq_wordstack
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-41-1.svg" width="672" />

It looks better than a word cloud, but doesn't tell us anything more than we have already learned. Here is a word stack using the top terms for each book by tf-idf with text size also weighted to tf-idf. It's the same information as the lollipop plot, but it's possible to put a few more words on there, though precision in the relative differences is lost. It's by far the most informative visual on the CPE that we have produced yet, but still leaves a lot wanting.


```r
tf_idf_wordstack <- cpe_tfidf %>% 
  ds4cs_wordstack(y = rank, 
                  x = tf_idf,
                  label = feature,
                  size = log(tf_idf), 
                  color = group,
                  n_max = 20,
                  overlaps = 10) +
  scale_color_cpe +
  labs(y = "Ranked by tf-idf", x = NULL) +
  labs(subtitle = "Size is proportionate to term frequency-inverse document frequency")

tf_idf_wordstack
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-42-1.svg" width="768" />

## Using one document to explore the others: measures of keyness and wordscore models

### Detecting document key words with keyness statistics

At this point, we have taken frequency based text analysis about as far as it can go. There are too many dimensions (one per word) in an average text-as-data set to thoroughly explore and understand the data through just counting words and staring at bar charts. It's possible to paint a much more specific picture of how the texts are related through the words used in them. Using the `textstat_keyness()` function, it's possible to calculate a [keyness statistic](https://eprints.lancs.ac.uk/id/eprint/51449/4/Gabrielatos_Marchi_Keyness.pdf) for a particular reference document, identifying **key words** that set it apart from the rest of the documents in the corpus. 

The keyness statistic provides a measure of how central or key a given term is to a document derived by conducting a statistical test based on the relative frequency distributions of the reference document versus target document(s). Generally, the larger the effect size of the statistical test, the more *key* the word is to the given document. There are several options for keyness tests provided by the `textstat_keyness()` function, the default is to return a chi² statistic.

To compute keyness statistics, just call `textstat_keyness()` on a DFM and indicate the target document with the `target` argument. The result is a long dataframe with one row per term in the DFM, containing a test statistic (`chi2`) and p value, along with counts, of each feature. In general, it's the effect size and not the statistical significance that is of interest here.


```r
test_keyness <- textstat_keyness(grouped_dfm,
                 target = "Capital, Vol. I")

test_keyness %>% 
  head(20)
```

```
##            feature     chi2 p n_target n_reference
## 1           labour 530.4935 0     1305        1153
## 2            hours 521.6521 0      349          69
## 3         children 364.6385 0      174           3
## 4             work 363.8512 0      327         117
## 5      working_day 281.7988 0      269         105
## 6        machinery 274.6170 0      295         134
## 7            linen 254.2942 0      180          41
## 8              men 224.1217 0      129          15
## 9             coat 210.2606 0       99           1
## 10         machine 194.0108 0      158          48
## 11             day 191.7913 0      146          39
## 12     manufacture 191.7631 0      158          49
## 13         workman 190.7692 0       90           1
## 14         workmen 175.9353 0       85           2
## 15    labour_power 152.1785 0      539         565
## 16           women 145.2993 0       69           1
## 17         factory 123.2643 0       95          26
## 18 modern_industry 117.8076 0       68           8
## 19          number 110.3905 0      231         185
## 20      workpeople 108.2515 0       50           0
```

Since keyness needs a reference document, it's not possible to do a grouped test other than by aggregating documents together. However, we can use `map` to generate keyness statistics for each volume of Capital relative to the other books in the corpus. This way, we can get a much more specific idea of the key words of each Volume relative to the other books in the collection.


```r
capitals_keyness <- map(c("Capital, Vol. I", "Capital, Vol. II", "Capital, Vol. III"),
                        ~textstat_keyness(grouped_dfm, target = paste(.x)))
```

In addition to providing a function for calculating the keyness stat, `quanteda` also includes a function for creating a keyness plot using a diverging bar chart. The filled bars on the right hand side represent the positive estimate effects for terms that are more key to the reference document, while those on the left in gray are terms that are less important to it. While measures of keyness are based on statistics that don't account for semantics or linguistics, they nevertheless see wide use because they do tend to track well with human judgement of important terms. At the very least, the keyness statistic will probably give you some good terms to begin further investigations with. 

We can then pass the list of keyness dataframes created above with `map()` and chart colour palette to the keyplot function within `map2()` and create a list of keyword plots. What can we discern about the CC by inspecting the keyness plots? Let's find out! 


```r
capitals_keyplots <- map2(
  .x = capitals_keyness, 
  .y = capitals_palette,
  .f = ~ textplot_keyness(.x,
                     min_count = 3L,
                     n = 20,
                     labelsize = 5,
                     margin = .12,
                     color = c(.y, "gray")) +
    theme(legend.position = 'none')
  )
```

Reading the tf-idf plots, I could infer a lot about the relationships of the distinct words and their related concepts toeach of the books because of my background knowledge in Marxist sociology. There are many cases in reality where, sadly, the user won't have the luxury of extensive domain knowledge. Compared to keyword analysis by plotting tf-idf, the keyness plot makes the comparison between texts explicit, quantified with a statistical estimate, and made visual for us to easily see in one dimension (left to right). 

##### Capital Volume I

The positive end of the keyness plot represents the terms that are the most key to the text, the higher the estimate effect, the more key the word is. These associated terms will have a fair amount of overlap with the terms you might see on a tf-idf plot. We can see that what sets Volume I apart from the others is Marx's incredibly detailed analysis of the processes of capitalist industrial production. Reading this book, one will find very thorough treatments of commodity production (linen, coat), large-scale industrial production (machine, manufacture, factory), and moreso than any other topic, the production of surplus value by the exploitation of labour. Both the words children *and* women appear in the most key terms, as Marx examines both the gendered and age-based aspects of capitalist exploitation at great length. Wither claims of economic or class reductionism.

The negative left side of the plot, filled in gray, shows the *least* key terms to a document, key words that set the other documents apart from the reference document. In Volume I, Marx is less likely to use words related to capital circulation, finance, credit, and rent. He is especially less likely to mention profit, which checks out, since the thrust of the book is to explain the production of surplus value in capitalist production through exploitation. Marx treats the **circulation** and **realization** of capital and surplus value as problems deserving of their own books, hence Volumes II and III. 


```r
capitals_keyplots[[1]]
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-46-1.svg" width="960" />

##### Capital Volume II

Again, quite a bit of overlap on the right side with the tf-idf top terms. We know that Volume II is about the **circulation** of value. What does this mean? There will always exist a certain distance both in time and space between the production and sale of the commodity, so that means that capital needs to circulate, to move, in order to be realized. 

Looking at some of the key words (circulation, weeks, turnover, process) we can see the implication that capitalism is a *system in motion* where value is both produced and is moved around through monetary transactions. Capitalists cannot profit just by paying to have commodities produced after all, they actually have to sell them for money to realize that surplus value in profit!

Looking at a keyness plot that mixes bigrams with unigrams can be really helpful in *pointing* to important topics in the document. Notice the differentiation between many forms of capital in Volume II: productive capital, fixed capital, money capital, circulating value, commodity capital. Marx clearly gave capital a complicated, multi-faceted interrogation in this book. This also goes to show that Marx strode to avoid mechanical, one-sided explanations for complex social phenomenon. 

On the negative effect strength side, the least key words, we can see that, as in Volume I, Marx devotes much less ink to the realization of surplus value as profit. Again, since this is mostly the domain of Volume III, this seems to check out. We can see that he also tends to talk less about credit and finance, rent, which are also mostly the domain of the third volume.  


```r
capitals_keyplots[[2]]
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-47-1.svg" width="960" />

##### Capital Volume III

As mentioned earlier, Volume III contends with the circuit of capital as a whole, how production, circulation, and realization of profit unfold as part of a whole system. We have finally found Marx's investigation of the final process of surplus value, the sale of commodities for **profit** and reinvestment into the next round of production. Marx also dedicates a significant analysis to the role of banking, finance, credit, and rent under capitalism. 

We can also see differentiation of average profit and surplus profit from profit in general. Both indeed end up being very important concepts to the CPE, though the keyness chart won't shed much light on **why** they are key beyond a statistical effect size. 

On the grey side, we can see that Volume III involves less discussion of the actual process of industrial commodity production, the exploitation of workers, and the circulation process of capital; entirely consistent with what we saw in the two previous keyness charts. 


```r
capitals_keyplots[[3]]
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-48-1.svg" width="960" />

If I had to boil down this keyness analysis into one more meaningful take away, it would be this: **we can't get everything we need to understand the critique of capitalism in just one volume of Capital**. Based on the charts above, it appears that Volume I contains information on capitalist production, II on the exchange and circulation of capital, and III on profit and the reproduction of the system as a whole. 

This will not be apparent from the charts, but this notion goes further than that. Even after accounting for all three volumes, one still doesn't have the full picture of the critique of capitalism. Beginners to Marxism are likely not aware of this history, but Marx had initially planned for his *magnum opus* to span many more volumes, with additional [studies of rent, wage labour, the state, and world trade](https://yorkspace.library.yorku.ca/xmlui/bitstream/handle/10315/38546/Musto_AAM_10.1080.03017605.2017.1412623.pdf?sequence=1&isAllowed=y). While Marx is often presented unfairly by critics as never being able to finish a work due to being some sort of irresponsible profligate, his life's work was actually plagued by [severe chronic illness](http://www.afrh.fr/web-content/documents/asso/Marx&HS.pdf) and often crushing poverty as a result of disability, not to mention political persecution.

### Estimating a text's "perspective" on political economy with Wordfish scaling

There are even more ways to make statistical comparisons between texts offered by `quanteda`. The package features several tools for gauging the differing "perspectives" of author(s)/document(s) by placing them on a numerical scale. This technique, known as [word scoring or scaling](https://kenbenoit.net/assets/courses/cta2011ceu/CTA_CEU_Day6.pdf), has become a very popular tool among quantitative political scientists for estimating the relative positions of political actors in terms of ideology, policy choices, etc. 

The simplest forms of word scaling use a pre-made dictionary of word-scores to assign a score to each term. For example, on a "left-right" scale from -1 to +1, "tax cuts" might be a +.75 on the right, while "tax the rich" might be a -.75 on the left. I think these scales are of limited value in application to most Marxist texts, since they are mostly created to score very specific types of texts like political party speeches or manifestos of a country or region. Even worse, those political ideology scores also tend to be created by liberal political scientists and therefore operate within the ideological confines of a liberal approach to politics and economy. 

However, word scaling models that don't rely on pre-made dictionaries of scores are available through `quanteda` as well. It uses only documents in the corpus as a reference point to each other. The [Wordfish](http://www.wordfish.org/) method of document scaling, named for the [Poisson distribution](https://en.wikipedia.org/wiki/Poisson_distribution) that it draws on, estimates perspectives by using one document in a corpus as a reference point to scale another document in relation to. 

Wordfish places each document in the corpus on a one-dimensional scale that represents the "perspective" of the author as expressed in the words in the text. To run a Wordfish model with `quanteda`, two reference documents must be provided along with a DFM at the appropriate grouping level to the `textmodel_wordfish()` function. The reference documents can be indicated by row index numbers, in this case we will compare Volume I at row 1 and Volume III at row 3.


```r
library(quanteda.textmodels)

fish_ref <- c(
  which(rownames(grouped_dfm) == "Capital, Vol. I"),
  which(rownames(grouped_dfm) == "Capital, Vol. III")
)

capital_fish <- 
  grouped_dfm %>% 
  dfm_trim(min_termfreq = 20) %>% 
  textmodel_wordfish(dir = fish_ref)
```

Quanteda's plotting extension has a function specifically for plotting scales and models of documents along one dimension, called `textplot_scale1d()`. Like the other `textplot_` functions, it returns a `gg` object that can be used as any `ggplot2` object can. Based on the scaling model comparing Grundrisse to Capital Volume III, `quanteda` places each document on a scale representing the "perspective" of the document. 

I keep writing "perspective" because these scales are usually used to measure something like political ideological positions on a +/- scale, but unlike dictionary based methods, the scales themselves actually have no inherent meaning: it's up to the user to decide how to interpret the dimension. In this case, the theta scale measures something like "Marx's perspective on the critique of political economy" for each document. What aspects of his perspective on political economy is this scale attempting to represent? It's hard to say looking at just one dimension, but it looks like there is a clear separation between Volume I and the two other books.


```r
textplot_scale1d(capital_fish) +
  aes(color = doclabels) +
  geom_point(size = 3) +
  scale_color_cpe +
  theme(legend.position = 'none') +
  labs(subtitle = "Wordfish model: Estimated document 'perspective' on political economy (theta)")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-50-1.svg" width="672" />

### Plotting the most distinguishing words in a Wordfish model

To get a better idea of what the Wordfish scale is comparing in the texts, we can extract the model coefficients for each word by calling `coef()` on the model and specifying `margin = "features"`, then converting the output to a tibble for plotting. The tibble of coefficients has a value for bet, the marginal effect strength that measures the position of the word on the scale, and psi, the measure of fixed effects for words, reflecting the baseline frequency of word use. Below, the top 15 terms are taken for each end of the Wordfish scale measured by beta, which represents the marginal effect strength (how strongly it is related to either end of the scale) of each feature in the DFM. 


```r
capital_fish.coef <- coef(capital_fish, margin = "features") %>% 
  as_tibble(rownames = "feature") 

top_feat <- capital_fish.coef %>% slice_max(beta, n = 15, with_ties = FALSE) %>% .$feature
bot_feat <- capital_fish.coef %>% slice_min(beta, n = 15, with_ties = FALSE) %>% .$feature
wf_feats <- c(top_feat, bot_feat)

capital_fish.coef <- capital_fish.coef %>% 
    mutate(top_bot = case_when(
      feature %in% top_feat ~ 3,
      feature %in% bot_feat ~ 2,
    TRUE ~ 1))

capital_fish.coef
```

```
## # A tibble: 2,162 x 4
##    feature             beta   psi top_bot
##    <chr>              <dbl> <dbl>   <dbl>
##  1 wealth           -0.286  4.02        1
##  2 capitalist_mode   0.613  4.13        1
##  3 production        0.190  7.17        1
##  4 presents         -0.349  2.76        1
##  5 accumulation     -0.399  4.73        1
##  6 commodities      -0.0859 6.52        1
##  7 unit             -0.582  2.18        1
##  8 single_commodity -2.21   0.712       1
##  9 investigation    -0.796  1.99        1
## 10 must_therefore   -0.493  2.42        1
## # ... with 2,152 more rows
```

We can use the `top_bot` vector containing the names of the top and bottom marginal word effects to create a scatter plot with labels for the terms most strongly associated with each end of the scale. We'll also sample 10 random words from the middle of the cluster to illustrate the "neutral" terms in the middle of the scale.


```r
capital_fish_plot <- capital_fish.coef %>% 
  ggplot(aes(beta, psi, color = factor(top_bot), label = feature)) +
  geom_point(alpha = .2) +
  scale_color_manual(values = c("grey50", "#b7a4d6", "#8f1f3f")) +
  geom_label_repel(
     data = capital_fish.coef %>% 
       filter(feature %in% wf_feats),
    size = 3, fontface = "bold",
    max.overlaps = 200
  ) +
  geom_label_repel(
    data = capital_fish.coef %>% 
      filter(top_bot == 1) %>% 
      slice_sample(n = 10),
    size = 3, fontface = "bold",
    max.overlaps = 20
  ) +
  theme_ds4cs() +
  labs(x = "Term perspective (beta)", "Relative baseline word frequency (psi)",
       subtitle = "Wordfish model: Capital Vol. I versus Capital Vol. III")

capital_fish_plot
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-52-1.svg" width="768" />

It looks like the left end of the CPE Wordfish scale is more labour and production (Volume I), while the right end of the scale deals with credit, rent, and profit (Volume III). In the middle of the scale are "neutral" terms that are about as likely to appear in the discussion of either topic - production of surplus value or realization of monetary profit. This chart is pretty close to a representation of the three keyness plots, but all together in two dimensions. Notice as well that the higher a term's baseline frequency (psi), the less drawn toward either end of the scale they are.

### Exctracting context and meaning with keyword associations

So you've identified a bunch of document key words. They might be key, but terms on their own can only deliver so much information. What can we actually do with this information to  help us to read and understand the texts? This is in my opinion, the coolest and most useful thing that can be done with text frequencies and simple statistical testing in `quanteda`: extracting the local context for document keywords and then calculating a second keyness statistic that measures the associations of keywords to terms that are within a specified local area of text.

Go back and review the plots and data for word frequencies, tf-idf, and term keyness, make a few notes if you want to. Pick a short list of key terms that seem important, interesting, and/or helpful to the purpose of text analysis. For demonstration purposes, here's a list of eight key terms that point to key concepts in Marx's critique of capitalist political economy.  


```r
key_words <- c("capital", "labour", "value", "profit", "use_value", "exchange_value", "price", "money")
```

First, this method requires a `tokens` object in order to work. Since we only partially removed stopwords from the tokens, we'll start by removing both a pre-made and custom list of stopwords. To calculate associations for the keyword's neighboring terms, it's necessary to keep the space padding between tokens by specifying `remove_padding = FALSE` when tokenizing the corpus. 


```r
tokens_nostop <- cpe_tokens %>% 
  tokens_remove(stopwords("en")) %>% 
  tokens_remove(word_remove)
```

First, it's necessary to create two sets of tokens that represent the neighboring terms for each keyword within a specified window of terms. Below, we create a set of inside tokens containing the 10 terms to the left of each keyword in the token set.


```r
tokens_inside <- tokens_keep(tokens_nostop, pattern = "capital", window = 10, valuetype = "regex")
```

Then the keyword itself is removed from the inside window and an outside window of characters is created with an identical method to the inside layer. The inside and outside token sets will then need to be converted to a DFM, which are bound together.


```r
tokens_inside <- tokens_remove(tokens_inside, pattern = "capital", valuetype = "regex")
tokens_outside <- tokens_remove(tokens_nostop, pattern = "capital", window = 10, valuetype = "regex")

dfm_inside <- dfm(tokens_inside)
dfm_outside <- dfm(tokens_outside)
dfm_both <- rbind(dfm_inside, dfm_outside)
```

Feed the unified inside-outside DFM into the `textstat_keyness()` function's `x` argument, setting the `target` argument to the number of documents in the inside DFM. The resulting dataframe contains the target word co-allocation effect sizes for each feature in the DFM. This time, the keyness statistic indicates how strongly each feature is related to the keyword, based on how often it appears in the word window of `n` length around the target word. Now we can know not just what the keywords of each document are, but also how they are used in relation to other words in the text. 


```r
textstat_keyness(dfm_both, target = seq_len(ndoc(dfm_inside))) %>% 
  filter(feature != "") %>% 
  head()
```

```
##        feature     chi2 p n_target n_reference
## 1     advanced 231.4778 0      209         109
## 2   investment 205.4668 0      122          32
## 3     invested 179.8795 0      121          41
## 4 accumulation 173.5901 0      205         141
## 5     turnover 167.8071 0      201         140
## 6      circuit 143.2231 0      154          97
```

We can define a custom function to perform the operations above for a single keyword, which takes a set of tokens, a key word as a string, and the length of the text window. A smaller value of `n` will measure word co-allocation more locally, for example, an `n` of 2 would produce associated bigrams. On the other hand, a larger `n` value will capture more variance in the text. With a very large text data set, computing this statistic with a high window could be very computationally expensive. This one runs in a snap on the CC though!


```r
keyword_assoc <- function(toks, key_word, window = 10) {
  
tokens_inside <- tokens_keep(tokens_nostop, pattern = key_word, window = window, valuetype = "regex")
tokens_inside <- tokens_remove(tokens_inside, pattern = key_word, valuetype = "regex") # remove the keywords
tokens_outside <- tokens_remove(tokens_nostop, pattern = key_word, window = window, valuetype = "regex")

dfm_inside <- dfm(tokens_inside)
dfm_outside <- dfm(tokens_outside)

textstat_keyness(rbind(dfm_inside, dfm_outside), 
                                     target = seq_len(ndoc(dfm_inside))) %>% 
  filter(feature != "") %>% 
  mutate(key_word = key_word)

}
```

In order to produce a list of stongly associated terms for each keyword, we can wrap the call to `keyword_assoc()` within `map_dfr()` in order to iterate over each key word in the character vector provided to `.x` and return a single dataframe. After that, they keyword-terms table is grouped by `key_word` and the top 20 terms by effect size are taken for each group. Note that if you want a consistent number of words per keyword, you need to specify `with_ties = FALSE` in the call to `slice_max()`.  

We now have a dataframe of the most associated terms for each keyword by effect size. Let's create a wordstack plot for these keywords and their most associated terms to see what we can learn about the data. Inspecting the resulting plot reveals a lot of information, expanding from key words in isolation to a word set based on text co-allocation that is much more capable of conveying information on key concepts, themes, topics, *etc.* in the text. Based on the resulting plot, I am inclined to think of this technique as almost resembling a crude form of user-supervised [topic modeling](https://en.wikipedia.org/wiki/Topic_model) that captures local, rather than document-level variation in the text.


```r
keys_assoc <- map_dfr(key_words, ~ keyword_assoc(., .x)) %>% 
  group_by(key_word) %>% 
  mutate(feature = str_remove_all(feature, "[:digit:]"))

keys_wordstacks <- keys_assoc %>%
  slice_max(chi2, n = 10, with_ties = FALSE) %>%
  mutate(key_word = factor(key_word, levels = key_words)) %>% 
  ds4cs_wordstack(
    y = rank,
    x = chi2,
    size = log(chi2),
    label = feature,
    group = key_word,
    color = key_word,
    n_max = 10,
  ) +
  facet_wrap(~key_word, nrow= 2) +
  scale_color_manual(values = large_palette) +
  theme(axis.text = element_blank(),
        strip.text = element_text(size = 20),
        plot.margin = margin(r = 10, unit = "mm"),
        panel.spacing.y = unit(5, "mm")) +
  labs(x = NULL, y = "Ranked by effect size (chi²)", caption = "Data: MIA") +
  ggtitle("Capital Vol. I-III: Selected key words with their most associated terms",
          subtitle = "Terms ranked and size weighted by keyness statistic (chi²)")

keys_wordstacks
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-59-1.svg" width="960" />

Now that is quite a lot of detail! Too much to summarize in a paragraph or two. This is just the start with this type of analysis. The wordstack format can involve longer columns with fewer terms to get a more detailed view of the terms surrounding the keywords.


```r
keys_assoc %>% 
  filter(key_word %in% c("capital", "labour")) %>% 
  slice_max(chi2, n = 30, with_ties = FALSE) %>%
    ds4cs_wordstack(
    y = rank,
    x = chi2,
    size = log(chi2),
    label = feature,
    group = key_word,
    color = key_word,
    n_max = 40,
  ) + 
  facet_wrap(~key_word, nrow = 1) +
  scale_color_manual(values = large_palette) +
  labs(y = "Ranked by keyness", subtitle = "Terms ranked and size weighted by keyness statistic (chi²)")
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-60-1.svg" width="672" />

### Zooming in on Keywords in Context

Last, but not least, `quanteda` provides another great feature for isolating and examining document keywords in context with `kwic()`. Unlike the keyword-keyness method above, which provides a corpus-level overview of nearby terms related to keywords, this one allows the user to isolate and zoom in to get a detailed view of every use of the word in the text. 

Like the method above, finding keywords in context with `kwic()` requires a tokens object **with space padding between words intact**. If you want to use this method, make sure to keep the tokens with `remove_padding = FALSE` when both tokenizing and (if needed) removing stop words. Since we want to see the sentences as they are written in the book, we'll start by tokenizing the original corpus object, compounding strongly associated word pairings, and grouping it by book.


```r
# Using corpus, since it has nothing removed from it originally
cpe_tokens_withstop <- cpe_corpus %>%
  tokens(remove_numbers = TRUE, 
         remove_symbols = TRUE,
         remove_punct = TRUE)

cpe_tokens_withstop <- cpe_tokens_withstop %>%
  tokens_compound(cpe_coalloc[cpe_coalloc$z > 10]) %>% 
  tokens_group()
```

Calling `kwic()` on the `tokens` object will produce a dataframe table with each use of the target word and a windows of words before and after. Set the key word by supplying it as a string to the `pattern` argument; it's possible to look up multiple key words with wildcards or regular expressions. The `window` argument controls the number of words the target is surrounded by; so a window of 8 would have 4 words on either side of the key.

Use-value and exchange-value are the to two constituent elements of the commodity form. Every commodity must have *some* kind of use and also must have an exchange-value, which is ultimately expressed in terms of money. A newly built house isn't a home (use-value) to anyone until it is sold for money and it's exchange value it realized.


```r
# Use the tokens to create an object representing keywords in context
value_kwic <- cpe_tokens_withstop %>% 
  kwic(pattern = "exchange.value|use.value", valuetype = "regex", window = 8)

glimpse(value_kwic)
```

```
## Rows: 491
## Columns: 7
## $ docname <chr> "Capital, Vol. I", "Capital, Vol. I", "Capital, Vol. I", "Capi~
## $ from    <int> 198, 245, 268, 290, 307, 768, 784, 787, 808, 832, 841, 876, 89~
## $ to      <int> 198, 245, 268, 290, 307, 768, 784, 787, 808, 832, 841, 876, 89~
## $ pre     <chr> "The utility of a thing makes it a", "far as it is a material ~
## $ keyword <chr> "use_value", "use_value", "use_value", "use_values", "Use_valu~
## $ post    <chr> "But this utility is not a thing of", "something useful This p~
## $ pattern <fct> exchange.value|use.value, exchange.value|use.value, exchange.v~
```

By default, `kwic()` will return a dataframe with one row for every use of the search term in `pattern`. You can read through the first 30 uses of the phrases exchange value and use value in the corpus as a `kable` table below. With this keyword in context feature, you can zero in on keywords and even their strongly related terms to explore the meaning that they convey as written in the original documents. 


```r
library(kableExtra)
value_kwic %>%
  head(30) %>% 
  kable() %>% 
  kable_paper()
```

<table class=" lightable-paper" style='font-family: "Arial Narrow", arial, helvetica, sans-serif; margin-left: auto; margin-right: auto;'>
 <thead>
  <tr>
   <th style="text-align:left;"> docname </th>
   <th style="text-align:right;"> from </th>
   <th style="text-align:right;"> to </th>
   <th style="text-align:left;"> pre </th>
   <th style="text-align:left;"> keyword </th>
   <th style="text-align:left;"> post </th>
   <th style="text-align:left;"> pattern </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:right;"> 198 </td>
   <td style="text-align:left;"> The utility of a thing makes it a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> But this utility is not a thing of </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 245 </td>
   <td style="text-align:right;"> 245 </td>
   <td style="text-align:left;"> far as it is a material thing a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> something useful This property of a commodity is </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 268 </td>
   <td style="text-align:right;"> 268 </td>
   <td style="text-align:left;"> to appropriate its useful qualities When treating of </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> we always assume to be dealing with definite_quantities </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 290 </td>
   <td style="text-align:right;"> 290 </td>
   <td style="text-align:left;"> yards of linen or tons of iron The </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> of commodities furnish the material for a special </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 307 </td>
   <td style="text-align:right;"> 307 </td>
   <td style="text-align:left;"> study that of the commercial knowledge of commodities </td>
   <td style="text-align:left;"> Use_values </td>
   <td style="text-align:left;"> become a reality only by use or consumption </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 768 </td>
   <td style="text-align:right;"> 768 </td>
   <td style="text-align:left;"> affect the utility of those commodities make them </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> But the exchange of commodities is evidently an </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 784 </td>
   <td style="text-align:right;"> 784 </td>
   <td style="text-align:left;"> an act characterised by a total abstraction from </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> Then one use_value is just as good as </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 787 </td>
   <td style="text-align:right;"> 787 </td>
   <td style="text-align:left;"> by a total abstraction from use_value Then one </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> is just as good as another provided only </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 808 </td>
   <td style="text-align:right;"> 808 </td>
   <td style="text-align:left;"> sufficient quantity Or as old Barbon says As </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> commodities are above all of different qualities but </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 832 </td>
   <td style="text-align:right;"> 832 </td>
   <td style="text-align:left;"> and consequently do not contain an atom of </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> If then we leave out of consideration the </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 841 </td>
   <td style="text-align:right;"> 841 </td>
   <td style="text-align:left;"> If then we leave out of consideration the </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> of commodities they have only one common property </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 876 </td>
   <td style="text-align:right;"> 876 </td>
   <td style="text-align:left;"> in our hands If we make_abstraction from its </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> we make_abstraction at the same time from the </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 893 </td>
   <td style="text-align:right;"> 893 </td>
   <td style="text-align:left;"> material_elements and shapes that make the product a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> we see in it no longer a table </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 1095 </td>
   <td style="text-align:right;"> 1095 </td>
   <td style="text-align:left;"> manifests itself as something totally independent of their </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> But if we abstract from their use_value there </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 1102 </td>
   <td style="text-align:right;"> 1102 </td>
   <td style="text-align:left;"> their use_value But if we abstract from their </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> there remains their Value as defined above Therefore </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 1174 </td>
   <td style="text-align:right;"> 1174 </td>
   <td style="text-align:left;"> of value independently of this its form A </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> or useful article therefore has value only because </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 1939 </td>
   <td style="text-align:right;"> 1939 </td>
   <td style="text-align:left;"> in it A A thing can be a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> without having value This is the case whenever </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 1993 </td>
   <td style="text-align:right;"> 1993 </td>
   <td style="text-align:left;"> the produce of his own labour creates indeed </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> but not commodities In order to produce the </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2008 </td>
   <td style="text-align:right;"> 2008 </td>
   <td style="text-align:left;"> produce the latter he must not only produce </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> but use_values for others social use_values And not </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2010 </td>
   <td style="text-align:right;"> 2010 </td>
   <td style="text-align:left;"> latter he must not only produce use_values but </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> for others social use_values And not only for </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2014 </td>
   <td style="text-align:right;"> 2014 </td>
   <td style="text-align:left;"> only produce use_values but use_values for others social </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> And not only for others without more The </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2073 </td>
   <td style="text-align:right;"> 2073 </td>
   <td style="text-align:left;"> to another whom it will serve as a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> by means of an exchange Lastly nothing can </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2126 </td>
   <td style="text-align:right;"> 2126 </td>
   <td style="text-align:left;"> itself to us as a complex of two_things </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> and exchange value Later on we saw also </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2165 </td>
   <td style="text-align:right;"> 2165 </td>
   <td style="text-align:left;"> that belong to it as a creator of </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> I was the first to point out and </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2239 </td>
   <td style="text-align:right;"> 2239 </td>
   <td style="text-align:left;"> W the coat 2W The coat is a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> that satisfies a particular want Its existence is </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2296 </td>
   <td style="text-align:right;"> 2296 </td>
   <td style="text-align:left;"> which manifests itself by making its product a </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> we call useful_labour In this connection we consider </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2317 </td>
   <td style="text-align:right;"> 2317 </td>
   <td style="text-align:left;"> the coat and the linen are two qualitatively_different </td>
   <td style="text-align:left;"> use_values </td>
   <td style="text-align:left;"> so also are the two_forms of labour that </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2364 </td>
   <td style="text-align:right;"> 2364 </td>
   <td style="text-align:left;"> commodities Coats are not exchanged for coats one </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> is not exchanged for another of the same </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2520 </td>
   <td style="text-align:right;"> 2520 </td>
   <td style="text-align:left;"> account of private_individuals To resume then In the </td>
   <td style="text-align:left;"> use_value </td>
   <td style="text-align:left;"> of each commodity there is contained useful_labour i.e </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
  <tr>
   <td style="text-align:left;"> Capital, Vol. I </td>
   <td style="text-align:right;"> 2540 </td>
   <td style="text-align:right;"> 2540 </td>
   <td style="text-align:left;"> definite kind and exercised with a definite aim </td>
   <td style="text-align:left;"> Use_values </td>
   <td style="text-align:left;"> cannot confront each other as commodities unless the </td>
   <td style="text-align:left;"> exchange.value|use.value </td>
  </tr>
</tbody>
</table>

But there is even more that `quanteda` has to offer here! It also adds an extension for plotting the lexical dispersion of the target terms in the kwic dataframe. The `textplot_xray()` produces an x-ray chart that shows each instance of the target token across each document in the corpus. You can use a regular expression to look up multiple keywords separated by the or operator `"|"` and it will return a chart with the occurrences of every term in the look-up pattern. 


```r
kwic_value <- textplot_xray(kwic(cpe_tokens_withstop, pattern = "use_value|exchange_value", valuetype = "regex")) +
  aes(color = docname) +
  scale_color_manual(values = labels_colors$color, breaks = labels_colors$book) +
  theme(legend.position = 'none')

kwic_value
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-64-1.svg" width="672" />

To a plot faceted by many keywords at once, just pass multiple `kwic` objects to the plotting function. This last one is based on what we **didn't** find in any of the text analysis on the CPE corpus. Marx left us a scant few writings on what a communist society would be like or how to accomplish rearranging society in such a way; the little bit he did leave us, though, have great value. Unfortunately, in the CC, you won't find any reference to the political and economic aims of Communism. It's possible, with a thorough understanding of the CPE, to infer some things about an alternative society from the critique of capitalism. It's an exciting area of research that is more relavent than ever, so I hope to expand on it with some more text analysis in the future.


```r
kwic_rev_plot <- 
  textplot_xray(
    kwic(cpe_tokens_withstop, pattern = "communism", valuetype = "regex"),
    kwic(cpe_tokens_withstop, pattern = "socialism", valuetype = "regex")
  ) +
  aes(color = docname) +
  scale_color_manual(values = labels_colors$color, breaks = labels_colors$book) +
  theme(legend.position = "none")

kwic_rev_plot
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-65-1.svg" width="672" />


