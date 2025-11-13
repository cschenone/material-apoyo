texto <- "Aquí va el texto que deseas analizar. Mira el texto que deseas analizar."
keywords <- c("mira", "deseas", "texto")

# Limpieza del texto
corpus <- Corpus(VectorSource(texto))
corpus$content
corpus <- tm_map(corpus, content_transformer(tolower))
corpus$content
corpus <- tm_map(corpus, removePunctuation)
corpus$content
corpus <- tm_map(corpus, removeNumbers)
corpus$content
corpus <- tm_map(corpus, removeWords, stopwords("spanish"))
corpus$content
corpus <- tm_map(corpus, stripWhitespace)
corpus$content
corpus <- tm_map(corpus, PlainTextDocument, "spanish") 
corpus$content
corpus <- tm_map(corpus, stemDocument, "spanish")
corpus$content

# Creación de la matriz de términos
corpus_TDM <- TermDocumentMatrix(corpus, control=list(wordLengths=c(1,Inf)))
corpus_TDM

# Creación de la matriz de términos
corpus_freq <- sort(rowSums(as.matrix(corpus_TDM)), decreasing=TRUE)
corpus_freq

wf <- data.frame(word=names(corpus_freq), freq=corpus_freq)
wf

# Encontrar las palabras más relevantes para nuestro estudio
# Lowfreq permite filtrar las palabras según su frecuencia 

findFreqTerms(corpus_TDM, lowfreq=1)

# Otra forma
corpus_dtm <- DocumentTermMatrix(corpus)
inspect(corpus_dtm)

# Encontrar la frecuencia de los terminos
findFreqTerms(corpus_dtm, lowfrew=1)

### Analizar Dictionary en el documento
#A dictionary is a (multi-)set of strings. It is often used to denote relevant terms in text mining. We represent a
#dictionary with a character vector which may be passed to the DocumentTermMatrix() constructor as a control
#argument. Then the created matrix is tabulated against the dictionary, i.e., only terms from the dictionary
#appear in the matrix. This allows to restrict the dimension of the matrix a priori and to focus on specific terms
#for distinct text mining contexts, e.g.,

# https://cran.r-project.org/web/packages/tm/vignettes/tm.pdf



# Limpieza de las palabras clave

keywords <- paste(keywords, collapse = "")
keywords <- Corpus(VectorSource(keywords))
keywords$content
keywords <- tm_map(keywords, content_transformer(tolower))
keywords$content
keywords <- tm_map(keywords, removePunctuation)
keywords$content
keywords <- tm_map(keywords, removeNumbers)
keywords$content
keywords <- tm_map(keywords, removeWords, stopwords("spanish"))
keywords$content
keywords <- tm_map(keywords, stripWhitespace)
keywords$content
keywords <- tm_map(keywords, PlainTextDocument, "spanish") 
keywords$content$content
keywords <- tm_map(keywords, stemDocument, "spanish")
keywords$content

# Cargar librarías
library("tm")
# Ejemplo de texto
text <- "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed malesuada elit ut neque feugiat, ac volutpat nunc pharetra. Proin at felis metus. Nunc vitae tortor ac lacus condimentum auctor. Nulla facilisi. Sed convallis, urna eu rhoncus efficitur, justo dolor aliquam risus, ac consectetur lectus urna vel justo. Morbi auctor tellus sit amet tortor porttitor, vitae facilisis purus finibus. Cras condimentum malesuada turpis, sed feugiat velit pharetra id. Mauris rhoncus purus non facilisis sollicitudin. Nullam id finibus turpis. Integer ac efficitur nisl. Nam luctus semper est ac ultrices. Quisque suscipit dictum lorem at posuere. Suspendisse ut condimentum est. Phasellus ut risus mi."
# Ejemplo de palabras clave
keywords <- c("Lorem ipsum", "consectetur adipiscing elit", "ac volutpat", "Nulla facilisi", "finibus turpis", "Nam luctus semper")

# Preprocesamiento del texto
text <- tolower(text)
text <- removePunctuation(text)
  
# Crear un objeto de tipo PlainTextDocument
doc <- PlainTextDocument(text)

# Crear una matriz término-documento para el documento de texto
dtm <- DocumentTermMatrix(doc)

# Obtener las palabras clave y sus frecuencias en el documento
keyword_frequencies <- termFreq(dtm, keywords)

# Calcular la puntuación basada en la suma de las frecuencias de palabras clave
score <- sum(keyword_frequencies)
