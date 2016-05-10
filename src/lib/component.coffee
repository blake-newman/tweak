###
  TweakJS wraps its Models, Views, Templates, and Controllers into a Component
  module. The Component module acts intelligently to build up your application
  with simple configuration files. Each Component its built through a config
  object; this allows for powerful configuration with tonnes of flexibility.
  The config objects are extremely handy for making Components reusable, with
  easy accessible configuration settings.

  Each Component can have sub Components which are accessible in both directions;
  although it is recommended to keep functionality separate it sometimes comes in
  handy to have access to other parts of the application. Each Component can
  extend another Component, which will then inherent the models, views, templates,
  and controllers directly from that Component. If you however want to extend a
  Component using a different Model you can simply overwrite that model, or extend
  the functionality to the inherited model Components model.
###
class Tweak.Component

  # @property [Object]
  model: null
  # @property [Object]
  view: null
  # @property [Object]
  components: null
  # @property [Object]
  controller: null
  # @property [Object]
  router: null

  modules: ['router', 'components', 'collection', 'model', 'controller', 'view']

  ###
    Set the component up along with its default modules.

    @param [Object] relation Relation to the Component.
    @param [Object] options Configuration for the Component.
  ###
  constructor: (relation, options) ->
    if not options? then throw new Error 'No options given'

    # Build relation if window and build its default properties
    # The relation is it direct caller
    relation = @relation = if relation is window then {} else relation
    relation.relation ?= {}
    # Get parent Component
    @parent = if relation instanceof Tweak.Component then relation else relation.component or relation
    @root = @parent.root or @
    # Set name of Component
    @name = options.name
    if not @name? then throw new Error 'No name given'
    options.name = @name = Tweak.toAbsolute @parent.name or '', @name

    @config = __buildConfig.call @, options
    # Router is optional as it is performance heavy
    # So it needs to be explicitly defined in the config for the Component that it should be used
    if @config.router then __addModule.call @, 'router', Tweak.Router
    if @config.collection then __addModule.call @, 'collection', Tweak.Collection

    # Add modules to the Component
    __addModule.call @, 'model', Tweak.Model
    __addModule.call @, 'view', Tweak.View
    __addModule.call @, 'controller', Tweak.Controller
    __addModule.call @, 'components', Tweak.Components

    # Add references to the the modules
    for name in @modules when prop = @[name]
      prop.parent = @parent
      prop.component = @
      for name2 in @modules when name isnt name2 and prop2 = @[name2]
        prop[name2] = prop2

  ###
    When the component is initialised it's modules are also initialised.
  ###
  init: ->
    # Call init on all the modules
    for name in @modules when item = @[name] then item.init?()
    return

  ###
    Builds the configuration object for the Component.
    @param [Object] options Component options.
    @return [Object] Combined config based on the components inheritance.
  ###
  __buildConfig = (options) ->
    configs = [Tweak.clone options]
    paths = @paths = [@name]
    extension = options.extends or @name

    # Gets all configs, by configs extension path
    name = @parent?.name or @name
    while extension
      requested = Tweak.request name, "#{extension}/config", if Tweak.strict then null else {}
      # Store the path to component
      _path =  Tweak.toAbsolute name, extension
      if paths.indexOf(_path) is -1  then paths.push _path
      # Push a clone of the config file to remove reference
      configs.push Tweak.clone requested
      extension = requested.extends

    # Combine all the config files into one
    # The values of the config files from lower down the chain have priority
    result = configs[configs.length-1]
    for i in [configs.length-1..0]
      result = Tweak.combine result, configs[i]

    # Set initial values in config if they do not exist
    result.model ?= {}
    result.view ?= {}
    result.controller ?= {}
    result.components ?= []
    result

  ###
    Add a module to the Component, if module can't be found then it will use a surrogate object.
    @param [String] name Name of the module.
    @param [Object] surrogate Surrogate if the module can not be found.
  ###
  __addModule = (name, surrogate) ->
    Module = Tweak.request @paths, "./#{name}", surrogate
    module = @[name] = new Module @config[name]
    module.component = @
    module.root = @root
    # Calls a modules __constructor method if exists
    module.__constructor?()
    return

  ###
    Reusable method to render and re-render.
    @param [String] type The type of rendering to do either 'render' or 'rerender'.
  ###
  __render = (type) ->
    @view.addEvent "#{type}ed", ->
      @components.addEvent 'ready', ->
        @controller.triggerEvent 'ready'
      , @, 1
      @components[type]()
    , @, 1
    @view[type]()
    return

  ###
    Renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/rendered.
  ###
  render: ->
    __render.call @, 'render'
    return

  ###
    Re-renders itself and its subcomponents.
    @event ready Triggers ready event when itself and its Components are ready/re-rendered.
  ###
  rerender: ->
    __render.call @, 'rerender'
    return

  ###
    Destroy this Component. It will clear the view if it exists; and removes it from the Components Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
  ###
  destroy: (silent) ->
    @view.clear()
    components = @relation.components
    if components?
      for key, item of components.data when item is @
        components.remove key, silent
    return

  ###
    Short-cut to the controllers findEvent method.

    @overload findEvent(names, build)
      Find events on controller with a space separated string.
      @param [String] names The event name(s); split on a space.
      @param [Boolean] build (default = false) Whether to add an event object to the controller when none can be found.
      @return [Array<Event>] All event objects that are found/created then it is returned in an Array.

    @overload findEvent(names, build)
      Find events on controller with an array of names (strings).
      @param [Array<String>] names An array of names (strings).
      @param [Boolean] build (default = false) Whether to add an event object to the controller when none can be found.
      @return [Array<Event>] All the controllers event objects that are found/created then it is returned in an Array.
  ###
  findEvent: (names, build) -> @controller.findEvent names, build


  ###
    Short-cut to the controllers addEvent method.

    @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback The event callback function.
    @param [Number] maximum (default = null) The maximum calls on the event listener. After the total calls the events
    callback will not invoke.
    @param [Object] context The contextual object of which the event to be bound to.
  ###
  addEvent: (names, callback, max, context) -> @controller.addEvent names, callback, max, context

  ###
    Short cut to the controllers removeEvent method.

    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Function] callback (optional) The callback function of the event. If no specific callbacki s given then all
    the controller events under event name are removed.
    @param [Object] context (default = this) The contextual object of which the event is bound to. If this matches then
    it will be removed, however if set to null then all events no matter of context will be removed.
  ###
  removeEvent: (names, callback, context) -> @controller.removeEvent names, callback, context

  ###
    Short cut to the controllers triggerEvent method.

    @overload triggerEvent(names, params)
      Trigger events on controller by name only.
      @param [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @param [...] params Parameters to pass into the callback function.

    @overload triggerEvent(options, params)
      Trigger events on controller by name and context.
      @param [Object] options Options and limiters to check against callbacks.
      @param [...] params Parameters to pass into the callback function.
      @option options [String, Array<String>] names The event name(s). Split on a space, or an array of event names.
      @option options [Context] context (default = null) The context of the callback to check against a callback.
  ###
  triggerEvent: (names, params...) -> @controller.triggerEvent names, params...

  ###
    Shortcut to the controllers updateEvent method.

    @param [String] names The event name(s). Split on a space, or an array of event names.
    @param [Object] options Optional limiters and update values.
    @option options [Object] context The contextual object to limit updating events to.
    @option options [Function] callback Callback function to limit updating events to.
    @option options [Number] max Set a new maximum calls to an event.
    @option options [Number] calls Set the amount of calls that has been triggered on this event.
    @option options [Boolean] reset (default = false) If true then calls on an event get set back to 0.
    @option options [Boolean] listen Whether to enable or disable listening to event.
  ###
  updateEvent: (names, options) -> @controller.updateEvent names, options

  ###
    Resets the controllers events to empty.
  ###
  resetEvents: -> @controller.resetEvents()

  ###
    This method is used to extract all data of a component. If there is an export method within the Component Controller
    then the Controller export method will be executed with the data returned from the method.
    @param [Object] limit Limit the data from model to be exported
    @return [Object] Extracted data from Component.
  ###
  export: (limit) -> @controller.export?() or model: @model.export(limit), components: @components.export()

  ###
    This method is used to import data into a component. If there is an import method within the Component Controller
    then the Controller import method will be executed with the data passed to the method.
    @param [Object] data Data to import to the Component.
    @option data [Object] model Object to import into the Component's Model.
    @option data [Array<Object>] components Array of Objects to import into the Component's Components.
  ###
  import: (data) ->
    if @controller.import?
      @controller.import data
    else
      if data.model then @model.import data.model
      if data.components then @components.import data.components
