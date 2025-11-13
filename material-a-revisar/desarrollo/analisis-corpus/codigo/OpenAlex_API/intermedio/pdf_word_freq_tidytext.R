if(!require('tidytext')) {
  install.packages('tidytext')
  library('tidytext')
}

library(dplyr)
library(janeaustenr)




d <- tibble(txt = prideprejudice)
d %>%
  unnest_ngrams(word, txt, n = 2)
d %>%
  unnest_skip_ngrams(word, txt, n = 3, k = 3)

d %>%
  unnest_characters(word, txt)

d %>%
  unnest_character_shingles(word, txt, n = 3)

d %>%
  unnest_ptb(word, txt)

d %>%
  unnest_tokens(word, txt)
d %>%
  unnest_tokens(sentence, txt, token = "sentences")

d %>%
  unnest_tokens(ngram, txt, token = "ngrams", n = 3) %>%
  head(20)

d %>%
  unnest_tokens(chapter, txt, token = "regex", pattern = "Chapter [\\\\d]")
d %>%
  unnest_tokens(shingle, txt, token = "character_shingles", n = 4)

d %>%
  unnest_tokens(word, txt, token = stringr::str_split, pattern = " ")
# tokenize HTML
h <- tibble(row = 1:2,
            text = c("<h1>Text <b>is</b>", "<a href='example.com'>here</a>"))
h %>%
  unnest_tokens(word, text, format = "html")

