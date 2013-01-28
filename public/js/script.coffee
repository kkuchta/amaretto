window.states = ["AL", "AK", "AS", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FM", "FL", "GA", "GU", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MH", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "MP", "OH", "OK", "OR", "PW", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VI", "VA", "WA", "WV", "WI", "WY"]

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

class DropdownField extends AppField
    constructor: (@name,@spanWidth,@width,@options) ->
        super( @name,@spanWidth )
    render: () ->
        field = templates.dropdown( this )
        #input = $(field).find( 'select' )
        #id = this.id
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

    # Bind buttons
    $('a#printViewLink').click () ->
        console.log "here"
        toHide = $('.hideOnPrint')
        toHide.hide(600)
        setTimeout ( () -> toHide.show(400) ), 5000

    

    window.appForm = new AppForm '#application'
    appForm.startNewSection( 'Basics' )
    appForm.addField( new TextField( 'First Name', 5, 34 ) )
    appForm.addField( new TextField( 'Middle Initial', 2, 2 ) )
    appForm.addField( new TextField( 'Last Name', 5, 29 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Social Security Number', 5, 20, '999-99-9999' ) )
    appForm.addField( new TextField( 'Date of Birth (MM/DD/YYYY)', 5, 11, '99/99/9999' ) )
    appForm.startNewLine()
    appForm.addField( new TextField( "Driver's License Number", 6, 19 ) )
    appForm.addField( new DropdownField( "State", 6, 19, window.states ) )
    appForm.startNewSection( 'Contact' )
    appForm.addField( new TextField( 'Primary Phone', 3, 12, '999-999-9999' ) )
    appForm.addField( new TextField( 'Alt Phone', 3, 12, '999-999-9999' ) )
    appForm.addField( new TextField( 'Best time to call', 6, 36 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Email Address', 6, 46 ) )
    appForm.render()

    $(document).trigger('postAppFormAppended')
