###
  Web applications often provide linkable, bookmark, shareable URLs for important locations in the application. The
  Router module provides methods for routing to events which can control the application. Traditionally it used to be
  that routers worked from hash fragments (#page/22). However, the HTML5 History API now provides standard URL formats
  (/page/22). Routers provide functionality that links applications/components/modules together through data passed
  through the URL.

  The router's routes can be formatted as a string that provides additional easy management to routing of events. Routes
  can implement splats, parameters and optional parameters. Routes can also be RegExp for more flexibility. When the
  history changes it will automatically compare routes and trigger events when matches are found; the triggered events
  will pass the data from the URL.

  @example Route with parameters
    Adding a route ':section:page' or ':section/:page' attached to the event of 'navigation', will trigger a
    'navigation' event and pass the following data with a similar HashState of '/#/5/93'.
    {
      url:'/5/93',
      data:{
        section:'5',
        page:'93'
      }
    }

  @example Route with parameters one being optional
    Adding a optional parameter route ':section?page' or ':section/?page' attached to the event of 'navigation',
    will trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5/6'.
    {
      url:'/5/6',
      data:{
        section:'5',
        page:'6'
      }
    }

    Adding a optional parameter route ':section?page' or ':section/?page' attached to the event of 'navigation',
    will trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5'.
    {
      url:'/5',
      data:{
        section:'5'
      }
    }

  @example Route with splat
    Adding a splat route ':section:page/*' or ':section/:page/*' attached to the event of 'navigation', will
    trigger a 'navigation' event and pass the following data with a similar HashState of '/#/5/6/www.example.com'.
    {
      url:'/5/6/www.example.com',
      data:{
        section:'5',
        page:'6',
        splat:'www.example.com'
      }
    }

  @example URL with query string
    When you want to use URLs that contain a query string, '/blog?id=9836384&light&reply=false', then the data
    sent back to an event will look like:
    {
      url:'/blog?id=9836384&light&reply=false',
      data:{
        blog:{
          id:9836384,
          light:'true',
          reply:'false'
        }
      }
    }

###
class Tweak.Router extends Tweak.Events
  ###
    The constructor initialises the router with default routes. It will also begin listening to Tweak.History.

    @param [object] routes (optional, default = {}) An object containing event name based keys to an Array of routes.

    @example Creating a Router with a set of predefined routes.
      var router;
      router = new tweak.Router({
        'navigation':[
          ':section/:page',
          /:website/:section/?page
        ],
        'demo':[
          ':splat/:example/*'
        ]
      });
  ###
  constructor: (@routes = {}) ->
    Tweak.History.addEvent 'changed', __changed, @

  ###
    Add a route to an event.
    @param [String] event The event name.
    @param [String, Reg-ex] route A string or Reg-ex formatted string or Reg-ex.

    @example Adding a single string formatted route to an event.
      var router;
      router = new tweak.Router();
      router.add('navigation', '/:section/:page');

    @example Adding a single Reg-ex formatted route to an event.
      var router;
      router = new tweak.Router();
      router.add('navigation', /^(*.)$/);
  ###
  add: (event, route) ->
    # If the route event exists then push route to existing event
    if @routes[event]? then @routes[event].push route
    # If route event doesn't exist create a new route event attaching the route
    else @routes[event] = [route]
    return

  ###
    @overload remove(event, route)
      Remove a single string formatted route from an event.
      @param [String] event The event name to add route to.
      @param [String] route A string formatted string. (':section/:page')

    @overload remove(event, route)
      Remove a string containing multiple string formatted routes from an event.
      @param [String] event The event name to add route to.
      @param [String] route A string containing multiple string formatted routes. (':section/:page :section/:page/*')

    @overload remove(event, route)
      Remove a single Reg-ex formatted route from an event.
      @param [String] event The event name to add route to.
      @param [Boolean] route A Reg-ex formatted route. (/^.*$/)

    @example Removing a single string formatted route from an event
      var router;
      router = new tweak.Router();
      router.remove('navigation', '/:section/:page');

    @example Removing a multiple string formatted routes from an event.
      var router;
      router = new tweak.Router();
      router.remove('navigation', '/:section/:page /:website/:section/?page');

    @example Removing a single Reg-ex formatted route from an event.
      var router;
      router = new tweak.Router();
      router.remove('navigation', /^(*.)$/);
  ###
  remove: (event, routes) ->
    routers = @routes[event]
    # Converts routes to Array if it is a string
    if typeof routes is 'string' then routes = " #{routes.replace /\s+/g, ' '} ".split ' '

    # Delete matching routes
    for key, route of routers when route is routes then delete routers[key]

    # Update event routes
    @routes[event] = routers

    # If no routes specified in parameter then remove all or if the total routes is now none.
    if routers? and (not routes? or routers.length is 0) then delete @routes[event]

    return

  ###
    Reg-ex to get parameters from a URL.
  ###
  __paramReg = /\/?[?:]([^?\/:]*)/g

  ###
    Reg-ex to escape characters for the returned Reg-ex
  ###
  __escapeReg = /[\-\\\^\[\]\s{}+.,$|#]/g

  ###
    Reg-ex to be able to retrieve the splat from end of URL
  ###
  __splatReg = /\/?(\*)$/

  ###
    Checks URL segment to see if it can extract additional data when formatted like a query string.
    @param [String] segment The URL segment to extract additional data when formatted as a query string.
    @return [Object, String] Extracted data of given segment parameter.
  ###
  __getQuery = (segment) ->
    # If query string from end of the segment exists. Query string is delimited by a ? character
    if query = /^.*\?(.+)/.exec segment
      # Get the parameters by splitting on the & character
      if params = /([^&]+)&*/.exec query[1]
        # Set the result to an Object
        result = {}
        # Get the data from the parameter
        for option in params
          if props = /(.+)[:=]+(.+)|(.+)/.exec option then result[props[3] or props[1]] = props[2] or 'true'

    # If there is no valid query string remove any ? characters
    else if segment
      result = segment.replace /\?/g, ''

    # Return the segment if no query string is found or if query string then return its data
    result

  ###
    Converts a string formatted route into its Reg-ex counterpart.
    @param [String] route The route to convert into a Reg-ex formatted route.
    @return [Reg-ex] The Reg-ex formatted route of given string formatted route.
  ###
  __toRegex = (route) ->
    # Escape the route
    route = route.replace __escapeReg, '\\$&'
    # Retrieve optional and non-optional parameters from route
    route = route.replace __paramReg, (match) ->
      # The Reg-ex equivalent to a non-optional parameter
      res = '\\/?([^\\/]*?)'
      # If the parameter is optional then wrap the Reg-ex equivalent to make it an optional Reg-ex equivalent
      if /^\/?\?/.exec match then "(?:#{res})?" else res

    # Replace the splat to its Reg-ex equivalent
    route = route.replace __splatReg, '\\/?(.*?)'
    # Return the Reg-ex equivalent
    new RegExp "^#{route}[\\/\\s]?$"

  ###
    Get the parameter keys from a string formatted route to use as the data passed to event.
    @param [String] route The string formatted route to get parameter keys from.
  ###
  __getKeys = (route) ->
    (res = route.match(__paramReg) or []).push 'splat'
    res

  ###
    When history event is made this method is called to check this Routers events to see if any route events can be triggered.
    @param [String] url A URL to check route events to.
    @event {event_name} Triggers a route event with data from URL.
  ###
  __changed = (url) ->
    # Remove trailing slashes from url
    url = url.replace /^\/+|\/+$/g, ''

    # For each route event
    for event, routes of @routes
      # For each route in the route events routes
      for route in routes
        keys = []
        # If the route is formatted as string
        if typeof route is 'string'
          # Get the keys of this string formatted route
          keys = __getKeys route
          # Get the Reg-ex equivalent of the string formatted route
          route = __toRegex route

        # Check the reg-ex to the URL
        if match = route.exec url
          # Create the data to pass into event
          res = {url, data: {}}
          match.splice 0,1
          key = 0
          for item in match
            res.data[keys[key]?.replace(/^[?:\/]*/, '') or key] = __getQuery item
            key++
          # Trigger this route event with the retrieved data from the URL
          @triggerEvent event, res

    return
