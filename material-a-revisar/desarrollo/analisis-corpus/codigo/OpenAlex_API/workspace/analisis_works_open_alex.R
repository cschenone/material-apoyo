install.packages("syuzhet")
install.packages("tm")
install.packages("wordcloud")

library(syuzhet) # Funciones get_
library(stringr) # Funciones str_
library(tm) # Funciones de text mining
library(wordcloud) # Crear mapa de nubes

library(tidyverse)

# Importar los datos

url <- "https://doi.org/10.1038/s42256-020-00236-4"
work <- get_text_as_string(url)
work_ora <- get_sentences(work)

# Limpiar los datos

total_lineas <- length(work_ora)
linea_empieza <- 115
linea_final <- total_lineas - linea_empieza

texto_limpio <- oraciones[linea_empieza:linea_final]

texto_limpio <- work_ora %>% 
  str_replace_all(., "[[:cntrl:]]", " ") %>% 
  str_to_lower() %>% 
  removePunctuation() %>% 
  str_replace_all(., "—", " ")

texto_limpio <- removeWords(texto_limpio, words = stopwords("english"))
texto_limpio <- stripWhitespace(texto_limpio)

coleccion <- texto_limpio %>% 
  VectorSource() %>%
  Corpus()

palabras <- coleccion %>% 
  TermDocumentMatrix() %>% 
  as.matrix() %>% 
  rowSums() %>% 
  sort(decreasing = TRUE)

palabras %>% 
  head(20)

frecuencias <- data.frame(
  palabra = names(palabras),
  frecuencia = palabras
)

# Visualización de "top 10 palabras"

frecuencias[1:10,] %>% 
  ggplot() +
  aes(frecuencia, y = reorder(palabra, frecuencia)) +
  geom_bar(stat = "identity", color = "white", fill = "blue") +
  geom_text(aes(label = frecuencia, hjust = 1.5), color = "white") +
  labs(
    x = NULL,
    y = "Palabras más usadas en la obra"
  )

# Visualización "nube de palabras"

wordcloud(coleccion, 
          min.freq = 5,
          max.words = 80, 
          random.order = FALSE, 
          colors = brewer.pal(name = "Dark2", n = 8)
)


# Instala los paquetes necesarios
install.packages("rvest")
install.packages("tm")
install.packages("wordcloud")

# Carga las bibliotecas necesarias
library(rvest)
library(tm)
library(wordcloud)

# Obtén el texto de la página
url <- "https://doi.org/10.1038/s42256-020-00236-4"
page <- read_html(url)
text <- html_text(page)

# Limpieza de texto
clean_text <- tolower(text)  # Convertir a minúsculas
clean_text <- gsub("<.*?>", "", clean_text)  # Eliminar etiquetas HTML
clean_text <- gsub("[^a-zA-Z0-9 ]", "", clean_text)  # Eliminar caracteres especiales
clean_text <- removePunctuation(clean_text)  # Eliminar signos de puntuación

# Crear un corpus de texto
corpus <- Corpus(VectorSource(clean_text))

# Realizar la limpieza de texto adicional
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, stripWhitespace)

# Calcular la frecuencia de las palabras
word_freq <- termFreq(corpus)
word_freq <- sort(word_freq, decreasing = TRUE)

# Graficar la nube de palabras
wordcloud(names(word_freq), word_freq, scale = c(5, 0.5), random.order = FALSE, colors = brewer.pal(8, "Dark2"))


# Otra forma
url <- "https://doi.org/10.1038/s42256-020-00236-4"
page <- read_html(url)
texto <- html_text(page)
                  
sms_corpus <- VCorpus(VectorSource(texto))

sms_dtm <- DocumentTermMatrix(sms_corpus)

sms_dtm2 <- DocumentTermMatrix(sms_corpus,
                               control = list(
                                 tolower = TRUE,
                                 removeNumbers = TRUE,
                                 stopwords = TRUE,
                                 removePunctuation = TRUE,
                                 stemming = TRUE
                                )
                              )

findFreqTerms(sms_dtm2)

inspect(sms_dtm2)

datos<-data.frame(inspect(sms_dtm2))
datos
View(datos)

wordcloud(sms_dtm2, min.freq = 1, random.order = FALSE)

datos_tb <- as_tibble(datos)
