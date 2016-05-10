describe 'Tweak.Collection', ->

  Collection = class Collection extends Tweak.Collection
  collection = new Collection()

  it 'Should have event methods/properties', ->
    expect(collection.findEvent).toBeDefined()
    expect(collection.addEvent).toBeDefined()
    expect(collection.removeEvent).toBeDefined()
    expect(collection.triggerEvent).toBeDefined()
    expect(collection.updateEvent).toBeDefined()
    expect(collection.resetEvents).toBeDefined()

  it 'Should have model methods/properties', ->
    expect(collection.__base).toBeDefined()
    expect(collection.length).toBeDefined()
    expect(collection.attributes).toBeDefined()
    expect(collection.init).toBeDefined()
    expect(collection.set).toBeDefined()
    expect(collection.get).toBeDefined()
    expect(collection.remove).toBeDefined()
    expect(collection.has).toBeDefined()
    expect(collection.same).toBeDefined()
    expect(collection.toLocaleString).toBeDefined()
    expect(collection.toString).toBeDefined()
    expect(collection.where).toBeDefined()
    expect(collection.reset).toBeDefined()
    expect(collection.import).toBeDefined()
    expect(collection.export).toBeDefined()

  it 'Should have certain methods/properties', ->
    expect(collection.add).toBeDefined()
    expect(collection.at).toBeDefined()
    expect(collection.push).toBeDefined()
    expect(collection.splice).toBeDefined()
    expect(collection.insert).toBeDefined()
    expect(collection.unshift).toBeDefined()
    expect(collection.pop).toBeDefined()
    expect(collection.shift).toBeDefined()
    expect(collection.reduce).toBeDefined()
    expect(collection.reduceRight).toBeDefined()
    expect(collection.concat).toBeDefined()
    expect(collection.every).toBeDefined()
    expect(collection.filter).toBeDefined()
    expect(collection.forEach).toBeDefined()
    expect(collection.join).toBeDefined()
    expect(collection.map).toBeDefined()
    expect(collection.reverse).toBeDefined()
    expect(collection.slice).toBeDefined()
    expect(collection.some).toBeDefined()
    expect(collection.sort).toBeDefined()


  describe 'Tweak.Collection.__base', ->
    
    it 'Should return a base of an empty Array', ->
      expect(collection.__base()).toEqual []

  describe 'Tweak.Collection.length', ->

    it 'Should be instance of a Number', ->
      expect(typeof collection.length).toEqual 'number'

  describe 'Tweak.Collection.attributes', ->

    it 'Should return a base of an empty Array when no data passed to constructor', ->
      expect(collection.attributes).toEqual []

    it 'Should return an Array when data passed to constructor', ->
      collection = new Collection [true]
      expect(collection.attributes).toEqual [true]

  describe 'Tweak.Collection.init', ->

    it 'Should be a function', ->
      expect(typeof collection.init).toEqual 'function'

  describe 'Tweak.Collection.set', ->

    beforeEach ->
      collection = new Collection()

    it 'Should set a single attribute', ->
      collection.set 0, 50
      expect(collection.attributes[0]).toEqual 50

    it 'Should set multiple attributes', ->
      collection.set [50, 100]
      expect(collection.attributes[0]).toEqual 50
      expect(collection.attributes[1]).toEqual 100
    
    it 'Should use a setters returned value', ->
      collection.setter_0 = (setTo) ->
        expect(setTo).toEqual 100
        50
      collection.set 0, 100
      expect(collection.attributes[0]).toEqual 50
    
    it 'Should pass parameters to setters', ->
      collection.setter_0 = (setTo, args...) ->
        expect(setTo).toEqual 100
        expect(args.length > 0).toEqual true
        50
      collection.set 0, 100, false, [20]
      collection.set 0, 100, false, [20, 30, 40]
      collection.set [100, 50], false, [[20, 30, 40], []]
      expect(collection.attributes[0]).toEqual 50
    
    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks = {
      fn1: ->
      fn2: ->
    }

    it 'Should trigger a changed events', (done) ->
      collection = new Collection()
      collection.addEvent 'changed:0', fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.set 0, 100
      collection.set [100]
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 2
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

    it 'Should not trigger events when setting silently', (done) ->
      collection = new Collection()
      collection.addEvent 'changed:dummy', fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.set 0, 100, true
      collection.set [100], true
      setTimeout ->
        expect(callbacks.fn1).not.toHaveBeenCalled()
        expect(callbacks.fn2).not.toHaveBeenCalled()
        done()
      , 1

    it 'Should return new length of attributes', ->
      expect(collection.length).toEqual 0
      collection.set 0, 2
      expect(collection.length).toEqual 1
      collection.set 0, 3
      expect(collection.length).toEqual 1
      collection.set [3, 'prop', true, false]
      expect(collection.length).toEqual 4
      data = []
      data[5] = 3
      data[7] = 5
      collection.set data
      expect(collection.length).toEqual 6

  describe 'Tweak.Collection.get', ->

    beforeEach ->
      collection = new Collection [30, 40, 50]

    it 'Should get a single attribute', ->
      expect(collection.get 0).toEqual 30
      expect(collection.get 2).toEqual 50

    it 'Should get multiple attributes limited by Array attribute names', ->
      expect(collection.get [0, 2]).toEqual [30, 50]
      expect(collection.get [2, 0]).toEqual [50, 30]

    it 'Should use the value of getter if available', ->
      collection.getter_0 = (previous) ->
        expect(previous).toEqual 30
        10
      expect(collection.get 0).toEqual 10
      expect(collection.get [0, 1]).toEqual [10, 40]


    it 'Should pass additional parameters to getters', ->
      collection.getter_0 = (previous, args...) ->
        expect(previous).toEqual 30
        expect(args.length > 0).toEqual true
        50
      collection.get 0, [20]
      collection.get 0, [20, 30, 40]
      collection.get [0, 2], [[20, 30, 40], []]
      collection.get [2, 0], [[], [20]]

    it 'Should return undefined if not an attribute', ->
      expect(collection.get [5]).not.toBeDefined()
      expect(collection.get [5, 0]).toEqual [undefined, 30]

  describe 'Tweak.Collection.remove', ->

    beforeEach ->
      collection = new Collection [30, 40, 50]

    it 'Should remove a single attribute', ->
      collection.remove 1
      expect(collection.attributes[0]).toEqual 30
      expect(collection.attributes[1]).toEqual 50
      expect(collection.length).toEqual 2

    it 'Should remove multiple attributes limited by Array of attribute names', ->
      collection.remove [0, 2]
      expect(collection.attributes[0]).toEqual 40
      expect(collection.length).toEqual 1

      collection = new Collection [30, 40, 50]
      collection.remove [7, 50, 1]
      expect(collection.attributes[0]).toEqual 30
      expect(collection.attributes[1]).toEqual 50
      expect(collection.length).toEqual 2



    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks = {
      fn1: ->
      fn2: ->
    }

    it 'Should trigger changed events', (done) ->
      collection.addEvent 'changed:0', fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.remove [0, 2]
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

    it 'Should not trigger changed events if removing silently', (done) ->
      collection.addEvent 'changed:dummy', fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.remove 'dummy', true
      collection.remove ['prop', 'val'], true
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 0
        expect(callbacks.fn2.calls.count()).toEqual 0
        done()
      , 1

    it 'Should not trigger individual change event if removing non existent property', (done) ->
      collection.addEvent 'changed:5', fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.remove 5
      collection.remove [5, 6, 0]
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 0
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

    it 'Should return the new length of collection', ->
      expect(collection.remove 2).toEqual 2
      expect(collection.remove 2).toEqual 2
      expect(collection.remove [3, 0, 1]).toEqual 0

  describe 'Tweak.Collection.has', ->

    beforeEach ->
      collection = new Collection [20, 30, 40]

    it 'Should return the existence of properties', ->
      expect(collection.has 1).toEqual true
      expect(collection.has 5).toEqual false
      expect(collection.has [1, 5]).toEqual false
      expect(collection.has [0, 1]).toEqual true
      collection.getter_3 = -> true
      collection.getter_1 = -> undefined
      expect(collection.has [3, 0]).toEqual true
      expect(collection.has [3, 1]).toEqual false

  describe 'Tweak.Collection.same', ->

    it 'Should return whether two simple Objects are the same (similar)', ->
      arr1 = [50, '30']
      arr2 = [50, '30']
      arr3 = [30, '50']
      arr4 = [30, '50', 20]
      expect(collection.same arr1, arr2).toEqual true
      expect(collection.same arr2, arr3).toEqual false
      expect(collection.same arr3, arr4).toEqual false
      expect(collection.same arr4, arr3).toEqual false

  describe 'Tweak.Model.toLocalString', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'Should return stringified array', ->
      expect(collection.toLocaleString()).toEqual '10,20,30'

  describe 'Tweak.Model.toString', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'Should return stringified array', ->
      expect(collection.toString()).toEqual '10,20,30'

  describe 'Tweak.Collection.where', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should return an Array of attribute names where the value given is the same', ->
      expect(collection.where 20).toEqual ['0']
      expect(collection.where 40).toEqual ['2', '3']

  describe 'Tweak.Collection.add', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should add an element at the last index', ->
      collection.add 200
      expect(collection.attributes).toEqual [20, 30, 40, 40, 200]

  describe 'Tweak.Collection.at', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should point to Tweak.Model.get', ->
      spyOn collection, 'get'
      collection.at()
      expect(collection.get).toHaveBeenCalled()
      collection.at 1, true, ['test']
      expect(collection.get).toHaveBeenCalledWith 1, true, ['test']

  describe 'Tweak.Collection.push', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should point to Tweak.Collection.add', ->
      spyOn collection, 'add'
      collection.push()
      expect(collection.add).toHaveBeenCalled()
      collection.push 100, true, ['test']
      expect(collection.add).toHaveBeenCalledWith 100, true, ['test']

  describe 'Tweak.Collection.splice', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

     it 'Should remove from start', ->
      collection.splice 0, 2
      expect(collection.length).toEqual 2
      expect(collection.attributes).toEqual [40, 40]

    it 'Should remove from middle', ->
      collection.splice 1, 2
      expect(collection.length).toEqual 2
      expect(collection.attributes).toEqual [20, 40]

    it 'Should remove from end', ->
      collection.splice 2, 2
      expect(collection.length).toEqual 2
      expect(collection.attributes).toEqual [20, 30]

    it 'Should insert single attribute', ->
      collection.splice 0, 0, 10
      expect(collection.length).toEqual 5
      expect(collection.attributes).toEqual [10, 20, 30, 40, 40]

    it 'Should insert into attributes from start', ->
      collection.splice 0, 0, [0, 10]
      expect(collection.length).toEqual 6
      expect(collection.attributes).toEqual [0, 10, 20, 30, 40, 40]

    it 'Should insert into attributes at middle', ->
      collection.splice 2, 0, [0, 10]
      expect(collection.length).toEqual 6
      expect(collection.attributes).toEqual [20, 30, 0, 10, 40, 40]

    it 'Should insert into attributes at end', ->
      collection.splice 4, 0, [0, 10]
      expect(collection.length).toEqual 6
      expect(collection.attributes).toEqual [20, 30, 40, 40, 0, 10]

    it 'Should insert into attributes from start while removing attributes', ->
      collection.splice 0, 2, [0, 10]
      expect(collection.length).toEqual 4
      expect(collection.attributes).toEqual [0, 10, 40, 40]

    it 'Should insert into attributes at middle while removing attributes', ->
      collection.splice 2, 2, [0, 10]
      expect(collection.length).toEqual 4
      expect(collection.attributes).toEqual [20, 30, 0, 10]

    it 'Should pass parameters to .set', ->
      spyOn collection, 'set'
      collection.splice 2, 2, [0, 10], [[50], [60]]

      expect(collection.set).toHaveBeenCalledWith 2, 0, true, [50]
      expect(collection.set).toHaveBeenCalledWith 3, 10, true, [60]

    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks = {
      fn1: ->
      fn2: ->
    }
    it 'Should trigger change events accross the whole of the attributes', (done) ->
      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
        'changed:5'
      ], fn1
      collection.addEvent 'changed', fn2
      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'
      collection.splice 0, 0, [0, 2]
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 6
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.insert', ->

    beforeEach ->
      collection = new Collection [10, 50]

    it 'Should insert data at a given index',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
        'changed:5'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      collection.insert 1, [20, 30]
      expect(collection.attributes).toEqual [10,20,30,50]
      collection.insert 3, 40, true
      expect(collection.attributes).toEqual [10,20,30,40,50]
      collection.insert 5, 60
      expect(collection.attributes).toEqual [10,20,30,40,50,60]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 10
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

  describe 'Tweak.Collection.unshift', ->
    beforeEach ->
      collection = new Collection [50, 60]

    it 'Should insert data at beginning of attributes',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
        'changed:5'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      collection.unshift [30, 40]
      expect(collection.attributes).toEqual [30,40,50,60]
      collection.unshift 20
      expect(collection.attributes).toEqual [20,30,40,50,60]
      collection.unshift 10, true
      expect(collection.attributes).toEqual [10,20,30,40,50,60]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 9
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1

  describe 'Tweak.Collection.pop', ->

    beforeEach ->
      collection = new Collection [10, 20, 30, 90, 200]

    it 'Should pop the last item of attributes',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.pop()).toEqual 200
      expect(collection.attributes).toEqual [10,20,30, 90]
      expect(collection.pop true).toEqual 90
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 4
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.shift', ->

    beforeEach ->
      collection = new Collection [-10, 0, 10, 20, 30]

    it 'Should shift the first item at beginning of attributes',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.shift()).toEqual -10
      expect(collection.attributes).toEqual [0,10,20,30]
      expect(collection.shift true).toEqual 0
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 4
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.reduce', ->
    beforeEach ->
      collection = new Collection [-30, -20, -10, 0, 10, 20, 30]

    it 'Should reduce the Array from the left',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
        'changed:5'
        'changed:6'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.reduce 2).toEqual 5
      expect(collection.attributes).toEqual [-10,0,10,20,30]
      expect(collection.reduce 2, true).toEqual 3
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 5
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.reduceRight', ->

    beforeEach ->
      collection = new Collection [10, 20, 30, 50, 90, 0]

    it 'Should reduce the Array from the right',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
        'changed:4'
        'changed:5'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.reduceRight 2).toEqual 4
      expect(collection.attributes).toEqual [10,20,30,50]
      expect(collection.reduceRight 1, true).toEqual 3
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 4
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.concat', ->

    beforeEach ->
      collection = new Collection

    it 'Should concatenate Array to end of attributes',  (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
      ], fn1
      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.concat [10]).toEqual 1
      expect(collection.attributes).toEqual [10]
      expect(collection.concat [20, 30], true).toEqual 3
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.every', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'It should check that all element pass a test implemeted through a function', ->
      ctx = @
      count = 0
      work = -> true
      broken = -> false
      partial = (val, index) ->
        expect(index).toEqual count++
        expect(@).toEqual ctx
        if val is 30 then true else false
      
      expect(collection.every work).toEqual true
      expect(collection.every broken).toEqual false
      expect(collection.every partial, ctx).toEqual false

  describe 'Tweak.Collection.filter', ->

    beforeEach ->
      collection = new Collection [0, 10, 20, 30, 40, 50]

    it 'It should return an Array of element where element passes a test function', ->
      ctx = @
      count = 0
      all = -> true
      none = -> false
      partial = (val, index) ->
        expect(index).toEqual count++
        expect(@).toEqual ctx
        switch val
          when 10, 20, 30 then true
          else false
      
      expect(collection.filter all).toEqual collection.attributes
      expect(collection.filter none).toEqual []
      expect(collection.filter partial, ctx).toEqual [10, 20, 30]

  describe 'Tweak.Collection.forEach', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'It should execute a function across all atrtibutes', ->
      ctx = @
      fn = (val, index, arr) ->
        expect(arr).toEqual collection.attributes
        expect(@).toEqual ctx
        expect(val).toEqual collection.attributes[index]
    
      collection.forEach fn, ctx

  describe 'Tweak.Collection.indexOf', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should get the index where a value is found', ->
      expect(collection.indexOf 40).toEqual 2
      expect(collection.indexOf 40, 2).toEqual 2
      expect(collection.indexOf 40, 3).toEqual 3

  describe 'Tweak.Collection.join', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'Should return joined attributes', ->

      expect(collection.join()).toEqual '10,20,30'
      expect(collection.join '-').toEqual '10-20-30'

  describe 'Tweak.Collection.lastIndexOf', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 40]

    it 'Should get the last index where a value is found', ->
      expect(collection.lastIndexOf 30).toEqual 1
      expect(collection.lastIndexOf 40).toEqual 3
      expect(collection.lastIndexOf 40, 2).toEqual 2

  describe 'Tweak.Collection.map', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'It should execute a function across all atrtibutes mapping the returned values to a new Array', ->
      ctx = @
      half = (val, index, arr) ->
        expect(arr).toEqual collection.attributes
        expect(@).toEqual ctx
        expect(val).toEqual collection.attributes[index]
        val/2
    
      expect(collection.map half, ctx).toEqual [5, 10, 15]

  describe 'Tweak.Collection.reverse', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'Should reverse attributes', (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
      ], fn1

      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      expect(collection.reverse()).toEqual [30,20,10]
      expect(collection.attributes).toEqual [30,20,10]
      expect(collection.reverse true).toEqual [10,20,30]
      expect(collection.attributes).toEqual [10,20,30]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 3
        expect(callbacks.fn2.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.slice', ->

    beforeEach ->
      collection = new Collection [0, 10, 20, 30, 40]

    it 'Shoud return a shallow copy in specified range from attributes', ->
      expect(collection.slice 0, collection.length).toEqual collection.attributes
      expect(collection.slice 0, collection.length-1).toEqual [0, 10, 20, 30]
      expect(collection.slice 1, collection.length-1).toEqual [10, 20, 30]

  describe 'Tweak.Collection.some', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    it 'It should check that all element pass a test implemeted through a function', ->
      ctx = @
      count = 0
      work = -> true
      broken = -> false
      partial = (val, index) ->
        expect(index).toEqual count++
        expect(@).toEqual ctx
        if val is 20 then true else false
      
      expect(collection.some work).toEqual true
      expect(collection.some broken).toEqual false
      expect(collection.some partial, ctx).toEqual true

  describe 'Tweak.Collection.sort', ->

    beforeEach ->
      collection = new Collection [20, 10, 40, 30]


    it 'Should sort the attributes', (done) ->
      fn1 = -> callbacks.fn1()
      fn2 = -> callbacks.fn2()
      callbacks = {
        fn1: ->
        fn2: ->
      }

      collection.addEvent [
        'changed:0'
        'changed:1'
        'changed:2'
        'changed:3'
      ], fn1

      collection.addEvent 'changed', fn2

      spyOn callbacks, 'fn1'
      spyOn callbacks, 'fn2'

      descFn = (a, b) -> b-a

      expect(collection.sort()).toEqual [10,20,30,40]

      collection.attributes = [20, 10, 40, 30]
      expect(collection.sort true).toEqual [10,20,30,40]


      collection.attributes = [20, 10, 40, 30]
      expect(collection.sort descFn).toEqual [40,30,20,10]


      collection.attributes = [20, 10, 40, 30]
      expect(collection.sort descFn, true).toEqual [40,30,20,10]

      collection.attributes = [20, 10, 40, 30]
      expect(collection.sort true, descFn).toEqual [40,30,20,10]

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 8
        expect(callbacks.fn2.calls.count()).toEqual 2
        done()
      , 1


  describe 'Tweak.Collection.reset', ->

    beforeEach ->
      collection = new Collection [10, 20, 30]

    fn1 = -> callbacks.fn1()
    callbacks = {
      fn1: ->
    }

    it 'Should reset the Collection', (done) ->
      collection.addEvent 'changed', fn1
      spyOn callbacks, 'fn1'
      collection.reset()
      expect(collection.length).toEqual 0
      expect(collection.attributes).toEqual []
      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        done()
      , 1

  describe 'Tweak.Collection.import', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 50]

    it 'Should import data from simple Object', ->
      collection.import [30, 40, 50, 60]
      expect(collection.attributes).toEqual [30, 40, 50, 60]
    
    it 'Should import data into attribute value if the value has an import method', ->
      collection.attributes[2] = new Collection [10, 80]
      collection.import [30, 40, [20, 70, 90], 60]
      expect(collection.attributes).toEqual [30, 40, collection.attributes[2], 60]
      expect(collection.attributes[2].attributes).toEqual [20, 70, 90]

  describe 'Tweak.Collection.export', ->

    beforeEach ->
      collection = new Collection [20, 30, 40, 50]
    
    it 'Should export data from Collection', ->
      expect(collection.export()).toEqual collection.attributes

    it 'Should export data from Collection where exported data is limited to an Array of attribute names', ->
      expect(collection.export [0, 3]).toEqual [20, 50]
      expect(collection.export [0, 3, 5]).toEqual [20, 50]
   
    it 'Should export data when it contains attributes that are an instance of a Collection', ->
      collection.attributes[2] = new Collection [100, 200]
      expect(collection.export [0, 1, 2]).toEqual [20, 30, [100, 200]]
      expect(collection.export [0, {name: 2}]).toEqual [20, [100, 200]]
      expect(collection.export [0, {name: 2, limit: [1]}]).toEqual [20, [200]]
      expect(collection.export [0, {name: 2, limit: [1, 5]}]).toEqual [20, [200]]
   