# Unpack the utilities
[fa, html, url] = [utils.fa, utils.html, utils.url]

# Get and use the docs of a package
on_docs = (pkg, subpath, action, branch="master") ->
    $.getJSON url.raw(pkg, branch, ".stats.json")
        .done (stats) ->
            action(pkg, subpath, stats.doc)
        .fail () ->
            console.log "failed to load docs for #{pkg}"

format =
    class: (name, file, line, text) -> html.div("""
        <h3>#{name}</h3>
        <p>#{text}</p>
        <p>Defined at line <a>#{line}</a> in <a>#{file}</a></p>
        """, class_="docs-item")
    function: (name, file, line, text) -> html.div("""
        <h3>#{name}</h3>
        <p>#{text}</p>
        <p>Defined at line <a>#{line}</a> in <a>#{file}</a></p>
        """, class_="docs-item")
    module: (pkg, name, file, line, text, content) -> html.div("""
        <h3><a href=\"docs.html?#{pkg}.#{name}\">#{pkg}.#{name}</a></h3>
        <p>#{text}</p>
        """, class_="docs-item")

# Format the docs for a package
format_docs = (pkg, subpath, docs) ->
    while subpath
        [base, subpath] = subpath.split(".", 2)
        docs = docs.modules[base][3]
        pkg = "#{pkg}.#{base}"
    modules = (format.module(pkg, k, v...) for k, v of docs.modules).join ""
    functions = (format.function(k, v...) for k, v of docs.functions).join ""
    classes = (format.class(k, v...) for k, v of docs.classes).join ""

    content = """
    <h1>#{pkg}</h1>
    <h2>Sub-modules</h2>
    #{modules}
    <h2>Functions</h2>
    #{functions}
    <h2>Classes</h2>
    #{classes}
    """
    $ ".docs-content"
        .html(content)
    $ ".docs-content"
        .fadeIn "slow"

# Parse the url parameters
parse_url = () ->
    [baseurl, tag] = window.location.href.split("?", 2)
    if not tag
        return
    tag.split(".", 2)

# Set the document loader
$ document
    .ready ->
        [pkg, subpath] = do parse_url
        on_docs(pkg, subpath, format_docs)
