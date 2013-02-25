window.states = ["AL", "AK", "AS", "AZ", "AR", "CA", "CO", "CT", "DE", "DC", "FM", "FL", "GA", "GU", "HI", "ID", "IL", "IN", "IA", "KS", "KY", "LA", "ME", "MH", "MD", "MA", "MI", "MN", "MS", "MO", "MT", "NE", "NV", "NH", "NJ", "NM", "NY", "NC", "ND", "MP", "OH", "OK", "OR", "PW", "PA", "PR", "RI", "SC", "SD", "TN", "TX", "UT", "VT", "VI", "VA", "WA", "WV", "WI", "WY"]

class AppForm
    constructor: (@selector) ->
        @sections = []

    startNewSection: (name) ->
        @sections.push new AppSection name
    startNewLine: () ->
        this.getOrCreateLastSection().startNewLine()
    addHR: (spanWidth = 3) ->
        this.addLine( new HrLine(spanWidth) )

    addField: ( field ) ->
        this.getOrCreateLastSection().addField( field )
    addLine: ( line ) ->
        this.getOrCreateLastSection().addLine( line )
    render: () ->
        container = $(@selector).empty()
        for i, section of @sections
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

class TextLine extends AppLine
    constructor: (@content) ->

    addField: () -> false
    render: () ->
        line = $ '<div class="row">'
        line.append '<div class="span12">' + @content + "</div>"
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

class PredefinedLine extends AppLine
    constructor: (predefinedFields) ->
        super
        @constructing = true
        this.addField field for field in predefinedFields
        @constructing = false

    addField: (field) -> if @constructing then super field

class AddressLine extends PredefinedLine
    constructor: (addressTitle) ->
        super [
            new TextField(addressTitle, 5, 50 ),
            new TextField("City", 3, 20 ),
            new TextField("State", 2, 2, 'aa' ),
            new TextField("Zip", 2, 10 ) 
        ]


class BankLine extends PredefinedLine
    constructor: (accountNumberTitle, numberMask) ->
        super [
            new TextField( accountNumberTitle, 4, 22, numberMask )
            new TextField( 'Bank', 4, 40 )
            new TextField( 'Balance', 3, 20 )
        ]

counter = 0
class AppField
    constructor: (@name,@spanWidth) ->
        @id = AppField.makeID @name
    render: () ->
        return 'Some subclass forgot to override render'

    @makeID: (name) ->
        return name.toLowerCase().replace( new RegExp(/\x20/g), '-' ).replace( /[^a-z0-9\-]/g, '' ) + "_" + (++counter)


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

class CheckboxField extends AppField
    constructor: (@name,@spanWidth) ->
        super( @name, @spanWidth )
    render: () ->
        field = templates.checkboxField( this )
        return field

# Options = ["One","Two","Three"]
# Checked = "Two"
class RadioButtonField extends AppField
    constructor: (@name,@spanWidth,options, @checked) ->
        @options = for i,option of options
            { value: option, checked: option==@checked }
        super( @name, @spanWidth )
    render: () ->
        field = templates.radioButtonField( this )
        return field

class DropdownField extends AppField
    constructor: (@name,@spanWidth,@width,@options) ->
        super( @name,@spanWidth )
    render: () ->
        field = templates.dropdown( this )
        $('body').append(field)
        container = $(field).find('.select-container')
        $(field).detach()
        #input = $(field).find( 'select' )
        #id = this.id
        return field

$ () ->
    console.log("Coffeescript and jquery loaded")
    window.templates = []

    # Compile templates
    $sources = $('script[type="text/x-handlebars-template"]')
    $sources.each( (i,source) ->
        id =  $(source).attr('id')
        compiled = Handlebars.compile($(source).html())
        window.templates[id] = compiled
    )

    # Bind buttons
    $('#printViewLink').click () ->
        toHide = $('.hideOnPrint')
        toHide.hide(600)
        setTimeout ( () -> toHide.show(400) ), 5000

    $('#clearFormLink').click () ->
        $('input').each () ->
            this.value = null
            delete localStorage[this.id]

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
    appForm.addField( new TextField( "State", 2, 2, 'aa' ) )
    appForm.addField( new TextField( 'Expiration', 3, 11, '?99/99/9999' ) )

    appForm.startNewSection( 'Contact' )
    appForm.addField( new PhoneField( 'Primary Phone' ) )
    appForm.addField( new PhoneField( 'Alt Phone' ) )
    appForm.addField( new TextField( 'Best time to call', 6, 36 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Email Address', 6, 46 ) )

    appForm.startNewSection( 'Rental History' )
    addRentalHistory( appForm, "Current Address" )
    appForm.addHR(6)
    addRentalHistory( appForm, "Previous Address" )

    appForm.startNewSection( 'Employment History' )
    addEmploymentHistory( appForm, "Current Employer" )
    appForm.addHR(6)
    addEmploymentHistory( appForm, "Last Employer" )
    appForm.addHR(6)
    addEmploymentHistory( appForm, "Previous Employer" )

    appForm.startNewSection( 'Financial History' )
    appForm.addField( new TextField( 'Monthly Income', 3, 10 ) )
    appForm.addField( new TextField( 'Or Annual Income', 3, 10 ) )
    appForm.addField( new TextField( 'Additional Income', 3, 10 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'If additional income, list sources', 12, 145 ) )
    appForm.addLine( new BankLine( 'Savings Account Number' ) )
    appForm.addLine( new BankLine( 'Checking Account Number' ) )
    appForm.addLine( new BankLine( 'Credit Card Number', 'XXXX-XXXX-XXXX-9999' ) )
    appForm.addLine( new BankLine( 'Credit Card Number', 'XXXX-XXXX-XXXX-9999' ) )

    appForm.startNewSection( 'Housemates' )
    for i in [0..2]
        appForm.startNewLine()
        appForm.addField( new TextField( 'Name', 4, 40 ) )
        appForm.addField( new TextField( 'Relation', 5, 50 ) )

    appForm.startNewSection( 'Pets' )
    appForm.addField( new TextField( 'Name (or N/A)', 3, 20 ) )
    appForm.addField( new TextField( 'Age', 3, 20 ) )
    appForm.addField( new TextField( 'Sex', 3, 20 ) )
    appForm.addField( new TextField( 'Weight', 3, 20 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'Breed', 3, 20 ) )
    appForm.addField( new TextField( 'Spayed/Neutered', 3, 20 ) )

    appForm.startNewSection( 'Personal References' )
    for i in [0..1]
        appForm.addField( new TextField( 'Name', 4, 30 ) )
        appForm.addField( new TextField( 'Relationship', 4, 40 ) )
        appForm.addField( new TextField( 'Years known', 3, 20 ) )
        appForm.startNewLine()
        appForm.addField( new TextField( 'Profession', 4, 30 ) )
        appForm.addField( new PhoneField( 'Phone' ) )
        appForm.addLine( new AddressLine( 'Address' ) )
        if i != 1
            appForm.addHR()

    appForm.startNewSection( 'Vehicles' )
    for i in [0..1]
        appForm.addField( new TextField( 'Make', 3, 20 ) )
        appForm.addField( new TextField( 'Model', 3, 20 ) )
        appForm.addField( new TextField( 'Year', 2, 4 ) )
        appForm.addField( new TextField( 'Plate', 2, 7 ) )
        appForm.addField( new TextField( 'State', 2, 2, 'aa' ) )
        appForm.startNewLine()

    appForm.startNewSection( 'Personal' )
    appForm.addField( new RadioButtonField( 'Do you smoke?', 4, ["Yes", "No"], "No" ) )
    appForm.startNewLine()
    appForm.addField( new RadioButtonField( 'Have you ever been evicted?', 4, ["Yes","No"], "No") )
    appForm.addField( new TextField( 'If so, why?', 8, 105 ) )
    appForm.startNewLine()
    appForm.addField( new RadioButtonField( 'Have you ever filed for bankruptcy?', 4, ["Yes","No"], "No") )
    appForm.addField( new TextField( 'When?', 8, 110 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'If so, describe', 12, 168 ) )
    appForm.startNewLine()
    appForm.addField( new RadioButtonField( 'Have you ever been convicted of a felony?', 5, ["Yes","No"], "No") )
    appForm.addField( new TextField( 'When?', 7, 93 ) )
    appForm.startNewLine()
    appForm.addField( new TextField( 'If so, describe', 12, 168 ) )

    appForm.startNewSection( 'Emergency Contact' )
    appForm.addField( new TextField( 'Name', 4, 30 ) )
    appForm.addField( new TextField( 'Relationship', 4, 40 ) )
    appForm.addField( new PhoneField( 'Phone' ) )
    appForm.addLine( new AddressLine( "Address" ) )

    appForm.startNewSection( 'Signature' )
    appForm.addLine( new TextLine( 'Applicant represents that all the above statements are true and correct and hereby authorizes verification of the above statements and information including but not limited to the obtaining of a credit report and tenant history report and applicant agrees to furnish additional information on request.' ) )
    appForm.addField( new TextField( 'Signature', 6, 60 ) )
    appForm.addField( new TextField( 'Date (MM/DD/YYYY)', 5, 11, '?99/99/9999' ) )

    appForm.render()

    # Save/restore textbox content to/from localStorage
    $(document).trigger('postAppFormAppended')
    $('input').blur( () ->
        localStorage[this.id] = this.value
    ).each( () ->
        if localStorage[this.id]
            this.value = localStorage[this.id]
    )

    # Save/restor radio button content to/from localStorage
    $('input:radio').change( () ->
        name = this.name
        valueSet = {}
        checkedRadio = $( 'input:radio[name="' + name + '"]:checked' );
        localStorage[name] = checkedRadio.attr('val')
    ).each ()->
        val = $(this).attr('val')
        lsVal = localStorage[this.name]
        if( typeof lsVal != "undefined" )
            $(this).prop('checked',lsVal == val)

# Convenience methods

addRentalHistory = ( form, addressTitle ) ->
    appForm.addLine( new AddressLine(addressTitle) )
    appForm.startNewLine()
    form.addField( new TextField("Time at address", 4, 30 ) )
    form.addField( new TextField("Manager/owner", 4, 30 ) )
    form.addField( new PhoneField("Phone number") )
    appForm.startNewLine()


addEmploymentHistory = ( form, nameTitle ) ->
    form.addField( new TextField(nameTitle, 6, 60 ) )
    form.addField( new TextField("Postion", 6, 70 ) )
    appForm.startNewLine()
    form.addField( new TextField("How Long", 4, 30 ) )
    form.addField( new TextField("Supervisor", 4, 30 ) )
    form.addField( new PhoneField("Phone number") )
    appForm.addLine( new AddressLine('Address') )
    

