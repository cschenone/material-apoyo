# Author: Carlos Schenone
# Documento de referencia: https://rpubs.com/jboscomendoza/redes_semanticas_r
# Date: 2022-02-13
# Modified: 2022-02-13
# Description: This function realize semantic anlysis from a text.
# Packages Used: tidytext, tidiverse, tm   
# Blog Reference: Not published

# Copyright (c) 2023, under the Creative Commons Attribution-NonCommercial 3.0 Unported (CC BY-NC 3.0) License
# For more information see: https://creativecommons.org/licenses/by-nc/3.0/
# All rights reserved.

# Carga de librerías

library(stringr) # Herramientas de procesamiento de texto
library(tidytext) # Herramientas para procesar texto de manera limpia e intuitiva.
library(tidyverse) # Un meta paquete que llama a otros más (dplyr, readr, purrr, etc.) que nos facilitan la lectura, procesamiento y visualización de datos
library(tm) # Herramientas de minería de texto
library(igraph) # Paquete con funciones que amplían el paquete ggplot2 del tidyverse.
library(ggraph) # Paquete con funciones que amplían el paquete ggplot2 del tidyverse. En particular, graph hará el trabajo de crear las redes semánticas

# Bibliographic databases

# Prueba con OpenAlex

## Carga de librerías

library(openalexR) # A full package to gather bibliographic metadata about publications, authors, venues, institutions, and concepts from OpenAlex using API.
## (Aria, M. and Cuccurullo, C. (2022). openalexR: Gathering Bibliographic Records from ‘OpenAlex’ Database Using ‘DSL’ API. R package version 0.0.1. https://github.com/massimoaria/openalexR).
library(bibliometrix) # A full package for Science Mapping Workflow
library(dplyr)

## Configuramos openalexR
options(openalexR.mailto = "example@email.com")

# Data acquisition
## Querying from OpenAlex (https://openalex.org/)

# Objetivo 1) Recuperar trabajos utilizando como filtros:
## palabras clave
## cantidad de citas
## intervalo de fecha de publicación

## Descripción: Se aborda en dos fases, en la primera se recuperan los trabajos de interés identificados a través de:
### a) parámetros generales: cantidad de citas e intervalo de publicación
### b) parámetros particulares: palabras clave. En este caso se utilizan búsquedas por palabras clave y posteriormente
### se aplican criterios de unión (objetivo a)o intersección de los trabajos recuperados en las búsquedas.

### búsqueda individuales por palabras clave y operadores y en la segunda se  etapas. En primer lugar se recuperar, primero 

# a) Objetivo recuperar los trabajos en el campo de la inteligencia artificial 

## Definimos los parámetros de la búsqueda

### Search #1a
cited <- ">50"
from_date <- "2020-01-01"
to_date <- "2021-12-31"

key_search <- "artificial intelligence"
search1a <- works_search_taf(key_search, cited, from_date, to_date)
count(search1a)
head(search1a)

### Search #2a
key_search <- "machine learning"
search2a <- works_search_taf(key_search, cited, from_date, to_date)
count(search2a)
head(search2a)

### Unimos en un conjunto de datos los trabajos recuperados en ambas búsquedas (search1a "o" search2a) (full_join)
###  Nota: Reduce() takes a function f of two arguments and a list or vector x which is to be ‘reduced’ using f.
search1a_o_2a <- Reduce(full_join, list(search1a, search2a))

count(search1a_o_2a)
head(search1a_o_2a)

### Search #3a
key_search <- "deep learning"
search3a <- works_search_taf(key_search, cited, from_date, to_date)
count(search3a)
head(search3a)

### Unimos en un conjunto de datos los trabajos recuperados (search12a "o" search3a) (full_join)
search1a_2a_o_3a <- Reduce(full_join, list(search1a_o_2a, search3a))

count(search1a_2a_o_3a)
head(search1a_2a_o_3a)


# b) Objetivo: Recuperar los trabajos en el campo de la gestión del agua:
# Hydrology, Water, Groundwater, Hydrological Science, Groundwater, Water Storage, Water Quality

## Definimos los parámetros de la búsqueda

### Search #1b
cited <- ">50"
from_date <- "2020-01-01"
to_date <- "2021-12-31"

key_search <- "hydrology"
search1b <- works_search_taf(key_search, cited, from_date, to_date)
count(search1b)
head(search1b)

### Search #2b
key_search <- "water"
search2b <- works_search_taf(key_search, cited, from_date, to_date)
count(search2b)
head(search2b)

### Unimos en un conjunto de datos los trabajos recuperados en ambas búsquedas (search1b "o" search2b) (full_join)
###  Nota: Reduce() takes a function f of two arguments and a list or vector x which is to be ‘reduced’ using f.
search1b_o_2b <- Reduce(full_join, list(search1b, search2b))

count(search1b_o_2b)
head(search1b_o_2b)

### Search #3b
key_search <- "groundwater"
search3b <- works_search_taf(key_search, cited, from_date, to_date)
count(search3b)
head(search3b)

### Unimos en un conjunto de datos los trabajos recuperados en ambas búsquedas (search12b "o" search3b) (full_join)
search1b_2b_o_3b <- Reduce(full_join, list(search1b_o_2b, search3b))
count(search1b_2b_o_3b)
head(search1b_2b_o_3b)

# c) Objetivo: Unimos (Intersección) en un conjunto de datos los trabajos recuperados en ambas búsquedas (search123a "y" search123b) (inner_join)

search1a_2a_o_3a_y_1b_2b_o_3b <-Reduce(inner_join, list(search1a_2a_o_3a, search1b_2b_o_3b))
count(search1a_2a_o_3a_y_1b_2b_o_3b)
head(search1a_2a_o_3a_y_1b_2b_o_3b)

df <- search1a_2a_o_3a_y_1b_2b_o_3b

## EDA de los resultados usando funciones de R
count(df) # Cantidad de trabajos recuperados
glimpse(df) # Variables y sus atributos
names(df) # nombres de las variables
head(df) # Primeros valores del data set

# Objetivo 
## Evaluar el alcance del paquete bibliometrix
### Referencia: https://www.bibliometrix.org/vignettes/Introduction_to_bibliometrix.html

# Data loading and converting
## The data set must be converted on bibliometrix object using the function oa2bibbliometrix
### For a complete list of field tags see https://www.bibliometrix.org/documents/Field_Tags_bibliometrix.pdf

M <- oa2bibliometrix(df)


# Bibliometric Analysis
## The first step is to perform a descriptive analysis of the bibliographic data frame.

results <- biblioAnalysis(M, sep = ";")

## Functions summary
### To summarize main results of the bibliometric analysis, use the generic function summary.
### It displays main information about the bibliographic data frame and several tables, such as annual scientific production,
### top manuscripts per number of citations, most productive authors, most productive countries, total citation per country,
### most relevant sources (journals) and most relevant keywords.
### Main information table describes the collection size in terms of number of documents, number of authors,
### number of sources, number of keywords, timespan, and average number of citations.
### Furthermore, many different co-authorship indices are shown. In particular, the Authors per Article index is calculated
### as the ratio between the total number of authors and the total number of articles.
### The Co-Authors per Articles index is calculated as the average number of co-authors per article.
### In this case, the index takes into account the author appearances while for the “authors per article” an author,
### even if he has published more than one article, is counted only once. For that reasons, Authors per Article index ≤ Co-authors per Article index.
### The Collaboration Index (CI) is calculated as Total Authors of Multi-Authored Articles/Total Multi-Authored Articles
### (Elango and Rajendran, 2012; Koseoglu, 2016). In other word, the Collaboration Index is a Co-authors per Article index
### calculated only using the multi-authored article set.
### Elango, B., & Rajendran, P. (2012). Authorship trends and collaboration pattern in the marine sciences literature: a scientometric study. International Journal of Information Dissemination and Technology, 2(3), 166.
### Koseoglu, M. A. (2016). Mapping the institutional collaboration network of strategic management research: 1980–2014. Scientometrics, 109(1), 203-226.
### summary accepts two additional arguments. k is a formatting value that indicates the number of rows of each table. pause is a logical value (TRUE or FALSE) used to allow (or not) pause in screen scrolling. Choosing k=10 you decide to see the first 10 Authors, the first 10 sources, etc.

options(width=100)
S <- summary(object = results, k = 10, pause = FALSE)

### PRUEBAS con tibble
M_t <- tibble(M) # Transformamos el df de resultados en un tibble
### Nota: observamos que falta el atributo DE (porque OpenAlex no lo incorpora), pero se dispone del atributo ID,
### por lo cual se va a realizar la prueba de generar este atributo copiando el valor del atributo ID, y observar el resultado
### de la función summary (si genera la tabla "Most Relevant Keywords")

results_t <- biblioAnalysis(M_t, sep = ";") # Realizamos el análisis bibliometrico sobre el tibble
options(width=100)
S_t <- summary(object = results_t, k = 10, pause = FALSE) # Obtenemos el resultado


## Functions plot
### Some basic plots can be drawn using the generic function :
  
plot(x = results, k = 10, pause = FALSE)

# Objetivo 
## a) Definir un criterio de puntuación de trabajos





# Definición de funciones de interés para el trabajo

## Definimos la función para recuperar los trabajos, según palabra clave y otros atributos, buscando en el titulo, abstract y full_text
### Name: works_search_taf 
### Description: Recuperar los trabajos, según palabra clave y otros atributos, buscando en el titulo, abstract y full_text
### Parámetros: 
#### key_search: palabras clave utilizadas como criterio de búsqueda
#### cited: filtro de corte por cantidad de citas del trabajo
#### from_date: filtro de corte inicial para fecha de publicación del trabajo
#### to_date: filtro de corte final para fecha de publicación del trabajo

works_search_taf <- function(key_search, cited, from_date, to_date) {

  ## Recuperamos los trabajos buscando en el titulo
  works_search_t <- oa_fetch(
    entity = "works",
    title.search = key_search,
    cited_by_count = cited,
    from_publication_date = from_date,
    to_publication_date = to_date,
    sort = "cited_by_count:desc",
    verbose = TRUE
  )
  
  ## Recuperamos los trabajos buscando en el abstract
    works_search_a <- oa_fetch(
    entity = "works",
    abstract.search = key_search,
    cited_by_count = cited,
    from_publication_date = from_date,
    to_publication_date = to_date,
    sort = "cited_by_count:desc",
    verbose = TRUE
  )
  
  ## Recuperamos los trabajos buscando en el contenido
  works_search_f <- oa_fetch(
    entity = "works",
    fulltext.search = key_search,
    cited_by_count = cited,
    from_publication_date = from_date,
    to_publication_date = to_date,
    sort = "cited_by_count:desc",
    verbose = TRUE
  )
  
  ## Unimos en un conjunto de datos los trabajos recuperados
  ###  Nota: Reduce() takes a function f of two arguments and a list or vector x which is to be ‘reduced’ using f.
  Reduce(full_join, list(works_search_t,works_search_a,works_search_f))
 
}




# -----------------------------------------------------------------------------------------------------
# Estas son funciones generales para procesamiento de texto, analizar luego
# -----------------------------------------------------------------------------------------------------

# Listado de funciones
  
## Función: Crear párrafos y transformar en tibble.
### Argumentos: texto separado en renglones  
### Resultado: tibble formado por los párrafos del texto
  
crear_parrafos <- function(texto) {
  texto %>% 
    map(trimws) %>% 
    ifelse(. == "", "_salto_", .) %>% 
    paste0(., collapse = " ") %>% 
    strsplit(split = "_salto_") %>% 
    map(trimws) %>% 
    data.frame(stringsAsFactors = FALSE) %>% 
    tibble::as_tibble() %>% 
    {
      names(.) <- "texto"
      .
    }
}

## Función: Encontrar capítulos
### Argumentos: texto separado en renglones  
### Resultado: tibble formado por los párrafos del texto

encontrar_capitulos <- function(texto) {
  texto %>% 
    mutate(capitulo = ifelse(grepl("^[[:upper:]]+$", texto), texto, NA)) %>% 
    fill(capitulo) %>% 
    filter(texto != capitulo)
}

## Función: Quitar renglones vacíos
### Argumentos: texto separado en renglones  
### Resultado: tibble sin renglones vacíos

borrar_vacios <- function(texto) {
  texto %>% 
    filter(!texto %in% c(" ", "")) %>% 
    mutate_all(trimws)
}


## Función: Generar bigramas (con palabras huecas inclusive)
### Nota: para el análisis de importancia de ngramas no influyen las palabras huecas

## Generar bigramas sin stopwords
### Argumentos: texto separado en parrafo  
### Resultado: tibble formado las palabras de cada bigrama, el bigrama y la cantidad

generar_bigramas_ssw <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = 2) %>% 
    separate(bigrama, into = c("uno", "dos"), sep = " ") %>% 
    filter(!uno %in% c("á", "ó", NA)) %>% 
    filter(!dos %in% c("á", "ó", NA)) %>%
    filter(!uno %in% stopwords("es")) %>% 
    filter(!dos %in% stopwords("es")) %>% 
    mutate(ngrama = paste(uno,dos)) %>%
    count(ngrama, name = "count", sort = TRUE)
}

## Generar ngramas
### Nota: hay dos posibilidades, eliminar las palabras huecas (stopwords) o manteneralas
### Si se desea eliminar los ngramas que contengan palabras huecas el método utilizado separa las palabras y filtra
### pero esto no permite generalizar el proceso.

### Argumentos: texto separado en parrafo  
### Resultado: tibble formado las palabras de cada bigrama, el bigrama y la cantidad (sin stopwords)

generar_bigramas_csw <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = 2) %>% 
    separate(bigrama, into = c("uno", "dos"), sep = " ") %>% 
    filter(!uno %in% c("á", "ó")) %>% 
    filter(!dos %in% c("á", "ó")) %>%
    filter(!uno %in% c(NA)) %>% 
    filter(!dos %in% c(NA)) %>%
    mutate(ngrama = paste(uno,dos)) %>%
    count(ngrama, name = "count", sort = TRUE)
}




## Función: Generar trigramas (sin filtrar palabras huecas)

## Generar trigramas con stopwords
### Argumentos: texto separado en parrafo  
### Resultado: tibble formado las palabras de cada trigrama, el trigrama y la cantidad

generar_trigramas <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = 3) %>% 
    filter(!ngrama %in% c(NA)) %>% 
    count(ngrama, name = "count", sort = TRUE)
}


## Función: Generar ngramas (sin filtras palabras huecas)

## Generar ngramas a partir de un texto
### Argumentos: texto separado en párrafos, cantidad de palabras del ngrama a construir  
### Resultado: tibble formado los ngramas y su cantidad

generar_ngramas <- function(libro_parrafo, ngrama) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = ngrama) %>% 
    filter(!ngrama %in% c(NA)) %>% 
    count(ngrama, name = "count", sort = TRUE)
}

## Función: Distancia entre palabras
### Objetivo: construir una función que devuelva la distancia (cantidad de palabras) entre dos palabras

## Función: Buscar una palabra en el texto (ngrama)
### Argumentos: texto, palabra a buscar  
### Resultado: tibble mostrando las entidades (por ejemplo oraciones, párrafos) donde aparece la palabra en el texto

buscar_palabra_ngrama <- function(texto, palabra) {
  texto %>%
    filter(.,str_detect(ngrama,palabra))
}

## Función: Generar red semántica a partir de una red de bigramas
### Argumentos: tibble de bigramas y su frecuencia
### Resultado: gráfico mostrando los vínculos entre  bigramas coloreado según la frecuencia de ocurrencia.

crear_red_bigramas <- function(libro_bigrama, umbral = 5) {
  libro_bigrama %>% 
    filter(n > umbral) %>% 
    graph_from_data_frame() %>% 
    ggraph() +
    geom_edge_link(aes(edge_alpha = n),
                   arrow = arrow(type = "closed", length = unit(.1, "inches"))) +
    geom_node_point(size = 2, color = "#9966dd") +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}

## Función: Generar red semántica a partir de una red de ngramas
### Argumentos: tibble de ngramas y su frecuencia  
### Resultado: gráfico mostrando los vínculos entre ngramas coloreado según la frecuencia de ocurrencia.

crear_red_ngramas <- function(libro_ngrama, umbral = 5) {
  libro_ngrama %>% 
    filter(n > umbral) %>% 
    graph_from_data_frame() %>% 
    ggraph() +
    geom_edge_link(aes(edge_alpha = n),
                   arrow = arrow(type = "closed", length = unit(.1, "inches"))) +
    geom_node_point(size = 2, color = "#9966dd") +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_void()
}

## Función: Obtener bigramas de un texto
### Argumentos: texto  
### Resultado: Tibble conteniendo los bigramas del texto

texto_bigrama <- function(texto) {
  texto %>%
    crear_parrafos() %>% 
    encontrar_capitulos() %>% 
    borrar_vacios() %>% 
    generar_bigramas()
}

## Función: Obtener trigramas de un texto
### Argumentos: texto  
### Resultado: Tibble conteniendo los trigramas del texto

texto_trigrama <- function(archivo) {
  archivo %>%
    crear_parrafos() %>% 
    encontrar_capitulos() %>% 
    borrar_vacios() %>% 
    generar_trigramas()
}

## Función: Obtener ngramas de un texto
### Argumentos: texto , cantidad de componentes del ngrama a generar 
### Resultado: Tibble conteniendo los ngramas del texto

texto_ngrama <- function(archivo, ngrama) {
  crear_parrafos() %>% 
    encontrar_capitulos() %>% 
    borrar_vacios() %>% 
    generar_ngramas(ngrama)
}  

# ###--- EXAMPLES ---###

## Generar una red semántica de bigramas y mostrarla gráficamente, tomando como origen un documento guardado en el disco

### Cargar el texto a analizar

#### Acceder al texto "El amigo manso" y guardarlo en el disco local
download.file(url = "https://raw.githubusercontent.com/jboscomendoza/rpubs/master/red_semantica/55563-0.txt",
              destfile = "55563-0.txt")

#### Configurar argumentos de la función
archivo <- "55563-0.txt"
inicio <- 153 ## linea inicial de captura del texto
final <- 10612 ## linea final de captura del texto

#### Cargar el texto original en un tibble
df_texto_original <- read_lines(archivo, skip = inicio, n_max = (final - inicio)) %>%
   tibble() %>%
   map_chr(trimws)

### Analizar el texto

#### Configurar argumentos de la función

set.seed(175) # Fija la semilla de la red, de manera que el grafico se mantenga similar
umbral <- 5 # Cantidad de ocurrencias mínima de un ngrama para que sea considerado en la representación gráfica

texto_bigrama(texto = texto_original)

#### Crear red de bigramas y mostrar la representación gráfica

crear_red_bigramas(texto = texto_bigrama)


texto_ngrama(archivo = texto_original, ngrama)

#### Crear red de ngramas y mostrar la representación gráfica

crear_red_ngramas(texto = libro_ngrama, umbral = umbral)
