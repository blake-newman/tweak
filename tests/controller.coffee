describe 'Tweak.Controller', ->

  Controller = class Controller extends Tweak.Controller
  controller = new Controller()

  it 'Should have event methods/properties', ->
    expect(controller.findEvent).toBeDefined()
    expect(controller.addEvent).toBeDefined()
    expect(controller.removeEvent).toBeDefined()
    expect(controller.triggerEvent).toBeDefined()
    expect(controller.updateEvent).toBeDefined()
    expect(controller.resetEvents).toBeDefined()

  
  describe 'Tweak.Model.init', ->

    it 'Should be a function', ->
      expect(typeof controller.init).toEqual 'function'
