library (openalexR)

# Próximos Pasos
## Hallazgos:

# Hallazgos
## Si se incorporan las palabras clave de búsqueda en el titulo, abstract y full text con la restricción "AND"
## la búsqueda no devuelve resultados. Parece ser ¿demasiado restrictiva?
## Se propone mantener el criterio "AND" y realizar la búsqueda en full text

# Próximos pasos
## Contar las ocurrencias de palabras clave en cada documento, para utilizarlo como un criterio de pertenencia.
## Es decir un documento donde solamente figure una ocurrencia de las palabras clave, no parecería ser un trabajo donde se aborde el tema.
## Por lo cual se propondria un criterio de ocurrencia mayor a 10 veces. Para lo cual se podría ajustar el número comparando con documentos
## donde seguro aborden un tema (por ejemplo filtrando por titulo y abstract) y luego contar la cantidad de ocurrencias de las palabras clave,
## así se podría encontrar una cantidad mínima de ocurrencias.

## Archivo de trabajo: Script_de_trabajo_n-gramas_Red_semantica

# Clave: mirar en los n-gramas
## Otra posiblidad es usar Palabras clave en los filtros y Conceptos.
## Hallazgos: No todos los trabajos indexados en OpenAlex cuentan con n-gramas. Entonces no parece un criterio correcto para tomas decisiones.

# Caso en R usando openalexR

## oa_query() arguments
entity = "works"
sort = "cited_by_count:desc"
verbose = TRUE

## oa_query() filter arguments
#title.search = c("artificial intelligence", "environmental science") # Lo traduce como OR con el simbolo "|"
#title.search = 'artificial intelligence|environmental science' # Otra forma de armar la expresión

keywords_search1 = c("artificial intelligence", "machine learning", "deep learning") # Lo traduce como OR
keywords_search2 = c("water", "water resources") # Lo traduce como OR

#search1 = 'artificial intelligence, environmental science' # Busca en titulo, abstract y fulltext
#search2 = 'science' # Busca en titulo, abstract y fulltext

cited_by_count = ">50"
from_publication_date = "2020-01-01"
to_publication_date = "2021-12-31"

## oa_request() argument
per_page = 200
count_only = TRUE
mailto = "example@email.com"

# oa2f() arguments
abstract = TRUE
group_by = NULL

# Passing all these arguments to the function

# Generate an OpenAlex query from a set of parameters
query <- oa_query(
  entity = entity,
#  title.search = keywords_search1,
#  title.search = keywords_search2,
#  abstract.search = keywords_search1,
#  abstract.search = keywords_search2,
  fulltext.search = keywords_search1,
  fulltext.search = keywords_search2,
  cited_by_count = cited_by_count,
  from_publication_date = from_publication_date,
  to_publication_date = to_publication_date,
  sort = sort,
  verbose = verbose
)

query

res <- oa_request(
  query_url = query,
  per_page = per_page,
  count_only = count_only,
  mailto = mailto,
  verbose = verbose
)

# Número de ítems recuperados por la consulta
n_items <- res$count

n_items


