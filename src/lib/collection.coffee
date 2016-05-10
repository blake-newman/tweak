###
  A Collection is an extension to the Model Class. The main difference being that there the base to the attributes is an
  Array for a Collection. As Collections' base type is an Array there is extra methods available such as; push, splice,
  slice and many more. The collection can take advantage of all the Model based methods like setters and getters. Please
  see the Model class for more information on the methods inherited to the Collection.

###
class Tweak.Collection extends Tweak.Model

  # @property [Function] The base object type ie {}, []
  __base: -> []

  ###
    Method to trigger a change event for all of the properties in the Collection
  ###
  __fullTrigger = (ctx) ->
    for key, item of ctx.attributes then ctx.triggerEvent "changed:#{key}", item
    ctx.triggerEvent 'changed', ctx.attributes

  ###
    Add a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  add: ->
    args = Array::slice.call arguments
    args.unshift @length
    @set.apply @, args

  ###
    Get an element at specified index.
    @param [Number] index Index of property to return.
    @param [Array<*>] params Additional parameters in an Array to pass to getter.
    @return [*] Returned data from the specified index.
  ###
  at: -> @get.apply @, arguments

  ###
    Push a new property to the end of the Collection.
    @param [*] data Data to add to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  push: -> @add.apply @, arguments

  ###
    Splice method that allows for event triggering on the base object.
    @param [Number] position The position to insert the property at into the Collection.
    @param [Number] remove The amount of properties to remove from the Collection.
    @param [Array<*>] data an array of data to insert into the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.
    @return [Number] The length of the Collection.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Removing four properties from the 6th position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(5, 4);

    @example Inserting two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, 0, ['100', '200']);

    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, 0, ['100', '200'], true);
  ###
  splice: (position, remove, data = [], silent = false, params = []) ->
    if remove > 0 then @remove [position..position+remove-1], true

    if silent instanceof Array
      params = silent
      silent = params ? false

    if not (data instanceof Array) then data = [data]
    for key, attr of data
      # If attribute does not exist previously then update Store's length
      @length++
      pos = Number(key)+position
      @attributes.splice pos, 0, 0
      @set pos, attr, true, params[key]

    if not silent then __fullTrigger @
    @length

  ###
    Insert values into base data at a given index (Short cut to splice method).
    @param [Number] index The index to insert the property at into the Collection.
    @param [Array<*>] data an array of data to insert into the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.
    @return [Number] The length of the Collection.

    @event changed:#{key} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Inserting two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.insert(2, ['100', '200']);

    @example Silently insert two properties from the 3rd position in the array.
      var collection;
      collection = new tweak.Collection();
      collection.splice(2, ['100', '200'], true);
  ###
  insert: (index, data, silent, params) -> @splice.call @, index, 0, data, silent, params

  ###
    Adds property to the first index of the Collection.
    @param [Array<*>] data an array of data to insert at the first index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.
    @return [Number] The length of the Collection.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  unshift: (data, silent, params) -> @splice.call @, 0, 0, data, silent, params

  ###
    Remove a property at the last index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @return [*] The property value that was popped.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Remove the last property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.pop();

    @example Silently remove the last property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.pop(true);
  ###
  pop: (silent) ->
    length = @length-1
    result = @attributes[length]
    @remove length, silent
    result

  ###
    Remove a property at the first index of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @return [*] The property value that was shifted.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Remove the first property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.shift();

    @example Silently remove the first property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.shift(true);
  ###
  shift: (silent) ->
    result = @attributes[0]
    @remove 0, silent
    result

  ###
    Reduce the collection by removing properties from the first index.
    @param [Number] length The length of the Array to shorten to.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @return [Number] The length of the Collection.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Remove the first five properties from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5);

    @example Silently remove the first five property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5, true);
  ###
  reduce: (length, silent) -> @splice.call @, 0, length, [], silent

  ###
    Reduce the collection by removing properties from the last index.
    @param [Number] length The length of the Array to shorten to.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.
    @return [Number] The length of the Collection.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Remove the first five properties from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5);

    @example Silently remove the first five property from the Collection.
      var collection;
      collection = new tweak.Collection();
      collection.reduce(5, true);
  ###
  reduceRight: (length, silent) -> @splice.call @, @length-length, length, [], silent

  ###
    Concatenate Arrays to the end of the Collection.
    @param [Array] array An Array to concatenate to the end of the Collection.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes to the data.
    @param [Array<*>] params Additional parameters in an Array to pass to setter.
    @return [Number] The length of the Collection.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.

    @example Concatenate an Array to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([1,4,6]);

    @example Silently concatenate a set of Arrays to the end of a collection.
      var collection;
      collection = new tweak.Collection();
      collection.concat([1,4,6], true);
  ###
  concat: (array, silent, params) -> @splice.call @, @length, 0, array, silent, params

  ###
    This method directly accesses the Collection's attributes's every method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/every
  ###
  every: -> @attributes.every (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's filter method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/filter
  ###
  filter: -> @attributes.filter (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's forEach method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/forEach
  ###
  forEach: -> @attributes.forEach (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's indexOf method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/indexOf
  ###
  indexOf: (val, from) -> @attributes.indexOf val, from

  ###
    This method directly accesses the Collection's attributes's join method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/join
  ###
  join: -> @attributes.join (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's lastIndexOf method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/lastIndexOf
  ###
  lastIndexOf: (val, from = @attributes.length-1) -> @attributes.lastIndexOf val, from

  ###
    This method directly accesses the Collection's attributes's map method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/map
  ###
  map: -> @attributes.map (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's reverse method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/reverse

    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  reverse: (silent) ->
    result = @attributes.reverse()
    if not silent then __fullTrigger @
    result

  ###
    This method directly accesses the Collection's attributes's slice method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/slice
  ###
  slice: (begin, end) -> @attributes.slice begin, end

  ###
    This method directly accesses the Collection's attributes's some method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/some
  ###
  some: -> @attributes.some (Array::slice.call arguments)...

  ###
    This method directly accesses the Collection's attributes's sort method.
    See: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Array/sort

    @param [Function] fn (optional) If a comparing function is present then this is passed to sort function.
    @param [Boolean] silent (optional, default = false) If true events are not triggered upon any changes.

    @event changed:#{index} Triggers an event and passes in changed property.
    @event changed Triggers a generic event that the Collection has been updated.
  ###
  sort: (fn, silent) ->
    if typeof fn is 'boolean' then [silent, fn] = [fn, silent]
    result = if fn? then @attributes.sort fn else @attributes.sort()
    if not silent then __fullTrigger @
    result
