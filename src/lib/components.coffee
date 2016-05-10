###
  This class provides a collection of components. Upon initialisation components
  are dynamically built, from its configuration. The configuration for this
  component is an Array of component names (Strings). The component names are
  then used to create a component. Components nested within those components are
  then initialised creating a powerful scope of nest components that are
  completely unique to themselves.
###
class Tweak.Components extends Tweak.Collection

  ###
    Construct the Components module based on the information already in its attributes. The __constructor method is
    called before initialization of its components - to ensure all components are accessible at the time of
    initialization.
  ###
  __constructor: ->
    _componentName = @component.name
    _absolute = (path) -> Tweak.toAbsolute _componentName, path
    _paths = (paths) -> _absolute path for path in Tweak.splitPaths paths

    attributes = []
    for item in @attributes
      if item instanceof Array
        _extends = _absolute item[1]
        for name in _paths item[0] then attributes.push new Tweak.Component @, {name, extends:_extends}
      else if typeof item is 'string'
        for name in _paths item then attributes.push new Tweak.Component @, {name}
      else if not(item instanceof Tweak.Component)
        item.extends = _absolute item.extends
        for name in _paths item.name
          item.name = name
          attributes.push new Tweak.Component @, item

    # Add components to attributes
    for component, i in attributes then @set i, component


  ###
    Construct the Components derived collection with given options from the Components configuration.
  ###
  init: ->
    # Initialise all components
    for component in @attributes then component.init()

    return

  ###
    @private
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either 'render' or 'rerender'.
  ###
  __render = (type) ->
    if @length is 0
      @triggerEvent 'ready'
    else
      @total = 0
      for item in @attributes
        _item = item
        item.controller.addEvent 'ready', ->
          if ++@total is @length then @triggerEvent 'ready'
        , @, 1
        _item[type]()
    return

  ###
    Renders all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/rendered.
  ###
  render: ->
    __render.call @, 'render'
    return

  ###
    Re-render all of its Components.
    @event ready Triggers ready event when itself and its sub-Components are ready/re-rendered.
  ###
  rerender: ->
    __render.call @, 'rerender'
    return

  ###
    Find Component with matching data in model.
    @param [String] property The property to find matching value against.
    @param [*] value Data to compare to.
    @return [Array] An array of matching Components.
  ###
  whereData: (property, value) ->
    result = []
    componentData = @attributes
    for collectionKey, data of componentData
      modelData = data.model.data or model.data
      for key, prop of modelData when key is property and prop is value
        result.push data
    result

  ###
    Reset this Collection of components. Also destroys it's components (views removed from DOM).
    @event changed Triggers a generic event that the store has been updated.
  ###
  reset: ->
    for item in @attributes
      item.destroy()
    super()
    return
