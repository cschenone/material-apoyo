#install.packages("openalexR")
library(openalexR)
library(dplyr)
library(knitr)

library(tidyverse)
library(datos)

library(httr)
#install.packages("rjson")
library(rjson)
library(curl)

#Los tibbles son data frames, pero modifican algunas características antiguas para hacernos la vida más fácil.
#La mayoría de los paquetes de R suelen usar data frames clásicos, así que algo que podrías querer hacer es convertir un data frame en un tibble.
#Esto lo puedes hacer con as_tibble()

#Caso en python (usando filter)
#dois = ["10.3322/caac.21660", "https://doi.org/10.1136/bmj.n71", "10.3322/caac.21654"]
#pipe_separated_dois = "|".join(dois)
#r = requests.get(f"https://api.openalex.org/works?filter=doi:{pipe_separated_dois}&per-page=50&mailto=support@openalex.org")
#works = r.json()["results"]

# Caso en R, usando la API Web

#Ejemplo de phyton

# specify endpoint

# build the 'filter' parameter
#filters = ",".join((
#  'institutions.ror:https://ror.org/02y3ad647',
#  'is_paratext:false',
#  'type:journal-article', 
#  'from_publication_date:2012-08-24'
#))

key_word_aux = 'artificial intelligence'
key_word <- curl_escape(key_word_aux) #La URI no puede contener espacios en blanco, se reemplazan por %20

endpoint_tit <- 'https://api.openalex.org/'
entity <- 'works'
sep1 <- '?'
endpoint <- paste0(endpoint_tit,entity,sep1)

filter_tit <- 'filter'
sep3 <- '='

title.search_tit <- 'title.search'
sep2 <- ':'
title.search_arg <- key_word
title.search <- paste0(title.search_tit,sep2,title.search_arg)

abstract.search_tit <- 'abstract.search'
sep2 <- ':'
abstract.search_arg <- key_word
abstract.search <- paste0(abstract.search_tit,sep2,abstract.search_arg)

fulltext.search_tit <- 'fulltext.search'
sep2 <- ':'
fulltext.search_arg <- key_word
fulltext.search <- paste0(fulltext.search_tit,sep2,fulltext.search_arg)

type_tit <- 'type'
sep4 <- ':'
type_arg <- 'journal-article'
type <- paste0(type_tit,sep4,type_arg)

from_publication_date_tit <- 'from_publication_date'
sep5 <- ':'
from_publication_date_arg <- '2012-04-20'
from_publication_date <- paste0(from_publication_date_tit,sep5,from_publication_date_arg)

#count_only_tit = 'count_only'
#count_only_sep = ':'
#count_only_val = 'TRUE'
#count_only = paste0(count_only_tit, count_only_sep, count_only_val)

#filter_arg = paste(title.search, abstract.search, fulltext.search, type, from_publication_date , count_only, sep = ',')

filter_arg <- paste(title.search, abstract.search, fulltext.search, type, from_publication_date, sep = ',')

filter <- paste0(filter_tit,sep3,filter_arg)

# put the URL together
filtered_works_url <- paste0(endpoint,filter)

#Complete URL with filters
filtered_works_url

# Solicitar la información.
# Por defecto, la API devuelve la primer pagina de información, conteniendo las primeras 25 entidades.
getdata <- httr::GET(url = filtered_works_url)
getdata

# Convert json object
getdata_json <- rjson::fromJSON(httr::content(getdata, type='text', encoding = 'UTF-8'))

# Metadados de la consulta, entre otros la cantidad de entidades recuperadas, y
# las páginas en las cuales se separan los resultados
meta <- getdata_json[1]
View(meta)

# Resultados de la consulta, agrupados en páginas,
# cada página es una lista de elementos, cdada elemento contiene los atributos de la entidad recuperada por la consulta
results <- getdata_json[2]
View(results)

head(results)

# Resultados de la consulta, en caso de haber definido una agrupación particular
group_by <- getdata_json[3]
View(group_by)
