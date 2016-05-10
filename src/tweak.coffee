###
  Tweak.js 1.0.0
  (c) 2014 Blake Newman.
  TweakJS may be freely distributed under the MIT license.
  For all details and documentation:
  http://tweakjs.com

  NOTE: This version of Tweak.js is a sub version created for Ignition as a stable code base for current projects.
  It is hosted on bitbucket.org under eframe.

  Tweak.js can be accessed globaly by tweak or Tweak. If using in node or a CommonJs then Tweak.js is not global.

  @note Assign ($, jQuery, Zepto...) to Tweak.$ for internal use. By default it will try to auto detect a value to use.
  This value can be overriden at any point.

  @note Assign module loader's require method to Tweak.require. By default it will try to auto detect a value to use;
  depending on the enviroment and module loader used you may need to overwrite this value.

  @note Assign true to Tweak.strict when you wish all components to require a related config module. By default this
  module does not need to exist however  it is recommended as it allows powerful auto generation of components and deep
  extensions.
###
class Tweak

  root = null

  ###
    This constructs Tweak with default properties. Tweak is automatically assigned to Tweak, tweak and module.exports.
  ###
  constructor: (_root, @require, @$) ->
    root = _root
    @pTweak = root.Tweak

  ###
    To extend an object with JS use Tweak.extends().
    @note This is documented as a variable but is actually a method.
    @param [Object] child The child Object to extend.
    @param [Object] parent The parent Object to inheret methods.
  ###
  extends: `extend`


  ###
    Bind a context to a method. For example with 'that' being a different context Tweak.bind(this.pullyMethod, that).
    @note This is documented as a variable but is actually a method.
    @param [Function] fn The function to bind a property to.
    @param [Context] context The context to bing to a function.
  ###
  bind: `bind`

  ###
    To super a method with JS use Tweak.super(context);. Alternativaly just do (example) Model.__super__.set(this);
    @param [Object] context The context to apply a super call to.
    @param [Obect] that Pass a context to the super call.
    @param [String] name The method name to call super upon.
  ###
  super: (context, that, name, params...) -> context.__super__[name].apply that, params

  ###
    Restore the previous stored Tweak/tweak.
  ###
  noConflict: ->
    if @pTweak then root.Tweak = @pTweak
    @

  ###
    Clone a simple Object to remove reference to original Object or simply to copy it.
    @param [Object, Array] ref Reference Object to clone.
    @return [Object, Array] Returns the copied Object, while removing references.
    @throw An error will be thrown if an object type is not supported.

    @example Cloning an Object.
      var obj, obj2;
      obj = {
        test:'test',
        total:4
      }

      // Clone the object.
      obj2 = Tweak.Clone(obj);

      // Alter the new object without adjusting other Object.
      obj2.test = null

  ###
  clone: (obj, parent) ->
    # Returns itself if doesnt exist or if the obj is the same as the parent.
    # This prevents stackoverflow if objects include themselves (like window).
    if not obj? or typeof obj isnt 'object' or obj is parent
      return obj

    # Clone Date object
    if obj instanceof Date
      return new Date obj.getTime()

    # Clone RegExp Object
    if obj instanceof RegExp
      # Recreate RegExp flags
      flags = ''
      flags += 'g' if obj.global?
      flags += 'i' if obj.ignoreCase?
      flags += 'm' if obj.multiline?
      flags += 'y' if obj.sticky?
      return new RegExp obj.source, flags

    # Recreate new Object or Array
    _new = if obj instanceof Array then [] else {}

    for key of obj when obj.hasOwnProperty key
      _new[key] = @clone obj[key], obj

    return _new


  ###
    Similar to Tweak.extends. However this will combine nested objects to make a full cobined object. This should only
    be done with simple objects; as this method can get very expensive.
    @param [Object, Array] ref Reference Object.
    @param [Object, Array] ref Object to merge into.
    @return [Object, Array] Returns the combined Object.

    @example Combining an Object.
      var obj, obj2;
      obj = {
        total:{
          laps:10,
          miles:30
        }
      }

      obj2 = {
        total:{
          miles:32
        }
      }

      // Clone the object.
      Tweak.Combine(obj);


  ###
  combine: (obj, parent) ->
    for key, prop of parent
      if typeof prop is 'object'
        obj[key] ?= if prop instanceof Array then [] else {}
        obj[key] = @combine obj[key], prop
      else
        obj[key] = prop
    obj

  ###
    @overload request(context, module, surrogate)
      Require/request a module from given context and path or return a surrogate.
      @param [String] context The context path.
      @param [String] module The module path to convert to absolute path, based on the context path.
      @param [*] surrogate (Optional) A surrogate that can be used if there is no module found.
      @return [*] Returns found module or surrogate.


    @overload request(contexts, module, surrogate)
      Try to find a module by name from multiple context paths returning the first found module. A final surrogate will be
      returned if no modules could be found.
      @param [Array<String>] paths An array of context paths.
      @param [String] module The module path to convert to absolute path; based on the context path.
      @param [*] surrogate (Optional) A surrogate that can be used if there is no module found.
      @return [*] Returns found module or surrogate.

    @throw When a module is not found and there is no surrogate an error will be thrown -
    "No module #{module name} for #{component name}".

    @example Request 'template' module from contexts of ['app/index', 'components/page']
      Tweak.request(['app/index', 'components/page'], './template');
      // Returns template module if found in any of the contexts or throws error

    @example Request 'template' module from contexts of ['app/index', 'components/page'], if not found a surrogate is used
      var sur;
      sur = {
        body:'<body></body>'
      }
      Tweak.request(['app/index', 'components/page'], './template', surr);
      // Returns template module if found or returns the surrogate
  ###
  request: (contexts, module, surrogate) ->
    if typeof contexts is 'string' then contexts = [contexts]
    else if contexts.length is 0 then contexts[0] = ''
    # Iterate each context
    for context in contexts
      try
        # Attempt to request module
        return @require tweak.toAbsolute context, module
      catch e
        # If the error thrown isn't a direct call on 'Error' Then the module was found
        # however there was an internal error in the module
        if e.name isnt 'Error'
          throw e
    # No module found - return sourrogate if supplied
    return surrogate if surrogate?
    # Throw an error as no module is found
    throw new Error "No module #{module} for #{contexts[0]}"

  # RegExp to split out the name prefix, suffix and the amount to expand by
  splitPathReg = ///
    ^           # Assert start of string
    (.*)        # Capture any character up to the next statement (prefix)
    \[          # Check for a single [ character
      (\d*)     # Greedily capture digits (min)
      (?:       # Look ahead
        [,\-]   # check for , or - character
        (\d*)   # Greedily capture digits (max)
      ){0,1}    # End look ahead - only between 0 and one times
    \]          # Check for a single ] character
    (.*)        # Capture any character up to the next statement (suffix)
    $           # Assert end of string
  ///

  ###
    Split a path formated as a 'multi-path' into individual paths.
    @param [Array<String>, String] paths 'multi-path's to format.
    @return [Array<String>] Array of paths.

    @example Names formated as './cd[2-4]'
      Tweak.splitPaths('./cd[2-4]');
      // Returns ['./cd2','./cd3','./cd4']

    @example Names formated as ['./cd[2]/model', '../what1']
      Tweak.splitPaths(['./cd[2]', '../what1']);
      // Returns ['./item0/model','./item1/model','./item2/model', '../what1']

    @example Names formated as single space delimited String './cd[2]/model ../what1'
      Tweak.splitPaths('./cd[2]/model ../what1');
      // Returns ['./item0/model','./item1/model','./item2/model', '../what1']
  ###
  splitPaths: (paths) ->
    # Split name if it is a string
    if typeof paths is 'string'
      paths = paths.split /\s+/

    results = []
    # Iterate through paths
    for path in paths
      match = splitPathReg.exec path
      # If RegExp has a match then the path needs to be expanded
      if match?
        # Deconstruct match to variables
        [path, prefix, min, max, suffix] = match
        # For each path in min to max create a single path and push it to results Array
        results.push "#{prefix}#{num}#{suffix}" for num in [(if not max? then 0 else min)..(max or min)]
      else
        # Push path to results Array
        results.push path
    # Return split paths
    results

  # RegExp to find the affix point on the relative path (./ ../ ../../ ect)
  affixReg = ///
    ^           # Assert start of String
    (           # Open capture group
      \.+       # One or more . characters
      [\/\\]+   # Zero or more / characters
    )+          # Close capture group - capture 1 or more times
  ///

  # RegExp to detirmine how many levels path should go up by (defined by ../)
  upReg = ///
    (           # Open capture group
      \.{2,}    # Two or more . characters
      [\/\\]+   # Zero or more \ or / characters
    )           # Close capture group - capture 1 or more times
  ///g

  # RegExp to detirmine if should ignore context
  rootReg = ///
    ^
    (           # Open capture group
      ~+        # one or more ~ characters
      [\/\\]+   # Zero or more \ or / characters
    )           # Close capture group - capture 1 or more times
  ///

  # RegExp to find duplicate / or \ characters
  slashReg = /[\/\\]+/g

  ###
    Convert a relative path to an absolute path; relative path defined by ./ or .\ It will also
    navigate up per defined ../.
    @param [String] context The path to navigate to find absolute path based on given relative path.
    @param [String] relative The relative path to convert to absolute path.
    @return [String] Absolute path based upon the given context and relative path.


    @example Create absolute path from context of "albums/cds/songs"  with a path of '../cd1'
      Tweak.toAbsolute('albums/cds/songs', '../cd1');
      // Returns 'albums/cds/cd1'

    @example Create absolute path from context of "album1/cd1"  with a path of './beautiful'
      Tweak.toAbsolute('album1/cd1', './beautiful');
      // Returns 'album1/cd1/beautiful'
  ###
  toAbsolute: (context, relative) ->
    relative = relative.replace slashReg, '/'
    context = context.replace slashReg, '/'

    if relative.match rootReg then return relative.replace(rootReg, '').replace affixReg, ''

    # The amount or directories/paths to go up by
    amount = relative.match(upReg)?.length or 0

    # RegExp to reduce the context path
    reduceReg = ///
      (             # Open capture group
        [\/\\]*     # Zero or more \ or / characters
        [^\/\\]+    # One or more characters that are not \ or /
      ){#{amount}}  # Close capture group - capture x amount of times
      [\/\\]?       # Single \ or / charater - Lazy (doesn't have to exist)
      $             # Assert end of String
    ///

    # Return the combined paths
    relative = relative.replace affixReg, "#{context.replace reduceReg, ''}/"
    relative.replace /^[\/\\]+/, ''

Tweak = do ->
  ###
    Assign root as either self, global or window.
  ###
  root = (typeof(self) is 'object' and self.self is self and self) or
  (typeof(global) is 'object' and global.global is global and global) or
  window

  if typeof(exports) isnt 'undefined'
    ###
      CommonJS and Node environment; including brunch.
      Dom manipulator assigned to $ will take piority
    ###
    for item in ['jquery', 'zepto', 'ender', '$'] when not $
      try $ = root.require item

    module?.exports = exports = new Tweak root, root.require, $ or root.$
  else
    ###
      Typical web environment.
    ###
    root.tweak = root.Tweak = new Tweak root, root.require, root.jQuery or root.Zepto or root.ender or root.$
