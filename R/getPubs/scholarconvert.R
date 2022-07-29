## Script to help convert scholar profile to md folders
library(templates)
library(tidyverse)
library(magrittr)
library(scholar)
library(rcrossref)


# Todo:
# detect Journal or Conference
# Full source name from details page
# Link to scholar page


#prof <- scholar::get_profile("K6EVDoYAAAAJ")
publications <- scholar::get_publications("K6EVDoYAAAAJ")

pubs <- publications %>% filter(year > 2019)

source("R/getPubs/template.R")

pubs$title

# read source bib for generating cite keys
bibsource <- here::here("R", "getPubs", "source.bib")
my_bibsource <- readLines(bibsource)

for(pub_index in 1:nrow(pubs)) {
  #pub_index <- 26
  pub <- pubs[pub_index,]
  cat(paste0("Generating: ",pub$title,"\n"))

  pub$authors_full <- names(scholar::get_complete_authors(id= "K6EVDoYAAAAJ", pubid = pub$pubid))
  pub$abstract <- paste(scholar::get_publication_abstract(id= "K6EVDoYAAAAJ", pub_id = pub$pubid), collapse = " ")

  # Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
  # 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
  # 7 = Thesis; 8 = Patent
  pub_type <- 2
  fullmeta <- scholar::get_publication_data_extended(id= "K6EVDoYAAAAJ", pub_id = pub$pubid)
  pub$source <- pub$journal
  pub$pub_type <- 2
  if(!is.null(fullmeta$Source)){
    pub$source <- fullmeta$Source
    pub$pub_type <- 2
  }
  if(!is.null(fullmeta$Conference)){
    pub$source <- fullmeta$Conference
    pub$pub_type <- 1
  }
  if(!is.null(fullmeta$Journal)){
    pub$source <- fullmeta$Journal
    pub$pub_type <- 2
  }
  if(!is.null(fullmeta$Book)){
    pub$source <- fullmeta$Book
    pub$pub_type <- 6
  }

  cat(paste(names(fullmeta),"\n"))
  pub$pub_type
  pub$date <- fullmeta$`Publication date`
  if(str_length(pub$date)<5){
    pub$date <- paste0(pub$date, "/01/01")
  }
  if(str_length(pub$date)<8){
    pub$date <- paste0(pub$date, "/01")
  }


  #todo get full source name
  # scholar::get
  pub$url <- scholar::get_publication_url(id= "K6EVDoYAAAAJ", pub_id = pub$pubid)

  # fix
  #rcrossref::cr_works_(query = pub$title, limit = 1)
  pub$doi <- ""

  #generate google citekey
  stopwords <- c("a", "the", "on")

  lastname <- pub$author %>%
    str_split(", ") %>% extract2(1) %>% extract(1) %>% #get first author
    str_split(" ") %>% extract2(1) %>% extract(2) %>% #get last name
    str_to_lower() %>%
    str_replace_all("ö", "o") %>%
    str_replace_all("ä", "a") %>%
    str_replace_all("ü", "u")

  title_words <- pub$title %>%
    str_split(" ") %>% extract2(1) %>% #get all words
    str_to_lower() %>%
    str_replace_all("[[:punct:]]", "")

  title_word <- ""
  # iterate over words
  for (i in 1:length(title_words)) {
    title_word <- title_words[i]
    if(title_word %in% stopwords) { # ignore stop words
      next
    }
    break
  }
  # calero2022amazing
  citekey <- paste0(lastname, pub$year, title_word)
  cat(paste0(" Citekey: ",citekey,"\n"))

  # markdown author list
  auths <- pub$authors_full %>% str_split(", ") %>% extract2(1) %>% paste("-", ., collapse = "\n") %>%
    str_replace("André Calero Valdez", "admin") %>%
    str_replace("Andre Calero Valdez", "admin") %>%
    str_replace("Andre Calero Valdez", "admin")



  # fill in template
  res <- tmplUpdate(
    publication_md,
    title = pub$title,
    authors = auths,
    pub_type = pub_type,
    sourcename = pub$source,
    abstract = pub$abstract,
    tags = "- human-computer interaction",
    doi = pub$doi, # fix
    pubdate = lubridate::format_ISO8601(lubridate::as_datetime(pub$date)),
    publishdate = lubridate::format_ISO8601(lubridate::now()),
    preprint_url = paste0("http://papers.calerovaldez.com/",citekey,".pdf"),
    public_url = pub$url
  )

  # generate filepath
  path <- here::here("R", "getPubs", "output", citekey)
  if(!dir.exists(path)) {
    dir.create(path)
  }

  fileConn<-file(paste0(path, "/index", ".md"), encoding = "UTF-8")
  writeLines(res, fileConn)
  close(fileConn)

  # generate cite.bib


  start_line <- str_which(my_bibsource, citekey)
  last_line <- start_line
  repeat{
    last_line <- last_line + 1
    if(my_bibsource[last_line]==""){
      break
    }
    if(last_line == length(my_bibsource)){
      break
    }
  }

  fileConn<-file(paste0(path, "/cite.bib"))
  writeLines(my_bibsource[start_line:last_line], fileConn)
  close(fileConn)
  Sys.sleep(5)
}






