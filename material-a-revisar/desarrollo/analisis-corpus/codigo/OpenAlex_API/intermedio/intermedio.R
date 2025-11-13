library(tidyverse)
library(dplyr)

searchkey <- "deep   learning  && water   //   machine learning intelligence water"
searchkey <- searchkey %>%
  str_remove("&&") %>%
  str_squish() 

phrasekey <- tibble(wordkey = str_split(searchkey, " // ")) %>%
  unnest(cols = c(wordkey))

buscar_wks <- function(keywords, cited=">50", from_date=today()-years(5), to_date=today(), limit_wks = 10000) {
  # Desc: Recuperar trabajos en la BD OpenAlex según criterios pasados como argumentos
  # Args:
  # * keywords: palabras clave utilizadas en la búsqueda. En caso de desear la búsqueda por criterios múltiples,
  #   deberá separar cada frase con el operador // (operador "OR"). Formato: "keywords 1" // "keywords 2" // "keywords 3".
  #   Ejemplo "machine learning water // deep learning water".
  # * cited: limite de citas de los trabajos. Formato "Operador lógico" + "Número". Ejemplo ">=100". Valor por defecto: ">50"
  # * from_date: fecha inferior de publicación. Formato "AAAA-MM-DD". Valor por defecto: 5 años hacia atrás de la fecha actual
  # * to_date: fecha máxima de publicación. Formato "AAAA-MM-DD". Valor por defecto: la fecha actual
  # * limit_wks : límite de trabajos a recuperar en la búsqueda. Valor por defecto: 10000
  # Resp: dataframe conteniendo los trabajos que cumplen con los criterios. En caso que exista algún error en los argumentos devuelve "NA" 
  # Ej: buscar_wks(keywords = "machine learning water // deep learning water", cited = ">50", from_date = "2019-01-01", to_date = "2022-31-12")
  
  # Inicialización de variables  
  df_wks <- tibble(NA)   # Dataframe contenedor de los resultados de la búsqueda
  
  # Validación de los argumentos
  if (is.null(keywords)) {
    message("No ingresó ninguna palabra clave. Por favor intente nuevamente ingresando alguna palabra")
    message("Ejemplo: buscar_wks(keywords = bibliometrix, cited = >50, from_date = 2019-01-01, to_date = 2022-31-12")
    Return(df_wks)
  }  
  
  if (!is.Date(from_date) || !is.Date(from_date)) {
    message("La fecha del intervalo debe ser una fecha en el formato YYYY-MM-DD")
    Return(df_wks)
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
  cat("Palabras clave a buscar en el título, abstract o full text:", keywords)
  cat("Cantidad de citas:", cited)
  cat("Trabajos publicados entre", from_date,"y", to_date)
  
  # Analiza la cadena de búsqueda, en caso de encontrar el operador "&&" (operador "AND") lo remueve, dado que la búsqueda lo aplica por defecto.
  # En caso de encontrar el operador "//" (operador "OR") lo utiliza para partir la frase de búsqueda, luego realiza la búsqueda en forma separada y reúne el conjunto resultante.
  # keywords <- "deep   learning  && water   //   machine learning intelligence water"
  
  keywords <- keywords %>%
    str_remove("&&") %>%
    str_squish() # removes whitespace at the start and end, and replaces all internal whitespace with a single space
  
  split_search_key <- tibble(wordkey = str_split(searchkey, " // ")) %>%
    unnest(cols = c(wordkey))
  
  search_key_wks <- mutate(split_search_key)
  
  # Antes de realizar la consulta, valida que la cantidad de trabajos no superen el límite establecido
  
  total_wks <- 0 # Acumula la cantidad total de trabajos de cada criterio
  
  for (phrase_key in split_search_keys) {
    args <- list(
      entity = "works",
      search = phrase_key,
      cited_by_count = cited,
      from_publication_date = from_date,
      to_publication_date = to_date,  
      sort = "relevance_score:desc, cited_by_count:desc", # Ordenamos el conjunto por cantidad de citas y relevance_score
      mailto = "example@email.com",
      verbose = TRUE,
    )
    
    # Passing all these arguments to the function
    query_wks <- do.call(oa_query, args) # Genero la string de consulta considerando los criterios
    
    # Búsqueda de trabajos
    res_wks <- do.call(oa_request, c(per_page = 25, count_only = "TRUE")) # Solo necesitamos conocer la cantidad de trabajos ("count_only = TRUE")
    cant_res_wks <- as_tibble(as.list(res_wks))$count # Cantidad de trabajos recuperados en la consulta
    cat("El criterio ", phrase_key, "devuelve ", cant_res_wks, "trabajos.")
    
    if(cant_res_wks > limit_wks) {
      # El resultado supera la cantidad máxima de trabajos
      cat("El criterio de búsqueda", phrase_key, " encontró ", cant_res_wks," trabajos.")
      message("El resultado supera el límite, establecido en ", limit_wks, ". Por favor, revise las palabras clave y repita la búsqueda")
      Return(NULL)
    }
    
    total_wks <- total_wks + cant_res_wks
    
    if(total_wks > limit_wks) {
      # El resultado supera la cantidad máxima de trabajos
      cat("La suma de los criterios de búsqueda, encontró ", total_wks," trabajos.")
      message("El resultado supera el límite, establecido en ", limit_wks, ". Por favor, revise las palabras clave y repita la búsqueda")
      Return(NULL)
    }
    
  }
  
  # Si la cantidad de trabajos para cada criterio en forma individual y el acumulado para todos los criterios no supera
  # el límite establecido, se avanza en el procesamiento
  
  df_res_wks <- NULL
  
  for (phrase_key in split_search_keys) {
    
    args <- list(
      entity = "works",
      search = keywords,
      cited_by_count = cited,
      from_publication_date = from_date,
      to_publication_date = to_date,  
      sort = "relevance_score:desc, cited_by_count:desc", # Si deseamos ordenar el conjunto debemos incluir relevance_score, de otra forma reemplaza el valor relevance_score por NA
      mailto = "example@email.com",
      verbose = TRUE,
    )
    
    # Passing all these arguments to the function
    query_wks <- do.call(oa_query, args) # Genero la string de consulta considerando los criterios
    res_wks <- do.call(oa_request, c(args, list(count_only = "FALSE"))) # Recuperamos los trabajos que cumplen los criterios de búsqueda
    df_wks <- do.call(oa2df, c(abstract = "TRUE", group_by = "NULL")) # Convertimos el resultado en un dataframe
    cat("Se recuperaron los trabajos del criterio:", keywords)
    
    df_res_wks <- bind_rows(df_res_wks, df_wks)
  }  
  
  df_res_wks <- tibble(df_wks) %>%
    dictinct() %>%
    arrange(desc(relevance_score), desc(cited_by_count))
  
  Return(df_res_wks)
  
}

a <- tibble(
  a = 1,
  b = 2,
  c = 3
)  

a <- bind_rows(a, c(a = 2, b = 3, c = 4))

a <- mutate(a, role = "origin", id_origin = origin_wk_new) # Agrego la variable "role" para identificar los trabajos relacionados, 
# le asigno el nombre "role" para guardar compatibilidad con los trabajos recuperados de la búsqueda oa_snowball
# además, agrego una nueva variable "id_origin" para mantener el id del trabajo original

