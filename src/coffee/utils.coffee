# Noteworthy urls
url =
    # Formater for github raw files
    raw: (pkg, branch, path) ->
        "https://raw.githubusercontent.com/grand-mother/\
         #{pkg}/#{branch}/#{path}"
    # Formater for github API
    api: (pkg, path="") ->
        "https://api.github.com/repos/grand-mother/#{pkg}#{path}"
    # Formater for github blobs
    blob: (path, branch="master") ->
        "https://github.com/grand-mother/framework/blob/#{branch}/#{path}"

# HTML formatters
html =
    a: (href, content="", class_="") ->
        "<a href=\"#{href}\" class=\"#{class_}\">#{content}</a>"
    div: (content, class_="") ->
        "<div class=\"#{class_}\">#{content}</div>"
    h2: (content, class_="") ->
        "<h2 class=\"#{class_}\">#{content}</h2>"
    h3: (content, class_="") ->
        "<h3 class=\"#{class_}\">#{content}</h3>"
    img: (src, alt="") ->
        "<img src=\"#{src}\" alt=\"#{alt}\">"
    span: (content, class_="") ->
        "<span class=\"#{class_}\">#{content}</span>"
    tr: (content, class_="") ->
        "<tr class=\"#{class_}\">#{content}</tr>"
    td: (content, class_="") ->
        "<td class=\"#{class_}\">#{content}</td>"

# Font Awesome formatters
font_awesome = (class_) ->
    "<span class=\"#{class_}\" \\>"

fa =
    user: font_awesome "fas fa-user-edit"
    github: font_awesome "fab fa-github"

# Export utilities to a global object
@utils =
    fa: fa
    html: html
    url: url
