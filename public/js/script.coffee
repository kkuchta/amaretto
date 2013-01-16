class AppForm
    constructor: (@selector) ->
        @sections = []

    startNewSection: (name) ->
        @sections.push new AppSection name
    startNewLine: () ->
        this.getOrCreateLastSection().startNewLine()

    addField: ( field ) ->
        this.getOrCreateLastSection().addField( field )
    render: () ->
        container = $(@selector).empty()
        console.log 'rendering'
        for i, section of @sections
            console.log( "Section=" + section );
            container.append section.render()
        return container

    getOrCreateLastSection: () ->
        if @sections.length == 0
            startNewSection()
        return @sections[ @sections.length - 1 ]
    




class AppSection
    constructor: (@header) ->
        @lines = []
        this.startNewLine()
    startNewLine: () ->
        @lines.push new AppLine
    addField: (field) ->
        this.getOrCreateLastLine().addField( field )

    render: () ->
        console.log("rendering app section" );
        section = $ '<section><h2>' + @header + '</h2></section>'
        for i, line of @lines
            section.append line.render()
        return section

    getOrCreateLastLine: () ->
        if @lines.length == 0
            startNewLine()
        return @lines[ @lines.length - 1 ]

class AppLine
    constructor: () ->
        @fields = []
    addField: (field) ->
        @fields.push field
    render: () ->
        line = $ '<div class="row">'
        for i, field of @fields
            line.append field.render()
        return line

class AppField
    constructor: (@name,@spanWidth) ->
        @id = AppField.makeID @name
    render: () ->
        return 'Some subclass forgot to override render'

    @makeID: (name) ->
        return name.toLowerCase().replace( new RegExp(/\x20/g), '-' ).replace( /[^a-z0-9\-]/g, '' )


class TextField extends AppField
    constructor: (@name,@spanWidth,@chars, @mask) ->
        super( @name,@spanWidth )
    render: () ->
        field = templates.textField( this )
        input = $(field).find( 'input' )
        mask = @mask
        id = this.id
        if mask then $(document).on( 'postAppFormAppended', () ->
            $('#' + id).mask(mask)
        )
        return field


$ () ->
    console.log("Coffeescript and jquery loaded")
    window.templates = []

    # Compile templates
    $sources = $('script[type="text/x-handlebars-template"]')
    console.log $sources
    $sources.each( (i,source) ->
        id =  $(source).attr('id')
        compiled = Handlebars.compile($(source).html())
        console.log( "id=" + id )
        console.log( "compiled=" + compiled )
        window.templates[id] = compiled
    )

    window.appForm = new AppForm '#application'
    appForm.startNewSection( 'Basics' )
    appForm.addField( new TextField( 'First Name', 5, 29 ) )
    appForm.addField( new TextField( 'Middle Initial', 2, 2 ) )
    appForm.addField( new TextField( 'Last Name', 5, 29 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Social Security Number', 5, 20, '999-99-9999' ) )
    appForm.addField( new TextField( 'Date of Birth (MM/DD/YYYY)', 5, 11, '99/99/9999' ) )
    appForm.render()

    $(document).trigger('postAppFormAppended')
