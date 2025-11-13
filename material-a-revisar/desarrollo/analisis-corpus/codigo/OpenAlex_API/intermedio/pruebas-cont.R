## Se trasladan propuestas del documento functions-objetivo.r, con el objetivo de limpiar el documento original

#######################################################################################
# Analizar el criterio de búsqueda por PALABRAS CLAVE vs CONCEPTOS
#
# analizar si aporta algo más, considerando que anteriormente se buscaron los trabajos
# relacionados con el conjunto inicial, según la cercanía de conceptos.
#
######################################################################################
# op1: Buscar conceptos similares a las palabras incluidas como clave de búsqueda
# op2: Filtrar las observaciones cuyos conceptos sean de nivel 2 e inferior y recuperar
# trabajos con estos conceptos
# https://api.openalex.org/works?filter=concepts.id:C71924100,concepts.id:C154945302 (AND entre conceptos)
######################################################################################

# Obtener los conceptos de los trabajos
df_concepto <- df %>%
  filter(unnest(concepts), levels)

## Filtrar resultados según palabras
data <- df %>%
  filter(str_detect(df$publisher, "Chin"))

## Analizar el criterio de búsqueda por concepto

### Ejemplo: Get all works that have concepts "Medicine" and "Artificial Intelligence"
### (You can repeat a filter to create an AND query within a single attribute. Example:
### https://api.openalex.org/works?filter=concepts.id:C71924100,concepts.id:C154945302

## La estrategia debería ser: mostrar el concepto de mayor nivel y los conceptos relacionados, a fin de mejorar la búsqueda de trabajos relacionados
## a la temática

## Hallazgos
## en la variable works_api_url : se encuentra la sintaxis de la api que permite recuperar los trabajos donde se encuentre el concepto

## oa_query() arguments
entity = "concepts"
#sort = "cited_by_count:desc"
verbose = TRUE

## oa_query() filter arguments
#search = c("artificial intelligence", "hidrology")
search = c("artificial intelligence")
cited_by_count = ">50"
#from_publication_date = "2020-01-01"
#to_publication_date = "2021-12-31"

## oa_request() argument
per_page = 25
count_only = FALSE
mailto = "example@email.com"

## Estrategia:
### 1) busco la palabra clave en los conceptos (entity = "concepts")

#### Passing all these arguments to the function

query <- oa_query(
  entity = entity,
  search = search,
  #  cited_by_count = cited_by_count,
  #  from_publication_date = from_publication_date,
  #  to_publication_date = to_publication_date,
  #  sort = sort,
  verbose = verbose
)

res <- oa_request(
  query_url = query,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

#### La consulta devuelve los resultados ordenados por relevance_score

df <- oa2df(
  res, 
  entity = entity,
  verbose = verbose    
)

### 2) recupero la observación con el concepto con mayor relevancia

cmi2 <- df %>%
  slice(which.max(relevance_score))


### 3) recupero los trabajos relacionados con el concepto aplicando el endpoint de la variable works_api_url 

## oa_query() arguments
### Nota: la variable works_api_url contiene la url de búsqueda de trabajos representando el valor oa_query() de openalexR

## oa_request() argument
per_page = 200
count_only = FALSE
mailto = "example@email.com"

## Estrategia:
### 1) busco la palabra clave en los conceptos (entity = "concepts")

#### Passing all these arguments to the function

query <- cmi2$works_api_url

res <- oa_request(
  query_url = query,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

#### La consulta devuelve los resultados ordenados por relevance_score

df <- oa2df(
  res, 
  entity = entity,
  verbose = verbose    
)  


### 3) ordenar los trabajos de acuerdo al score correspondiente al concepto buscado


## Extraigo la lista de conceptos relacionados  
df_2 <- unnest(tibble(rc = df_1$related_concepts), rc)

df_3 <- filter(df_2, level ==1)

## OBJETIVO 1: Criterios generales:
### 1)a) recuperar los trabajos consultando por palabras clave en titulos, abstracts y full text.
#### 1)a)2) unir los resultados de varias búsquedas

## oa_query() arguments
entity = "works"
verbose = TRUE

## oa_query() filter arguments
search = c("artificial intelligence")

## oa_request() argument
per_page = 100
count_only = FALSE
mailto = "example@email.com"

# oa2f() arguments
abstract = TRUE
count_only = FALSE
group_by = NULL

works_search <- oa_fetch(
  entity = "works",
  search = search,
  cited_by_count = cited,
  from_publication_date = from_date,
  to_publication_date = to_date,
  sort = "cited_by_count:desc",
  verbose = TRUE,
  count_only = count_only
)

search <- count(works_search)

works_search_t <- oa_fetch(
  entity = "works",
  title.search = key_search,
  cited_by_count = cited,
  from_publication_date = from_date,
  to_publication_date = to_date,
  sort = "cited_by_count:desc",
  verbose = TRUE,
  count_only = count_only
)

works_search_a <- oa_fetch(
  entity = "works",
  abstract.search = key_search,
  cited_by_count = cited,
  from_publication_date = from_date,
  to_publication_date = to_date,
  sort = "cited_by_count:desc",
  verbose = TRUE,
  count_only = count_only
)

works_search_f <- oa_fetch(
  entity = "works",
  fulltext.search = key_search,
  cited_by_count = cited,
  from_publication_date = from_date,
  to_publication_date = to_date,
  sort = "cited_by_count:desc",
  verbose = TRUE,
  count_only = count_only
)

search_taf <- count(works_search_t) + count(works_search_a) + count(works_search_f)

r_search_ta <- union(works_search_t, works_search_a)
r_search_taf <- union(r_search_ta, works_search_f)

##########################################################################
# PRUEBA (si una búsqueda amplia incluye la búsqueda mas restrictiva)
##########################################################################

## Variables generales
limite_trabajos <- 10000

## oa_query() arguments
entity <- "works"
sort <- "relevance_score:desc,cited_by_count:desc" # Si usamos sort, debemos incluir relevance_score sino no aparece en el resultado
verbose <- TRUE

## oa_query() filter arguments
search1 <- "deep machine learning water"
search2 <- "deep machine learning water reservoir"
cited_by_count <- ">100"
from_publication_date <- "2018-01-01"
to_publication_date <- "2022-12-31"

## oa_request() argument
per_page <- 25
count_only <- TRUE
mailto <- "example@email.com"

# oa2df() arguments
abstract <- TRUE
group_by <- NULL

# Passing all these arguments to the function

query1 <- oa_query(
  entity = entity,
  search = search1,
  cited_by_count = cited_by_count,
  from_publication_date = from_publication_date,
  to_publication_date = to_publication_date,
  sort = sort,
  verbose = verbose
)

res1 <- oa_request(
  query_url = query1,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

query2 <- oa_query(
  entity = entity,
  search = search2,
  cited_by_count = cited_by_count,
  from_publication_date = from_publication_date,
  to_publication_date = to_publication_date,
  sort = sort,
  verbose = verbose
)

res2 <- oa_request(
  query_url = query2,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

res1 <- as_tibble(as.list(res1)) 
res2 <- as_tibble(as.list(res2)) 

if(res1$count <= limite_trabajos & res2$count <= limite_trabajos) {
  count_only <- FALSE
  
  ## Recupero los trabajos
  res1 <- oa_request(
    query_url = query1,
    per_page = per_page,
    count_only = count_only,
    mailto = mailto,
    verbose = verbose
  )
  
  df1 <- oa2df(
    res1, 
    entity = entity,
    count_only = count_only,  
    verbose = verbose    
  )
  
  cat("La consulta del conjunto de datos 1 recuperó", count(df1), "trabajos.")
  
  res2 <- oa_request(
    query_url = query2,
    per_page = per_page,
    count_only = count_only,
    mailto = mailto,
    verbose = verbose
  )
  
  df2 <- oa2df(
    res2, 
    entity = entity,
    count_only = count_only,  
    verbose = verbose    
  )
  
  cat("La consulta del conjunto de datos 2 recuperó", count(df2), "trabajos.")
  
  df <- union(df1, df2) # devuelve la unión; es decir, las observaciones de df1 y de df2 (quitando las posibles filas duplicadas)
  
} else {
  
  cat("La consultas recuperaron", res1$count, "y", res2$count, "trabajos.", "Superando en algún caso el máximo admitido de 10.000 trabajos")
  
}
