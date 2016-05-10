describe 'Tweak', ->

  it 'Should exist', ->
    expect(Tweak).toBeDefined()
    expect(Tweak).not.toBeNull()

  it 'Should have require set', ->
    expect(Tweak.require).toBeDefined()
    expect(Tweak.require).not.toBeNull()

  it 'Should have a DOMManipulator set', ->
    expect(Tweak.$).toBeDefined()
    expect(Tweak.$).not.toBeNull()
  
  it 'Should allow for no conflict', ->
    # This will simulate a no conflict scenario by creating two instances
    Tweak.pTweak = version: 'previous'
    Tweak.version = 'current'
    noConflict = Tweak.noConflict()

    # Check that the versions differ
    expect(Tweak.version).not.toBe noConflict.version

    window.Tweak = noConflict

  it 'Should have modules assigned', ->
    for item in ['Model', 'Collection', 'View', 'Controller', 'Events', 'History', 'Router', 'Component', 'Components']
      expect(Tweak[item]).toBeDefined()
      expect(Tweak[item]).not.toBeNull()


###
  Tweak methods.
  Ignoring Tweak.bind and Tweak.extends as they use CoffeeScript built in methods
###

describe 'Tweak.super', ->

  it 'Should super its parent method white passing additional parameters', ->
    class SuperModelTest extends Tweak.Model
      constructor: (obj) ->
        Tweak.super SuperModelTest, this, 'constructor', obj

    model = new SuperModelTest({dummy:'test'})

    expect(model.attributes.dummy).toEqual 'test'

describe 'Tweak.clone', ->

  it 'Should create a clone of an Object', ->
    obj1 = {ref:1, sub:{ref:1}}
    obj2 = Tweak.clone obj1

    # Check that the Objects differ
    expect(obj1).not.toBe obj2

    # Check that references have been destroyed
    obj2.ref = 2
    obj2.sub.ref = 2
    expect(obj1.ref).not.toBe obj2.ref
    expect(obj1.sub.ref).not.toBe obj2.sub.ref

describe 'Tweak.combine', ->

  it 'Should combine two Objects', ->
    obj1 = {ref:1, old:false, sub:{ref:1}, arr:[1,2,3]}
    obj2 = {ref:2, sub:{ref:2}, new:true, arr:[3,2,1,4]}

    obj3 = Tweak.combine obj1, obj2

    # Check that second object takes priority during merge
    expect(obj3.ref).toEqual 2

    # Check new property remains in combined object
    expect(obj3.old).toEqual false

    # check that nested object combine

    expect(obj3.sub.ref).toEqual 2
    # Check new property is merged
    expect(obj3.new).toEqual true

    # Check Array merges correctly
    expect(obj3.arr[0]).toEqual 3
    expect(obj3.arr[1]).toEqual 2
    expect(obj3.arr[2]).toEqual 1
    expect(obj3.arr[3]).toEqual 4

describe 'Tweak.toAbsolute', ->
  context = 'root/context'
  joined = ''

  it 'Should accept non joining path', ->
    joined = Tweak.toAbsolute context, 'path'
    expect(joined).toEqual 'path'


  it 'Should join path with a ./', ->
    joined = Tweak.toAbsolute context, './path'
    expect(joined).toEqual context+'/path'

  it 'Should navigating up context path by one ../', ->
    joined = Tweak.toAbsolute context, '../path'
    expect(joined).toEqual 'root/path'


  it 'Should navigating up context path with more than one ../', ->
    joined = Tweak.toAbsolute context, '../../path'
    expect(joined).toEqual 'path'

  it 'Should navigate to top when context path is exceeded by ../', ->
    joined = Tweak.toAbsolute context, '../../../../../path'
    expect(joined).toEqual 'path'

  it 'Should ignore context when using ~/', ->
    joined = Tweak.toAbsolute context, '~/path'
    expect(joined).toEqual 'path'

  it 'Should ignore multiple sequential /', ->
    joined = Tweak.toAbsolute context, './dummy//path'
    expect(joined).toEqual context+'/dummy/path'

    joined = Tweak.toAbsolute context, './/path'
    expect(joined).toEqual context+'/path'

  it 'Should ignore ./ when using ../', ->
    joined = Tweak.toAbsolute context, '.././path'
    expect(joined).toEqual 'root/path'

  it 'Should ignore trailing / on context', ->
    joined = Tweak.toAbsolute context+'/', './path'
    expect(joined).toEqual 'root/context/path'

  it 'Should allow \ characters', ->
    joined = Tweak.toAbsolute context, '.\\path'
    expect(joined).toEqual 'root/context/path'

  it 'Should keep trailing / character on relative', ->
    joined = Tweak.toAbsolute context, './path/'
    expect(joined).toEqual 'root/context/path/'

describe 'Tweak.request', ->
  require.register 'dummy/controller', (exports, require, module) ->
    exports = module.exports = class RequireClass
      @type = 'require'

  class SurrogateClass
    @type = 'surrogate'

  it 'Should find a module from single context path without surrogate', ->
    Module1 = Tweak.request 'dummy', './controller'
    expect(Module1.type).toEqual 'require'

  it 'Should find a module from single context path even when surrogate supplied', ->
    Module1 = Tweak.request 'dummy', './controller', SurrogateClass
    expect(Module1.type).toEqual 'require'

  it 'Should supply surrogate when module not found from single context path', ->
    Module1 = Tweak.request 'dummy', './fake/path', SurrogateClass
    expect(Module1.type).toEqual 'surrogate'

  it 'Should error when module is not found from single context path and no surrogate is found', ->
    try
      Tweak.request '', 'dummy/wrong/path'
      # So it fails if it doesnt throw an error
      expect(false).toEqual true
    catch e
      expect(e).toBeDefined()

  it 'Should find a module from a collection of contexts with no surrogate', ->
    Module1 = Tweak.request ['dummy', 'fake', 'fake/path'], './controller'
    expect(Module1.type).toEqual 'require'

  it 'Should find a module from a collection of contexts even when surrogate supplied', ->
    Module1 = Tweak.request ['dummy', 'fake', 'fake/path'], './controller', SurrogateClass
    expect(Module1.type).toEqual 'require'

  it 'Should supply surrogate when module from a collection of contexts is not found ', ->
    Module1 = Tweak.request ['dummy', 'fake', 'fake/path'], './fake/path', SurrogateClass
    expect(Module1.type).toEqual 'surrogate'

  it 'Should error when module is not found from a collection of contexts and no surrogate is found', ->
    try
      Tweak.request ['dummy', 'fake', 'fake/path'], 'dummy/wrong/path'
      # So it fails if it doesnt throw an error
      expect(false).toEqual true
    catch e
      expect(e).toBeDefined()


describe 'Tweak.splitPaths', ->
  split = []

  it 'Should split paths with format of context/path[1-3]', ->
    split = Tweak.splitPaths 'context/path[1-3]'
    expect(split[0]).toEqual 'context/path1'
    expect(split[1]).toEqual 'context/path2'
    expect(split[2]).toEqual 'context/path3'

  it 'Should split paths with format of context/path[2]', ->
    split = Tweak.splitPaths 'context/path[2]'
    expect(split[0]).toEqual 'context/path0'
    expect(split[1]).toEqual 'context/path1'
    expect(split[2]).toEqual 'context/path2'

  it 'Should split paths with format of context/path[0]', ->
    split = Tweak.splitPaths 'context/path[0]'
    expect(split[0]).toEqual 'context/path0'

  it 'Should accept multiple paths split on a space', ->
    split = Tweak.splitPaths 'context/path[0] another/path[1]'
    expect(split[0]).toEqual 'context/path0'
    expect(split[1]).toEqual 'another/path0'
    expect(split[2]).toEqual 'another/path1'

  it 'Should accept multiple paths contained in an array', ->
    split = Tweak.splitPaths ['context/path[0]','another/path[1]']
    expect(split[0]).toEqual 'context/path0'
    expect(split[1]).toEqual 'another/path0'
    expect(split[2]).toEqual 'another/path1'

  it 'It should return normal paths', ->
    split = Tweak.splitPaths 'context/path'
    expect(split[0]).toEqual 'context/path'

  it 'It should keep trailing parts', ->
    split = Tweak.splitPaths 'context/path[1-2]/extra'
    expect(split[0]).toEqual 'context/path1/extra'
    expect(split[1]).toEqual 'context/path2/extra'