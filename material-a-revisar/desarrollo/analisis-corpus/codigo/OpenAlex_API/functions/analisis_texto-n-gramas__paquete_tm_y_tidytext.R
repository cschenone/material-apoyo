# Revisar el documento de referencia: https://docs.ropensci.org/openalexR/reference/oa_ngrams.html#ref-examples
# Al final hay una función para mostrar los principales ngramas de un corpus

# Documento de referencia: https://rpubs.com/jboscomendoza/redes_semanticas_r

# install.packages("stringr") # Herramientas de procesamiento de texto
# install.packages("tidytext") # Contiene herramientas para procesar texto de manera limpia e intuitiva.
# install.packages("tidyverse") # Un meta paquete que llama a otros más (dplyr, readr, purrr, etc.) que nos facilitan la lectura, procesamiento y visualización de datos
# install.packages("tm") # Herramientas de minería de texto
# install.packages("igraph") # Amplían las funciones del paquete ggplot2 del tidyverse.
# install.packages("ggraph") # Amplían las funciones del paquete ggplot2 del tidyverse. En particular, graph hará el trabajo de crear las redes semánticas

#library(stringr)  
library(tidytext) # Incorpora el análisis de tokens
library(tidyverse) # Incorpora el paquete tibble
library(tm) # Incorpora stopwords
library(igraph) # Incorpora graph_from_data_frame()
library(ggraph) # Incorpora ggraph

# Acceder al texto: "El amigo manso"

download.file(url = "https://raw.githubusercontent.com/jboscomendoza/rpubs/master/red_semantica/55563-0.txt",
              destfile = "55563-0.txt")

# Analizar la estructura del texto

read_lines("55563-0.txt") %>% 
  head(15)

file.show("55563-0.txt")

## Cargar en una variable el dato origen

manso <- 
  read_lines("55563-0.txt", skip = 153, n_max = (10612 - 153)) %>% 
  map(trimws)

## Filtrar caracteres no válidos. 

manso <- 
  manso %>%
  str_replace_all(.,"_"," ") %>% # Elimina los "_" utilizados como marca en el texto para identificar "itálica"
  str_replace_all(.," á "," a ") %>% # Reemplaza las "á"
  str_replace_all(.," ó "," o ") %>% # Reemplaza las "ó"
  str_replace_all(.,"á ","a ") %>% # Reemplaza las "á"
  str_replace_all(.,"ó ","o ") # Reemplaza las "ó"
  
## Crear párrafos

manso <-
  manso %>%
  ifelse(. == "", "_salto_", .) %>% 
  paste0(., collapse = " ") %>% 
  strsplit(split = "_salto_") %>% 
  map(trimws)

## Convertir a tibble

manso <-
  manso %>%
  data.frame(stringsAsFactors = FALSE) %>% 
  tibble::as_tibble() %>% 
  {
    names(.) <- "texto"
    .
  }

## Quitar renglones vacíos

manso <- 
  manso %>% 
  filter(!texto %in% c(" ", "")) %>% 
  mutate_all(trimws)

## Obtener capítulos

### Mostrar los capítulos
manso %>% 
  filter(grepl("^[[:upper:]]+$", texto))

manso <- 
  manso %>% 
  mutate(capitulo = ifelse(grepl("^[[:upper:]]+$", texto), texto, NA)) %>% 
  fill(capitulo) %>% 
  filter(texto != capitulo)

# Crear tokens: bigramas
## Para esta tarea usaramos la función unnest_tokens() de tidytext, con los argumentos token = "ngram" y n = 2.
## Tomamos la columna “texto” como entrada y obtenemos “bigrama” de salida

manso_bigrama <- 
  manso %>% 
  unnest_tokens(input = "texto", output = "bigrama", token = "ngrams", n = 2)

## Explorar cuáles son los bigramas más comunes.

manso_bigrama <- 
  manso_bigrama %>%
  count(bigrama, name = "count", sort = TRUE)

# Quitar palabras huecas
## Para quitarlas de nuestro texto, contamos con la ayuda de la función stopwords() de tm.
## Si llamamos a esta función con el argumento kind = "es",
## nos devolverá un vector con un listado de palabras huecas en español
stopwords(kind = "es") %>% head(15)

manso_bigrama <- 
  manso_bigrama %>% 
  separate(bigrama, into = c("uno", "dos"), sep = " ") %>% 
  filter(!uno %in% stopwords(kind = "es")) %>% 
  filter(!dos %in% stopwords(kind = "es"))

# Filtrar las palabras que no corresponden y escaparon al filtro de palabras huecas

manso_bigrama <- 
  manso_bigrama %>% 
  filter(!uno %in% c("á", "ó", NA)) %>% 
  filter(!dos %in% c("á", "ó", NA))

# Recuperar la columna bigramas
manso_bigrama <-  
  manso_bigrama %>%
  mutate(bigrama = paste(uno,dos))

# Crear tokens: trigramas
## Para esta tarea usaramos la función unnest_tokens() de tidytext, con los argumentos token = "ngram" y n = 3.
## Tomamos la columna “texto” como entrada y obtenemos “bigrama” de salida

manso_trigrama <- 
  manso %>% 
  unnest_tokens(input = "texto", output = "trigrama", token = "ngrams", n = 3)

## Explorar cuáles son los trigramas más comunes.

manso_trigrama <- 
  manso_trigrama %>%
  filter(!is.na(trigrama)) %>%
  count(trigrama, name = "count", sort = TRUE)

### Función: Buscar una palabra en el trigrama

buscar_palabra_trigrama <- function(texto, palabra) {
  texto %>%
  filter(.,str_detect(trigrama, palabra))
  }  

# Quitar palabras huecas
## Para quitarlas de nuestro texto, contamos con la ayuda de la función stopwords() de tm.
## Si llamamos a esta función con el argumento kind = "es",
## nos devolverá un vector con un listado de palabras huecas en español
#stopwords(kind = "es") %>% head(15)

# manso_trigrama <- 
#  manso_trigrama %>% 
#  separate(trigrama, into = c("uno", "dos", "tres"), sep = " ") %>% 
#  filter(!uno %in% stopwords(kind = "es")) %>% 
#  filter(!dos %in% stopwords(kind = "es")) %>%
#  filter(!tres %in% stopwords(kind = "es"))

# Filtrar las palabras que no corresponden y escaparon al filtro de palabras huecas

# manso_trigrama <- 
#  manso_trigrama %>% 
#  filter(!uno %in% c("á", "ó", NA)) %>% 
#  filter(!dos %in% c("á", "ó", NA)) %>%
#  filter(!tres %in% c("á", "ó", NA))

# Recuperar la columna trigramas
# manso_trigrama <-  
#  manso_trigrama %>%
#  mutate(trigrama = paste(uno,dos,tres))

# Creando una red semántica

## Hemos hecho el conteo de palabras porque
## crearemos una red que muestre la intensidad con la que se relacionan las palabras,
## cuyo indicador será la frecuencia con la que parejas de palabras aparecen en el texto.

## Sin embargo, tenemos un pequeño problema.
## Hay una gran cantidad de conexiones a un par de palabras que no fueron identificadas como huecas,
## pues aparecen con tilde ("á" y "ó"), lo cual no es convencional en el español moderno filtramos estas palabras

set.seed(175)
manso_bigrama %>% 
  filter(n >= 5) %>% 
  graph_from_data_frame() %>% 
  ggraph() +
  geom_edge_link(arrow = arrow(type = "closed", length = unit(.075, "inches"))) +
  geom_node_point() +
  geom_node_text(aes(label = name), vjust = 1, hjust = 1) + 
  theme_void()

# Listado de funciones

### Función: Leer el texto desde url.

install.packages("rvest")
library(rvest)

# retrieving the target web page 

works_url1 <- "https://doi.org/10.1016/j.jbusres.2021.04.070"
works_url2 <- "https://doi.org/10.1016/j.jbusres.2020.06.057"
works_url3 <- "https://doi.org/10.3145/epi.2020.ene.03"
works_url4 <- "https://doi.org/10.1111/ijcs.12605"
works_url5 <- "https://doi.org/10.21037/atm-20-42352"

works_url <- paste0(
  "https://doi.org/10.1016/j.jbusres.2021.04.070",
  "https://doi.org/10.1016/j.jbusres.2020.06.057",
  "https://doi.org/10.3145/epi.2020.ene.03"
  )

docs_html <- lapply(works_url,read_html)

doc_html <- read_html("https://doi.org/10.1016/j.jbusres.2021.04.070")
View(html_nodes(doc_html, "body"))

library(stringr)
indice <- str_detect(doc_html, "Abstract|Abstract")


View(doc_html)
doc_html


leer_html <- function(archivo, inicio, final) {
  read_lines(archivo, skip = inicio, n_max = (final - inicio)) %>% 
    map_chr(trimws)
}



mostrar_html <- function(url) {
  
  
}


### Función: Leer el texto desde un archivo.

leer_archivo <- function(archivo, inicio, final) {
  read_lines(archivo, skip = inicio, n_max = (final - inicio)) %>% 
    map_chr(trimws)
}

### Función: Crear párrafos y transformar en tibble.

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

### Función: Quitar renglones vacíos

borrar_vacios <- function(libro_vacios) {
  libro_vacios %>% 
    filter(!texto %in% c(" ", "")) %>% 
    mutate_all(trimws)
}

### Función: Encontrar capítulos

encontrar_capitulos <- function(libro) {
  libro %>% 
    mutate(capitulo = ifelse(grepl("^[[:upper:]]+$", texto), texto, NA)) %>% 
    fill(capitulo) %>% 
    filter(texto != capitulo)
}

### Función: Generar bigramas con palabras huecas inclusive
### Nota: para el análisis de importancia de ngramas no molestan las palabras huecas

### Generar bigramas sin stopwords
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

### Generar bigramas con stopwords
generar_bigramas_csw <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = 2) %>% 
    separate(bigrama, into = c("uno", "dos"), sep = " ") %>% 
    filter(!uno %in% c(NA)) %>% 
    filter(!dos %in% c(NA)) %>%
    mutate(ngrama = paste(uno,dos)) %>%
    count(ngrama, name = "count", sort = TRUE)
}


### Función: Generar trigramas con palabras huecas inclusive

### Generar trigramas con stopwords
generar_trigramas <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = 3) %>% 
    filter(!ngrama %in% c(NA)) %>% 
    count(ngrama, name = "count", sort = TRUE)
}


### Función: Generar ngramas con palabras huecas inclusive

### Generar ngramas a partir de un texto
generar_ngramas <- function(libro_parrafo, ngrama) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "ngrama", token = "ngrams", n = ngrama) %>% 
    filter(!ngrama %in% c(NA)) %>% 
    count(ngrama, name = "count", sort = TRUE)
}

### Función: Distancia entre palabras

### Función: Buscar una palabra en el texto (ngrama)
### Argumento: tibble formado por los ngramas de un texto, palabra a buscar
### Resultado: ngramas donde se encontró la palabra

buscar_palabra_ngrama <- function(texto, palabra) {
  texto %>%
    filter(.,str_detect(ngrama,palabra))
}

### Función: Generar redes semánticas.

#### con algunos ajustes para mejorar la presentación de la red semántica,
#### entre otras, que los vínculos tengan un color que corresponda la frecuencia con la que ocurren.

crear_red <- function(libro_bigrama, umbral = 5) {
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

### Función: Generar bigramas (ajustes a la función creada anteriormente)

generar_bigramas <- function(libro_parrafo) {
  libro_parrafo %>% 
    unnest_tokens(input = "texto", output = "bigrama", token = "ngrams", n = 2) %>% 
    separate(bigrama, into = c("uno", "dos"), sep = " ") %>% 
    filter(!uno %in% c(stopwords("es"), "á", "ó")) %>% 
    filter(!dos %in% c(stopwords("es"), "á", "ó")) %>% 
    count(uno, dos)
}

## Resultado final: Todo en uno

### Función: Todo el proceso.

red_texto <- function(archivo, inicio, final, umbral = 5) {
  leer_texto(archivo, inicio = inicio, final = final)  %>% 
    crear_parrafos() %>% 
    encontrar_capitulos() %>% 
    borrar_vacios() %>% 
    generar_bigramas() %>% 
    crear_red(umbral = umbral)
}

### Generar una red semántica y mostrarla gráficamente

set.seed(175)
red_texto(archivo = "55563-0.txt", inicio = 153, final = 10612, umbral = 5)

