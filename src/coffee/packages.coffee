# Unpack the utilities
[badge, fa, html, packages, url] = [
    utils.badge, utils.fa, utils.html, utils.packages, utils.url]


# Get and use the statistics of a package
identity = (x) ->x
empty = -> $.Deferred().resolve().promise()

on_statistics = (pkg, action, branch="master") ->
    $.when(
        $.getJSON url.raw(pkg, branch, ".stats.json")
            .then(identity, empty)
        $.getJSON url.raw(pkg, branch, ".grand-pkg.json")
            .then(identity, empty)
        $.getJSON url.api(pkg)
            .then(identity)
        $.getJSON url.api(pkg, "/contributors")
            .then(identity)
    )
    .then(
        (old_stats, pkg_data, gh_stats, gh_contrib) ->
            if old_stats?
                pkg_stats = old_stats
                pkg_stats.package =
                    name: pkg.replace("-", "_")
                    "git-name": pkg
                    "dist-name": "grand-" + pkg
                    "description": "Add a brief description"
            else
                pkg_stats = pkg_data
                pkg = pkg_stats.package.name
            stats = $.extend(gh_stats, pkg_stats)
            stats.contributors = gh_contrib
            action(pkg, stats)
    )


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
    docs_url = "docs.html?#{pkg}"

    gh_ref = html.a(url.base(pkg), fa.github, class_="packages-github")
    doc_ref = html.a(docs_url, pkg, class_="packages-name")
    name = html.h2("#{doc_ref}&nbsp;&nbsp;#{gh_ref}")
    authors = statistics.contributors
        .map (c) ->
            "#{html.a(c.html_url, c.login)} (#{c.contributions})"
        .join ", "

    item = html.div("""
        #{name}
        <p class="packages-description">#{statistics.package.description}</p>
        <p>#{fa.user}&nbsp;&nbsp;#{authors}</p>
    """, class_="pure-u-3-4")

    git_name = packages[pkg]
    dist_name = statistics.package["dist-name"]
    badges = html.div("""
        #{badge.style(git_name, style_score)}
        #{badge.coverage git_name}
        #{badge.build git_name}
        #{badge.docs(pkg, docs_score)}
        #{badge.version dist_name}
    """, class_ = "pure-u-1-4 packages-badges")

    $ "\#package-#{pkg}"
        .html "#{item}#{badges}"


# Set the document loader
$ document
    .ready ->
        # Sort the packages by name
        pkgs = (k for k of packages).sort()

        # Prepare the packages sections, in order to preserve their order
        content = []
        for pkg in pkgs
            content.push """
                <div id="package-#{pkg}"
                     class="packages-item shaded-box shake pure-g">
                </div>
            """
        $ "#content"
            .html(content.join "")

        # Fill the sections
        initialise = (pkg) -> on_statistics(pkg, format_summary)
        initialise pkg for pkg in pkgs
