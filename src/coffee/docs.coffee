# Unpack and configure the utilities
[fa, html, url] = [utils.fa, utils.html, utils.url]


markdown = new showdown.Converter(
    extensions : [
        ->
            ext =
                type: "lang"
                regex: /(grand-mother[/]\w+)#(\d+)/g
                replace: "[#$2](https://github.com/$1/issues/$2)"
            [ext]
    ]
)
markdown.setFlavor "github"
markdown.setOption("simpleLineBreaks", false)

# Get the brief description from a docstring
brief = (s) ->
    return "" if !s?
    markdown.makeHtml(s.split(/\r?\n *\r?\n/, 1)[0])


# Process a docstring by splitting the brief and detailed parts
process_description = (s) ->
    return ["", ""] if !s?
    [brief, detail...] = s.split(/\r?\n *\r?\n/)
    detail = detail.join "\n"
    (markdown.makeHtml(v) for v in [brief, detail])


# Shortcuts for doc references
docref =
    class: (pkg, name) ->
        "<a href=\"docs.html?#{pkg}/classes/#{name}\">#{name}</a>"
    classes: (pkg, tag="Classes") ->
        html.span(
            html.a("docs.html?#{pkg}/classes", tag),
            class_="docs-category")
    definition: (pkg, name) ->
        "<a href=\"docs.html?#{pkg}/definitions/#{name}\">#{name}</a>"
    definitions: (pkg, tag="Definitions") ->
        html.span(
            html.a("docs.html?#{pkg}/definitions", tag),
            class_="docs-category")
    attribute: (pkg, class_, name) -> """
        <a href=\"docs.html?#{pkg}/classes/#{class_}/attributes/#{name}\">
            #{name}
        </a>
        """
    attributes: (pkg, class_, tag="Attributes") ->
        html.span(
            html.a("docs.html?#{pkg}/classes/#{class_}/attributes", tag),
            class_="docs-category")
    function: (pkg, name) ->
        "<a href=\"docs.html?#{pkg}/functions/#{name}\">#{name}</a>"
    functions: (pkg, tag="Functions") ->
        html.span(
            html.a("docs.html?#{pkg}/functions", tag),
            class_="docs-category")
    method: (pkg, class_, name) ->"""
        <a href=\"docs.html?#{pkg}/classes/#{class_}/methods/#{name}\">
            #{name}
        </a>
        """
    methods: (pkg, class_, tag="Methods") ->
        html.span(
            html.a("docs.html?#{pkg}/classes/#{class_}/methods", tag),
            class_="docs-category")
    module: (pkg, name) ->
        "<a href=\"docs.html?#{pkg}.#{name}\">#{name}</a>"
    modules: (pkg) ->
        html.span(
            html.a("docs.html?#{pkg}/modules", "Sub-modules"),
            class_="docs-category")


# Format the main page of a package or sub-module
format_main = (pkg, docs, navpkg) ->
    module_names = (k for k of docs.modules).sort()
    modules = (docref.module(pkg, k) for k in module_names)
        .join ", "

    functions_names = (k for k of docs.functions).sort()
    functions = (docref.function(pkg, k) for k in functions_names)
        .join ", "

    classes_names = (k for k of docs.classes).sort()
    classes = (docref.class(pkg, k) for k in classes_names)
        .join ", "

    definitions_names = (k for k of docs.definitions).sort()
    definitions = (docref.definition(pkg, k) for k in definitions_names)
        .join ", "

    [brief, detail] = process_description(docs.doc)
    content = ["""
    <h1>#{navpkg.join "."}</h1>
    <p class="docs-brief">#{brief}<p>
    """]

    if modules.length
        content.push html.div("""
        <h2 class=\"docs-category\">#{docref.modules pkg}</h2>
        #{modules}
        """, class_="shaded-box shake")

    if functions.length
        content.push html.div("""
        <h2 class=\"docs-category\">#{docref.functions pkg}</h2>
        #{functions}
        """, class_="shaded-box shake")

    if classes.length
        content.push html.div("""
        <h2 class=\"docs-category\">#{docref.classes pkg}</h2>
        #{classes}
        """, class_="shaded-box shake")

    if definitions.length
        content.push html.div("""
        <h2 class=\"docs-category\">#{docref.definitions pkg}</h2>
        #{definitions}
        """, class_="shaded-box shake")

    if detail.length
        content.push html.div(detail)

    html.div(content.join(""), class_="docs-item")


# Format the sub-modules summary page
format_modules = (pkg, docs, navpkg) ->
    # Formater for a brief function entry
    format_module = (name, path, text) ->
        html.div("""
            <h3>#{docref.module(pkg, name)}</h3>
            <p class="docs-brief docs-brief-smaller">#{brief(text)}</p>
            <p>Defined in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")

    # Format the main content
    modules_names = (k for k of docs.modules).sort()
    modules = (format_module(k, docs.modules[k].path, docs.modules[k].doc)     \
                 for k in modules_names).join ""

    html.div("""
        <h1>#{navpkg.join "."} :: #{docref.modules(pkg)}</h1>
        #{modules}
    """, class_="docs-item")


# Decorate a function or a method with its meta data
decorate_function = (meta) ->
    content = []

    # Process the parameters
    if !$.isEmptyObject meta.parameters
        s = ["<h3>Parameters</h3>"]
        s.push "<table>"
        for name, value of meta.parameters
            value = ["?", "?"] if value == null
            [types, text] = value
            s.push """
            <tr>
                <td><strong>#{name}</strong></td>
                <td><em>#{types}</em></td>
                <td>#{text}</td>
            </tr>
            """
        s.push "</table>"
        content.push html.div(s.join(""), class_="shaded-box shake")

    # Process any returns or yields
    for category in ["returns", "yields", "raises"]
        data = meta[category]
        if data? and data.length
            title = category[0].toUpperCase() + category[1..]
            s = ["<h3>#{title}</h3>"]
            s.push "<table>"
            for [type_, text, name] in data
                s.push """
                <tr>
                    <td><strong>#{type_}</strong></td>
                    <td>#{text}</td>
                </tr>
                """
            s.push "</table>"
            content.push html.div(s.join(""), class_="shaded-box shake")

    content.join ""


# Format the functions summary page
format_functions = (pkg, docs, navpkg) ->
    # Formater for a brief function entry
    format_function = (name, path, line, text, meta, altpath) ->
        path = altpath if altpath?
        html.div("""
            <h3>#{docref.function(pkg, name)} (#{meta.prototype})</h3>
            <p class="docs-brief docs-brief-smaller">#{brief(text)}</p>
            <p>Defined at line
                <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
                in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")

    # Format the main content
    functions_names = (k for k of docs.functions).sort()
    functions = (format_function(k, docs.path, docs.functions[k]...)           \
                 for k in functions_names).join ""

    html.div("""
        <h1>#{navpkg.join "."} :: #{docref.functions(pkg)}</h1>
        #{functions}
    """, class_="docs-item")


# Format a function detailed page
format_function = (pkg, name, docs, navpkg) ->
    [line, text, meta, path] = docs.functions[name]
    path = docs.path if !path?

    tl = docref.functions(pkg, tag="Function")
    [brief, detail] = process_description text
    html.div("""
        <h2>#{tl} #{navpkg.join "."}.#{docref.function(pkg, name)}
            (#{meta.prototype})</h2>
        <p class=\"docs-brief\">#{brief}</p>
        <p>Defined at line
            <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
            in #{html.a(url.blob(pkg, path), path)}.<p>
        #{decorate_function meta}
        <div class="docs-detail">#{detail}</div>
    """, class_="docs-item")


# Format the classes summary page
format_classes = (pkg, docs, navpkg) ->
    # Formater for a brief class entry
    format_class = (name, path, line, text, data, altpath) ->
        path = altpath if altpath?
        html.div("""
            <h3>#{docref.class(pkg, name)}</h3>
            <p class="docs-brief docs-brief-smaller">#{brief text}</p>
            <p>Defined at line
                <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
                in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")

    # Format the main content
    classes_names = (k for k of docs.classes).sort()
    classes = (format_class(k, docs.path, docs.classes[k]...)                  \
                 for k in classes_names).join ""

    html.div("""
        <h1>#{navpkg.join "."} :: #{docref.classes(pkg)}</h1>
        #{classes}
    """, class_="docs-item")


# Format a class detailed page
format_class = (pkg, name, docs, navpkg) ->
    [line, text, data, path] = docs.classes[name]
    path = docs.path if !path?

    bases = data["bases"]
    if bases.length
        bases = bases.join ", "
        bases = " (#{bases})"
    else
        bases = ""

    methods_names = (k for k of data.methods).sort()
    methods = (docref.method(pkg, name, k) for k in methods_names)
        .join ", "

    attributes_names = (k for k of data.attributes).sort()
    attributes = (docref.attribute(pkg, name, k) for k in attributes_names)
        .join ", "

    [brief, detail] = process_description text
    tl = docref.classes(pkg, tag="Class")
    content = ["""
        <h2>#{tl} #{navpkg.join "."}.#{docref.class(pkg, name)}#{bases}</h2>
        <p class="docs-brief">#{brief}</p>
        <p>Defined at line
            <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
            in #{html.a(url.blob(pkg, path), path)}.<p>
    """]

    if attributes.length
        content.push html.div("""
        <h2>#{docref.attributes(pkg, name)}</h2>
        #{attributes}
        """, class_="shaded-box shake")

    if methods.length
        content.push html.div("""
        <h2>#{docref.methods(pkg, name)}</h2>
        #{methods}
        """, class_="shaded-box shake")

    if detail.length
        content.push html.div(detail, class_="docs-detail")

    html.div(content.join(""), class_="docs-item")


# Format the methods summary page
format_methods = (pkg, class_name, docs, navpkg) ->
    # Formater for a brief method entry
    format_method = (name, path, line, text, meta, altpath) ->
        path = altpath if altpath?
        html.div("""
            <h3>#{docref.method(pkg, class_name, name)}
                (#{meta.prototype})
            </h3>
            <p>#{brief(text)}</p>
            <p>Defined at line
                <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
                in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")

    # Format the main content
    data = docs.classes[class_name][2]
    methods_names = (k for k of data.methods).sort()
    methods = (format_method(k, docs.path, data.methods[k]...)                 \
                 for k in methods_names).join ""

    html.div("""
        <h2>#{navpkg.join "."}.#{docref.class(pkg, class_name)} ::
            #{docref.methods(pkg, class_name)}
        </h2>
        #{methods}
    """, class_="docs-item")


# Format a method detailed page
format_method = (pkg, class_name, name, docs, navpkg) ->
    data = docs.classes[class_name][2]
    [line, text, meta, path] = data.methods[name]
    path = docs.path if !path?

    tl = docref.methods(pkg, class_name, tag="Method")
    cl = docref.class(pkg, class_name)
    mt = docref.method(pkg, class_name, name)
    [brief, detail] = process_description text
    html.div("""
        <h2>#{tl} #{navpkg.join "."}.#{cl}.#{mt} (#{meta.prototype})</h2>
        <p>#{brief}</p>
        <p>Defined at line
            <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
            in #{html.a(url.blob(pkg, path), path)}.<p>
        #{decorate_function meta}
        <div class="docs-detail">#{detail}</div>
    """, class_="docs-item")


# Format the attributes summary page
format_attributes = (pkg, class_name, docs, navpkg) ->
    # Formater for a brief attribute entry
    format_attribute = (name, path, line, text, unused, altpath) ->
        path = altpath if altpath?
        html.div("""
            <h3>#{docref.attribute(pkg, class_name, name)}</h3>
            <p class="docs-brief docs-brief-smaller">#{brief(text)}</p>
            <p>Defined at line
                <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
                in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")

    # Format the main content
    data = docs.classes[class_name][2]
    attributes_names = (k for k of data.attributes).sort()
    attributes = (format_attribute(k, docs.path, data.attributes[k]...)        \
                 for k in attributes_names).join ""

    html.div("""
        <h2>#{navpkg.join "."}.#{docref.class(pkg, class_name)} ::
            #{docref.attributes(pkg, class_name)}
        </h2>
        #{attributes}
    """, class_="docs-item")


# Format an attributes detailed page
format_attribute = (pkg, class_name, name, docs, navpkg) ->
    data = docs.classes[class_name][2]
    [line, text, unused, path] = data.attributes[name]
    path = docs.path if !path?

    [brief, detail] = process_description text
    tl = docref.attributes(pkg, class_name, tag="Attribute")
    cl = docref.class(pkg, class_name)
    mt = docref.attribute(pkg, class_name, name)
    content = ["""
        <h2>#{tl} #{navpkg.join "."}.#{cl}.#{mt}</h2>
        <p class="docs-brief">#{brief}</p>
        <p>Defined at line
            <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
            in #{html.a(url.blob(pkg, path), path)}.<p>
    """]

    if detail
        content.push html.div(detail, class_"docs-detail")

    html.div(content.join(""), class_="docs-item")


# Format the definitions page
format_definitions = (pkg, docs, navpkg) ->
    # Formater for a definition entry
    format_definition = (name, path, line, text, data, altpath) ->
        path = altpath if altpath?
        html.div("""
            <h3>#{docref.definition(pkg, name)}</h3>
            <p class="docs-brief docs-brief-smaller">#{brief(text)}</p>
            <p>Defined at line
                <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
                in #{html.a(url.blob(pkg, path), path)}.<p>
            """, class_="shaded-box shake")
 
    # Format the main content
    definitions_names = (k for k of docs.definitions).sort()
    definitions = (format_definition(k, docs.path, docs.definitions[k]...)     \
                 for k in definitions_names).join ""

    html.div("""
        <h1>#{navpkg.join "."} :: #{docref.definitions(pkg)}</h1>
        #{definitions}
    """, class_="docs-item")


# Format a definition detailed page
format_definition = (pkg, name, docs, navpkg) ->
    [line, text, data, path] = docs.definitions[name]
    path = docs.path if !path?

    [brief, detail] = process_description text
    tl = docref.definitions(pkg, tag="Definition")
    content = ["""
        <h2>#{tl} #{navpkg.join "."}.#{docref.definition(pkg, name)}</h2>
        <p class="docs-brief">#{brief}</p>
        <p>Defined at line
            <a href="#{url.blob(pkg, path)}\#L#{line}">#{line}</a>
            in #{html.a(url.blob(pkg, path), path)}.<p>
    """]

    if detail
        content.push html.div(detail, class_="docs-detail")

    html.div(content.join(""), class_="docs-item")


# Format the docs for a package
format_docs = (pkg, pkgpath, docpath, docs) ->
    # Unpack the data
    navpkg = [html.a("docs.html?#{pkg}", pkg)]
    while pkgpath
        [base, pkgpath] = pkgpath.split(".", 2)
        docs = docs.modules[base]
        pkg = "#{pkg}.#{base}"
        navpkg.push html.a("docs.html?#{pkg}", base)

    # Format the docs content depending on the encoded request
    if docpath.length
        if docpath[0] == "modules"
            content = format_modules(pkg, docs, navpkg)
        if docpath[0] == "functions"
            if docpath.length == 1
                content = format_functions(pkg, docs, navpkg)
            else
                content = format_function(pkg, docpath[1], docs, navpkg)
        else if docpath[0] == "classes"
            if docpath.length == 1
                content = format_classes(pkg, docs, navpkg)
            else if docpath.length == 2
                content = format_class(pkg, docpath[1], docs, navpkg)
            else
                if docpath[2] == "attributes"
                        if docpath.length == 3
                                content = format_attributes(
                                    pkg, docpath[1], docs, navpkg)
                        else
                                content = format_attribute(
                                    pkg, docpath[1], docpath[3], docs, navpkg)
                else
                        if docpath.length == 3
                                content = format_methods(
                                    pkg, docpath[1], docs, navpkg)
                        else
                                content = format_method(
                                    pkg, docpath[1], docpath[3], docs, navpkg)
        else if docpath[0] == "definitions"
            if docpath.length == 1
                content = format_definitions(pkg, docs, navpkg)
            else
                content = format_definition(pkg, docpath[1], docs, navpkg)
    else
        content = format_main(pkg, docs, navpkg)

    # Update the HTML
    $ "#content"
        .html(content)

    $("pre code")
        .each (index, element) -> hljs.highlightBlock(element)

# Parse the url parameters
parse_url = () ->
    [baseurl, tag] = window.location.href.split("?", 2)
    if !tag?
        return [undefined]
    [pkg, docpath...] = tag.split("/")
    [pkg, pkgpath] = pkg.split(".", 2)
    [pkg, pkgpath, docpath]


# Get and use the docs of a package
on_docs = (pkg, pkgpath, docpath, action, branch="master") ->
    $.getJSON url.raw(pkg, branch, ".stats.json")
        .done (stats) ->
            action(pkg, pkgpath, docpath, stats.doc)
        .fail () ->
            console.log "failed to load docs for #{pkg}"


# Set the document loader
$ document
    .ready ->
        [pkg, pkgpath, docpath] = do parse_url
        if pkg?
            on_docs(pkg, pkgpath, docpath, format_docs)
