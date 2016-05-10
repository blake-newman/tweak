describe 'Tweak.Model', ->

  Model = class Model extends Tweak.Model
  model = new Model()

  it 'Should have event methods/properties', ->
    expect(model.findEvent).toBeDefined()
    expect(model.addEvent).toBeDefined()
    expect(model.removeEvent).toBeDefined()
    expect(model.triggerEvent).toBeDefined()
    expect(model.updateEvent).toBeDefined()
    expect(model.resetEvents).toBeDefined()

  it 'Should have inherit methods/properties', ->
    expect(model.__base).toBeDefined()
    expect(model.length).toBeDefined()
    expect(model.attributes).toBeDefined()
    expect(model.init).toBeDefined()
    expect(model.set).toBeDefined()
    expect(model.get).toBeDefined()
    expect(model.remove).toBeDefined()
    expect(model.has).toBeDefined()
    expect(model.same).toBeDefined()
    expect(model.toLocaleString).toBeDefined()
    expect(model.toString).toBeDefined()
    expect(model.where).toBeDefined()
    expect(model.reset).toBeDefined()
    expect(model.import).toBeDefined()
    expect(model.export).toBeDefined()

  describe 'Tweak.Model.__base', ->
    
    it 'Should return a base of an empty Object', ->
      expect(model.__base()).toEqual {}

  describe 'Tweak.Model.length', ->

    it 'Should be instance of a Number', ->
      expect(typeof model.length).toEqual 'number'

  describe 'Tweak.Model.attributes', ->

    it 'Should return a base of an empty Object when no data passed to constructor', ->
      expect(model.attributes).toEqual {}

    it 'Should return an Object when data passed to constructor', ->
      model = new Model {test:true}
      expect(model.attributes).toEqual {test:true}

  describe 'Tweak.Model.init', ->

    it 'Should be a function', ->
      expect(typeof model.init).toEqual 'function'

  describe 'Tweak.Model.set', ->

    it 'Should set a single attribute', ->
      model.set 'dummy', 50
      expect(model.attributes.dummy).toEqual 50

    it 'Should set multiple attributes', ->

      model.set {dummy: 60, val: '80'}
      expect(model.attributes.dummy).toEqual 60
      expect(model.attributes.val).toEqual '80'
    
    it 'Should use a setters returned value', ->
      model.setter_prop = (setTo) ->
        expect(setTo).toEqual 100
        50
      model.set 'prop', 100
      expect(model.attributes.prop).toEqual 50
    
    it 'Should pass parameters to setters', ->
      model.setter_prop = (setTo, args...) ->
        expect(setTo).toEqual 100
        expect(args.length > 0).toEqual true
        50
      model.set 'prop', 100, false, [20]
      model.set 'prop', 100, false, [20, 30, 40]
      model.set {prop:100, dummy:50}, false, [[20, 30, 40], []]
      model.set {dummy:50, prop:100}, false, [[], [20]]
      expect(model.attributes.prop).toEqual 50
    
    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks = {
      fn1: ->
      fn2: ->
    }

    it 'Should trigger a changed events', (done) ->
      model = new Model()
      model.addEvent 'changed:dummy', fn1
      model.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      model.set 'dummy', 100
      model.set {'dummy': 100}
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 2
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

    it 'Should not trigger events when setting silently', (done) ->
      model = new Model()
      model.addEvent 'changed:dummy', fn1
      model.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      model.set 'dummy', 100, true
      model.set {'dummy': 100}, true
      setTimeout ->
        expect(callbacks.fn1).not.toHaveBeenCalled()
        expect(callbacks.fn2).not.toHaveBeenCalled()
        done()
      , 1

    it 'Should return new length of model attributes', ->
      model = new Model {dummy: true}

      expect(model.length).toEqual 1
      model.set 'face', 2
      expect(model.length).toEqual 2
      model.set 'face', 3
      expect(model.length).toEqual 2
      model.set {face: 3, dummy: false, prop: 90, val: 100}
      expect(model.length).toEqual 4

  describe 'Tweak.Model.get', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0'}

    it 'Should get a single attribute', ->
      expect(model.get 'dummy').toEqual true
      expect(model.get 'prop').toEqual 10

    it 'Should get multiple attributes limited by Array attribute names', ->
      expect(model.get ['dummy', 'val']).toEqual {dummy: true, val: '0'}

    it 'Should use the value of getter if available', ->
      model.getter_val = (previous) ->
        expect(previous).toEqual '0'
        10
      expect(model.get 'val').toEqual 10
      expect(model.get ['val']).toEqual 10


    it 'Should pass additional parameters to getters', ->
      model.getter_prop = (previous, args...) ->
        expect(previous).toEqual 10
        expect(args.length > 0).toEqual true
        50
      model.get 'prop', [20]
      model.get 'prop', [20, 30, 40]
      model.get ['prop', 'dummy'], [[20, 30, 40], []]
      model.get {'dummy', 'prop'}, false, [[], [20]]

    it 'Should return undefined if not an attribute', ->
      expect(model.get 'here').not.toBeDefined()
      expect(model.get ['here', 'dummy']).toEqual {here: undefined, dummy: true}

  describe 'Tweak.Model.remove', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0'}

    it 'Should remove a single attribute', ->
      model.remove 'dummy'
      expect(model.attributes.dummy).not.toBeDefined()
      expect(model.attributes.prop).toEqual 10
      expect(model.attributes.val).toEqual '0'


    it 'Should remove multiple attributes limited by Array of attribute names', ->
      model.remove ['dummy', 'val']
      expect(model.attributes.dummy).not.toBeDefined()
      expect(model.attributes.val).not.toBeDefined()
      expect(model.attributes.prop).toEqual 10

    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks = {
      fn1: ->
      fn2: ->
    }

    it 'Should trigger a changed events', (done) ->
      model.addEvent 'changed:dummy', fn1
      model.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      model.remove 'dummy'
      model.remove ['prop', 'val']
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

    it 'Should not trigger changed events if removing silently', (done) ->
      model.addEvent 'changed:dummy', fn1
      model.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      model.remove 'dummy', true
      model.remove ['prop', 'val'], true
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 0
        expect(callbacks.fn2.calls.count()).toEqual 0
        done()
      , 1

    it 'Should not trigger individual change event if removing non existent property', (done) ->
      model.addEvent 'changed:fake', fn1
      model.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      model.remove 'fake'
      model.remove ['fake', 'another_fake', 'prop']
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 0
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

    it 'Should return the new length of model', ->
      expect(model.remove 'fake').toEqual 3
      expect(model.remove 'dummy').toEqual 2
      expect(model.remove ['fake', 'dummy', 'val', 'prop']).toEqual 0

  describe 'Tweak.Model.has', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0'}

    it 'Should return the existence of properties', ->
      expect(model.has 'dummy').toEqual true
      expect(model.has 'pizza').toEqual false
      expect(model.has ['pizza', 'dummy']).toEqual false
      expect(model.has ['val', 'dummy']).toEqual true
      model.getter_pizza = -> true
      model.getter_prop = -> undefined
      expect(model.has ['pizza', 'dummy']).toEqual true
      expect(model.has ['prop', 'dummy']).toEqual false

  describe 'Tweak.Model.same', ->

    beforeEach ->
      model = new Model {dummy: 2, val: false}

    it 'Should return whether two simple Objects are the same (similar)', ->
      obj1 = {dummy: 2, val: false}
      obj2 = {dummy: 2, val: false}
      obj3 = {dummy: 3, val: false}
      obj4 = {dummy: 2, val: false, prop: 5}
      expect(model.same obj1, obj2).toEqual true
      expect(model.same obj2, obj3).toEqual false
      expect(model.same obj2, obj4).toEqual false
      expect(model.same obj4, obj2).toEqual false
      expect(model.same obj1).toEqual true
      expect(model.same obj2).toEqual true

  describe 'Tweak.Model.toLocalString', ->

    beforeEach ->
      model = new Model {dummy: 2, val: false}

    it 'Should return [object Object]', ->
      expect(model.toLocaleString()).toEqual '[object Object]'


  describe 'Tweak.Model.toString', ->

    beforeEach ->
      model = new Model {dummy: 2, val: false}

    it 'Should return [object Object]', ->
      expect(model.toString()).toEqual '[object Object]'


  describe 'Tweak.Model.where', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0', extra: 10}

    it 'Should return an Array of attribute names where the value given is the same', ->
      expect(model.where '0').toEqual ['val']
      expect(model.where 10).toEqual ['prop', 'extra']

  describe 'Tweak.Model.reset', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0', extra: 10}

    fn1 = -> callbacks.fn1()
    callbacks = {
      fn1: ->
    }

    it 'Should reset the Model', (done) ->
      model.addEvent 'changed', fn1
      spyOn callbacks, 'fn1'
      model.reset()
      expect(model.length).toEqual 0
      expect(model.attributes).toEqual {}
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Model.import', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0'}

    it 'Should import data from simple Object', ->
      model.import {dummy: false, prop: 20, extra: 10}
      expect(model.attributes).toEqual {dummy: false, prop: 20, val: '0', extra: 10}
    
    it 'Should import data into attribute value if the value has an import method', ->
      model.attributes['nested'] = new Model {val: 50}

      model.import {dummy: false, prop: 20, extra: 10, nested: {val: 100}}
      expect(model.attributes).toEqual {dummy: false, prop: 20, val: '0', extra: 10, nested: model.attributes.nested}
      expect(model.attributes.nested.attributes).toEqual {val: 100}

  describe 'Tweak.Model.export', ->

    beforeEach ->
      model = new Model {dummy: true, prop: 10, val: '0'}
    
    it 'Should export data from Model', ->
      expect(model.export()).toEqual model.attributes

    it 'Should export data from Model where exported data is limited to an Array of attribute names', ->
      expect(model.export ['dummy', 'prop']).toEqual {dummy: true, prop: 10}
      expect(model.export ['dummy', 'prop', 'fake']).toEqual {dummy: true, prop: 10}
   
    it 'Should export data when it contains attributes that are an instance of a Model', ->
      model.attributes.nested = new Model {val: 100}
      expect(model.export ['dummy', 'nested']).toEqual {dummy: true, nested: {val: 100}}
      expect(model.export ['dummy', {name: 'nested'}]).toEqual {dummy: true, nested: {val: 100}}
      expect(model.export ['dummy', {name: 'nested', limit: ['val']}]).toEqual {dummy: true, nested: {val: 100}}
      expect(model.export ['dummy', {name: 'nested', limit: ['val', 'fake']}]).toEqual {dummy: true, nested: {val: 100}}
   