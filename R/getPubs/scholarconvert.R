## Script to help convert scholar profile to md folders
library(templates)
library(tidyverse)
library(magrittr)
library(scholar) # get_complete_authors/get_publication_data_extended etc. are now upstream on CRAN (>= 0.2.6)
library(rcrossref)
library(logging)

# Google Scholar sometimes serves pages with a declared ISO-8859-1 charset.
# scholar's internal `page %>% read_html()` calls ignore that declared charset
# and assume UTF-8, corrupting accented names (e.g. "Alagöz" -> "Alag�z").
# httr::content(x, as = "text") without a forced encoding respects the
# response's declared charset, so route xml2's response-reading through it.
xml2_ns <- asNamespace("xml2")
patched_read_html_response <- function(x, encoding = "", ..., options = c("RECOVER", "NOERROR", "NOBLANKS")) {
  xml2::read_html(httr::content(x, as = "text"), encoding = encoding, ..., options = options)
}
environment(patched_read_html_response) <- xml2_ns
unlockBinding("read_html.response", xml2_ns)
assignInNamespace("read_html.response", patched_read_html_response, ns = "xml2")
lockBinding("read_html.response", xml2_ns)



# After running this script you need to copy the folders into the publication
# folder and add the pdfs to the static pdf route using the citekey as the pdf
# name.

# Todo:
# Full source name from details page
# Link to scholar page
#

# Setup variables ----
# Set scholar id
scholar_id <- "K6EVDoYAAAAJ"
publications <- scholar::get_publications(scholar_id)

pubs <- publications #%>% filter(year > 2021)

# generated publication_md template function to the global environmnent
source("R/getPubs/template.R")


# Test if this works in the long run
# Does not
# Manual export of all bibtex from google scholar
#all_bibtexs <- "https://scholar.googleusercontent.com/citations?view_op=export_citations&user=K6EVDoYAAAAJ&citsig=AM0yFCkAAAAAZcCq47RZIcw3RR5-WSaRETxeIok&hl=de"
#all_bibsources <- readLines(all_bibtexs)

# read source data ----
# read source bib for generating cite keys
# generate an accurate file with all bibtex source using scholars export here.
bibsource <- here::here("R", "getPubs", "2026-07-07-pubs.bib")
my_bibsource <- readLines(bibsource)


source("R/getPubs/convert.R")
cross_ref_data <- get_cr_list("André Calero Valdez", limit = nrow(pubs) * 2)


missing_pdf <- c()
# Loop ----
for(pub_index in 1:nrow(pubs)) {

  #pub_index <- 4
  logging::loginfo(paste("**********************", pub_index, "**********************"))
  pub <- pubs[pub_index,]

  pub <- convert(pub, scholar_id, cross_ref_data)



  # generate citekey
  citekey <- gen_citekey(pub)

  # markdown author list
  auths <-
    pub$authors_full %>%
    str_split(", ") %>%
    extract2(1) %>% paste("-", ., collapse = "\n") %>%
    str_replace("André Calero Valdez", "admin") %>%
    str_replace("Andre Calero Valdez", "admin") %>%
    str_replace("Andre Calero Valdez", "admin")

  my_preprint_url <- paste0("http://papers.calerovaldez.com/",citekey,".pdf")

  # check if pdf exists
  if(!RCurl::url.exists(my_preprint_url)){
    missing_pdf <- c(missing_pdf, citekey)
    logging::logwarn(paste("Missing pdf for", my_preprint_url))
  }

  # fill in template
  res <- tmplUpdate(
    publication_md,
    title = pub$title,
    authors = auths,
    pub_type = pub$pub_type,
    sourcename = pub$source,
    abstract = pub$abstract,
    tags = "- human-computer interaction",
    doi = pub$doi, # fix
    pubdate = lubridate::format_ISO8601(lubridate::as_datetime(pub$date)),
    publishdate = lubridate::format_ISO8601(lubridate::now()),
    preprint_url = my_preprint_url,
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

  logging::loginfo(paste("Looking for citekey", citekey, "in bibsource"))
  start_line <- str_which(my_bibsource, citekey)
  last_line <- start_line
  repeat{
    last_line <- last_line + 1
    if(str_length(my_bibsource[last_line])==0){
      break
    }
    if(last_line == length(my_bibsource)){
      break
    }
  }
  logging::loginfo(paste("Found citekey", citekey, "in bibsource", "from", start_line, "to", last_line))
  logging::loginfo(paste(my_bibsource[start_line:last_line]))

  fileConn<-file(paste0(path, "/cite.bib"))
  writeLines(my_bibsource[start_line:last_line], fileConn)
  close(fileConn)
  Sys.sleep(4)
}

logging::loginfo("Missing pdfs:")
logging::loginfo(missing_pdf)




