# Unpack the utilities
[badge, fa, html, url] = [utils.badge, utils.fa, utils.html, utils.url]


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
        [n_errors, n_tokens] = [0, 0]
        for path, obj of d
            n_errors += obj.n_errors
            n_tokens += obj.n_tokens
        docs_score = Math.floor(100 * (n_tokens - n_errors) / n_tokens)
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
    """, class_ = "pure-u-1-4 packages-badges")

    $ "\#package-#{pkg}"
        .html "#{item}#{badges}"


# Set the document loader
$ document
    .ready ->
        # List of packages to process
        packages = ["framework", "radio-simus", "grand-radiomorphing",
                    "tools"].sort()

        # Prepare the packages sections, in order to preserve their order
        content = []
        for pkg in packages
            content.push """
                <div id="package-#{pkg}"
                     class="packages-item shaded-box shake pure-g">
                </div>
            """
        $ "#content"
            .html(content.join "")

        # Fill the sections
        initialise = (pkg) -> on_statistics(pkg, format_summary)
        initialise pkg for pkg in packages
