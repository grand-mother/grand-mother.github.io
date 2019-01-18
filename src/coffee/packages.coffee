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
    score = Math.floor(100 * (lines - statistics.pep8.count) / lines)
    base_url = "https://github.com/grand-mother/#{pkg}"

    name = html.h3("#{html.a(base_url, pkg)}", class_="packages-name")
    authors = statistics.contributors
        .map (c) ->
            "#{html.a(c.html_url, c.login)} (#{c.contributions})"
        .join ", "

    item = html.div("""
        #{name}
        <p>#{statistics.description}</p>
        <p>#{fa.user}&nbsp;&nbsp;#{authors}</p>
    """, class_="packages-description pure-u-3-4")
    badges = html.div("""
        #{badge.style(pkg, score)}
        #{badge.coverage pkg}
        #{badge.build pkg}
        #{badge.version pkg}
    """, class_ = "packages-badges pure-u-1-4")

    $ ".packages-content"
    .append html.div("#{item}#{badges}", class_="packages-item pure-g")
    $ ".packages-content"
    .fadeIn "slow"

# Set the document loader
$ document
    .ready ->
        initialise = (pkg) -> on_statistics(pkg, format_summary)
        initialise pkg for pkg in ["framework", "framework-example",
            "grand-radiomorphing", "tools"]
