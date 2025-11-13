library(dplyr)
library(tidyverse)
library(openalexR)
library(stringr)

db <- tibble(id = c("deep learning", "machine learning", "artificial intelligence water", "water", "intelligence water", "water"), 
             col1 = c("c", "d", "e", "f", "g", "f"),
             col2 = c("h", "i", "j", "k", "l", "k"),
             publication_date = c("2020-01-01", "2019-01-01", "2021-01-01", "1999-01-01", "2020-02-01", "2020-10-01")
)

db3 <- db %>%
  mutate(cited_by_count = 1:6)
  
buscar_wks_2 <- function (phrase) {
  res <- distinct(filter(db, id == phrase))
}

search_wks <- oa_fetch(
  identifier = c("W3160856016"),
  entity = "works",
##  title.search = c("bibliometric analysis", "science mapping"),
##  cited_by_count = ">100",
##  from_publication_date = "2020-01-01",
##  to_publication_date = "2021-12-31",
##  sort = "cited_by_count:desc",
  verbose = TRUE
)

snowball_wks <- oa_snowball(
  identifier = c("W3160856016"),
  verbose = TRUE
)

union_wks <- bind_rows(search_wks, snowball_wks)

snowball_wks <- oa_snowball(
  identifier = c("W3160856016", "W3038273726"),
  verbose = TRUE
)

target_wks <- c("W3160856016")

snowball_wks_1 <- oa_snowball(
  identifier = target_wks,
  verbose = TRUE
)

cited_wks <- snowball_wks_1 %>%
  filter(role == "cited") %>%
  mutate(target_wks = target_wks)
  
mutate(filter(snowball_wks_1, role == "cited"), target_id = snowball_wks_1)
citing_wks <- filter(snowball_wks_1, role == "citing")
target_wks <- filter(snowball_wks_1, role == "target")

#Objetivo: continuar trabajando en el archivo "Pruebas.R", ajustando la función oa_snowball, de manera que se almacene en
#la variable oa_target el trabajo original, para lograr mantener esta variable se deberá procesar cada trabajo en forma
#independiente, por lo cual no tiene sentido el procesamiento en lotes de 25.

View(cited_wks)

####################
## 
## 
####################


filter_wks_cbyc <- function(snowball_wks, filtro) {
## Desc: Filtra un conjunto de datos formado por trabajos obtenidos de la base de datos OpenAlex según la cantidad de citas 
## Args: 
## snowball_wks: Conjunto de datos en el formato openalex
## filtro: filtro a aplicar al conjunto de datos en la variable "cited_by_count"    
## Resp: Conjunto de datos cuyos trabajos cumplen con el filtro recibido como argumento
## Ej: filtrar_wks_cbyc( works, ">=50" ), devuelve un conjunto de datos con los trabajos citados al menos 50 veces     
  
  filtro <- str_replace(filtro, ",", ".")
  
  num <- parse_number(filtro)
  oper <- str_sub(filtro, start = 1, end = as_tibble(str_locate(filtro, "[:digit:]"))$start-1)
  
  if (is.na(oper) || oper == "") {
    message("No se detectó un operador junto a la cantidad de citas, se asigna por defecto el operador >=")
    oper <- ">="
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


filter_wks_pbyd <- function(snowball_wks, from_date = today() - year(5), to_date = today()) {
  ## Desc: Filtra un conjunto de datos formado por trabajos obtenidos de la base de datos OpenAlex según la fecha de publicación 
  ## Args: 
  ## snowball_wks: Conjunto de datos en el formato openalex
  ## from_date : filtro a aplicar al conjunto de datos, tal que la fecha de publicación de los trabajos sea mayor o igual que el filtro    
  ## to_date : filtro a aplicar al conjunto de datos, tal que la fecha de publicación de los trabajos sea menor o igual que el filtro    
  ## Resp: Conjunto de datos cuyos trabajos cumplen con los filtros recibidos como argumentos
  ## Ej: filtrar_wks_pbyd( works, "2020-01-01", "2020-10-03"), devuelve un conjunto de datos conteniendo los trabajos publicados entre el "2020-01-01" y el "2020-10-03"
  
  if ( is.na(from_date) || is.na(to_date) ) {
    message("La/las fechas ingresadas no se reconocen como una fecha. Por favor ingrese nuevamente la/las fecha/s en el formato YYYY-MM-DD")
    return(NULL)
  }
  
  if ( from_date > to_date ) {
    message("La fecha de inicio no puede ser mayor que la fecha de fin del intervalo. Se invirten los valores")
    from_date_tmp <- from_date
    from_date <- to_date
    to_date <- from_date_tmp
  }
  
  snowball_wks <- filter(snowball_wks, publication_date >= from_date && publication_date <= to_date)
  return(snowball_wks)
}

snowball_wks <- db3

## Filtro los trabajos según el tipo: "journal-article"
snowball_wks <- filter(snowball_wks, type == "journal-article")

## Filtro los trabajos según cantidad de citas
filtro_cc <- "==50,5"
filter_wks_cbyc(snowball_wks, filtro_cc)
  
## Filtro los trabajos según fecha de publicación
from_date <- "2020-01-01"
to_date <- "2022-01-01"
filter_wks_cbyc(snowball_wks, from_date, to_date)

a <- tibble(res2)
b <- str_remove(res2$related_works, "https://openalex.org/")

# Defino una función para recuperar los trabajos relacionados con un conjunto de datos utilizando la cercanía de conceptos.

concepts_rel_wks <- function( works, limite_wks = 1000) {
  # Desc: Busca en la base de datos los trabajos relacionados con el conjunto original tomando como parámetro la cercanía de conceptos
  # (https://docs.openalex.org/api-entities/concepts)
  # La búsqueda se vale de la variable "related_works", la cual contiene los 10 trabajos cuyos conceptos están más cerca de los conceptos del 
  # trabajo original. 
  # Args: 
  #  works: un conjunto de datos en formato openalex. 
  #  limite_wks: la cantidad de trabajos a procesar. Valor por defecto : 1000
  # Resp: Devuelve como resultado un conjunto de datos conteniendo los trabajos relacionados con un conjunto de datos recibidos como argumento.
  # En caso de error devuelve NULL.
  # La consulta agrega la variable "role", conteniendo el valor "related_wk" y la variable "origin" conteniendo el id del trabajo original.
  # Ej: related_wk( works, 25 )
  
  # Inicialización de variables de error
  related_wks <- NULL
  error <- FALSE
  
  # Validación de los argumentos
  if (is.null(works)) {
    message("No se ingresó un conjunto de datos, por favor defina un conjunto de datos válidos e intente nuevamente.")
    error <- TRUE
  }

  if (is.null(limite_wks) || limite_wks > 1000 || limite_wks > count(works) ) {
    message("No se ingresó un límite de trabajos a procesar o la cantidad ingresada es mayor a la cantidad de trabajos del conjunto de datos, o la cantidad es mayor a 1.000. Se asigna como valor límite 1.000 trabajos.")
    limite_wks <- 1000
  }
  
  if ( error ) {
    message("No se pudo completar la operación. Por favor revise que el formato de los argumentos sea correcto.")
    return (related_wks)
  } 
  
  # Inicialización de variables
  posi <- 1 # Puntero que marca la posición de la observación a procesar 
  
  # Recortamos la cantidad de trabajos a procesar de acuerdo a la cantidad recibida como argumento
  works <- head(works, limite_wks)
  
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

  while (posi < limite_wks ) {
    
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

# Recuperar los trabajos relacionados con el conjunto de datos pasado en el argumento.
related_wks <- concepts_rel_wks( snowball_wks, limite_wks = 10 )

# Conocer la posición de un elemento en un vector
posi <- match()


