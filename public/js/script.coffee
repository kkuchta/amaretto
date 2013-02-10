window.states = ["AL", "AK", "AS", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FM", "FL", "GA", "GU", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MH", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "MP", "OH", "OK", "OR", "PW", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VI", "VA", "WA", "WV", "WI", "WY"]

class AppForm
    constructor: (@selector) ->
        @sections = []

    startNewSection: (name) ->
        @sections.push new AppSection name
    startNewLine: () ->
        this.getOrCreateLastSection().startNewLine()
    addHR: (spanWidth = 3) ->
        this.getOrCreateLastSection().addLine( new HrLine(spanWidth) )

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
        this.addLine( new AppLine )
    addLine: (line) ->
        @lines.push line
    addField: (field) ->
        if( !this.getOrCreateLastLine().addField( field ) )
            this.startNewLine()
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

    # Return false if the field was not added, and should instead be added to
    # the next line
    addField: (field) ->
        @fields.push field
        return true

    render: () ->
        line = $ '<div class="row">'
        for i, field of @fields
            line.append field.render()
        return line

class HrLine extends AppLine
    constructor: (@spanWidth) ->
        @blankSpan = Math.floor( (12 - @spanWidth) / 2 )

    addField: (field) ->
        return false
    render: () ->
        line = $ '<div class="row">'
        line.append '<div class="span' + @blankSpan + '"></div>'
        line.append '<hr class="span' + @spanWidth + '" />'
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

class PhoneField extends TextField
    constructor: (@name,@spanWidth = 3) ->
        super(@name,@spanWidth,20, '999-999-9999 ?x9999')

class DropdownField extends AppField
    constructor: (@name,@spanWidth,@width,@options) ->
        super( @name,@spanWidth )
    render: () ->
        field = templates.dropdown( this )
        $('body').append(field)
        container = $(field).find('.select-container')
        console.log( container )
        console.log('width=', container.prop('width'));
        $(field).detach()
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
    appForm.addField( new TextField( 'First Name', 4, 34 ) )
    appForm.addField( new TextField( 'Middle Initial', 2, 2 ) )
    appForm.addField( new TextField( 'Last Name', 5, 29 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Social Security Number', 4, 20, '?999-99-9999' ) )
    appForm.addField( new TextField( 'Date of Birth (MM/DD/YYYY)', 5, 11, '?99/99/9999' ) )
    appForm.startNewLine()
    appForm.addField( new TextField( "Driver's License Number", 4, 19 ) )
    appForm.addField( new TextField( "State", 2, 2, '?aa' ) )
    appForm.addField( new TextField( 'Expiration', 3, 11, '?99/99/9999' ) )
    appForm.startNewSection( 'Contact' )
    appForm.addField( new PhoneField( 'Primary Phone' ) )
    appForm.addField( new PhoneField( 'Alt Phone' ) )
    appForm.addField( new TextField( 'Best time to call', 6, 36 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Email Address', 6, 46 ) )
    appForm.startNewSection( 'Rental History' )
    addRentalHistory( appForm, "Current Address" )
    appForm.addHR(4)
    #appForm.addField( { render: () ->
        #"<hr class='span3' />"
    #})
    addRentalHistory( appForm, "Previous Address" )
    appForm.render()

    $(document).trigger('postAppFormAppended')

addRentalHistory = ( form, addressTitle ) ->
    form.addField( new TextField(addressTitle, 5, 50 ) )
    form.addField( new TextField("City", 3, 20 ) )
    form.addField( new TextField("State", 2, 2 ) )
    form.addField( new TextField("Zip", 2, 2 ) )
    appForm.startNewLine()
    form.addField( new TextField("Time at address", 3, 20 ) )
    form.addField( new TextField("Manager/owner", 4, 30 ) )
    form.addField( new PhoneField("Phone number") )
    appForm.startNewLine()


# TODO: Fix span width halving thing for HRs
