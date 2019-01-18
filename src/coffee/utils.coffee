# Noteworthy urls
url =
    # Formatter for github raw files
    raw: (pkg, branch, path) ->
        "https://raw.githubusercontent.com/grand-mother/\
         #{pkg}/#{branch}/#{path}"
    # Formatter for github API
    api: (pkg, path="") ->
        "https://api.github.com/repos/grand-mother/#{pkg}#{path}"

# HTML formatters
html =
    a: (href, content="") ->
        "<a href=\"#{href}\">#{content}</a>"
    div: (content, class_="") ->
        "<div class=\"#{class_}\">#{content}</div>"
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

# Export utilities to a global object
@utils =
    fa: fa
    html: html
    url: url
