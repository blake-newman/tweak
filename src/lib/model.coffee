###
  A Model is used to store, retrieve and listen to attributes.Tweak.js will call events through its **event system**,
  when the Model is updated when it will trigger a 'changed' event. By listening to change events, you can action
  functionality upon changes to the Model's attributes. The Model’s attributes are not perisistant, as such it is not a
  storage medium, but a layer for actioning functionailty upon changes. The Model's data can be exported as a JSON
  represtaion which can be used to store/retrieve data form persistant storage sources. The main difference between a
  Model and collection it the base of its attributes. The Model uses an Object as its attributes base and a collection
  uses an Array as its attributes base, to add the Collection Class extends the Model Class.

  A Model based class has a getter and setter system. So you can easily apply additional functionality when setting or
  getting an attribute. When calling the set method, a setter method may be called if a setter to the naming convention
  of 'setter_{property name}' exists. The returning value of the setter method will be used in setting the attribute.
  When calling the get method, a getter method may be called if a getter to the naming convention of
  'getter_{property name}' exists. The value of the getter method will be used at the result of the get call. Setters
  and getters can also have additional parameters passed to them to provide extra logic. When setting or getting
  multiple attributes each set of parameters should be contained in a multidimesional Array. For example this is the
  structure when setting on attribute model.set('pizza', 'cheesy', ['extra', 'cheesy', 'please']);. If you where
  to set/get multiple attributes then this would be the structure to pass extra parameters to the setter/getter.
  model.set({'pizza':'cheesy', price:20}, ['extra cheesy'], [10, 50]);.

  @example Creating a setter and getter in Model.
    // This example is very trivial but it illustrates some use of setters and getters
    var QuestionModel, _model, exports;

    module.exports = exports = QuestionModel = (function() {
      function QuestionModel() {}

      Tweak.extends(QuestionModel, Tweak.Model);

      // Correct getter will return true or false
      QuestionModel.prototype.getter_correct = function(_prev) {
        _correct = this.get('answer') === this.get('correct_answer');
        // You can use a getter to compare to the previous value
        if (_prev === true && _correct === false) {
          alert('You already got this correct, you should know the answer!');
        }
        // You can use the model value as a private property to later use as a comparison
        // In this instance when answer has been answered correct it will be saved to model
        if (_correct === true) {
          // Set correct silently
          this.set('correct', true, true);
        }
        return _correct
      };

      // The answer may only be in the range of 0 - 100
      // This setter will auto validate the answer to within the range, while if its not in range it will trigger an
      // event from the model. For example a notification could be displayed letting the user know his answer was
      QuestionModel.prototype.setter_answer = function(value) {
        var error;
        error = value > 100 ? 'above' : value < 0 ? 'below' : null;
        if (error) {
          this.trigger('error:range:' + error, value);
        }
        if (error < 0) {
          return 0;
        } else if (value > 100) {
          return 100;
        } else {
          return value;
        }
      };

      return QuestionModel;

    })();

    // Create a new QuestionModel where the answer correct_answer is 10
    _model = new QuestionModel({
      correct_answer: 10
    });

    // Listen to answer being set alerting whether the user has got the answer correct
    _model.addEvent('changed:answer', function() {
      return alert('Answer is ' + (this.get('correct') ? 'Correct' : 'Wrong'));
    });

    // Listen range error - lets the user knows that his answer was above range
    _model.addEvent('error:range:above', function(value) {
      return alert('Answer (' + value + ') is above max range of 100, answer has been altered to 100');
    });

    // Listen range error - lets the user knows that his answer was above range
    _model.addEvent('error:range:below', function(value) {
      return alert('Answer (' + value + ') is below min range of 100, answer has been altered to 0');
    });

    // Alerts 'Answer is Wrong'
    _model.set('answer', 20);

    // Alerts 'Answer (500) is above max range of 100, answer has been altered to 100'
    // Alerts 'Answer is Wrong'
    _model.set('answer', 500);

    // Alerts 'Answer is Correct'
    _model.set('answer', 10);

    // Alerts 'You already got this correct, you should know the answer!'
    // Alerts 'Answer is wrong'
    _model.set('answer', 5);
###
class Tweak.Model extends Tweak.Events

  # @property [Function] The base object type i.e. {}, []
  __base: -> {}

  # @property [Integer] Length of the attributes
  length: 0

  ###
    Method to trigger a change event for all of the properties in the Collection
  ###
  __fullTrigger = (ctx) -> for key, item of ctx.attributes then ctx.triggerEvent "changed:#{key}", item

  ###
    The constructor will set the initial attributes. The attributes set at this point will be applied silently.

    @example Creating a Collection with predefined set of attributes.
      var collection;
      collection = new tweak.Collection([
        new Tweak.Model({drink:'Pepsi'}),
        new Tweak.Model({drink:'Lemonade'})
      ]);

    @example Creating a Model with predefined set of attributes
      var model;
      model = new tweak.Model({
        'demo':true,
        'example':false,
        'position':99
      });
  ###
  constructor: (attributes = @__base()) ->
    @attributes = attributes
    for item of attributes then @length++


  ###
    Default initialiser function. By default this is empty, upon initialisation of a component this will be called.
    This acts as your constructor, giving you access to the other modules of the component. Please note you can use a
    constructor method but you will not have access to other modules.
  ###
  init: ->

  ###
    Set attribute(s), upon setting an attribute there will be an event triggered; you can use this to listen to changes
    and act upon the changes as required. There is also a final generic changed event fired.

    @overload set(data, silent, params)
      Set multiple attributes by an object of data.
      @param [Object] data Key and property based object.
      @param [Boolean] silent (optional, default = false) Trigger 'changed' events upon changes to attribute.
      @param [Array<Array<*>>] params Additional parameters in an multidimensional Array to pass to setters. Each
      key in the object will need its own set of additional parameters.
      @return [Number] Length of attributes.

    @overload set(name, data, silent, params)
      Set an individual attribute by the name (String).
      @param [String] name The name of the attribute.
      @param [*] data Attribute value.
      @param [Array<*>] params Additional parameters in an Array to pass to getter.
      @param [Boolean] silent (optional, default = false) Trigger 'changed' events upon changes to attributes.
      @return [Number] Length of attributes.

    @example Setting single attribute.
      this.set('sample', 100);

    @example Setting multiple attributes.
      this.set({sample:100, second:2});

    @example Setting attributes silently, with additional parameters to pass to setters.
      this.set('sample', 100, true, [false, true, 50]);
      this.set({sample:100, second:2}, true, [
        [200],
        [true, true]
      ]);

    @event changed:#{key} Triggers an event of the changed attribute, with the value of the new attribute.
    @event changed Triggers a generic event that the attributes have been updated, with changed attributes and values.
  ###
  set: (data, silent, arg3, params) ->
    type = typeof data
    # If first argument is a sting then structure into object
    if type is 'string' or type is 'number'
      # Create new Object with attribute key as first argument with value as second argument
      (_data = {})[data] = silent
      # Assign new object to data
      data = _data
      # Set silent variable based on the third argument
      silent = arg3
      params = [params]
    else
      # As augments a shifted along on the params becomes value of arg3
      params = arg3 or []


    # Variable to store the changed attributes
    changed = @__base()

    # set i as the counter
    i = 0
    # Iterate through each attribute of data, setting the keys to a changed Array
    for key, attr of data
      # If attribute does not exist previously then update Store's length
      if not @attributes[key]? then @length++
      # Set reference to setter method
      fn = @["setter_#{key}"]
      # Set the attribute. If there is a setter method then the returning value will be used
      changed[key] = @attributes[key] = if fn?
        # Add attribute value to beginning of params
        (params[i] ?= []).unshift attr
        # Call the setter
        fn.apply @, params[i]
      else attr
      i++
      # If not silent then trigger 'changed' event to the attribute name
      if not silent then @triggerEvent "changed:#{key}", changed[key]

    # If not silent then trigger a general 'changed' event, passing the names of all the changed attributes
    if not silent then @triggerEvent 'changed', changed

    # Return the new length
    @length

  ###
    It is possible to limit attributes by passing a array of attribute names of a single attribute name. If you want to
    retrieve all attributes then don't pass a limiter.

    @note When passing additional params

    @overload get(name, params)
      Get an individual attribute.
      @param [String] name The name of the attribute.
      @param [Array<*>] params Additional parameters in an Array to pass to getter.
      @return [Array<*>, Object, *] Value of attribute.

    @overload get(limit, params)
      Get multiple attributes.
      @param [Array<String>] limit Array of attribute names.
      @param [Array<Array<*>>] params Additional parameters in an multidimensional Array to pass to getters. Each
      item in the get limiter will need its own set of additional parameters.
      @return [Array<*>, Object] Values of attributes.

    @example Get attribute.
      this.get('sample');

    @example Get mutiple attributes.
      this.get(['sample', 'pizza']);

  ###
  get: (limit, params = []) ->

    # If limit is not instanceof Array then wrap in Array
    if not (limit instanceof Array)
      limit = [limit]
      params = [params]

    # Set the attributes default
    attributes = @__base()
    typeArray = attributes instanceof Array

    # Iterate through each item of limit
    for item, i in limit
      # Reference to getter method
      fn = @["getter_#{item}"]

      # Get attribute
      attr = @attributes[item]

      # If there is a getter method then the attribute value will become the returned value.
      # The current attribute value is passed to getter method
      data = if fn?
        # Add previous attribute value to beginning of params
        (params[i] ?= []).unshift attr
        # call the getter
        fn.apply @, params[i]
      else attr

      attributes[if typeArray then i else item] = data

    # If i is 1 then the returned value will be the single value
    if i <= 1 then attributes = attributes[if typeArray then 0 else item]

    # Return the retrieved attributes
    attributes

  ###
    Remove attribute(s).

   @overload remove()
      Remove all attributes.
      @return [Number] Length of attributes.

    @overload remove(name)
      Get an individual attribute by attribute name.
      @param [String] name The name of the attribute.
      @return [Number] Length of attributes.

    @overload remove(limit)
      Get multiple attributes from base storage.
      @param [Array<String>] limit Array of attribute names.
      @return [Number] Length of attributes.

    @event changed:#{key} Triggers an event of the changed attribute, with the value of the new attribute.
    @event changed Triggers a generic event that the attributes have been updated, with changed attributes and values.

    @example Removing a single attribute.
      var model;
      model = new tweak.Model();
      model.remove('demo');

    @example Removing multiple attributes.
      var model;
      model = new tweak.Model();
      model.remove(['demo', 'example']);

    @example Removing attributes silently.
      var model;
      model = new tweak.Model();
      model.remove(['demo', 'example'], true);
      model.remove('position', true);
  ###
  remove: (limit, silent) ->
    # If limit isnt an Array then wrap in Array
    if not (limit instanceof Array) then limit = [limit]

    isArray = @__base() instanceof Array
    i = 0
    # Iterate over each attribute in limit
    for attribute in limit
      if isArray then attribute = attribute-i
      if @attributes[attribute]?
        # Decrease length of attributes
        @length--
        # Delete attribute
        if isArray then @attributes.splice attribute, 1 else delete @attributes[attribute]
        # If not silent name trigger change event to the attribute name
        if not silent and not isArray then @triggerEvent "changed:#{attribute}"
        # Increase offset count
        i++

    # If not silent then trigger changed events
    if not silent
      if isArray then __fullTrigger @
      @triggerEvent 'changed'

    # Returns the length of the attributes
    @length

  ###
    Checks the existence of attribute(s).

    @overload has(name, params)
      Check the existence of a single attribute.
      @param [String] name The name of the attribute.
      @param [Array<*>] params Additional parameters in an Array to pass to getter.
      @return [Boolean] Attribute existence.

    @overload has(limit, params)
      Check the existence of multiple attributes.
      @param [Array<String>] limit Array of attribute names.
      @param [Array<Array<*>>] params Additional parameters in an multidimensional Array to pass to getters. Each
      item in the get limiter will need its own set of additional parameters.
      @return [Boolean] Attributes existence.

    @example Check the existence of a single attribute.
      this.has('sample');

    @example Check the existence of multiple attributes.
      this.has(['sample', 'pizza']);
  ###
  has: (limit, params) ->
    # Get the attributes
    attributes = @get limit, params
    # If the returned is a single attribute then wrap in Array
    if not (limit instanceof Array) then attributes = [attributes]
    # Iterate over attributes if value is null or undefined then return false
    for key, attr of attributes when attr is undefined or not attr? then return false
    # All attributes exist to return true
    true

  ###
    Returns whether two objects are the same (similar).
    @param [Object, Array] one Object to compare to Object two.
    @param [Object, Array] two Object to compare to Object one.
    @return [Boolean] Are the two Objects the similar?

    @example comparing objects.
      this.same({'sample':true},{'sample':true}); //true
      this.same({'sample':true},{'not':true}); //false
  ###
  same: (one, two = @attributes) ->
    for key, prop of one when not two[key]? or prop isnt two[key] then return false
    for key, prop of two when not one[key]? or prop isnt one[key] then return false
    true

  ###
    This method directly accesses the Collection's attributes's toString method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/toString
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toString
  ###
  toString: -> @attributes.toString()

  ###
    This method directly accesses the Collection's attributes's toLocalString method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/toLocalString
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/toLocalString
  ###
  toLocaleString: -> @attributes.toLocaleString()

  ###
    Returns an Array of attribute names where the attribute value matches.
    @param [*] value Value to check.
    @return [Array<String>] Returns an Array of attribute names where the attribute value matches argument.

    @example Find attribute names where value matches attributes.
      this.where(1009); //[3,87]
  ###
  where: (value) -> for key, attr of @attributes when attr is value then key

  ###
    Reset the attributes and set length to 0 and triggers 'changed' event.
    @event changed Triggers a generic event that the attributes have been updated.
  ###
  reset: ->
    # Set the length to 0
    @length = 0
    # Reset attributes to the base
    @attributes = @__base()
    # Trigger 'changed' event
    @triggerEvent 'changed'
    return

  ###
    Import attributes, attributes can be imported silently. The import method will overwrite attributes that already
    exists; if the existing attribute value has an import method the data will be passed to the attributes' method.

    @param [Object, Array] attributes Attribute data to import.
    @param [Boolean] silent (optional, default = false) Trigger 'changed' events upon changes to attributes.
    @return [Number] Length of attributes.


    @event changed:#{key} Triggers an event of the changed attribute, with the value of the new attribute.
    @event changed Triggers a generic event that the attributes have been updated, with changed attributes and values.
  ###
  import: (attributes, silent = true) ->
    # Iterate over the attributes
    for key, attr of attributes
      value = @get key
      # If existing value exists and has import method then return the value of the import method
      if value?.import?
        value.import attr, silent
      else
        @set key, attr, true
        # If not silent name trigger change event to the attribute name
        if not silent then @triggerEvent "changed:#{key}"


    # If not silent then trigger changed events
    if not silent then @triggerEvent 'changed'
    return

  ###
    Export attributes, the exported attributes can be limited by an Array of attribute names. If the attribute value has
    an export method then value will be equal to the returned value.

    @param [Array<String>] limit (default = all attributes) Limit attributes to export.
    @return [Object] Exported attributes.
  ###
  export: (limit) ->
    # Set the results base type
    result = @__base()
    # If limit not passed then generate limit of all attributes
    limit ?= for key, item of @attributes then key

    isArray = result instanceof Array

    # Iterate over each key in limit
    for key, limiter of limit
      if limiter instanceof Object
        _limit = limiter.limit
        limiter = limiter.name

      nKey = Number limiter
      if isArray and not isNaN(nKey) then limiter = nKey
      value = @get limiter
      if value?
        if typeof value.export is 'function' then value = value.export _limit
        if isArray and typeof limiter is 'number' then result.push value else result[limiter] = value

    result
