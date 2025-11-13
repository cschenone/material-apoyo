# HALLAZGOS
------------
  
## Problema: Sucede un error cuando se realizan consultas de grandes volúmenes (aproximadamente 35.000 trabajos o más, resultando en un peso aproximado de 2GB)  
### Alternativa 1: Explorar el cliente Python. Resultado: luego de la exploración no parece mas simple.
### Alternativa 2: Separar las consultas. Se opta por separar las consultas en titulo, abstract y full-text.

## Estrategia para búsquedas por palabras o frases tomadas como palabras
### 1) search devuelve los mismos resultados que aplicar search por separado en search.title, search.abstract y search.fulltext
### 2) search solo devuelve "relevance_score" si el único argumento es search (se validó que no devuelve relevance_score si
### se aplican filtros de búsqueda y/o ordenamiento; por lo cual se deberán aplicar los filtros y ordenamiento posteriormente, al tibble recuperado)
### 3) search en la clave de búsqueda: si no se usan comillas para buscar una frase el algoritmo busca las palabras en el documento y 
### puntúa (en relevance_score) de acuerdo a la cercanía.
### 4) search busca en todas las palabras clave incorporadas en la clave de búsqueda, puntuando la cercanía en "relevance_score" 

## Estrategias para buscar trabajos relacionados a partir de frases (una palabra, junto a grupos de más de una palabra)
### 1) Buscar todos los trabajos que contengan determinados conceptos, ordenados por cercanía (relevance_score) con las palabras utilizadas en la búsqueda
### Ejemplo: https://api.openalex.org/concepts?search=water%20resources
### Resultado: un conjunto de links, del estilo: https://explore.openalex.org/concepts/C153823671, cuya información es la siguiente:
### Conceptos ancestros y relacionados
### Trabajos vinculados: https://api.openalex.org/works?filter=concepts.id:C153823671

### 2) Buscar todos los trabajos que contengan determinados conceptos.
### Por ejemplo: Get all works that have concepts "Medicine" and "Artificial Intelligence" (You can repeat a filter to create an AND query within a single
### attribute.
### Ejemplo: https://api.openalex.org/works?filter=concepts.id:C71924100,concepts.id:C154945302

# Notas para ayudar a retomar el tema:
## Seguir el link: https://docs.openalex.org/how-to-use-the-api/get-lists-of-entities/search-entities

# PRUEBAS A REALIZAR:
## Avanzar con los criterios para complementar la evaluación de importancia de un trabajo: 
## 1) Categorización: Se deberán considerar elementos complementarios:
## Analizar como resaltar la disponibilidad de abstract (debido a que no todos los trabajos disponen el abstract entre los metadatos)
## Analizar como resaltar la disponibilidad de fulltext (debido a que openalex permite acceder al fulltext a través de la indexación de palabras,
## pero no todos los trabajos cuentan con el análisis del texto completo)
## 2) Ordenamiento: ordenar los trabajos según cada criterio y luego, tomar el orden del trabajo para armar un indice,
## re-ordenando finalmente los trabajos según este nuevo indice.

## Criterios a analizar:
### a) ngramas (sumar la cantidad de apariciones de ngramas que coincidan con la clave de búsqueda (se encuentra la cantidad de ocurrencias de cada palabra),
#### a.1) en el campo title
#### a.2) en el campo abstract (ver el atributo abstract_inverted_index)
#### a.3) en el campo fulltext (definir ¿que pasa si no dispone del campo fulltext?, ¿se penaliza?)
### b) relevance_score (disponible si se busca una entidad utilizando "search")
### c) cantidad de citas (SI, podria aplicar cited_by_count, dado que el argumento se encuentra en las entidades)
### d) importancia del autor (ver como puntuar al autor, atributos internos: cited_by_count
### Integer: The total number  Works that cite a work this author has created.)
### e) importancia de la institución (ver como puntuar a la institución, atributos internos:
### Integer: The total number Works that cite a work created by an author affiliated with this institution.
### Or less formally: the number of citations this institution has collected.

## PENDIENTES
### (OK) 1) El uso de Search considera:
#### - Todas las palabras clave (puntúa de acuerdo a la cercanía de palabras)
#### - Busca en titulo, abstract y full text.
#### - Agrega un atributo "relevance_score" en orden descendiente de acuerdo Relevance score. WWhen you use search, each returned entity
#### in the results lists gets an extra property called relevance_score, and the list is by default sorted in descending order of
#### relevance_score. The relevance_score is based on text similarity to your search term. It also includes a weighting term for
#### citation counts: more highly-cited entities score higher, all else being equal.
#### If you search for a multiple-word phrase, the algorithm will treat each word separately, and rank results higher when the words appear
#### close together. If you want to return only results where the exact phrase is used, just enclose your phrase within quotes. 
#### Entrega N-grams (si están disponibles). Fulltext search is powered by an index of word sequences called n-grams
#### see Get N-grams for more details.

#### ANALIZAR LO SIGUIENTE:
#### For example: Get works with the words "fierce" and "creatures" in the title or abstract, with works that have the two words close together
#### ranked higher by relevance_score (returns way more results)
#### Esto abre una posibilidad para buscar por palabras independientes y tomar los resultados que tengan mayor relevance_score

#################################################################################
# Install and load packages and library
#################################################################################

# Install openalexR released version 
# install.packages("openalexR")

# install openalexR developer version of from github
# Nota: la version en desarrollo incorpora funciones de conversión que la versión liberada no dispone, por ejemplo "oa2bibliometrix"
install.packages("remotes")
# A full package to gather bibliographic metadata about publications, authors, venues, institutions, and concepts from OpenAlex using API.
# (Aria, M. and Cuccurullo, C. (2022). openalexR: Gathering Bibliographic Records from ‘OpenAlex’ Database Using ‘DSL’ API. R package version 0.0.1. https://github.com/massimoaria/openalexR).
remotes::install_github("ropensci/openalexR")
install.packages("bibliometrix")
install.packages("dplyr") # Data transformation
install.packages("stringr") # String manipulation
install.packages("tidyr") # Data tidying 
install.packages("timechange") # Date manipulation

# Bibliometry packets
library(openalexR) # helps you interface with the OpenAlex API to retrieve bibliographic infomation from Open Alex (fully open catalog of the global research system)
library(bibliometrix) # A full package for Science Mapping Workflow

## Before we go any further, we highly recommend you set openalexR.mailto option so that your requests go to the polite pool for faster response times. If you have OpenAlex Premium, you can add your API key to the openalexR.apikey option as well. These lines best go into .Rprofile with file.edit("~/.Rprofile").
options(openalexR.mailto = "example@email.com")
options(openalexR.apikey = "EXAMPLE_APIKEY")

# Data Science packets

library(dplyr) # Data transformation
library(stringr) # String manipulation
library(tidyr) # Data tidying 
library(tidyverse) # Data tidying 
library(lubridate)

## OBJETIVO 1: CONTRUIR EL CORPUS (tomando como criterio de búsqueda las palabras clave)
## (OK) OBJETIVO 1)A): Criterios generales: recuperar los trabajos consultando por palabras clave en titulos, abstracts y full text.
### The search query parameter finds results that match a given text search. When you search works, the API looks for matches in titles, abstracts, and fulltext

## OBJETIVO 1)B): Criterios ampliados: complementar los trabajos hallados utilizando facilidades propias de la base de datos OpenAlex
### (OK) 2)a) snowballing: recuperar trabajos "citados por" y "que citen a".
### 2)b) trabajos que comparten conceptos.

# OBJETIVO 2: CATEGORIZAR EL CORPUS
## NOTA: definir un criterio para valorizar los hallazgos (puede ser el atributo cited_by_count)
## Evaluar si se podría mejorar con una polinómica que contemple otros parámetros, por ejemplo:

## En General
### cited_by_count
### puntos por autor
### puntos por institución
### puntos por cantidad de aparición de palabras

## Específicos de Openalex
### relevance_score (tener en cuenta que solamente se calcula cuando se realiza la búsqueda inicial utilizando la clave "search")

#################################################################################
# DESARROLLO DE LA INVESTIGACIÓN
#################################################################################

## Restricciones

## OBJETIVO 1: Criterios generales:
### 1)a) Analizar los búsquedas cuyas observaciones no superen los 10.000 trabajos

### 1)b) recuperar los trabajos consultando por palabras clave en titulo, abstract y full text.
### (include the strings in the title, abstract or full text)
### The search query parameter finds results that match a given text search. When you search works, the API looks for matches in titles, abstracts, and fulltext
### Nota: recordar que el argumento relevance_score se genera solamente si no se incorporan filtros en la consulta

### 1)c) trabajos citados más de 50 veces (have been cited more than 50 times)
### 1)d) trabajos cuya fecha de publicación no supere los 5 (cinco) años (published between 2018 and 2023)

#################################################################################
# The filter query parameter
#################################################################################
### find results by attributes cited_by_count = ">50", from_publication_date = "2018-01-01", to_publication_date = "2023-12-31"
### descendent order results by atributes relevance_score and cited_by_count

# Function definition

#################################################################################################
## Function: contar_wks
## Descripción: Consultar la cantidad de trabajos recuperados para los criterios búsqueda definidos en los argumentos
## Ejemplo: contar_wks(keywords = "bibliometrix", cited = ">50", from_date = "2019-01-01", to_date = "2022-31-12", limit_wks = 1000)
#################################################################################################

contar_wks <- function(searchkeys, cited=">50", from_date=today()-years(5), to_date=today(), limit_wks = 1000) {
  # Desc: Consultar la cantidad de trabajos recuperados para los criterios búsqueda definidos en los argumentos
  # Args:
  # * searchkeys: palabras clave utilizadas en la búsqueda. En caso de requerir la búsqueda por criterios múltiples,
  #   deberá separar cada frase con el operador // (operador "OR"). Formato: "keywords 1" // "keywords 2" // "keywords 3".
  #   En cada búsqueda se calcula la variable "relevance_score" de acuerdo a la cercanía de palabras encontradas. 
  #   Ejemplo: "machine learning water // deep learning water".
  # * cited: limite de citas de los trabajos. Formato "Operador lógico" + "Número". Ejemplo ">=100". Valor por defecto: ">50"
  # * from_date: fecha inferior de publicación. Formato "AAAA-MM-DD". Valor por defecto: 5 años hacia atrás de la fecha actual
  # * to_date: fecha máxima de publicación. Formato "AAAA-MM-DD". Valor por defecto: la fecha actual
  # * limit_wks : límite de trabajos a recuperar en la búsqueda. Valor por defecto: 10000
  # Resp:
  # * resp : un dataframe conteniendo los criterios de búsqueda y la cantidad de trabajos recuperados por cada criterio. En caso
  #   que la cantidad de trabajos supere el límite. La función lo informa con un mensaje.
  #   Ejemplo: contar_wks(keywords = "bibliometrix", cited = ">50", from_date = "2019-01-01", to_date = "2022-31-12", limite_wks = 5000)
  
  # Inicialización de variables  
  df_kwords_wks <- tibble(NULL) # Dataframe contenedor de la cantidad de resultados para un criterio de búsqueda 
  df_ksearch_wks <- tibble(NULL) # Dataframe contenedor de la cantidad de resultados para todos los criterios de búsqueda 
  
  # Validación de los argumentos
  if (is.null(searchkeys)) {
    message("No ingresó ninguna palabra o frase de búsqueda. Por favor intente nuevamente ingresando algún criterio")
    message("Ejemplo: buscar_wks(keywords = bibliometrix, cited = >50, from_date = 2019-01-01, to_date = 2022-31-12")
    Return(bind_cols(searchkeys = df_ksearch_wks))
  }  
  
  if (!is.Date(from_date) || !is.Date(from_date)) {
    message("La fecha del intervalo debe ser una fecha en el formato YYYY-MM-DD")
    Return(bind_cols(searchkeys = df_ksearch_wks))
  } else if(from_date > to_date) {
    message("La fecha inicial del intervalo debe ser inferior o igual a la fecha final. Se invierten las fechas.")
    from_date <- from_date_ant
    from_date <- to_date
    to_date <- from_date_ant
  }
  
  if (is.null(cited)) {
    message("No ingresó un valor para cantidad mínima de citas, se asigna el valor por defecto: >50")
    cited <- ">50"    
  } else if(is.integer(cited)) {
    message("No ingresó un operador lógico junto a la cantidad de citas, se supone que desea filtar según cantidad de citas mínima.")
    cited <- paste0(">",cited)
  }
  
  ## oa_query() arguments
  cat("Vamos a realizar una búsqueda en OpenAlex utilizando los siguientes criterios:")
  cat("Palabras clave a buscar en el título, abstract o full text:", searchkeys)
  cat("Cantidad de citas:", cited)
  cat("Trabajos publicados entre", from_date,"y", to_date)
  
  # Analiza la cadena de búsqueda, en caso de encontrar el operador "&&" (operador "AND") lo remueve, dado que la búsqueda lo aplica por defecto.
  # En caso de encontrar el operador "//" (operador "OR") lo utiliza para partir la frase de búsqueda, luego realiza la búsqueda en forma separada y reúne el conjunto resultante.
  # keywords <- "deep   learning  && water   //   machine learning intelligence water"
  
  searchkeys <- searchkeys %>%
    str_remove("&&") %>%
    str_squish() # removes whitespace at the start and end, and replaces all internal whitespace with a single space
  
  split_searchkey <- tibble(wordskey = str_split(searchkeys, " // ")) %>%
    unnest(cols = c(wordskey))
  
  # Antes de realizar la consulta, validamos que la cantidad de trabajos a recuperar no supere el límite establecido
  
  for (phrasekey in split_searchkeys$wordskey) {
    args <- list(
      entity = "works",
      search = phrasekey,
      cited_by_count = cited,
      from_publication_date = from_date,
      to_publication_date = to_date,  
      sort = "relevance_score:desc, cited_by_count:desc", # Ordenamos el conjunto por cantidad de citas y relevance_score
      mailto = "example@email.com",
      verbose = TRUE,
    )
    
    # Passing all these arguments to the function
    query_wks <- do.call(oa_query, args) # Genero la string de consulta considerando el criterio de búsqueda seleccionado
    
    # Búsqueda de trabajos
    res_wks <- do.call(oa_request, c(per_page = 25, count_only = "TRUE")) # Solo necesitamos conocer la cantidad de trabajos ("count_only = TRUE")
    cant_wks <- as_tibble(as.list(res_wks))$count # Cantidad de trabajos recuperados en la consulta
    cat("El criterio de búsqueda", phrasekey, " encontró ", cant_wks, "trabajos.")
    
    df_kwords_wks <- tibble(cant = c(df_kwords_wks, cant_wks)) # Guardo los resultados en un tibble
    
    total_wks <- sum(df_kwords_wks) # Cantidad de trabajos acumulados para los criterios de búsqueda procesados
    
    if(total_wks > limit_wks) {
      # La cantidad acumulada supera la cantidad máxima de trabajos
      message("La cantidad de trabajos acumulada supera el límite, establecido en ", limit_wks)
      df_ksearch_wks <- bind_cols(split_searchkey, df_kwords_wks) # reúno en un dataframe las palabras clave y la cantidad de trabajos
      cat("Por favor revise los criterios y repita la búsqueda")
    }
    
  }
  Return(searchkeys = df_ksearch_wks)
}

# Ejemplo de uso de la función contar_wks

## Setting arguments

### General variables
limit_wks <- 10000 # Cantidad máxima de trabajos a procesar

### Query filter arguments
search_key <- "deep machine learning water || deep machine learning water reservoir"
cited_by_count <- ">50"
from_publication_date <- "2018-01-01"
to_publication_date <- "2022-12-31"

## Retriving count works from OpenAlex by filter criteria
search_wks <- contar_wks(searchkeys = search_key, cited = cited_by_count, from_date = from_publication_date, to_date = to_publication_date, limit_wks)

## Presentación anticipada de los resultados
if (sum(search_wks$cant) > limit_wks) {
  cat("La cantidad de trabajos total recuperada supera la cantidad límite establecida en ", limit_wks, " trabajos")
} else {
  cat("La consulta recuperó la siguiente cantidad de trabajos para cada criterio de búsqueda")
  print(search_wks)
}   

###############################################################################################################
## Función: buscar_wks
## Descripción: Recuperar trabajos indexados en la base de datos OpenAlex según los criterios de búsqueda pasados como argumentos
## Ejemplo: buscar_wks(keywords = "bibliometrix", cited = ">50", from_date = "2019-01-01", to_date = "2022-31-12")
###############################################################################################################

buscar_wks <- function(searchkeys, cited=">50", from_date=today()-years(5), to_date=today(), limit_wks = 10000) {
  # Desc: Recuperar trabajos indexados en la base de datos OpenAlex según los criterios de búsqueda pasados como argumentos
  # Args:
  # * searchkeys: palabras clave a utilizar como criterios de búsqueda. En caso de necesitar múltiples criterios,
  #   deberá separar cada frase con el operador "//" (operador "OR"), por ejemplo, "keywords // keywords // keywords".
  #   En cada búsqueda se calcula la variable "relevance_score" de acuerdo a la cercanía de palabras encontradas. 
  #   Ejemplo: "machine learning water // deep learning water".
  # * cited: limite de citas de los trabajos. Formato "Operador lógico" + "Número". Ejemplo ">=100". Valor por defecto: ">50"
  # * from_date: fecha inferior de publicación. Formato "AAAA-MM-DD". Valor por defecto: 5 años hacia atrás de la fecha actual
  # * to_date: fecha máxima de publicación. Formato "AAAA-MM-DD". Valor por defecto: la fecha actual
  # * limit_wks : límite de trabajos a recuperar en la búsqueda. Valor por defecto: 10000
  # Resp:
  # * Un dataframe conteniendo los siguientes dataframes:
  #   * works : los trabajos que cumplen con los criterios, en el formato OpenAlex. "NA" en caso que no se realice la búsqueda
  #   debido a un error en los argumentos o se haya superado la cantidad de trabajos permitida.
  #   Nota: para guardar compatibilidad con el modelo de datos oa_snowball y oa_related se agrega las columnas "role" e "id_origin" 
  #   * searchkeys : los criterios de búsqueda y la cantidad de trabajos recuperados por cada criterio.
  #   Ejemplo: buscar_wks(keywords = "bibliometrix", cited = ">50", from_date = "2019-01-01", to_date = "2022-31-12", limite_wks = 5000)

  # Inicialización de variables  
  df_wks <- tibble(NA) # Dataframe contenedor de los trabajos recuperados por un criterio de búsqueda
  df_res_wks <- tibble(NA) # Dataframe contenedor de los trabajos recuperados para todos los criterios de búsqueda
  df_kwords_wks <- tibble(NULL) # Dataframe contenedor de la cantidad de resultados para un criterio de búsqueda 
  df_ksearch_wks <- tibble(NULL) # Dataframe contenedor de la cantidad de resultados para todos los criterios de búsqueda 
    
  # Validación de los argumentos
  if (is.null(searchkeys)) {
    message("No ingresó ninguna palabra clave. Por favor intente nuevamente ingresando alguna palabra")
    message("Ejemplo: buscar_wks(keywords = bibliometrix, cited = >50, from_date = 2019-01-01, to_date = 2022-31-12")
    Return(bind_cols(works = df_res_wks, searchkeys = df_ksearch_wks))
  }  
  
  if (!is.Date(from_date) || !is.Date(from_date)) {
    message("La fecha del intervalo debe ser una fecha en el formato YYYY-MM-DD")
    Return(bind_cols(works = df_res_wks, searchkeys = df_ksearch_wks))
  } else if(from_date > to_date) {
      message("La fecha inicial del intervalo debe ser inferior o igual a la fecha final. Se invierten las fechas.")
      from_date <- from_date_ant
      from_date <- to_date
      to_date <- from_date_ant
  }
  
  if (is.null(cited)) {
    message("No ingresó un valor para cantidad mínima de citas, se asigna el valor por defecto: >50")
    cited <- ">50"    
  } else if(is.integer(cited)) {
    message("No ingresó un operador lógico junto a la cantidad de citas, se supone que desea filtar según cantidad de citas mínima.")
    cited <- paste0(">",cited)
  }
  
  ## oa_query() arguments
  cat("Vamos a realizar una búsqueda en OpenAlex utilizando los siguientes criterios:")
  cat("Palabras clave a buscar en el título, abstract o full text:", searchkeys)
  cat("Cantidad de citas:", cited)
  cat("Trabajos publicados entre", from_date,"y", to_date)
  
  # Analiza la cadena de búsqueda, en caso de encontrar el operador "&&" (operador "AND") lo remueve, dado que la búsqueda lo aplica por defecto.
  # En caso de encontrar el operador "//" (operador "OR") lo utiliza para partir la frase de búsqueda, luego realiza la búsqueda en forma separada y reúne el conjunto resultante.
  # keywords <- "deep   learning  && water   //   machine learning intelligence water"
  
  searchkeys <- searchkeys %>%
    str_remove("&&") %>%
    str_squish() # removes whitespace at the start and end, and replaces all internal whitespace with a single space
  
  split_searchkey <- tibble(wordskey = str_split(searchkeys, " // ")) %>%
    unnest(cols = c(wordskey))

  # Antes de realizar la consulta, validamos que la cantidad de trabajos a recuperar no supere el límite establecido

  for (phrasekey in split_searchkeys$wordskey) {
    args <- list(
      entity = "works",
      search = phrasekey,
      cited_by_count = cited,
      from_publication_date = from_date,
      to_publication_date = to_date,  
      sort = "relevance_score:desc, cited_by_count:desc", # Ordenamos el conjunto por cantidad de citas y relevance_score
      mailto = "example@email.com",
      verbose = TRUE,
    )
    
    # Passing all these arguments to the function
    query_wks <- do.call(oa_query, args) # Genero la string de consulta considerando el criterio de búsqueda seleccionado
    
    # Búsqueda de trabajos
    res_wks <- do.call(oa_request, c(per_page = 25, count_only = "TRUE")) # Solo necesitamos conocer la cantidad de trabajos ("count_only = TRUE")
    cant_wks <- as_tibble(as.list(res_wks))$count # Cantidad de trabajos recuperados en la consulta
    cat("El criterio de búsqueda", phrasekey, " encontró ", cant_wks, "trabajos.")
    
    df_kwords_wks <- tibble(cant = c(df_kwords_wks, cant_wks)) # Guardo los resultados en un tibble
    
    total_wks <- sum(df_kwords_wks) # Cantidad de trabajos acumulados para los criterios de búsqueda procesados
    
    if(total_wks > limit_wks) {
      # La cantidad acumulada supera la cantidad máxima de trabajos
      message("La cantidad de trabajos acumulada supera el límite, establecido en ", limit_wks)
      df_ksearch_wks <- bind_cols(split_searchkey, df_kwords_wks) # reúno en un dataframe las palabras clave y la cantidad de trabajos
      Return(bind_cols(works = df_res_wks, searchkeys = df_ksearch_wks))
      cat("Por favor revise los criterios y repita la búsqueda", df_ksearch_wks)
    }
    
  }
  
  # Si la cantidad de trabajos recuperados para cada uno de los criterios no supera el límite establecido, se procede a realizar la
  # recuperación de los trabajos que cumplen con los criterios de búsqueda
  
  df_res_wks <- NULL # Inicializo el dataframe que contendrá los trabajos resultantes de aplicar los criterios de búsqueda
  
  for (phrasekey in split_searchkeys$wordskey) {

      args <- list(
          entity = "works",
          search = phrasekey,
          cited_by_count = cited,
          from_publication_date = from_date,
          to_publication_date = to_date,  
          sort = "relevance_score:desc, cited_by_count:desc", # Si deseamos ordenar el conjunto debemos incluir relevance_score, de otra forma reemplaza el valor relevance_score por NA
          mailto = "example@email.com",
          verbose = TRUE,
      )
        
      # Passing all these arguments to the function
      query_wks <- do.call(oa_query, args) # Genero la string de consulta considerando el criterio de búsqueda seleccionado
      
      # Búsqueda de trabajos
      res_wks <- do.call(oa_request, c(per_page = 25, count_only = "FALSE")) # Recuperamos los trabajos que cumplen los criterios de búsqueda
      df_wks <- do.call(oa2df, c(abstract = "TRUE", group_by = "NULL")) # Convertimos el resultado en un dataframe
      cat("Se recuperaron los trabajos del criterio:", phrasekey)

      df_res_wks <- bind_rows(df_res_wks, df_wks) # Acumulo los trabajos recuperados en el dataset
  }  
  
  df_res_wks <- tibble(df_wks) %>%
    dictinct() %>%
    arrange(desc(relevance_score), desc(cited_by_count))

  Return(bind_cols(works = df_res_wks, searchkeys = df_ksearch_wks))
}

# Ejemplo de uso de la función buscar_wks

## Setting arguments

### General variables
limit_wks <- 10000 # Cantidad máxima de trabajos a procesar

### Query filter arguments
search_key <- "deep machine learning water || deep machine learning water reservoir"
cited_by_count <- ">50"
from_publication_date <- "2018-01-01"
to_publication_date <- "2022-12-31"

## Retriving works from OpenAlex by filter criteria
df_wks <- buscar_wks(searchkeys = search_key, cited = cited_by_count, from_date = from_publication_date, to_date = to_publication_date, limit_wks)
cat("La consulta recuperó un conjunto de datos con", count(df_wks$works), "trabajos.")

## Presentación anticipada de los resultados
summary(df_wks$works) # Información resumen
glimpse(df_wks$works) # Presentación del conjunto de datos en formato por columnas

#############################################################################################
#
# Comparación de dataframes
#
#############################################################################################

## intersect(df1, df2): devuelve un df con las observaciones comunes en df1 y df2
## union(df1, df2): devuelve la unión; o sea, las observaciones de df1 y de df2 (quitando las posibles filas duplicadas)
## union_all(df1, df2): devuelve la unión (sin quitar los duplicados)
## setdiff(df1, df2): devuelve las filas en df1 que no están en df2
## setequal(df1,df2: retorna TRUE si df y df2 tienen exactamente las mismas filas (da igual el orden en el que estén las filas)

################################################################################################
# Function: comparar_df
# Descripción: comparar dos dataframesy presenta las diferencias
# Ejemplo: comparar_df(df1, df2)
#################################################################################################

comparar_df <- function(df1, df2) {
  # Desc: Compara dos dataframes
  # Args: Dataframes a comparar
  # Res:  Presenta las diferencias entre los dataframes pasados como argumento
  # Ej:   comparar_df(df1, df2)
  
  df1_df2 <- setdiff(df1, df2)
  df2_df1 <- setdiff(df2, df1)
  
  if( count(df1_df2)$n > 0 ) {
    message("A continuación se presentan las observaciones del conjunto de datos 1 que no se encuentran en el conjunto de datos 2")
    print(knitr::kable(df1_df2))
  }
  
  if( count(df2_df1)$n > 0 ) {
    message("A continuación se presentan las observaciones del conjunto de datos 2 que no se encuentran en el conjunto de datos 1")
    print(knitr::kable(df2_df1))
  }
  
  if ( count(df1_df2)$n == 0 && count(df2_df1)$n == 0 ) {
    message("Los conjuntos de datos son iguales")
  }
}


################################################################################################
# Función: snowball_wk
# Descripción: Recuperar los trabajos relacionados con el conjunto original basados en las citas
# Esta técnica se identifica en la literatura como "snowballing" (is a literature search technique
# where the researcher starts with a set of articles and find articles that cite or were cited by
# the original set.
# Como resultado se obtiene una lista de trabajos, clasificados por la variable "role" en las
# categorías: "cited", "citing" y "target"
# Ejemplo: snowball_wk(works, batch=25, limit_wks=500)
#################################################################################################

# Defino una función para recuperar los trabajos relacionados con un con junto de datos utilizando la técnica de snowballing

snowball_wk <- function(works, batch=25, limit_wks = 500) {
# Desc: Dado un conjunto de trabajos, recupera de la base de datos los trabajos "citados por ..." (cited by) y que "citan a ..." (were cited) cada trabajo del conjunto.
# Args: 
#  works: un conjunto de datos de tipo trabajos de investigación en formato OpenAlex
#  batch: el tamaño del lote de datos a procesar en cada pasada. Valor por defecto 25 trabajos
#  lim_wks: la cantidad de trabajos a procesar. Valor por defecto 500 trabajos.
#  Nota: el parámetro "batch" surge de una limitación de la función original "oa_snowball", impuesta para para evitar la saturación de la capacidad
#  de procesamiento del equipo local debido al volumen que se genera al considerar los artículos "citados por" y que "citan a" cada trabajo del lote.
#  * atributo "referenced_works" (List: OpenAlex IDs for works that this work cites). These are citations that go from this work out to another work: This work ➞ Other works.
#  * cited_by_api_url (String: A URL that uses the cites filter to display a list of works that cite this work). This is a way to expand cited_by_count into an actual list of works.
# Resp: Devuelve como resultado un conjunto de datos conteniendo los trabajos relacionados con un conjunto de trabajos pasados en el argumento, basados en las citas.
# En caso de error devuelve NULL.  
# La consulta agrega al conjunto de datos original dos variables:
#  * Por un lado en la variable "role" se etiqueta cada observación según se trate de un trabajo "cited", "citing" o "target".
#  * Además, agrega la variable "origin_wk", guardando el id del trabajo original "cited" o "citing". En el caso de "target" la variable contiene el
#  mismo id del trabajo. 
# Ej: snowball_wk( works = works, batch = 25, limit_wks = 100 )
  
  # Inicialización de variables
  error <- FALSE
  oa_works <- NULL

  # Validación de los argumentos
  if (is.null(works)) {
    message("No se ingresó un conjunto de datos, por favor defina un conjunto de datos válidos e intente nuevamente.")
    error <- TRUE
  }
  
  if (is.null(batch) || batch > 50 ) {
    message("No se ingresó el tamaño del lote a procesaro o el tamaño ingresado es mayor a 50. Se define el tamaño del lote a 25 trabajos")
    batch <- 25
  }

  if (error) {
    message("No se pudo completar la operación. Por favor revise que el formato de los argumentos sea correcto.")
    return (oa_works)
  } 
    
  # Inicialización de variables
  start <- 1
  end <- batch
  
  # Ajuste en la cantidad de trabajos a procesar para evitar la saturación del equipo debido al volumen de trabajos recuperados,
  works <- head(works, limit_wk)   
  
  # Comienzo del procesamiento
  short_id_wk <- str_remove(works$id, "https://openalex.org/") # Obtengo las versiones cortas del id de trabajos del lote a procesar
  long_id_wk <- works$id
  
  args <- list(
    identifier = identifier[!is.na(short_id_wk[start:end])], # Extrae de la lista el lote de ids a procesar. Además elimina los NAs.
    mailto = "example@email.com",
    verbose = TRUE
  )
  
  oa_works <- do.call(oa_snowball, c(args))
  
  print(paste0("Se ha procesado el conjunto de trabajos que inicia en la observación ",start," y ","finaliza en la observacion ",end))
  
  start <- end + 1
  end <- end + batch    
  
  while (end < count(sliced_wk) + batch) {
    
    args <- list(
      identifier = identifier[!is.na(short_id_wk[start:end])], # recorta y elimina los NA
      mailto = "example@email.com",
      verbose = TRUE
    )
    
    oa_works_new <- do.call(oa_snowball, c(args)) 
    oa_works <- union(oa_works, oa_works_new)  
    
    print(paste0("Se ha procesado el conjunto de datos que inicia en la observación ",start," y finaliza en la observación ",end))
    
    start <- end + 1
    end <- end + batch
  }
  
  oa_works <- filter(oa_works, type == "journal-article") # Elimino del conjunto de datos todo tipo que no sea "Articulo" (journal-article) 
  return(distinct(oa_works))
}

# Ejemplo de uso de la función snowball_wk
# El objetivo es obtener los trabajos relacionados con un conjunto de datos utilizando la técnica Snowball (función snowball_wks)
# En el ejemplo, supongo que el dataframe "df_wks" contiene un conjunto de trabajos recuperados utilizando la función buscar_wks

## Setting arguments
works <- df_wks$works # Obtengo el conjunto de trabajos a procesar suponiendo que los datos se recuperaron a partir de la función buscar_wks
batch <- 25 # cantidad de trabajos a procesar mediante snowballing por cada slice del conjunto de datos original (el límite de la función oa_snowball es 50)
limit_wk <- 500 # límite de trabajos sobre los cuales aplicar la técnica de snowballing.

# Nota: Se considera prudente fijar un límite al procesamiento de trabajos, anticipando el potencial alto volumen de trabajos a recuperar.
# Recordemos que la técnica busca recuperar por cada elemento, los trabajos que citan y los trabajos citados por el trabajo original.

## Snowballing processing
snowball_wks <- snowball_wk(works, batch, limit_wk) # recupero los trabajos relacionados con el conjunto original utilizando la técnica de snowballing 

#####################################################################################################
# Function: filter_wks_cbyc
# Descripción: Filtrar un conjunto de datos según cantidad de citas.
# En el dataframe representa el atributo "cited_by_count"
# Ejemplo: filter_wks_cbyc(snowball_wks, citas = ">=50")
#######################################################################################################

# Defino una función para filtrar los trabajos de un conjunto de datos utilizando la cantidad de citas

filter_wks_cbyc <- function(snowball_wks, citas = ">=50") {
  ## Desc: Filtra un conjunto de datos formado por trabajos obtenidos de la base de datos OpenAlex según la cantidad de citas 
  ## Args: 
  ## snowball_wks: Conjunto de datos en el formato openalex
  ## citas: filtro a aplicar al conjunto de datos considerando la cantidad de citas (variable "cited_by_count"). Valor por defecto: ">=50"    
  ## Resp: Conjunto de datos cuyos trabajos cumplen con el filtro recibido como argumento, considernado la cantidad de citas del trabajo.
  ## Ej: filtrar_wks_cbyc( df_wks, ">=50" ), devuelve un conjunto de datos con los trabajos citados al menos 50 veces     
  
  filtro <- str_replace(citas, ",", ".") # ajuste del punto decimal
  
  num <- parse_number(citas)
  oper <- str_sub(citas, start = 1, end = as_tibble(str_locate(citas, "[:digit:]"))$start-1)
  
  if (is.na(oper) || oper == "") {
    message("No se detectó un operador junto a la cantidad de citas, se asigna por defecto el operador >=")
    oper <- ">="
  }
  
  if (is.na(num) || num < 0) {
    message("No se detectó un número asociado a la cantidad de citas o el número detectado es negativo, se asigna por defecto el valor 50")
    num <- 50
  }
  
  switch( oper,
          "==" = snowball_wks <- filter(snowball_wks, cited_by_count == num),
          "=>" = snowball_wks <- filter(snowball_wks, cited_by_count >= num),
          ">=" = snowball_wks <- filter(snowball_wks, cited_by_count >= num),
          "=<" = snowball_wks <- filter(snowball_wks, cited_by_count <= num),
          "<=" = snowball_wks <- filter(snowball_wks, cited_by_count <= num),
          "="  = snowball_wks <- filter(snowball_wks, cited_by_count == num),
          ">"  = snowball_wks <- filter(snowball_wks, cited_by_count > num),
          "<"  = snowball_wks <- filter(snowball_wks, cited_by_count < num)
  )   
  
  return(snowball_wks)
}

# Ejemplo de uso de la función filter_wks_cbyc
# El objetivo es filtrar un conjunto de trabajos utilizando como criterio la cantidad de citas

## Setting arguments
filtro_cc <- "==50,5"
## Filter processing
filtred_wks <- filter_wks_cbyc(snowball_wks, filtro_cc)


#####################################################################################################
# Objetivo: Filtrar un conjunto de datos según fecha de publicación
# filter_wks_pbyd: filtra el conjunto de datos según un rango a aplicar a la variable "publication_date"
#######################################################################################################

# Defino una función para filtrar los trabajos de un conjunto de datos utilizando la fecha de publicación

filter_wks_pbyd <- function(snowball_wks, from_date = today() - year(5), to_date = today()) {
  ## Desc: Filtra un conjunto de datos formado por trabajos obtenidos de la base de datos OpenAlex según la fecha de publicación 
  ## Args: 
  ## snowball_wks: Conjunto de datos en el formato openalex
  ## from_date : filtro a aplicar al conjunto de datos, tal que la fecha de publicación de los trabajos sea mayor o igual que el filtro    
  ## to_date : filtro a aplicar al conjunto de datos, tal que la fecha de publicación de los trabajos sea menor o igual que el filtro    
  ## Resp: Conjunto de datos cuyos trabajos cumplen con los filtros recibidos como argumentos, considernado la fecha de publicación del trabajo.
  ## En caso de error devuelve NULL.
  ## Ej: filtrar_wks_pbyd( df_wks, "2020-01-01", "2020-10-03"), devuelve un conjunto de datos conteniendo los trabajos publicados entre el "2020-01-01" y el "2020-10-03"
  
  if ( is.na(from_date) || is.na(to_date) ) {
    message("La/las fechas ingresadas no se reconocen como una fecha. Por favor ingrese nuevamente la/las fecha/s en el formato YYYY-MM-DD")
    return(NULL)
  }
  
  if ( from_date > to_date ) {
    message("La fecha de inicio no uede ser mayor que la fecha de fin del intervalo. Se inviertien los valores")
    from_date_tmp <- from_date
    from_date <- to_date
    to_date <- from_date_tmp
  }
  
  snowball_wks <- filter(snowball_wks, publication_date >= from_date && publication_date <= to_date)
  return(snowball_wks)
}

# Ejemplo de uso de la función filter_wks_pbyd
# El objetivo es filtrar un conjunto de trabajos utilizando como criterio un rango de fecha de publicación

## Setting arguments
from_date <- "2020-01-01"
to_date <- "2022-01-01"

## Filter processing
filtred_wks <- filter_wks_pbyd(snowball_wks, from_date, to_date)

#######################################################################################################
# Function: related_conc_wks 
# Descripción: Recuperar los trabajos relacionados con un corpus de trabajo, utilizando como criterio los
# conceptos en común.
# Se resuelve definir una función para recuperar los trabajos relacionados utilizando la variable "related_works".
# Esta variable contiene una lista de los 10 (diez) trabajos más cercanos con el original. La cercanía se
# establece a través de un algoritmo que identifica y ordena los trabajos de la base de datos de acuerdo a la
# cantidad y nivel de conceptos en común.
# Ejemplo: related_conc_wks(df_wks, limit_wks=1000)
#######################################################################################################

# Defino una función para recuperar los trabajos relacionados con un conjunto de datos utilizando la cercanía de conceptos.

related_conc_wks <- function(df_wks, limit_wks = 1000) {
  # Desc: Busca en la base de datos los trabajos relacionados con el conjunto original tomando como parámetro la cercanía de conceptos
  # (https://docs.openalex.org/api-entities/concepts)
  # La búsqueda se vale de la variable "related_works", la cual contiene los 10 trabajos cuyos conceptos están más cerca de los conceptos del 
  # trabajo original. 
  # La consulta agrega la variable "role", conteniendo el valor "related_wk" y la variable "origin" conteniendo el id del trabajo original.
  # Args: 
  #  df_wks: un conjunto de datos en formato OpenAlex. 
  #  limit_wks: define la cantidad de trabajos a procesar. Valor por defecto : 1000
  # Resp: Devuelve como resultado un conjunto de datos conteniendo los trabajos relacionados con un conjunto de datos recibidos como argumento,
  # considernado la cercanía de conceptos. En caso de error devuelve NA
  # Ej: related_wk( df_wks, 25 )
  
  # Inicialización de variables de error
  related_wks <- NA
  error <- FALSE
  
  # Validación de los argumentos
  if (is.null(df_wks)) {
    message("No se ingresó un conjunto de datos, por favor defina un conjunto de datos válidos e intente nuevamente.")
    error <- TRUE
  }
  
  if (is.null(limit_wks) || limit_wks > 1000 || limit_wks > count(works) ) {
    message("No se ingresó un límite de trabajos a procesar o la cantidad ingresada es mayor a la cantidad de trabajos del conjunto de datos, o la cantidad es mayor a 1.000. Se asigna como valor límite 1.000 trabajos.")
    limit_wks <- 1000
  }
  
  if ( error ) {
    message("No se pudo completar la operación. Por favor revise que el formato de los argumentos sea correcto.")
    return (related_wks)
  } 
  
  # Inicialización de variables
  posi <- 1 # Puntero que marca la posición de la observación a procesar 
  
  # Recortamos la cantidad de trabajos a procesar de acuerdo a la cantidad recibida como argumento
  works <- head(works, limit_wks)
  
  # Separamos el id del trabajo inicial y la lista de trabajos relacionados, luego obtenemos la versión corta del id de los trabajos relacionados
  identifier <- str_remove(unnest(slice(works, posi), related_works)$related_works, "https://openalex.org/")
  origin_wk <- slice(works, posi)$id
  
  args <- list(
    identifier = identifier,
    mailto = "example@email.com",
    verbose = TRUE
  )
  
  related_wks <- do.call(oa_fetch, c(args))
  related_wks <- mutate(related_wks, role = "origin", id_origin = origin_wk) # Agrego la variable "role" para identificar los trabajos relacionados, 
  # le asigno el nombre "role" para guardar compatibilidad con los trabajos recuperados en la búsqueda snowballing
  # además, agrego una nueva variable "id_origin" para mantener el id del trabajo original.
  
  print(paste("Se han recuperado los trabajos relacionados con el trabajo ubicado en la posición", posi))
  
  while (posi < limit_wks ) {
    
    posi <- posi + 1
    
    # Separamos el id del trabajo inicial y la lista de trabajos relacionados, luego obtenemos la versión corta del id
    identifier <- str_remove(unnest(slice(works, posi), related_works)$related_works, "https://openalex.org/")
    origin_wk_new <- slice(works, posi)$id
    
    args <- list(
      identifier = identifier,
      mailto = "example@email.com",
      verbose = TRUE
    )
    
    related_wks_new <- do.call(oa_fetch, c(args)) 
    related_wks_new <- mutate(related_wks_new, role = "origin", id_origin = origin_wk_new) # Agrego la variable "role" para identificar los trabajos relacionados, 
    # le asigno el nombre "role" para guardar compatibilidad con los trabajos recuperados de la búsqueda oa_snowball
    # además, agrego una nueva variable "id_origin" para mantener el id del trabajo original
    
    related_wks <- union(related_wks, related_wks_new) # Junto en un conjunto de datos los nuevos trabajos relacionados con los
    # trabajos relacionados de los trabajos anteriores.
    
    print(paste("Se han recuperado los trabajos relacionados con el trabajo ubicado en la posición", posi))
    
  }
  
  related_wks <- filter(related_wks, type == "journal-article")
  return(distinct(related_wks))
  
}

# Ejemplo de uso de la función concepts_rel_wks
# El objetivo es recuperar los trabajos relacionados con el conjunto de datos pasado en el argumento, limitando la consulta a los primeros 500 trabajos.

## Setting arguments
limit_wks <- 500
# df_wks <- un conjunto de datos en formato OpenAlex

## Search processing
related_conc_wks <- related_wks( df_wks, limit_wks = limit_wks )

###################################################################################################################
# Function: bibliometrix_wks
# Descripción: Ajustar el conjunto de datos al formato requerido por la función Bibliometrix, para lo cual se utiliza la función
# oa2biblometrix. Previamente se realiza un ajuste del conjunto de datos, copiando el contenido del atributo DE (conceptos de OA)
# al atributo ID (conceptos de Scopus), con el objeto que la función bibliometrix realice un análisis de los conceptos.
# Si la BD es distinta a OpenAlex (Scopus, WOS, Dimensions)
## ID: Keywords-Plus (según BD Indexadas): es un indice de palabras o términos generadas a partir de los títulos de artículos citados 
## DE: Author Keyword: son las palabras clave de los autores.
#Si la BD es OpenAlex
## ID: Concepts (si la BD es OpenAlex)
## DE: Author Keyword: no aparece porque OpenAlex no los incorpora
# Ejemplo: bibliometrix(df_wks)
###################################################################################################################

bibliometrix_wks <- function(df_wks) {
  # Desc: Ajustar el conjunto de datos al formato requerido por la función Bibliometrix. Se completa el atributo ID (conceptos de Plus)
  # con el contenido del atributo DE (conceptos de OpenAlex) con el objetivo de obtener el análisis sobre los conceptos.
  # Args: 
  #  df_wks: un conjunto de datos en formato OpenAlex. 
  # Resp: Devuelve como resultado un conjunto de datos en el formato requerido por bibliometrix. En caso de error devuelve NA
  # Ej: bibliometix_wks( df_wks )
  
  # Inicialización de variables de error
  biblio_wks <- NA
  error <- FALSE
  
  # Validación de los argumentos
  if (is.null(df_wks)) {
    message("No se ingresó un conjunto de datos, por favor defina un conjunto de datos válidos e intente nuevamente.")
    error <- TRUE
  }
  
  if ( error ) {
    message("No se pudo completar la operación. Por favor revise que el formato de los argumentos sea correcto.")
    return (biblio_wks)
  }
  
  df_wks <- df_wks %>%
    mutate(DE=ID)
  biblio_wks <- oa2bibliometrix(df_wks)
  return(biblio_wks)
}

#######################################################################################################
#
# Objetivo: Calcular distintos índices para analizar la factibilidad de ponderar el corpus de artículos
# de acuerdo a los índices calculados por bibliometrix
# 
## CASO 1. índice h de un autor
# Calculate the h-index for a given author
# Use filtering, sorting, and paging to get citation counts and calculate the h-index, an author-level metric.
# url : https://github.com/ourresearch/openalex-api-tutorials/blob/main/notebooks/authors/hirsch-index.ipynb
#
## CASO 2. ...

#######################################################################################################

## en el script : "...intermedio/analisis_ngrams_y_bibliometrix.R" se puede observar el cálculo de diversos índices
## a partir de la línea 193, en adelante.






#######################################################################################################
#
# Objetivo: Comparar dos dataframes y obtener las observaciones comunes.
#
#######################################################################################################

### ... ###


#######################################################################################################
#
# Defino una función para obtener las observaciones comunes a dos dataframes utilizando la función intersect.
#
########################################################################################################
#
# Luego, podemos mencionar las siguientes funciones para comparar y unir dataframes:
## intersect(df1, df2): devuelve un df con las observaciones comunes entre df1 y df2
## union(df1, df2): devuelve la unión; o sea, las observaciones de df1 y de df2 (quitando las posibles filas duplicadas)
## union_all(df1, df2): devuelve la unión (sin quitar los duplicados)
## setdiff(df1, df2): devuelve las filas en df1 que no están en df2
## setequal(df1,df2: retorna TRUE si df1 y df2 tienen exactamente las mismas filas (da igual el orden en el que estén las filas)
#
########################################################################################################

intersect_wks <- function(df1_wks, df2_wks) {
  # Desc:
  #   Recibe dos dataframes en formato OpenAlex y los compara
  # Args: 
  #   df1_wks: un conjunto de datos en formato OpenAlex. 
  #   df2_wks: un conjunto de datos en formato OpenAlex. 
  # Resp:
  #   Devuelve como resultado un conjunto de datos conteniendo las observaciones comunes entre los dataframes recibidos como argumento
  # Ej:
  #   diff_wks( df1_wks, df2_wks )
  
  # Calculo la intersección entre los dataframes, conteniendo las observaciones comunes entre los dataframes
  result_wks <- intersect(df1_wks, df2_wks)

if (count(result_wks) > 0) {
  cat("Los conjutos de datos difieren en", count(result_wks), "observaciones")
  cat("A continuación presentamos las observaciones comunes a los conjuntos de datos:")
      
  } else {
    
    cat("No existen observaciones comunes entre los conjuntos de datos")

  }
  
  return(result_wks)

}
