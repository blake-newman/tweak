describe 'Tweak.Events', ->
  
  Events = class Events extends Tweak.Events
  events = new Events()

  checkExists = (event) ->
    expect(events.__events[event]).toBeDefined()
    expect(events.__events[event].name).toEqual event
    expect(events.__events[event].__callbacks instanceof Array).toEqual true

  checkEvent = (name, position, context, callback, max, listen = true, calls = 0) ->
    checkExists name
    event = events.__events[name].__callbacks[position]
    expect(event.context).toEqual context
    expect(event.max).toEqual max
    expect(event.listen).toEqual listen
    expect(event.calls).toEqual calls
    expect(event.callback).toEqual callback

  it 'Should have certain methods', ->
    expect(events.findEvent).toBeDefined()
    expect(events.addEvent).toBeDefined()
    expect(events.removeEvent).toBeDefined()
    expect(events.triggerEvent).toBeDefined()
    expect(events.updateEvent).toBeDefined()
    expect(events.resetEvents).toBeDefined()

  describe 'Tweak.Events.findEvent', ->

    it 'Should create events with names delimited by space if build argument is passed', ->
      events.findEvent 'dummy/event another/event', true
      expect(events.__events).toBeDefined()
      expect(events.__events).not.toBeNull()
      checkExists 'dummy/event'
      checkExists 'another/event'


    it 'Should create events with names in Array if build argument is passed', ->
      events.findEvent ['dummy/event2', 'another/event2'], true
      checkExists 'dummy/event2'
      checkExists 'another/event2'

    it 'Should find created events with names delimited by space', ->
      found = events.findEvent 'dummy/event another/event2'
      expect(found.length).toEqual 2
      expect(found[0].name).toEqual 'dummy/event'
      expect(found[1].name).toEqual 'another/event2'

    it 'Should find created events with names in Array', ->
      found = events.findEvent ['dummy/event2', 'another/event']
      expect(found.length).toEqual 2
      expect(found[0].name).toEqual 'dummy/event2'
      expect(found[1].name).toEqual 'another/event'

    it 'Should not return events that are not found', ->
      found = events.findEvent ['dummy']
      expect(found.length).toEqual 0
  
  describe 'Tweak.Events.addEvent', ->
    beforeEach ->
      events = new Events()

    callback = ->
    callback2 = ->

    it 'Should add event with same context', ->
      events.addEvent 'dummy/event', callback
      checkEvent 'dummy/event', 0, events, callback

    it 'Should add multiple events', ->
      events.addEvent 'dummy/event dummy/event2', callback
      events.addEvent ['dummy/event3', 'dummy/event4'], callback
      checkEvent 'dummy/event', 0, events, callback
      checkEvent 'dummy/event2', 0, events, callback
      checkEvent 'dummy/event3', 0, events, callback
      checkEvent 'dummy/event4', 0, events, callback

    it 'Should add event with different context', ->
      events.addEvent 'dummy/event', callback, window
      checkEvent 'dummy/event', 0, window, callback

    it 'Should add event with maximum allowed calls', ->
      events.addEvent 'dummy/event', callback, 3
      checkEvent 'dummy/event', 0, events, callback, 3

    it 'Should allow context and max-calls arguments to be switched', ->
      events.addEvent 'dummy/event', callback, 3, window
      checkEvent 'dummy/event', 0, window, callback, 3

      events.addEvent 'dummy/event2', callback, window, 2
      checkEvent 'dummy/event2', 0, window, callback, 2

    it 'Should update event setting a new max if existing and setting event to listen', ->
      events.addEvent 'dummy/event', callback, 3
      events.__events['dummy/event'].__callbacks[0].listen = false
      checkEvent 'dummy/event', 0, events, callback, 3, false

      events.addEvent 'dummy/event', callback, 5
      checkEvent 'dummy/event', 0, events, callback, 5, true

    it 'Should create seperate events if they have diffferent callbacks', ->
      events.addEvent 'dummy/event', callback
      events.addEvent 'dummy/event', callback2, 2

      checkEvent 'dummy/event', 0, events, callback
      checkEvent 'dummy/event', 1, events, callback2, 2

    it 'Should create seperate events if they have diffferent contexts', ->
      events.addEvent 'dummy/event', callback, window
      events.addEvent 'dummy/event', callback, 2

      checkEvent 'dummy/event', 0, window, callback
      checkEvent 'dummy/event', 1, events, callback, 2

  describe 'Tweak.Events.removeEvent', ->

    callback = ->
    callback2 = ->

    beforeEach ->
      events = new Events()
      events.addEvent 'dummy/event', callback
      events.addEvent 'dummy/event', callback, window
      events.addEvent 'dummy/event', callback, window
      events.addEvent 'dummy/event', callback2

    it 'Should remove events', ->
      events.removeEvent 'dummy/event'
      expect(events.__events['dummy/event']).not.toBeDefined()

    it 'Should remove events limited to context', ->
      events.removeEvent 'dummy/event', null, window
      expect(events.__events['dummy/event'].__callbacks.length).toEqual 2

    it 'Should remove events limited callbacks', ->
      events.removeEvent 'dummy/event', callback
      expect(events.__events['dummy/event'].__callbacks.length).toEqual 1

    it 'Should remove events limited to contexts and callbacks', ->
      events.removeEvent 'dummy/event dummy/event2', callback, window
      expect(events.__events['dummy/event'].__callbacks.length).toEqual 2

  describe 'Tweak.Events.updateEvent', ->

    callback = ->
    callback2 = ->

    beforeEach ->
      events = new Events()
      events.addEvent 'dummy/event', callback
      events.addEvent 'dummy/event', callback2, window, 3
      events.addEvent 'dummy/event', callback, window, 2

    it 'Should set listening state of event', ->
      events.updateEvent 'dummy/event', {listen: false}
      checkEvent 'dummy/event', 0, events, callback, undefined, false
      checkEvent 'dummy/event', 1, window, callback2, 3, false
      events.updateEvent 'dummy/event', {listen: true}
      checkEvent 'dummy/event', 0, events, callback, undefined, true
      checkEvent 'dummy/event', 1, window, callback2, 3, true

    it 'Should reset listening state of event', ->
      # Simulate that an event had been previously called
      for item in events.__events['dummy/event'].__callbacks then item.calls = 1
      events.updateEvent 'dummy/event', {reset: true}
      checkEvent 'dummy/event', 0, events, callback, undefined, true
      checkEvent 'dummy/event', 1, window, callback2, 3, true

    it 'Should set maximum calls of event', ->
      events.updateEvent 'dummy/event', {max: 3}
      checkEvent 'dummy/event', 0, events, callback, 3, true
      checkEvent 'dummy/event', 1, window, callback2, 3, true

    it 'Should set total calls of event setting listening state if it surpasses', ->
      events.updateEvent 'dummy/event', {calls: 4}
      checkEvent 'dummy/event', 0, events, callback, undefined, true, 4
      checkEvent 'dummy/event', 1, window, callback2, 3, false, 4

    it 'Should update events limited to context', ->
      events.updateEvent 'dummy/event', {listen: false, context: window}
      checkEvent 'dummy/event', 0, events, callback, undefined, true
      checkEvent 'dummy/event', 1, window, callback2, 3, false

    it 'Should update events limited to callbacks', ->
      events.updateEvent 'dummy/event', {listen: false, callback: callback}
      checkEvent 'dummy/event', 0, events, callback, undefined, false
      checkEvent 'dummy/event', 1, window, callback2, 3, true

    it 'Should update events limited to contexts and callbacks', ->
      events.updateEvent 'dummy/event', {listen: false, context: window, callback: callback}
      checkEvent 'dummy/event', 0, events, callback, undefined, true
      checkEvent 'dummy/event', 1, window, callback2, 3, true
      checkEvent 'dummy/event', 2, window, callback, 2, false

  describe 'Tweak.Events.triggerEvent', ->
    callback = -> obj.callback()
    callback2 = -> obj.callback2()
    obj = {
      callback: ->
      callback2: ->
    }
    beforeEach ->
      events = new Events()
      events.addEvent 'dummy/event', callback
      events.addEvent 'dummy/event', callback2, window, 3
      events.addEvent 'dummy/event', callback, window, 2

      spyOn obj, 'callback'
      spyOn obj, 'callback2'


    it 'Should trigger events', (done) ->
      events.triggerEvent 'dummy/event'
      setTimeout ->
        expect(obj.callback.calls.count()).toEqual 2
        expect(obj.callback2.calls.count()).toEqual 1
        done()
      , 1

    it 'Should increase total calls', (done) ->
      events.triggerEvent 'dummy/event'
      setTimeout ->
        checkEvent 'dummy/event', 0, events, callback, undefined, true, 1
        checkEvent 'dummy/event', 1, window, callback2, 3, true, 1
        checkEvent 'dummy/event', 2, window, callback, 2, true, 1
        done()
      , 1

    it 'Should allow context limiter provided in options format', (done) ->
      events.triggerEvent {names: 'dummy/event', context: events}

      setTimeout ->
        expect(obj.callback.calls.count()).toEqual 1
        expect(obj.callback2.calls.count()).toEqual 0
        checkEvent 'dummy/event', 0, events, callback, undefined, true, 1
        checkEvent 'dummy/event', 1, window, callback2, 3, true, 0
        checkEvent 'dummy/event', 2, window, callback, 2, true, 0
        done()
      , 1

    it 'Should not trigger event if maximum calls have been reached while turning of listening state', (done) ->
      events.triggerEvent {names: 'dummy/event', context: window}
      events.triggerEvent {names: 'dummy/event', context: window}
      events.triggerEvent {names: 'dummy/event', context: window}

      setTimeout ->
        expect(obj.callback.calls.count()).toEqual 2
        expect(obj.callback2.calls.count()).toEqual 3
        checkEvent 'dummy/event', 0, events, callback, undefined, true, 0
        checkEvent 'dummy/event', 1, window, callback2, 3, false, 3
        checkEvent 'dummy/event', 2, window, callback, 2, false, 2
        done()
      , 1

    it 'Should not trigger event if listening state is off', (done) ->
      # Simulate listening state to be turned off
      for item in events.__events['dummy/event'].__callbacks then item.listen = false
      events.triggerEvent names: 'dummy/event'
      setTimeout ->
        expect(obj.callback.calls.count()).toEqual 0
        expect(obj.callback2.calls.count()).toEqual 0
        checkEvent 'dummy/event', 0, events, callback, undefined, false, 0
        checkEvent 'dummy/event', 1, window, callback2, 3, false, 0
        checkEvent 'dummy/event', 2, window, callback, 2, false, 0
        done()
      , 1

  describe 'Tweak.Events.resetEvents', ->

    it 'Should reset events', ->
      events.resetEvents()
      i = 0
      for key, item of events.__events then i++
      expect(i).toEqual 0
  