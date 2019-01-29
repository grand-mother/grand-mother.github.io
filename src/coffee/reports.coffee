# Unpack and configure the utilities
[badge, html, url] = [utils.badge, utils.html, utils.url]


# Generate a refrence to the code
docref = (path, line) ->
    if line?
        href = "#{url.blob(path)}\#L#{line}"
        tag = line
    else
        href = url.blob(path)
        tag = path
    "<a href=\"#{href}\" class=\"reports-line\">#{tag}</a>"


# Generate a documentation badge
docbadge = (pkg, n_tokens, n_errors, path) ->
        score = Math.floor(100 * (n_tokens - n_errors) / n_tokens)
        badge.docs pkg, score, path


# Generate a link to the main docs report
docmain = (pkg) ->
    html.a("reports.html?#{pkg}/docs", "documentation status")


# Format docs errors
format_docs_summary = (pkg, category, stats) ->

    # Compute the global score
    [n_tokens, n_errors] = [0, 0]
    for path, obj of stats
        n_tokens += obj.n_tokens
        n_errors += obj.n_errors

    if n_errors
        brief = "Found #{n_errors} errors out of #{n_tokens} tokens"
    else
        # If no errors, then redirect to the documentation page
        window.location.replace "docs.html?#{pkg}"
        return

    content = ["""
    <h1>
        #{docbadge(pkg, n_tokens, n_errors)}
        #{pkg} :: #{docmain pkg}
    </h1>
    <p class="reports-brief">
    #{brief}
    </p>
    """]

    for path, data of stats
        if !data.n_errors then continue

        if data.n_errors
            brief = """
                Found #{data.n_errors} errors out of #{data.n_tokens} tokens
                """
        else
            brief = "Found #{data.n_tokens} documentation tokens"

        content.push html.div("""
            <h2>
                #{docbadge(pkg, data.n_tokens, data.n_errors, path)}
                #{docref(path)}
            </h2>
            <p class="reports-brief reports-brief-smaller">#{brief}</p>
        """, class_="shaded-box shake reports-entity")

    $ "#content"
        .html(html.div(content.join(""), class_="reports-item"))


format_docs_entity = (pkg, category, args, stats) ->
    # Unpack the data
    path = args.join "/"
    data = stats[path]

    if data.n_errors
        brief = "Found #{data.n_errors} errors out of #{data.n_tokens} tokens"
    else
        brief = "Found #{data.n_tokens} documentation tokens"

    content = ["""
    <h2>
        #{docbadge(pkg, data.n_tokens, data.n_errors, path)}
        #{path} :: #{docmain pkg}
    </h2>
    <p class="reports-brief">
    #{brief}
    </p>
    """]

    for tag, token of data.tokens
        tag = html.span(tag, class_="reports-docs-tag")
        [line, errors] = token
        errors = [html.li(e) for e in errors]
        content.push html.div("""
            <h3>In #{tag} at line #{docref(path, line)}:</h3>
            <ul>#{errors}</ul>
        """, class_="reports-docs-token shaded-box shake")

    $ "#content"
        .html(html.div(content.join(""), class_="reports-item"))


# Dispatch doc errors formating
format_docs_report = (pkg, category, args, stats) ->
    # Unpack the data
    stats = stats.doc.statistics

    # Dispatch
    if args.length
        format_docs_entity(pkg, category, args, stats)
    else
        format_docs_summary(pkg, category, stats)


# Format style errors
format_style_report = (pkg, category, args, stats) ->
    undefined


# Dispatch to the report formater
format_report = (pkg, category, args, stats) ->
        # Ammping of report formaters
        format =
            docs: format_docs_report
            style: format_style_report

        f = format[category]
        if f then f(pkg, category, args, stats)


# Parse the url parameters
parse_url = () ->
    [baseurl, tag] = window.location.href.split("?", 2)
    if !tag?
        return [undefined]
    tag.split("/")


# Get and report the statistics of a package
on_statistics = (pkg, category, args, action, branch="master") ->
    $.getJSON url.raw(pkg, branch, ".stats.json")
        .done (stats) ->
            action(pkg, category, args, stats)
        .fail () ->
            console.log "failed to load docs for #{pkg}"


# Set the document loader
$ document
    .ready ->
        [pkg, category, args...] = do parse_url
        if pkg?
            on_statistics(pkg, category, args, format_report)
