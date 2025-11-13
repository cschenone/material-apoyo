#install.packages("openalexR")
library(openalexR)
library(dplyr)
library(knitr)

library(tidyverse)
library(datos)

#Los tibbles son data frames, pero modifican algunas características antiguas para hacernos la vida más fácil.
#La mayoría de los paquetes de R suelen usar data frames clásicos, así que algo que podrías querer hacer es convertir un data frame en un tibble.
#Esto lo puedes hacer con as_tibble()

# Caso en R usando openalexR

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

# Generate an OpenAlex query from a set of parameters
query <- oa_query(
  entity = entity,
  title.search = title.search,
  cited_by_count = cited_by_count,
  from_publication_date = from_publication_date,
  to_publication_date = to_publication_date,
  sort = sort,
  verbose = verbose
)

# La URL que se utiliza para consultar a la API
query

# It gets bibliographic records from OpenAlex database https://openalex.org/.
# The function oa_request queries OpenAlex database using a query formulated through the function oa_query.
# Value a data.frame or a list. Cada elemento de la lista contiene 

res <- oa_request(
  query_url = query,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

View(res) 

# Número de ítems recuperados por la consulta
n_items <- res$count

# Convert OpenAlex collection from list to data frame
# It converts bibliographic collections gathered from OpenAlex database https://openalex.org/
# into data frame.
# The function converts a collection of records about works, authors, institutions, venues
# or concepts obtained using oa_request into a data frame/tibble.

df <- oa2df(
  res, 
  entity = entity,     
  verbose = verbose    
)

# El resultado transformado en data frame
View(df)

# La cantidad de entidades recuperadas y sus atributos
dim(df)

# Los conceptos involucrados
View(df[[26]][[1]])






