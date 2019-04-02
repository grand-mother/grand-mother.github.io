# Mapping of maanaged packages (name: git-name)
packages =
    grand_libs: "libs"
    grand_pkg: "pkg"
    grand_tools: "tools"
    grand_radiomorphing: "grand-radiomorphing"
    radio_simus: "radio-simus"


# Noteworthy urls
url =
    # Formater for github raw files
    raw: (pkg, branch, path) ->
        "https://raw.githubusercontent.com/grand-mother/\
         #{packages[pkg]}/#{branch}/#{path}"
    # Formater for github API
    api: (pkg, path="") ->
        "https://api.github.com/repos/grand-mother/#{packages[pkg]}#{path}"
    # Formater for github project page
    base: (pkg) ->
        "https://github.com/grand-mother/#{packages[pkg]}"
    # Formater for github blobs
    blob: (pkg, path, branch="master") ->
        pkg = pkg.split(".", 1)[0]
        "https://github.com/grand-mother/#{packages[pkg]}/blob/#{branch}/#{path}"


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
    li: (content, class_="") ->
        "<li class=\"#{class_}\">#{content}</li>"
    span: (content, class_="") ->
        "<span class=\"#{class_}\">#{content}</span>"
    tr: (content, class_="") ->
        "<tr class=\"#{class_}\">#{content}</tr>"
    td: (content, class_="") ->
        "<td class=\"#{class_}\">#{content}</td>"
    ul: (content, class_="") ->
        "<ul class=\"#{class_}\">#{content}</ul>"


# Font Awesome formatters
font_awesome = (class_) ->
    "<span class=\"#{class_}\" \\>"


fa =
    user: font_awesome "fas fa-user-edit"
    github: font_awesome "fab fa-github"


# Colour map for shields.io badges
colourmap = (score) ->
    colours = ["red", "orange", "yellow", "yellowgreen", "green",
               "brightgreen"]
    n = colours.length
    index = Math.floor(n * score * 0.01)
    index = Math.min(n - 1, index)
    index = Math.max(0, index)
    colours[index]


# Badges formatters
format_badge_html = (href, src) ->
    html.a(href, html.img src)


badge =
    build: (pkg) ->
        format_badge_html(
            "https://travis-ci.com/grand-mother/#{pkg}",
            "https://travis-ci.com/grand-mother/#{pkg}.svg?branch=master")
    coverage: (pkg) ->
        format_badge_html(
            "https://codecov.io/gh/grand-mother/#{pkg}",
            "https://codecov.io/gh/grand-mother/#{pkg}\
                /branch/master/graph/badge.svg")
    docs: (pkg, score, path) ->
        format_badge_html(
            """reports.html?#{pkg}/docs#{if path? then "/" + path else ""}""",
            "https://img.shields.io/badge/docs-#{score}%25-\
                #{colourmap score}.svg")
    style: (pkg, score) ->
        format_badge_html(
            "https://github.com/grand-mother/#{pkg}\
                /blob/master/.grand-pkg.json",
            "https://img.shields.io/badge/pep8-#{score}%25-\
                #{colourmap score}.svg")
    version: (pkg) ->
        format_badge_html(
            "https://pypi.org/project/#{pkg}",
            "https://img.shields.io/pypi/v/#{pkg}.svg")


# Export utilities to a global object
@utils =
    badge: badge
    fa: fa
    html: html
    packages: packages
    url: url
