# Prueba de filtro utilizando:

# Calling the API in your browser
# Because the API is all GET requests without fancy authentication, you can view any request in your browser.
# This is a very useful and pleasant way to explore the API and debug scripts; we use it all the time. 
# However, this is much nicer if you install an extension to pretty-print the JSON; JSONVue (Chrome) and JSONView (Firefox) are popular, free choices. Here's what an API response looks like with one of these extensions enabled

## The polite pool
#The polite pool has much faster and more consistent response times. It's a good place to be. 
#To get into the polite pool, you just have to give us an email where we can contact you.
#
#You can give us this email in one of two ways:
#Add the mailto=you@example.com parameter in your API request, like this:
#https://api.openalex.org/works?mailto=you@example.com
#
#Add mailto:you@example.com somewhere in your User-Agent request header.

#library(openalexR)
#library(dplyr)
#library(knitr)
library(httr)
#install.packages('rjson')
library(rjson)
library(curl)

q1 <- 'https://api.openalex.org/'
q2 <- 'works?'
q4 <- 'filter='
url2 <- paste(q1, q2, q4, sep = '')

q5 <- 'cited_by_count:>50'
url3 <- paste(url2,q5, sep = '')

q6 <- 'abstract.search:'
url4 <- paste(url3,q6, sep = ',')


q7 <- 'artificial intelligence'
q8 <- curl_escape(q7) # La URI no puede contener espacios en blanco, se reemplazan por %20

url5 <- paste(url4,q8, sep = '') 

url5
url_query <- url5

openalex_works <- httr::GET(url = url_query, add_headers('mailto=you@example.com'))
openalex_works

meta <- openalex_works_GET[['url']]

View(openalex_works_GET)

