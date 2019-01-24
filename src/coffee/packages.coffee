# Unpack the utilities
[fa, html, url] = [utils.fa, utils.html, utils.url]


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
    build: (pkg) -> format_badge_html(
        "https://travis-ci.com/grand-mother/#{pkg}",
        "https://travis-ci.com/grand-mother/#{pkg}.svg?branch=master")
    coverage: (pkg) -> format_badge_html(
        "https://codecov.io/gh/grand-mother/#{pkg}",
        "https://codecov.io/gh/grand-mother/#{pkg}\
            /branch/master/graph/badge.svg")
    docs: (pkg, score) -> format_badge_html(
        "https://github.com/grand-mother/#{pkg}\
            /blob/master/.stats.json",
        "https://img.shields.io/badge/docs-#{score}%25-#{colourmap score}.svg")
    style: (pkg, score) -> format_badge_html(
        "https://github.com/grand-mother/#{pkg}\
            /blob/master/.stats.json",
        "https://img.shields.io/badge/pep8-#{score}%25-#{colourmap score}.svg")
    version: (pkg) -> format_badge_html(
        "https://pypi.org/project/grand-#{pkg}",
        "https://img.shields.io/pypi/v/g.svg")


# Get and use the statistics of a package
on_statistics = (pkg, action, branch="master") ->
    pkg_stats = null
    gh_stats = null
    gh_contrib = null
    $.when(
        $.getJSON(url.raw(pkg, branch, ".stats.json"), (s) -> pkg_stats = s),
        $.getJSON(url.api(pkg), (s) -> gh_stats = s),
        $.getJSON(url.api(pkg, "/contributors"), (s) -> gh_contrib = s))
    .then( ->
        stats = $.extend(gh_stats, pkg_stats)
        stats.contributors = gh_contrib
        action(pkg, stats))


# Format a summary of a package
format_summary = (pkg, statistics) ->
    lines = statistics.lines.code
    style_score = Math.floor(100 * (lines - statistics.pep8.count) / lines)
    d = statistics.doc.statistics
    if d?
        docs_score = Math.floor(100 * (d.tokens - d.n_errors) / d.tokens)
    else
        docs_score = 0
    base_url = "https://github.com/grand-mother/#{pkg}"
    docs_url = "docs.html?#{pkg}"

    gh_ref = html.a(base_url, fa.github, class_="packages-github")
    doc_ref = html.a(docs_url, pkg, class_="packages-name")
    name = html.h2("#{doc_ref}&nbsp;&nbsp;#{gh_ref}")
    authors = statistics.contributors
        .map (c) ->
            "#{html.a(c.html_url, c.login)} (#{c.contributions})"
        .join ", "

    item = html.div("""
        #{name}
        <p class="packages-description">#{statistics.description}</p>
        <p>#{fa.user}&nbsp;&nbsp;#{authors}</p>
    """, class_="pure-u-3-4")
    badges = html.div("""
        #{badge.style(pkg, style_score)}
        #{badge.coverage pkg}
        #{badge.build pkg}
        #{badge.docs(pkg, docs_score)}
        #{badge.version pkg}
    """, class_ = "packages-badges pure-u-1-4")

    $ "#content"
        .append html.div("#{item}#{badges}",
            class_="packages-item shaded-box shake pure-g")


# Set the document loader
$ document
    .ready ->
        initialise = (pkg) -> on_statistics(pkg, format_summary)
        initialise pkg for pkg in ["framework", "radio-simus",
            "grand-radiomorphing", "tools"].sort()
