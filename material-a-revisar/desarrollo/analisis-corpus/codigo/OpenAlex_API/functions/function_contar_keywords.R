# Carga de librerías para procesar estructuras de datos y texto
install.packages("tidytext")

library(tidytext) # Incorpora el análisis de tokens
library(tidyverse) # Incorpora el paquete tibble
library(tm) # Incorpora stopwords

# Carga de datos

keywords <- c("hola","que tal","como están")
corpus_titulo <- c("hola", "hola, que tal","hola, que tal, como están")
corpus_texto <- c("esto es un texto muestra, en la cual se contarán las palabras clave", "hola aparece en tres oportunidades, hola que tal parace en dos oportunidades", "como están aparece en una oportunidad")

# Estructura de datos de texto en tidytext

corpus_raw <- tibble(titulo = corpus_titulo, texto = corpus_texto)

corpus_1token <- corpus_raw %>%
                unnest_tokens(output = word, input = texto, token = "ngrams", n=1)

corpus_2token <- corpus_raw %>%
                unnest_tokens(output = word, input = texto, token = "ngrams", n=2)

head(corpus_1token)
head(corpus_2token)

# Limpiar texto de palabras frecuentes (stopwords)

library(stopwords) # Incorpora un diccionario de stopwords

corpus_1token <- corpus_1token %>% 
  filter(!word %in% stopwords(language = "es",source = "snowball"))

# Contar la frecuencia de palabras

corpus_1token <- corpus_1token %>% 
  group_by(titulo, word) %>% 
  summarise(conteo=n()) %>% 
  arrange(desc(conteo))

head(corpus_1token)

# Contar la frecuencia de palabras utilizando la transformación tf-idf
# tf (Term Frequency): hace referencia a la frecuencia de términos.
# En el análisis de texto, el TF mide la importancia de un término en un documento específico. 
# idf (Inverse Document Frequency): IDF se refiere a la frecuencia inversa de documentos.
# El IDF mide la importancia de un término en el corpus completo de documentos. 
# TF-IDF (Term Frequency-Inverse Document Frequency): TF-IDF es una combinación de TF e IDF
# Se utiliza para evaluar la importancia de un término en un documento dentro de un corpus completo de documentos.

corpus_titulo <- c("hola", "hola, que tal","hola, que tal, como están")
corpus_texto <- c("hola, esto es un texto muestra, en la cual se contarán las palabras clave", "hola, aparece en tres oportunidades, hola que tal parace en dos oportunidades", "hola, como están aparece en una oportunidad")

corpus_raw <- tibble(titulo = corpus_titulo, texto = corpus_texto)

corpusCompleteTokens <- corpus_raw %>%
                        unnest_tokens(output = word, input = texto) %>%
                        group_by(titulo, word) %>%
                        summarize(count=n()) %>%
                        arrange(desc(count))

head(corpusCompleteTokens)

corpusCompleteTokens <- corpusCompleteTokens %>% 
                        bind_tf_idf(term = word, document = titulo, n = count) %>% 
                        arrange(desc(tf_idf))

head(corpusCompleteTokens)
View(corpusCompleteTokens)

# Gráfico de las 15 palabras más importantes del corpus

corpus_first15 <- corpusCompleteTokens %>% 
  arrange(desc(tf_idf)) %>% 
  mutate(word=reorder_within(x=word, by=tf_idf, within=titulo)) %>% 
  group_by(titulo) %>% 
  slice_max(order_by=tf_idf, n=15, with_ties=FALSE) %>% 
  ungroup()

head(corpus_first15)
View(corpus_first15)

ggplot(corpus_first15) +
  geom_col(aes(y=word,x=tf_idf)) +
  scale_fill_brewer(palette = "Set1") +
  guides(fill=FALSE) +
  facet_wrap(~titulo) +
  theme_minimal()
  
ggplot(corpusAfinn) +
  geom_col(aes(x=sentimiento,y=titulo)) +
  scale_fill_brewer(palette = "Set1") +
  guides(fill=FALSE) +
  theme_minimal()

# Análisis de sentimiento

install.packages("textdata")
library(textdata)

diccionarioAfinn <- get_sentiments("afinn")
head(diccionarioAfinn)

corpus_1token %>% 
  inner_join(diccionarioAfinn)

head(corpus_1token)

# Preparación y Gráfico de resultados

corpus_Afinn <- corpus_1token %>%
  inner_join(diccionarioAfinn) %>% 
  group_by(titulo) %>% 
  summarise(sentimiento=mean(value)) %>%
  mutate(feeling=ifelse(sentimiento>0,"Positivo","Negativo"))

ggplot(corpusAfinn) +
  geom_col(aes(x=sentimiento,y=titulo, fill=feeling)) +
  scale_fill_brewer(palette = "Set1") +
  guides(fill=FALSE) +
  theme_minimal()


contar_palabras <- function(keywords, texto) {}