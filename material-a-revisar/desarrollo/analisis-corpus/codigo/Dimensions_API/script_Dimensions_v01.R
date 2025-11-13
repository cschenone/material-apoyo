# Resultado: 18(01/2022. Se estima que el acceso concedido no permite acceder a la API, dado que,
# si bien se obtiene un token cuando se realiza una consulta no devuelve ningún resultado)
# Se intentó enviando un pedido de acceso a la API, se espera respuesta

# dimensionsR: A brief example. An R-package to gather bibliographic data from DS Dimenions.ai. 
# The goal of dimensionsR is to gather metadata about publications, grants, policy documents, and clinical trials from DS Dimensions using DSL API.
# The Dimensions Analytics API is limited to 30 requests per IP address per minute. The query token is valid for around 2 hours so it should be reobtained when it expires.

# Installation
# You can install the released version of dimensionsR from CRAN with:
  
install.packages("dimensionsR")

# Load the package
library(dimensionsR)

# First step: Generate a valid token
# The token is temporary and needs to be generated again after a few hours.

# Token by Dimensions credentials:
username = "your_username"
password = "your_password"
token <- dsAuth(username = username, password = password)

# Token by Dimensions API key:
# token <- dsAuth(key = "your_apikey")

# Second step: Write a valid query
# Dimensions defined a custom query language called Dimensions Search Language (DSL). You can choose to write a valid query using that language or, in alternaative, using the function dsQueryBuild.
# dsQueryBuild generates a valid query, written following the Dimensions Search Language (DSL), from a set of search parameters provided by the user.
# Following our example, we have to define a query to download metadata about: (1) a set of journal articles which (2) have used bibliometric approaches in their researches, (4) in the field of management sciences, (3) and have been published for the past 20 years.

# To write that query, we should set the function arguments as following:
  
# a set of journal articles
# item = “publications”
# type = “articles”

# have used bibliometric approaches in their researches
# words = “bibliometric*”

# in the field of management sciences
# categories = “management”

# documents published from 2000 to 2020:
# start_year = 2000
# end_year = 2020

# and finally, export the following fields
# output_fields = c(“basics”, “extras”, “authors”, “concepts”)
# (you could also export all database fields setting output_fields = “all”)

# "search publications in title_abstract_only  for \"\\\"bibliometric*\\\"\" where year in [ 1980 : 2020 ] and type in [ \"article\" ] and (category_for.name ~\"management\") return publications[type + basics + extras + authors + concepts]"
# A complete list of output items is available at https://docs.dimensions.ai/dsl/data-sources.html

# To write that query, we should set the function arguments as following
item = "publications" 
words = "bibliometric*" 
type = "article" 
categories = "management" 
start_year = 1980
end_year = 2020
output_fields = "all"
#output_fields = c("basics", "extras", "authors", "concepts")

# Passing all these arguments to the function dsQueryBuild, we obtain the final query
  
query <- dsQueryBuild(item = item, 
                        words = words, 
                        type = type, 
                        categories = categories, 
                        start_year = start_year, end_year = end_year,
                        output_fields = output_fields)

# Show the final query

query
