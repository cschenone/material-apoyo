---
editor_options:
  markdown: null
  wrap: 72
output:
  html_document:
    df_print: paged
---

# Doctorado

Repositorio para organizar el material del doctorado, donde se podrá encontrar el documento principal *README*, conteniendo la explicación del contenido. A continuación se presentan las carpetas del repositorio y su contenido.

## desarrollo

Contiene los documentos de los proyectos de desarrollo

*analisis-corpus*: contiene el material del proyecto de desarrollo "Metodología híbrida para al análisis de un corpus de artículos académicos", dentro se podrá encontrar el documento *Próximos pasos*, conteniendo la bitácora del artículo y los próximos pasos. El material se ordena en las siguientes carpetas:

-   articulo: los artículos potenciales en construcción.
-   codigo: el codigo en R resultante del desarrollo. Dentro se disponen las carpetas:
    -   *Dimensions_API*, conteniendo el material vinculado al estudio sobre recuperación de información bibliográfica de la base de datos Dimensions utilizando la API provista por el fabricante
    -   *OpenAlex_API*, conteniendo el material vinculado al estudio sobre recuperación de información bibliográfica de la base de datos OpenAlex utilizando la API provista por el paquete OpenaAlexR. Dentro se ubica el documento *main_functions* con las funciones principales en R y las siguientes carpetas:
        -   *data*, contiene los datos utilizados por el estudio,
        -   *functions* son las funciones utilizadas en el estudio,
        -   *intermedio* contiene el código en proceso de construcción,
        -   *workspace* es el espacio de trabajo utilizado durante la construcción del código en general y las funciones relacionadas,
        -   *template_rmd* contiene los templates para los documentos RMarkdown.
-   en-revision: documentos en revisión.
-   estado_del_arte:documento presentando el estado del arte del tema en estudio.
-   metodologia: contiene la descripción de la metodología de abordaje del análisis híbrido (en primer término se realiza un abordaje de alto nivel y luego se mira en detalle el contenido del corpus)

*analisis-videos*: contiene el material del proyecto de desarrollo enfocado en el análisis de videos. El documento *Proximos pasos* describe los pasos en el proyecto. Dentro se encuentran las siguientes carpetas:

-   articulo: los artículos potenciales en construcción.
-   codigo: el codigo en R resultante del desarrollo.
-   en-revision: documentos en revisión.
-   estado_del_arte: documento presentando el estado del arte del tema en estudio.
-   metodologia: contiene la descripción de la metodología para realizar el abordaje de la extracción de patrones en videos usando CNN (redes neuronales convolucionales) y RNN (redes neuronales recurrentes)

### investigación

Contiene los documentos de los proyectos de investigación, agrupados en las siguientes carpetas:

-   *cianobacterias*: proyecto cuyo objetivo es la detección de cianobacterias a partir del análisis de imágenes.
-   *plagasymalezas*: proyecto cuyo objetivo es la detección de plagas y malezas a partir del análisis de imágenes.

### genericos

Contiene documentos genéricos del doctorado (lo que no sabemos bien donde ponerlo va acá). Dentro se ubican las siguientes carpetas:

-   *analisis de video con ia - 12092022 - v001-003*: contiene la última versión de un borrador de artículo sobre "análisis de video con IA".
-   *analisis de video con ia - 12092022 - v061*: contiene la última versión de un borrador de artículo sobre "análisis de video con IA".
-   *bibliometrix_Report*: ejemplo de un reporte obtenido utilizando la librería bibliometrix aplicada a un corpus de artículos académicos
-   *indice_de_BDs*: listado de base de datos indexadas abiertas.
-   *procesamiento de texto en R*: en el documento se proponen las líneas de trabajo en el procesamiento de texto enfocado en puntuar un texto según la ocurrencia de palabras clave.
-   *rsconnect*: ejemplo de publicación de un documento utilizando rconnect.
-   *templates*: templates rmarkdown.

### sitio_cschenone.github.io

Contiene los documentos html publicados en el sitio *cschenone.github.io* vinculado con el proyecto del doctorado y la carpeta *sitio_cschenone.github.io/docs*, donde se ubican los documentos publicados en sus versiones html. Esta carpeta funciona como respaldo, dado que la publicación se realiza copiando las versiones html de los documentos en la carpeta *docs* del proyecto *cschenone.github.io*.
