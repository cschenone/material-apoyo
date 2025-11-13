##########################################################################################
# 
# Análisis Bibliométrico y Ngramas de trabajos recuperados desde la base de datos OpenAlex
# 
# Ref: https://docs.ropensci.org/openalexR/
# openalexR helps you interface with the OpenAlex API to retrieve bibliographic infomation about publications,
# authors, venues, institutions and concepts with 5 main functions:
# 
# * oa_fetch: composes three functions below so the user can execute everything in one step, i.e., oa_query |> oa_request |> oa2df
# * oa_query: generates a valid query, written following the OpenAlex API syntax, from a set of arguments provided by the user.
# * oa_request: downloads a collection of entities matching the query created by oa_query or manually written by the user, and returns a JSON object in a list format.
# * oa2df: converts the JSON object in classical bibliographic tibble/data frame.
# * oa_random: get random entity, e.g., oa_random("works") gives a different work each time you run it
#
##########################################################################################

# Install packages
## Install openalexR released version 
## install.packages("openalexR")

## install openalexR developer version of from github
## Nota: la version en desarrollo incorpora funciones de conversión que la versión liberada no dispone, por ejemplo "oa2bibliometrix"
install.packages("remotes")
remotes::install_github("ropensci/openalexR")

install.packages("writexl")

# Load libraries
library(openalexR)
library(dplyr)
library(ggplot2)
library(bibliometrix)
library(writexl)
library(tidyr) # incluye el método unnest

## Before we go any further, we highly recommend you set openalexR.mailto option so that your requests go to the polite pool for faster response times. If you have OpenAlex Premium, you can add your API key to the openalexR.apikey option as well. These lines best go into .Rprofile with file.edit("~/.Rprofile").

options(openalexR.mailto = "example@email.com")
options(openalexR.apikey = "EXAMPLE_APIKEY")

## Alternatively, you can open .Renviron with file.edit("~/.Renviron") and add:
## 
## openalexR.mailto = example@email.com
## openalexR.apikey = EXAMPLE_APIKEY

# Análisis con bibliometrix

## Data loading and converting
### from bibtex example
file <- "https://www.bibliometrix.org/datasets/savedrecs.bib"
M1 <- convert2df(file = file, dbsource = "isi", format = "bibtex")

### from openalex example
works_search <- oa_fetch(
  entity = "works",
  title.search = c("bibliometric analysis", "science mapping"),
  cited_by_count = ">50",
  from_publication_date = "2020-01-01",
  to_publication_date = "2021-12-31",
  options = list(sort = "cited_by_count:desc"),
  verbose = TRUE
)

M2 <- oa2bibliometrix(works_search) 
## Cuando se pruebe con datos de OpenAlex, trasladando el atributo concepts al atributo DE Authors’Keywords

## Compare datasets M1 y M2

comparar_estructura_datasets <- function(dataset1, dataset2) {
  # Obtener nombres de columnas y tipos de datos para ambos datasets
  col_names1 <- names(dataset1)
  col_types1 <- sapply(dataset1, class)
  
  col_names2 <- names(dataset2)
  col_types2 <- sapply(dataset2, class)
  
  # Comparar las columnas y tipos de datos
  if (!identical(col_names1, col_names2)) {
    cat("Las columnas de ambos datasets no coinciden.\n")
    cat("Columnas en el primer dataset:\n")
    print(col_names1)
    cat("\nColumnas en el segundo dataset:\n")
    print(col_names2)
  } else {
    cat("Las columnas de ambos datasets coinciden.\n")
  }
  
  if (!identical(col_types1, col_types2)) {
    cat("\nLos tipos de datos de las columnas en ambos datasets no coinciden.\n")
    cat("Tipos de datos en el primer dataset:\n")
    print(col_types1)
    cat("\nTipos de datos en el segundo dataset:\n")
    print(col_types2)
  } else {
    cat("\nLos tipos de datos de las columnas en ambos datasets coinciden.\n")
  }
}

# Generar estructuras de trabajo

M2tb <- tibble(M2)
M2tb1 <- select(M2tb, concepts)
M2tb2 <- unnest(M2tb, cols = c(concepts))

###################################################################################################
###   CONTINUAR DESDE ACA ... 
# Observación inicial: Se genera un tibble con todos los conceptos del corpus, pero se pierde la pertenencia al trabajo
# Entonces se debe hace unnest pero manteniendo el id del trabajo.
#
# Esto es interesante: contenido del atributo concept, hecho unnest y mostrando el nombre:
#
# M2$concepts[[1]][["display_name"]]
# Tomar M2 y obtener en el atributo DE el listado de conceptos mayores a 0.5 tomandos de la lista concepts
# 
# Averiguar cual es el campo que está vació y debe ser completado por el valor del campo ID de M2
# La función M2 <- oa2bibliometrix(works_search) deja en el atributo ID los conceptos.
#
# Próximo paso:
# Copiar M2 en M3,
# Copiar el campo M3$ID en el campo M3$DE
# Ejecutar bibliometrix en M2 y M3
# Comparar los resultados (debería mostrar valores completos similares al resultado obtenido sobre M1)
#
# Resultado: luego de observar el comportamiento de la función oa2bibliometrix, se resuelve lo siguiente:
# 
# Dejar el atributo ID como está, dado que es la interpretación que le dieron los que desarrollaron
# la función oa2bibliometrix (OpenAlex decide no exponer las palabras clave de los autores)
#
###################################################################################################

###################################################################################################
##
## # Si la BD es OpenAlex
## ID: Concepts (si la BD es OpenAlex)
## DE: Author Keyword: no aparece porque OpenAlex no los incorpora
##
# Aporte: analizando la función show_works (https://docs.ropensci.org/openalexR/reference/show_works.html)
## Se descubre que extrae los 3 (tres) primeros conceptos con nivel 2 (dos), por lo cual siguiendo
# esta idea vamos a extraer estos conceptos y lo copiamos en el campo DE, de esta forma obtenemos otro análisis
## de las palabras clave brindado por la función bibliometrix
#
###################################################################################################

Buscar una forma en la cual se pueda filtrar los conceptos con nivel 2, luego, varias opciones
pegarlos en works_search en la variable DE, aplicarle bibliometrix y ver como los traduce (deberia quedar con el 
mismo formato que los conceptos en el atributo ID).

WC <- concepts2df(works_search, verbose = TRUE)
# Ref: https://rdrr.io/github/massimoaria/openalexR/man/concepts2df.html
WC <- show_works(works_search, simp_fun = identity) %>%
  select(id, top_concepts)

WC <- works_search %>%
  select(id, concepts) %>%
  unnest_longer(concepts) %>%
  filter(concepts$level == 2 )

# simp_func : R function to simplify the result. Default to `head`. If you want the entire table, set `simp_fun = identity`

M3 <- M2
M3 <- M3 %>%
  mutate(DE = ID)

## Ordenar columnas
d1 <- M1 [ , order(c(names(M1)))]
d2 <- M2 [ , order(c(names(M2)))]
d3 <- M3 [ , order(c(names(M3)))]

# Exportar dataset como archivo excel
write_xlsx(d1, path = "~/GitHub/doctorado/desarrollo/OpenAlexAPI/intermedio/data/dataset1.xlsx")
write_xlsx(d2, path = "~/GitHub/doctorado/desarrollo/OpenAlexAPI/intermedio/data/dataset2.xlsx")
write_xlsx(d3, path = "~/GitHub/doctorado/desarrollo/OpenAlexAPI/intermedio/data/dataset3.xlsx")

print("Comparación dataset1 y dataset2")
comparar_estructura_datasets(d1, d2)

print("Comparación dataset1 y dataset3 (agregamos DE)")
comparar_estructura_datasets(d1, d3)

# Luego, podemos mencionar las siguientes funciones para comparar y unir dataframes:
## intersect(df1, df2): devuelve un df con las observaciones comunes entre df1 y df2
## union(df1, df2): devuelve la unión; o sea, las observaciones de df1 y de df2 (quitando las posibles filas duplicadas)
## union_all(df1, df2): devuelve la unión (sin quitar los duplicados)
## setdiff(df1, df2): devuelve las filas en df1 que no están en df2
## setequal(df1,df2: retorna TRUE si df1 y df2 tienen exactamente las mismas filas (da igual el orden en el que estén las filas)

n1 <- names(M1)
n2 <- names(M2)
n3 <- names(M3)

ambos <- tibble(ambos = intersect(n1, n2))
solo_n1 <- tibble(solo_n1 = setdiff(n1, n2))
solo_n2 <- tibble(solo_n2 = setdiff(n2, n1))
count(ambos)

# Ejemplo de objeto trabajo de openalex
M4 <- tibble(works_search)
n4 <- tibble(names(M4))

####################################################################################################
##
# Bibliometric Analysis
#
## M2 <- oa2bibliometrix(works_search) 
####################################################################################################

results1 <- biblioAnalysis(M1, sep = ";")
results2 <- biblioAnalysis(M2, sep = ";")
results3 <- biblioAnalysis(M3, sep = ";")

r1 <- names(results1) 
r2 <- names(results2)
r3 <- names(results3)

solo_r1_r2 <- setdiff(r1, r2)
solo_r2_r1 <- setdiff(r2, r1)
solo_r1_r3 <- setdiff(r1, r2)

# Functions summary and plot

options(width=100)
S1 <- summary(object = results1, k = 10, pause = FALSE)
S2 <- summary(object = results2, k = 10, pause = FALSE)
S3 <- summary(object = results3, k = 10, pause = FALSE)

###################################################################################################
#
# Nota respecto a los atributos de OpenAlex:
# Si la BD es distinta a OpenAlex (Scopus, WOS, Dimensions)
## ID: Keywords-Plus (según BD Indexadas): es un indice de palabras o términos generadas a partir de los títulos de artículos citados 
## DE: Author Keyword: son las palabras clave de los autores.
#
# Si la BD es OpenAlex
## ID: Concepts (si la BD es OpenAlex)
## DE: Author Keyword: no aparece porque OpenAlex no los incorpora
#
##################################################################################################
#
# Some basic plots can be drawn using the generic function :
# plot(x = results, k = 10, pause = FALSE)
#
##################################################################################################

##################################################################################################
#
# Analysis of Cited References
#
##################################################################################################

## To obtain the most frequent cited manuscripts:
CR <- citations(M, field = "article", sep = ";")
cbind(CR$Cited[1:10])

## To obtain the most frequent cited first authors:
CR <- citations(M, field = "author", sep = ";")
cbind(CR$Cited[1:10])

## To obtain the most frequent local cited authors:
CR <- localCitations(M, sep = ";")
CR$Authors[1:10,]

## To obtain the most frequent papers:
CR$Papers[1:10,]

###################################################################################################
#
# Authors’ Dominance ranking
#
###################################################################################################

DF <- dominance(results, k = 10)
DF

###################################################################################################
#
# Authors’ h-index
#
###################################################################################################

## To calculate the h-index of Lutz Bornmann in this collection:
indices <- Hindex(M, field = "author", elements="BORNMANN L", sep = ";", years = 10)

### Bornmann's impact indices:
indices$H

### Bornmann's citations
indices$CitationList

## To calculate the h-index of the first 10 most productive authors (in this collection):
  
authors=gsub(","," ",names(results$Authors)[1:10])
indices <- Hindex(M, field = "author", elements=authors, sep = ";", years = 50)
indices$H

###################################################################################################
#
# Top-Authors’ Productivity over the Time
#
###################################################################################################

topAU <- authorProdOverTime(M, k = 10, graph = TRUE)

## Table: Author's productivity per year

head(topAU$dfAU)

## Table: Auhtor's documents list

head(topAU$dfPapersAU)

###################################################################################################
#
# Lotka’s Law coefficient estimation
#
###################################################################################################

L <- lotka(results)

## Author Productivity. Empirical Distribution

L$AuthorProd

## Beta coefficient estimate

L$Beta

## Constant
L$C

## Goodness of fit
L$R2

## P-value of K-S two sample test
L$p.value

###################################################################################################
#
# Observed distribution
#
###################################################################################################

Observed=L$AuthorProd[,3]

## Theoretical distribution with Beta = 2
Theoretical=10^(log10(L$C)-2*log10(L$AuthorProd[,1]))

plot(L$AuthorProd[,1],Theoretical,type="l",col="red",ylim=c(0, 1), xlab="Articles",ylab="Freq. of Authors",main="Scientific Productivity")
lines(L$AuthorProd[,1],Observed,col="blue")
legend(x="topright",c("Theoretical (B=2)","Observed"),col=c("red","blue"),lty = c(1,1,1),cex=0.6,bty="n")

###################################################################################################
#
# Bibliographic network matrices
#
###################################################################################################

## Bipartite networks
A <- cocMatrix(M, Field = "SO", sep = ";")

## Sorting, in decreasing order, the column sums of A, you can see the most relevant publication sources:
sort(Matrix::colSums(A), decreasing = TRUE)[1:5]

## Following this approach, you can compute several bipartite networks:
  
###  Citation network
A <- cocMatrix(M, Field = "CR", sep = ".  ")

### Author network
A <- cocMatrix(M, Field = "AU", sep = ";")

### Country network
### Authors’ Countries is not a standard attribute of the bibliographic data frame.
### You need to extract this information from affiliation attribute using the function metaTagExtraction.
M <- metaTagExtraction(M, Field = "AU_CO", sep = ";")

### metaTagExtraction allows to extract the following additional field tags:
### Authors’ countries (Field = "AU_CO");
### First Author’s countries (Field = "AU_CO");
### First author of each cited reference (Field = "CR_AU");
### Publication source of each cited reference (Field = "CR_SO"); and
### Authors’ affiliations (Field = "AU_UN").

## Author keyword network
A <- cocMatrix(M, Field = "DE", sep = ";")

## Keyword Plus network
A <- cocMatrix(M, Field = "ID", sep = ";")

###################################################################################################
#
# Bibliographic coupling
#
###################################################################################################

## The following code calculates a classical article coupling network:
NetMatrix <- biblioNetwork(M, analysis = "coupling", network = "references", sep = ".  ")

## normalizeSimilarity function calculates Association strength, Inclusion, Jaccard or Salton similarity among vertices of a network.
## normalizeSimilarity can be recalled directly from networkPlot() function using the argument normalize.
NetMatrix <- biblioNetwork(M, analysis = "coupling", network = "authors", sep = ";")

net <- networkPlot(NetMatrix,  normalize = "salton", weighted=NULL, n = 100, Title = "Authors' Coupling", type = "fruchterman", size=5,size.cex=T,remove.multiple=TRUE,labelsize=0.8,label.n=10,label.cex=F)

###################################################################################################
#
# Bibliographic co-citation
#
###################################################################################################

## Using the function biblioNetwork, you can calculate a classical reference co-citation network:
  
NetMatrix <- biblioNetwork(M, analysis = "co-citation", network = "references", sep = ".  ")

# Bibliographic collaboration  

## Using the function biblioNetwork, you can calculate an authors’ collaboration network:
NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "authors", sep = ";")

## or a country collaboration network:
NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "countries", sep = ";")

###################################################################################################
#
# Descriptive analysis of network graph characteristics 
#
###################################################################################################

## An example of a classical keyword co-occurrences network
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")
netstat <- networkStat(NetMatrix)

###################################################################################################
#
# The summary statistics of the network
#
###################################################################################################
#
# This group of statistics allows to describe the structural properties of a network:
#
## Size is the number of vertices composing the network;
## Density is the proportion of present edges from all possible edges in the network;
## Transitivity is the ratio of triangles to connected triples;
## Diameter is the longest geodesic distance (length of the shortest path between two nodes) in the network;
## Degree distribution is the cumulative distribution of vertex degrees;
## Degree centralization is the normalized degree of the overall network;
## Closeness centralization is the normalized inverse of the vertex average geodesic distance to others in the network;
## Eigenvector centralization is the first eigenvector of the graph matrix;
## Betweenness centralization is the normalized number of geodesics that pass through the vertex;
## Average path length is the mean of the shortest distance between each pair of vertices in the network.
names(netstat$network)

# The main indices of centrality and prestige of vertices
# These measures help to identify the most important vertices in a network and the propensity of two vertices that are connected
# to be both connected to a third vertex.
# The statistics, at vertex level, returned by networkStat are:
## Degree centrality
## Closeness centrality measures how many steps are required to access every other vertex from a given vertex;
## Eigenvector centrality is a measure of being well-connected connected to the well-connected;
## Betweenness centrality measures brokerage or gatekeeping potential. It is (approximately) the number of shortest paths between vertices that pass through a particular vertex;
## PageRank score approximates probability that any message will arrive to a particular vertex. This algorithm was developed by Google founders, and originally applied to website links;
## Hub Score estimates the value of the links outgoing from the vertex. It was initially applied to the web pages;
## Authority Score is another measure of centrality initially applied to the Web. A vertex has high authority when it is linked by many other vertices that are linking many other vertices;
## Vertex Ranking is an overall vertex ranking obtained as a linear weighted combination of the centrality and prestige vertex measures. The weights are proportional to the loadings of the first component of the Principal Component Analysis.
names(netstat$vertex)

## summarize the main results of the networkStat function
## summary accepts one additional argument. k is a formatting value that indicates the number of rows of each table.
## Choosing k=10, you decide to see the first 10 vertices.
summary(netstat, k=10)

###################################################################################################
#
# Visualizing bibliographic networks
#
###################################################################################################

## Country Scientific Collaboration

### Create a country collaboration network
M <- metaTagExtraction(M, Field = "AU_CO", sep = ";")
NetMatrix <- biblioNetwork(M, analysis = "collaboration", network = "countries", sep = ";")

### Plot the network
net=networkPlot(NetMatrix, n = dim(NetMatrix)[1], Title = "Country Collaboration", type = "circle", size=TRUE, remove.multiple=FALSE,labelsize=0.7,cluster="none")

## Co-Citation Network

### Create a co-citation network
NetMatrix <- biblioNetwork(M, analysis = "co-citation", network = "references", sep = ";")
### Plot the network
net=networkPlot(NetMatrix, n = 30, Title = "Co-Citation Network", type = "fruchterman", size=T, remove.multiple=FALSE, labelsize=0.7,edgesize = 5)

## Keyword co-occurrences

### Create keyword co-occurrences network
NetMatrix <- biblioNetwork(M, analysis = "co-occurrences", network = "keywords", sep = ";")
### Plot the network
net=networkPlot(NetMatrix, normalize="association", weighted=T, n = 30, Title = "Keyword Co-occurrences", type = "fruchterman", size=T,edgesize = 5,labelsize=0.7)

###################################################################################################
#
# Co-Word Analysis: The conceptual structure of a field
#
###################################################################################################

## Conceptual Structure using keywords (method="CA")
## conceptualStructure includes natural language processing (NLP) routines (see the function termExtraction)
## to extract terms from titles and abstracts.
## In addition, it implements the Porter’s stemming algorithm to reduce inflected (or sometimes derived) words to their word stem,
## base or root form.
CS <- conceptualStructure(M,field="ID", method="CA", minDegree=4, clust=5, stemming=FALSE, labelsize=10, documents=10)

###################################################################################################
#
# Historical Direct Citation Network
#
###################################################################################################

## Create a historical citation network
options(width=130)
histResults <- histNetwork(M, min.citations = 1, sep = ";")
## Plot a historical co-citation network
net <- histPlot(histResults, n=15, size = 10, labelsize=5)

###################################################################################################
#
# Main Authors’ references (about bibliometrics)
#
###################################################################################################
#
## Aria, M. & Cuccurullo, C. (2017). bibliometrix: An R-tool for comprehensive science mapping analysis, Journal of Informetrics, 11(4), pp 959-975, Elsevier, DOI: 10.1016/j.joi.2017.08.007 (https://doi.org/10.1016/j.joi.2017.08.007).
## Aria M., Misuraca M., Spano M. (2020) Mapping the evolution of social research and data science on 30 years of Social Indicators Research, Social Indicators Research. (DOI: )https://doi.org/10.1007/s11205-020-02281-3)
## Aria, M., Cuccurullo, C., D’Aniello, L., Misuraca, M., & Spano, M. (2022). Thematic Analysis as a New Culturomic Tool: The Social Media Coverage on COVID-19 Pandemic in Italy. Sustainability, 14(6), 3643, (https://doi.org/10.3390/su14063643).
## Aria M., Alterisio A., Scandurra A, Pinelli C., D’Aniello B, (2021) The scholar’s best friend: research trends in dog cognitive and behavioural studies, Animal Cognition. (https://doi.org/10.1007/s10071-020-01448-2)
## Cuccurullo, C., Aria, M., & Sarto, F. (2016). Foundations and trends in performance management. A twenty-five years bibliometric analysis in business and public administration domains, Scientometrics, DOI: 10.1007/s11192-016-1948-8 (https://doi.org/10.1007/s11192-016-1948-8).
## Cuccurullo, C., Aria, M., & Sarto, F. (2015). Twenty years of research on performance management in business and public administration domains. Presentation at the Correspondence Analysis and Related Methods conference (CARME 2015) in September 2015 (https://www.bibliometrix.org/documents/2015Carme_cuccurulloetal.pdf).
## Sarto, F., Cuccurullo, C., & Aria, M. (2014). Exploring healthcare governance literature: systematic review and paths for future research. Mecosan (https://www.francoangeli.it/Riviste/Scheda_Rivista.aspx?IDarticolo=52780&lingua=en).
## Cuccurullo, C., Aria, M., & Sarto, F. (2013). Twenty years of research on performance management in business and public administration domains. In Academy of Management Proceedings (Vol. 2013, No. 1, p. 14270). Academy of Management (https://doi.org/10.5465/AMBPP.2013.14270abstract).
#
# Citation for package ‘bibliometrix’
# To cite bibliometrix in publications, please use:
## Aria, M. & Cuccurullo, C. (2017) bibliometrix: An R-tool for comprehensive science mapping analysis, Journal of Informetrics, 11(4), pp 959-975, Elsevier.

###################################################################################################
#
# Análisis de ngramas
# Ref: https://rdrr.io/github/massimoaria/openalexR/src/R/oa_ngrams.R#sym-ngram2df
# ngram2df : Convert a "Work" entity's ngram data from list to data frame
# oa_ngrams : Get N-grams of works. Return A dataframe of paper metadatada and a list-column of ngrams
#
###################################################################################################

if (TRUE) {
  
  ngrams_data1 <- oa_ngrams(works_search$id)
  ngrams_data2 <- oa_ngrams(c("W1963991285", "W1964141474","W2284876136"))
 
  ngrams_data <- ngrams_data2 
# library(dplyr)
  first_paper_ngrams <- ngrams_data$ngrams[[1]]
  top_10_ngrams <- first_paper_ngrams %>%
    slice_max(ngram_count, n = 10, with_ties = FALSE)
  
  # Missing N-grams are `NULL` in the `ngrams` list-column
  # oa_ngrams("https://openalex.org/W2284876136")
}

