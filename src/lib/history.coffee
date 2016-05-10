###
  Simple cross browser history API. Upon changes to the history a change event is called. The ability to hook event
  listeners to the tweak.History API allows routes to be added accordingly, and for multiple Routers to be declared for
  better code structure.

  Examples are not exact, and will not directly represent valid code; the aim of an example is to be a rough guide. JS
  is chosen as the default language to represent Tweak.js as those using 'compile-to-languages' should have a good
  understanding of JS and be able to translate the examples to a chosen language. Support can be found through the
  community if needed. Please see our Gitter community for more help {http://gitter.im/blake-newman/TweakJS}.
###
class Tweak.History extends Tweak.Events

  usePush = true
  useHash = false

  __interval = null
  intervalRate = 50

  started = false
  root = '/'
  iframe = null
  url = null

  location = null
  history = null
  win = null

  ###
    Get the URL formatted without the hash.
    @param [Window] _win The window to retrieve hash.
    @return Normalized URL without hash.
  ###
  __getHash = (_win = win) ->
    match = _win.location.href.match /#(.*)$/
    return if match then match[1] else ''

  ###
    Get search part of url
    @return search if it matches or return empty string.
  ###
  __getSearch = ->
    match = location.href.replace(/#.*/, '').match /\?.+/
    return if match then match[0] else ''

  ###
    Get the pathname and search parameters, without the root.
    @return Normalized URL.
  ###
  __getPath = ->
    path = decodeURI "#{location.pathname}#{__getSearch()}"
    _root = root.slice 0, -1
    if not path.indexOf _root then path = path.slice _root.length
    return if path.charAt(0) is '/' then path.slice 1 else path

  ###
    Get a normalized URL.
    @param [String] URL The URL to normalize - if null then URL will be retrieved from window.location.
    @param [Boolean] force Force the returning value to be hash state.
    @return Normalized URL without trailing slashes at either side.
  ###
  __getURL = (_url, force) ->
    # If the URL is null then a URL will be retrieved from window.location
    if not _url?
      # If usePush or if to be forced to retrieve this format
      if usePush or force
        # Get the URL decoded
        _url = decodeURI "#{location.pathname}#{location.search}"
        # Get the root without trailing slash
        _root = root.replace /\/$/, ''
        # Get the URL minus the root
        if not _url.indexOf(_root) then _url = _url.slice _root.length
      else
        # Get the hash
        _url = __getHash()

    # Return URL without trailing slashes and force one at start
    _url = _url.replace /^\/{2,}/g, '/'
    if not _url.match /^\/+/ then _url ="/#{_url}"
    _url.replace /\/+$/g, ''

  ###
    Change the hash or replace the hash.
    @param [Location] _win The window object to use to set location.
    @param [String] URL The URL to replace the current hash with.
    @param [Boolean] replace Whether to replace the hash by href or to change hash directly.
  ###
  __setHash = (_win, url, replace) ->
    if iframe is _win then _win.document.open().close()
    # Some browsers require that the hash contains a leading #
    if replace
      _win.location.replace "#{location.href.replace /(javascript:|#).*$/, ''}##{url}"
    else
      _win.location.hash = "#{url}"
    return
  
  ###
    Add listeners of remove history change listeners.
    @param [String] prefix (Default = 'on') Set the prefix - 'on' or 'off'.
  ###
  __toggleListeners = (prefix = 'on') ->
    # Setup or remove event triggers for when the history updates - depending on the type of state being used.
    if usePush
      # If a pushState is available
      Tweak.$(win)[prefix] 'popstate', @changed
    else if useHash
      # If hashState is available and not using an iframe
      if not iframe
        Tweak.$(win)[prefix] 'hashchange', @changed
      # If using iframe and hash state
      else if prefix is 'on'
        __interval = setInterval @changed, intervalRate
      else
        clearInterval __interval
        document.body.removeChild iframe.frameElement
        iframe = __interval = null
    return

  ###
    Start listening to the URL changes to push back the history API if available.
    
    @param [Object] options An optional object to pass in optional arguments.
    @option options [Boolean] useHash (default = false) Specify whether to use hashState if true then pushState will be set to false.
    @option options [Boolean] forceRefresh (default = false) When set to true then pushState and hashState will not be used.
    @option options [Number] interval (default = null) When set to a number this is what the refresh rate will be when an interval has to be used to check changes to the URL.
    @option options [Boolean] silent (default = false) If set to true then an initial change event trigger will not be called.
    @option options [Window Object] window (default = window) Set the window object.
    @option options [Location Object] location (default = window.location) Set the location object.
    @option options [History Object] history (default = window.history) Set the history object.
    
    @event changed When the URL is updated a change event is fired from tweak.History.

    @example Starting the history with auto configuration.
      tweak.History.start();

    @example Starting the history with forced HashState.
      tweak.History.start({
        hashState:true
      });

    @example Starting the history with forced PushState.
      tweak.History.start({
        pushState:true
      });

    @example Starting the history with forced refresh or page.
      tweak.History.start({
        forceRefresh:true
      });

    @example Starting the history with an interval rate for the polling speed for older browsers.
      tweak.History.start({
        hashState:true,
        interval: 100
      });

    @example Starting the history silently.
      tweak.History.start({
        hashState:true,
        silent: true
      });
  ###
  start: (options = {}) ->
    # Check if tweak.History is already started
    # If started then return
    return if started
    started = true

    # Set-up window, location and history
    win = options.window or window
    location = options.location or win.location
    history = options.history or win.history

    # Set usePush and useHash based on the options passed in.
    usePush = if options.useHash then false else history?.pushState
    useHash = not usePush

    # If the page is to be refreshed on a navigation event then set both useHash and usePush to false
    if options.forceRefresh or (useHash and not ('onhashchange' of win)) then useHash = usePush = false

    # Set the interval rate for older browsers
    intervalRate = options.interval or intervalRate

    # Set the normalized root for the history to check against.
    root = ("/#{options.root or '/'}/").replace /^\/+|\/+$/g, '/'
    # Get the current URL
    url = __getURL()

    # Validate the hash state
    if useHash
      location.replace "#{root}##{__getPath()}#{__getHash()}"
    # Validate the push state
    else if usePush and __getHash() isnt ''
      @set __getHash(), replace: true

    # If the browser doesn't support hash or pushState and it isn't being forced to be refreshed
    if not usePush and not useHash and not options.forceRefresh
      # Creates a simple iframe element attaching to the body to trick IE into having a usable history
      frame = document.createElement 'iframe'
      frame.src = 'javascript:0'
      frame.style.display = 'none'
      frame.tabIndex = -1
      body = document.body
      iframe = body.insertBefore(frame, body.firstChild).contentWindow
      __setHash iframe, "##{url}", false

    __toggleListeners.call @
    if not options.silent then return @triggerEvent 'changed', url.replace /^\/+/, ''
  
  ###
   Stop tweak.History. Most likely useful for a web component that uses the history to change state,
   but if removed from page then component may want to stop the history.
  ###
  stop: ->
    __toggleListeners.call @, 'off'
    started = false

  ###
    Update the history while also updating the URL.
    
    @param [Object] options An optional object to pass in optional arguments.
    @option options [Boolean] replace (default = false) Specify whether to replace the current item in the history.
    @option options [Boolean] silent (default = true) Specify whether to allow triggering of event when setting the URL.

    @example Setting the History (updating the URL).
      tweak.History.set('/#/fake/url');

    @example Replacing the last History state (updating the URL).
      tweak.History.set('/#/fake/url', {
        replace:true
      });

    @example Setting the History (updating the URL) and calling history change event.
      tweak.History.set('/#/fake/url', {
        silent:false
      });
  ###
  set: (_url, options = {}) ->
    # If the history isn't started then return
    if not started then return
    # Set silent option to true if it is null
    options.silent ?= true
    replace = options.replace

    # Get the current URL formatted and validated
    _url = __getURL(_url) or ''

    # Get root without slash or question mark
    _root = root
    if _url is '' or _url.charAt(0) is '?'
      _root = _root.slice(0, -1) or  '/'

    # Create full URL with root
    fullUrl = "#{_root}#{_url.replace /^\/*/, ''}"

    # Strip the hash from the URL and decode
    _url = decodeURI _url.replace /#.*$/, ''

    # If the URL is the previous URL then return otherwise change current URL to current URL
    if url is _url then return
    url = _url

    # If pushState is available we can replace the current history state or add a state to the history
    if usePush
      history[if replace then 'replaceState' else 'pushState'] {}, document.title, fullUrl
    else if useHash
      # If hash is is available then update the hash
      __setHash win, _url, replace
      if iframe and _url isnt __getHash iframe
        __setHash iframe, _url, replace
    else
      # Forces refresh of page if not using push of hash state
      # Return as the page is refreshing at that point
      location.assign fullURL
      return
    # If the option not to be silent is made then send a change event
    if not options.silent then @triggerEvent 'changed', (url = _url).replace /^\/+/, ''
    return

  ###
    Check whether the URL has been changed. Triggerig change event when changes are detected

    @event changed Triggers 'changed' event when a change is detected in the History.
  ###
  changed: =>
    now = __getURL()
    old = url
    if now is old
      if iframe
        now = __getHash iframe
        @set now
      else return false
    @triggerEvent 'changed', url = now
    true

Tweak.History = new Tweak.History()