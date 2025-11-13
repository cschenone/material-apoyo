# Carga de librerías para procesar estructuras de datos y texto
install.packages("tidytext")

library(tidytext) # Incorpora el análisis de tokens
library(tidyverse) # Incorpora el paquete tibble
library(tm) # Incorpora stopwords

# Carga de datos

keywords <- c("hola","que tal","como están")
corpus_titulo <- c("hola", "hola, que tal","hola, que tal, como están")
corpus_texto <- c("esto es un texto muestra, en la cual se contarán las palabras clave",
                  "hola aparece en tres oportunidades, hola que tal parace en dos oportunidades",
                  "como están aparece en una oportunidad")

# Cargar los documentos en un corpus
corpus <- Corpus(VectorSource(corpus_texto))

# Ver los documentos en el corpus
inspect(corpus)

# Preprocesamiento de texto
corpus <- tm_map(corpus, content_transformer(tolower))
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, removeNumbers)
#corpus <- tm_map(corpus, removeWords, stopwords("english"))
corpus <- tm_map(corpus, removeWords, stopwords("spanish"))
corpus <- tm_map(corpus, stripWhitespace)

# Aplicar Stemming a los términos del corpus usando tm_map
# corpus <- tm_map(corpus, stemDocument) 
# el stemming reduce las palabras eliminando los sufijos o prefijos para obtener una forma más simple. El stemming se basa en reglas heurísticas y no siempre produce palabras válidas o reconocibles en el idioma. Por ejemplo, al aplicar stemming a las palabras "corriendo", "corrió" y "corre", es posible que se reduzcan a "corr". El stemming no tiene en cuenta el contexto o la gramática de las palabras, lo que puede llevar a una reducción inadecuada o a la generación de formas que no existen en el idioma.

inspect(corpus)

# Lematizar los términos del corpus usando tm_map
# La lematización reduce las palabras a su lema, que es la forma canónica o base de una palabra. El lema representa el significado fundamental de una palabra y puede ser un sustantivo en singular, un verbo en infinitivo, un adjetivo en grado positivo, etc. Por ejemplo, los lemas de las palabras "corriendo", "corrió" y "corre" son "correr". La lematización tiene en cuenta el contexto y la gramática de las palabras para obtener la forma base adecuada.
install.packages("textstem")
library(textstem)

# Lematizar los términos del corpus
corpus_text <- tm_map(corpus, PlainTextDocument)
corpus_lemaized <- lemmatize_strings(corpus_text)

# Mostrar los documentos después de la lematización
inspect(corpus)
inspect(corpus_lemaized)

# Crear la matriz DocumentTermMatrix
dtm_corpus <- DocumentTermMatrix(corpus)
dtm_corpus_lem <- DocumentTermMatrix(corpus_lemaized)

# Mostrar la matriz
as.matrix(dtm_corpus)
as.matrix(dtm_corpus_lem)


# Crear una matriz de términos
dtm <- DocumentTermMatrix(corpus)

as.matrix(dtm)

# Obtener las frecuencias de las palabras clave específicas
# keywords <- c("hola","que tal","como están")

# Definir las palabras clave
keywords <- c("hola", "que", "tal", "como", "están")

# Obtener los índices de las columnas que contienen las palabras clave
keyword_indices <- which(colnames(dtm) %in% keywords)

# Filtrar la matriz dtm
filtered_dtm <- dtm[, keyword_indices]

# Mostrar la matriz filtrada
as.matrix(filtered_dtm)

palabras_clave <- Corpus(VectorSource(palabras_clave))

inspect(palabras_clave)

palabras_clave <- tm_map(palabras_clave, content_transformer(tolower))
palabras_clave <- tm_map(palabras_clave, removePunctuation)
palabras_clave <- tm_map(palabras_clave, removeNumbers)
palabras_clave <- tm_map(palabras_clave, removeWords, stopwords("english"))
palabras_clave <- tm_map(palabras_clave, removeWords, stopwords("spanish"))

# Ver los documentos en el corpus
inspect(palabras_clave)

palabras_clave_text <- tm_map(palabras_clave, PlainTextDocument)
library(wordcloud)
wordcloud(palabras_clave_text, max.words = 80, random.order = F, colors = brewer.pal(name = "Dark2", n = 8))

frecuencias <- colSums(as.matrix(dtm[, palabras_clave_text]))

# Mostrar las frecuencias
print(frecuencias)
