---
title: Here is a test post
author: Ryan Romard
date: '2021-05-06'
slug: here-is-a-test-post
categories: []
tags: [test]
subtitle: 'I have always wanted a sub-title'
summary: 'This is a summary'
authors: []
lastmod: '2021-05-06T18:57:44-04:00'
featured: no
image:
  caption: ''
  focal_point: ''
  preview_only: no
projects: []
commentable: true
---

Test posts are really great, everyone loves them.

Maybe in _my_ post I will __do__ some R chunks


```r
library(ggplot2)
```

```
## Warning: package 'ggplot2' was built under R version 4.0.5
```

```r
plotto <- ggplot(Orange, aes(x = age, 
                   y = circumference, 
                   colour = Tree)) +
  geom_point() +
  geom_line() +
  guides(colour = FALSE) +
  theme_bw()

plotto
```

<img src="{{< blogdown/postref >}}index_files/figure-html/unnamed-chunk-1-1.png" width="672" />
