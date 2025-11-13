# openalexR helps you interface with the OpenAlex API to retrieve bibliographic infomation about publications, authors, venues, institutions and concepts with 5 main functions:
# oa_fetch: composes three functions below so the user can execute everything in one step, i.e., oa_query |> oa_request |> oa2df
# oa_query: generates a valid query, written following the OpenAlex API syntax, from a set of arguments provided by the user.
# oa_request: downloads a collection of entities matching the query created by oa_query or manually written by the user, and returns a JSON object in a list format.
# oa2df: converts the JSON object in classical bibliographic tibble/data frame.
# oa_random: get random entity, e.g., oa_random("works") gives a different work each time you run it

# Setup
#You can install the developer version of openalexR from GitHub with:
# install.packages("remotes")
# remotes::install_github("massimoaria/openalexR")

# You can install the released version of openalexR from CRAN with:
#install.packages("openalexR")

# You can install the released version of rmarkdown from CRAN with:
#install.packages("rmarkdown")

# Optional configurations 
# Before we go any further, we highly recommend you set openalexR.mailto option so that your requests go to the polite pool for faster response times:
# Bonus point if you put this in your .Rprofile with file.edit("~/.Rprofile").

options(openalexR.mailto = "example@email.com")

# Load library
library(openalexR)
library(dplyr)
library(ggplot2)
library(knitr)
library(bibliometrix)

# Goal
#  retrieve all works that
#  have been cited more than 50 times
#  published between 2020 and 2021
#  include the strings “bibliometric analysis” or “science mapping” in the title
#  sorted by total citations in a descending order

# To write that query, we should set the functions arguments as following

## oa_query() arguments
entity = "works"
sort = "cited_by_count:desc"
verbose = TRUE

## oa_query() filter arguments
title.search = c("artificial intelligence", "hidrology")
cited_by_count = ">50"
from_publication_date = "2020-01-01"
to_publication_date = "2021-12-31"

## oa_request() argument
per_page = 200
count_only = FALSE
mailto = "example@email.com"

# oa2f() arguments
abstract = TRUE
count_only = FALSE
group_by = NULL

# Passing all these arguments to the function

query <- oa_query(
  entity = entity,
  title.search = title.search,
  cited_by_count = cited_by_count,
  from_publication_date = from_publication_date,
  to_publication_date = to_publication_date,
  sort = sort,
  verbose = verbose
)

res <- oa_request(
  query_url = query,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

df <- oa2df(
  res, 
  entity = entity,     
  verbose = verbose    
)

df_authors <- oaWorks2df(
  res, 
  entity = entity,     
  verbose = verbose    
)


#EDA de los resultados usando funciones de R
dim(df)[1]
str(df)
head(df)


M <- oa2bibliometrix(df)

results <- biblioAnalysis(M, sep =";")

options(width=100)
summary(results, k = 10, pause = FALSE)

# Meta-datos de un trabajo
# No se observan palabras clave

paper_meta <- oa_fetch(
  identifier = "W2755950973",
  entity = "works",
  endpoint = "https://api.openalex.org/",
  count_only = TRUE,
  abstract = TRUE,
  verbose = TRUE
)

head(paper_meta)
View(paper_meta)

# Analisis de n-gramas
# An n-gram is a set of words that occur in a document. For example, in the sentence “the quick brown fox jumped”, a 3-gram would be “quick brown fox” and a bigram would be “brown fox”.

#Caso de análisis para filtros (atributo filter)
#Objetivo lograr identificar la sintaxis de los operadores lógicos en title.search, para luego aplicarlo al resto de los filtros (abstract.search, document.search y fulltext.search)

oa_fetch(
  entity = "works",
  title.search = c("bibliometric analysis", "science mapping"),
  cited_by_count = ">50",
  from_publication_date = "2020-01-01",
  to_publication_date = "2021-12-31",
  sort = "cited_by_count:desc",
  verbose = TRUE
) %>%
  show_works() %>%
  knitr::kable()

#url: https://api.openalex.org/works?filter=title.search:bibliometric analysis|science mapping,cited_by_count:>50,from_publication_date:2020-01-01,to_publication_date:2021-12-31&sort=cited_by_count:desc

#Caso de análisis para search (atributo search)

oa_fetch(
  entity = "works",
  search = "artificial intelligence | hidrology",
  cited_by_count = ">50",
  from_publication_date = "2020-01-01",
  to_publication_date = "2021-12-31",
  sort = "cited_by_count:desc",
  verbose = TRUE
) %>%
  show_works() %>%
  knitr::kable()

