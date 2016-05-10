###
  A View is a module to clearly define and separate the user interface functionality. A View is primarily used to render
  , manipulate and to listen to actions on a user interface. The view keeps data logic separated away from the UI, this
  is to leverage better code structure to prevent Data and the UI becoming tangled together.

  Tweak.js provides default functionality to render a template; like handlebars. Currently handlebars is used as default
  as the render. This will be separated out into an extension in a later version. Tweak.js's View can utilize two
  different methods to render a template. It also allows you to point directly to a element to use as the 'view area'
  examples below. The rendering methods include adding a data-attach attribute to an element; Tweak js will look at
  these attributes values to find where to attach a template to. If that not your scene you can also specify a selector
  to determine where to attach to.

  @example Static view
    var MainView;

    // This will create a view that points to an element with an id of "mainElement".
    MainView = new Tweak.View({
      method:"static",
      element:"#mainElement"
    });

    // Override the ready method to apply your logic - this will be called when the View is rendered.
    MainView.ready = function() {
      console.log(MainView.el); // Outputs the "#mainElement" element
    }

    // This must be called to initialise the view correctly
    MainView.init();

    // Called to invoke the View
    MainView.render();

###
class Tweak.View extends Tweak.Events

  $ = Tweak.$

  ###
    The constructor passes a config object that will be used upon the initialization of the view module. Use of the
    options is described below. Not all options need to be provided; when using component modules some of the option
    values will automatically be provided.

    @param [Object] config A configuration object that is used to describe how the View is initialised and rendered.

    @option config [String] name When using a View independently to Component modules this will be used to name the view
    Used in instances to apply a className to the Views main element, and will be used to find where to attach to; by
    default othe values will look at this so it is recommended each view has a name. When using Component modules this
    will use the Views relating component name.

    @option config [String] parentName When using a View independently to Component modules this can be is used to
    generate an absolute name to compare data-attach values to. This will be populated when using Component modules but
    you may overwrite the value if you wish. When using Component modules the default value will be the parent
    Component's name.

    @option config [*] data Use this to pass data to the view when using a View independently of a component, can
    reference a Model or Collection or just be any data type.

    @option config [String, DOMElement] element This is used to specify what element to attach to if directly attaching
    to an element using a DOM manipulation framework; if a static View is defined then this option is depended upon.

    @option config [String] attach This is used to specify where to attach to if using data-attach attributes. By
    default this will be equal to the config.name value.

    @option config [String, Element] parent When using a View independently to Component modules this can be is used to
    specify the parent element of the View - used to decide where generated template will be attached to. This will
    be populated when using Component modules but you may overwrite the value if you wish.

    @option config [String] method This is used to specify how the template is attached to. I.e. 'after' - default,
    'before', position (number), 'replace' or 'static'. If static is specified then the view will be treated as static
    and point directly to an element. This can be used when a template engine is not used.

    @option config [Array<String>] paths When using a View independently to Component modules this can be is used to
    specify context paths to use when converting data-attach values to an absolute equivalent. This value is also used
    to generate class names to the apply to the Views element. This will be populated when using Component modules but
    you may overwrite the value if you wish.

    @option config [String] template When using a View independently to Component modules this can be is used to
    specify the path of the template. This may also be used with config.paths to find an appropriate template. By
    default the name will be './template'.

    @option config [Boolean] async (Default = true) This can be used to turn off asynchronous calls to the ready function.
    This adds performance boosts, as it allows other components to continue rendering while functionality is added to the
    View. This may want to be set to false if for example if this View relies on functionality of another Component's
    View to be rendered successfully.

  ###
  constructor: (@config = {}) ->

  _name = -> @config.name or @component?.name or  ''

  _parentName = -> @config.parentName or @parent?.name or  ''

  _attach = -> @config.attach or _name.call @

  _paths = -> @config.paths or @component?.paths or []

  _classNames = ->
    names = Tweak.clone _paths.call @
    name = _name.call @
    # If _name() isn't included in names Array then add _name() to the list of names
    if names.indexOf(name) is -1 then names.unshift name
    for name in names then name.replace /[\/\\]+/g, '-'

  _async = -> @config.async ? true

  _parentElement = -> $(@config.parentElement)[0] or @parent?.view?.el or document.documentElement

  _data = -> @config.data ? @model?.attributes

  ###
    Default initialiser function - called when the View is initialised - this doesn't mean the view will be rendered.
    Use the ready method for applying methods functionality when the view has been rendered.
  ###
  init: ->

  ###
    Default initialiser function for when the view is rendered. This is empty by default.
  ###
  ready: ->

  ###
    Default template creation method - this will generate a template from data passed in. By default Tweak.js supports
    handlebar templates that are requirable. This will be separated out into an extension in a later version.

    @param [Object] data An object that can be passed to the template.
    @return [String] String representation of HTML to attach to View during render.
  ###
  template: (data) ->
    template = @config.template
    paths = _paths.call @
    (if template then Tweak.request paths, template else Tweak.request paths, './template') data

  ###
    Default attach method. This is used to attach a HTML string to an element. You can override this method with your
    own attachment functionality.

    @param [DOMElement] parent A DOMElement used as the parent Element to attach the content element to.
    @param [String, DOMElement] content A element of a HTML String that will be converted to a HTMLElement. This is
    element will be attached to the parent element.
    @return [DOMElement] Attached DOMElement (content).
  ###
  attach: (parent, content, method = @config.method) ->
    content = $(content)[0]
    switch method
      # Insert the content element at the start of the parents children.
      # Returning the first element of the parent
      when 'prefix', 'before'
        parent.insertBefore content, parent.firstChild
        return parent.firstElementChild
      # Replaces the content of the parent element innerHTML
      # Returning the first element of the parent
      when 'replace'
        for item in parent.children
          try
            parent.removeChild item
          catch e
        parent.appendChild content
        return parent.firstElementChild
      else
        # If the method is a digit then the content element will be attached at that position
        # Returning the element in that position of the parent element
        if not isNaN num = Number method
          parent.insertBefore content, parent.children[num]
          return parent.children[num]
        # If no parent specified then it will be attached as the last child of the parent element
        else
          parent.appendChild content
          return parent.lastElementChild

  ###
    Checks to see if the item is attached to a parent element. This is determined if an parent element contains a
    child element.
    @param [DOMElement, String] parent The parent element or a String representing a selector query, to check if the
    element contains the specified 'containing' element.
    @param [DOMElement, String] parent The 'containing' element or a String representing a selector query.
    @return [Boolean] Does the parent contain an element?
  ###
  isAttached: (element, parent) ->
    parent = $ parent or document.documentElement
    element = $ element or @el
    if not parent.length or not element.length then return false

    for _parent in parent
      for _element in element
        if not $.contains _parent, _element then return false

    true

  ###
    Finds an attachment node when using data-attach process.
  ###
  getAttachment: (parent) ->
    parent = $(parent)[0]
    # If no target then return
    if not parent then return

    # Get all elements with data-attach as an Array
    elements = $('[data-attach]', parent).toArray()
    # Put the parent element in elements if there is a data-attach attribute
    if parent.getAttribute('data-attach') then elements.unshift parent
    # Get the name to attach to. This name will automatically be converted to an absolute path.

    parentName = _parentName.call @
    name = Tweak.toAbsolute parentName, _attach.call @

    # Iterate each item in elements that have the data-attach property; when child does not exist
    for element in elements when not attachment
      # Get the attachment value of the element
      attachments = Tweak.splitPaths element.getAttribute('data-attach') or ''
      # Iterate over attachment paths
      for value in attachments
        if name is Tweak.toAbsolute parentName, value
          attachment = element
          break
    attachment

  ###
    Dynamically renders the view. This will use the views config object to decide the rendering process. Upon rendering
    the View's ready method will be called along with a 'rendered' event being fired. The ready method should be used to
    apply functionality to the Views UI.

    @param [Boolean] silent (Optional, default = false) If true events are not triggered upon any changes.
    @event rendered The event is called when the View has been rendered.
  ###
  render: (silent) ->

    _render = =>
      # If the element is already attached then trigger 'rendered' event and return from render method.
      if @isAttached() and not silent then return @triggerEvent 'rendered'

      parentElement = _parentElement.call @
      _element = @config.element

      # Generate the template and add reference to View
      _el = if @config.method is 'static' then $(_element)[0]
      else
        # If _element is available then use _element
        attachment = if _element then $(_element, parentElement)[0] or $(_element)[0]
        else
          docEl = document.documentElement
          # Use got attachment node or use parent or use document.documentElement
          @getAttachment(parentElement) or
          @getAttachment(docEl) or
          parentElement or
          docEl
        @attach attachment, @template _data.call @

      # Set the Views 'el' properties
      @$el = $ _el
      @el = @$el[0]

      # Add class names to Views main element
      @$el.addClass _classNames.call(@).join ' '
      # If not silent then trigger a 'rendered' event
      if not silent then @triggerEvent 'rendered'
      # Call ready method either synchronously of asynchronously depending on the config.async value.
      @ready()

      return

    if _async.call @
      setTimeout _render, 0
    else
      _render()

    return

  ###
    Clear and rerender view.
    @param [Boolean] silent (Optional, default = false) If true events are not triggered upon any changes.
    @event rendered The event is called when the View has been rendered.
  ###
  rerender: ->
    @clear()
    @render()
    return

  ###
    Clears and element and removes event listeners on itself and child DOM elements.
    @param [String, DOMElement] element A DOMElement or a string representing a selector query.
  ###
  clear: (element = @el) ->
    $(element).remove()
    return


  ###
    Select a DOMElement from within the assigned view element
    @param [String, DOMElement] element A DOMElement or a string representing a selector query.
    @param [DOMElement] root (Default = @el) The element root to search for elements with a selector engine.
    @return [Array<DOMElement>] An array of DOMElements.
  ###
  element: (element, root = @el) ->
    if element instanceof Array
      $ item, root for item in element
    else $ element, root
