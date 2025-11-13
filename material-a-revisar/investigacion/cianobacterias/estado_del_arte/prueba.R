install.packages("remotes")
remotes::install_github("ropensci/openalexR") ##Developer openalexR version
remotes::install_github("massimoaria/bibliometrix") ##Latest bibliometrix version

library(openalexR)
library(bibliometrix)

key_search1 = c("artificial intelligence OR machine learning OR deep learning")
key_search2 = c("images")
key_search3 = c("cyanobacteria OR cyanobacterium OR cyanotoxin")

key_search = c(key_search1, key_search2, key_search3)
  
works_search <- oa_fetch(
  entity = "works",
  title.search = key_search,
  abstract.search = key_search,
  fulltext.search = key_search,
  search = key_search,
  cited_by_count = ">50",
  from_publication_date = "2020-01-01",
  to_publication_date = "2021-12-31",
  options = list(sort = "cited_by_count:desc"),
  verbose = TRUE
  )

works_search <- oa_fetch(
  entity = "works",
  search = key_search1,
#  abstract.search = key_search,
#  fulltext.search = key_search,
#  search = key_search,
  cited_by_count = ">50",
  from_publication_date = "2020-01-01",
  to_publication_date = "2021-12-31",
  options = list(sort = "cited_by_count:desc"),
  verbose = TRUE
)

works_search |>
  show_works() |>
  knitr::kable()

View(works_search)

curl = https://api.openalex.org/works?search="elmo" AND "sesame street" NOT (cookie OR monster)

glimpse(works_search)

