publication_md <- tmpl(
  ~`---
title: "{{title}}"
authors:
{{authors}}
date: "{{pubdate}}"
doi: "{{doi}}"

publishDate: "{{publishdate}}"

# Publication type.
# Legend: 0 = Uncategorized; 1 = Conference paper; 2 = Journal article;
# 3 = Preprint / Working Paper; 4 = Report; 5 = Book; 6 = Book section;
# 7 = Thesis; 8 = Patent
publication_types: ["{{pub_type}}"]

# Publication name and optional abbreviated publication name.
publication: In *{{sourcename}}*
publication_short: In *{{sourcename}}*

abstract: |
  {{abstract}}

tags:
{{tags}}

featured: true

links:
url_preprint: {{preprint_url}}
url_pdf: {{public_url}}
url_code: ''
url_dataset: ''
url_poster: ''
url_project: ''
url_slides: ''
url_source: ''
url_video: ''

# Featured image
# To use, add an image named 'featured.jpg/png' to your page's folder.
image:
  caption: ''
focal_point: ""
preview_only: false

# Associated Projects (optional).
#   Associate this publication with one or more of your projects.
#   Simply enter your project's folder or file name without extension.
#   E.g. 'internal-project' references 'content/project/internal-project/index.md'.
#   Otherwise, set 'projects: []'.
projects: []
#  - digitale-muendigkeit

# Slides (optional).
#   Associate this publication with Markdown slides.
#   Simply enter your slide deck's filename without extension.
#   E.g. 'slides: "example"' references 'content/slides/example/index.md'.
#   Otherwise, set 'slides: ""'.
slides: ""
---
`
)
