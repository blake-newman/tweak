describe 'Tweak.View', ->

  View = class View extends Tweak.View
  view = new View()

  it 'Should have event methods/properties', ->
    expect(view.findEvent).toBeDefined()
    expect(view.addEvent).toBeDefined()
    expect(view.removeEvent).toBeDefined()
    expect(view.triggerEvent).toBeDefined()
    expect(view.updateEvent).toBeDefined()
    expect(view.resetEvents).toBeDefined()

  it 'Should have certain methods/properties', ->
    expect(view.config).toBeDefined()
    expect(view.init).toBeDefined()
    expect(view.ready).toBeDefined()
    expect(view.template).toBeDefined()
    expect(view.attach).toBeDefined()
    expect(view.isAttached).toBeDefined()
    expect(view.getAttachment).toBeDefined()
    expect(view.render).toBeDefined()
    expect(view.rerender).toBeDefined()
    expect(view.clear).toBeDefined()
    expect(view.element).toBeDefined()

  describe 'Tweak.View.init', ->

    it 'Should be a function', ->
      expect(typeof view.init).toEqual 'function'

  describe 'Tweak.View.config', ->

    it 'Should be a an empty object if no config passed to constructor', ->
      expect(view.config).toEqual {}

    it 'Should be the config that is passed to constructor', ->
      view = new View {attach: 'test'}
      expect(view.config).toEqual {attach: 'test'}

  describe 'Tweak.View.template', ->
    
    it 'Should get a template from template specified in config', ->
      view = new View {template: 'lib/template'}
      expect(view.template()).toEqual '<div></div>'

    it 'Should get a template from paths specified in config', ->
      view = new View {paths: ['fake', 'lib']}
      expect(view.template()).toEqual '<div></div>'

    it 'Should get a template from paths and template specified in config', ->
      view = new View {paths: ['fake', 'lib'], template: './template'}
      expect(view.template()).toEqual '<div></div>'

  describe 'Tweak.View.getAttachment', ->
    _html = $('html')[0]
    _body = $('body')[0]
    beforeEach ->
      $('html').attr 'data-attach', 'double-attachment path/lib'
      $('body').attr 'data-attach', 'test-attachment double-attachment lib'

    it 'Should find attachment from attach specified in config', ->
      view = new View {attach: 'test-attachment'}
      expect(view.getAttachment _html).toEqual _body
      expect(view.getAttachment _body).toEqual _body

    it 'Should find attachment from attach specified in config', ->
      view = new View {attach: 'test-attachment'}
      expect(view.getAttachment _html).toEqual _body
      expect(view.getAttachment _body).toEqual _body

    it 'Should find attachment from attach specified in config returning the first found element', ->
      view = new View {attach: 'double-attachment'}
      expect(view.getAttachment _html).toEqual _html
      expect(view.getAttachment _body).toEqual _body

    it 'Should find attachment from name specified in config', ->
      view = new View {name: 'lib'}
      expect(view.getAttachment _html).toEqual _body
      expect(view.getAttachment _body).toEqual _body

    it 'Should find attachment from name and parentName in config', ->
      view = new View {parentName: 'path', name: './lib'}
      expect(view.getAttachment _html).toEqual _html
      expect(view.getAttachment _body).not.toBeDefined()

      # Non compatible join
      view = new View {parentName: 'path', name: 'lib'}
      expect(view.getAttachment _html).toEqual _body
      expect(view.getAttachment _body).toEqual _body


    it 'Should find attachment from attach and parentName in config', ->
      view = new View {parentName: 'path', attach: './lib'}
      expect(view.getAttachment _html).toEqual _html
      expect(view.getAttachment _body).not.toBeDefined()

      # Non compatible join
      view = new View {parentName: 'path', attach: 'lib'}
      expect(view.getAttachment _html).toEqual _body
      expect(view.getAttachment _body).toEqual _body

  describe 'Tweak.View.attach', ->
    $body = $ 'body'
    $body.append '<main></main>'
    $element = $ '<span></span>'
    $main = $ 'main'
    _main = $main[0]

    beforeEach ->
      $main.html ''

    it 'Should append to a parent', ->
      view = new View()
      view.attach _main, '<div></div>'
      view.attach _main, $element

      expect($main.html()).toEqual '<div></div><span></span>'

    it 'Should prepend to a parent when configs method property is "before"', ->
      view = new View {method: 'before'}
      view.attach _main, '<div></div>'
      view.attach _main, $element

      expect($main.html()).toEqual '<span></span><div></div>'

    it 'Should prepend to a parent when configs method property is "prefix"', ->
      view = new View {method: 'prefix'}
      view.attach _main, '<div></div>'
      view.attach _main, $element
      expect($main.html()).toEqual '<span></span><div></div>'

    it 'Should replace contents of parent when configs method property is "replace"', ->
      view = new View {method: 'replace'}
      view.attach _main, '<div></div>'
      expect($main.html()).toEqual '<div></div>'
      view.attach _main, $element
      expect($main.html()).toEqual '<span></span>'

    it 'Should insert contents into a given position of parents childern when configs method property is a number', ->
      view = new View {method: 1}
      $main.html '<div></div><div></div>'
      view.attach _main, '<span></span>'
      expect($main.html()).toEqual '<div></div><span></span><div></div>'
      view = new View({method: 5000})
      view.attach _main, $element
      expect($main.html()).toEqual '<div></div><span></span><div></div><span></span>'

    it 'Should accept method through 3rd argument', ->
      view = new View {method: 1}
      $main.html '<div></div><div></div>'
      view.attach _main, '<span></span>'
      expect($main.html()).toEqual '<div></div><span></span><div></div>'
      view.attach _main, $element, 'before'
      expect($main.html()).toEqual '<span></span><div></div><span></span><div></div>'

  describe 'Tweak.View.clear', ->
    it 'Should clear an element from the DOM', ->
      $('body').html '<main></main>'
      view = new View()
      view.clear 'main'
      expect($('main')[0]).not.toBeDefined()

  describe 'Tweak.View.element', ->
    it 'Should find an element from within an element', ->
      view = new View()
      expect(view.element('body', 'html')[0]).toEqual $('body')[0]

  describe 'Tweak.View.isAttached', ->
    it 'Should an element is attached to the DOM', ->
      view = new View()
      expect(view.isAttached 'body', 'html').toEqual true
      expect(view.isAttached 'html', 'body').toEqual false
      
  describe 'Tweak.View.render', ->
    _html = $('html')[0]
    _body = $('body')[0]
    beforeEach ->
      $('body').html ''
      $('html').attr 'data-attach', ''
      $('body').attr 'data-attach', 'main'


    it 'Should render asynchronously', (done) ->
      view = new View
        template: 'lib/template'
        attach: 'main'
      view.render()
      expect($('body').html()).toEqual ''
      setTimeout ->
        expect($('body').html()).toEqual '<div></div>'
        done()
      , 100

    it 'Should render synchronously', ->
      view = new View
        template: 'lib/template'
        attach: 'main'
        async: false
      view.render()
      expect($('body').html()).toEqual '<div></div>'

    fn1 = -> callbacks.fn1()
    fn2 = -> callbacks.fn2()
    callbacks =
      fn1: ->
      fn2: ->
      
    it 'Should render triggering rendered event', (done) ->
      spyOn callbacks, 'fn1'
      view = new View
        template: 'lib/template'
        attach: 'main'
      view.addEvent 'rendered', fn1
      view.render()

      setTimeout ->
        expect(callbacks.fn1.calls.count()).toEqual 1
        done()
      , 100


    it 'Should render quietly', (done) ->
      spyOn callbacks, 'fn2'
      view = new View
        template: 'lib/template'
        attach: 'main'
      view.addEvent 'rendered', fn2
      view.render true

      setTimeout ->
        expect(callbacks.fn2.calls.count()).toEqual 0
        done()
      , 100

    it 'Should add el to view', ->
      view = new View
        template: 'lib/template'
        attach: 'main'
        async: false
      view.render true
      expect(view.el.outerHTML).toEqual '<div></div>'
    
    it 'Should add $el to view', ->
      view = new View
        template: 'lib/template'
        attach: 'main'
        async: false
      view.render true
      expect(view.$el.parent().html()).toEqual '<div></div>'

    it 'Should point to element in config if view is static', ->
      view = new View
        method: 'static'
        element: 'html'
        async: false
      view.render true
      expect(view.el).toBe _html

    it 'Should add class names to the view element', ->
      view = new View
        name: 'dummy-component-name'
        template: 'lib/template'
        attach: 'main'
        async: false
      view.render true
      expect(view.el.className).toBe 'dummy-component-name'
      view.el.className = ''

  describe 'Tweak.View.rerender', ->
    _html = $('html')[0]
    _body = $('body')[0]
    beforeEach ->

    it 'Should clear the view then render the view', ->
      view = new View
        name: 'dummy-component-name'
        template: 'lib/template'
        attach: 'main'
        async: false
      view.render true
      view.el.className = ''
      view.rerender()
      expect(view.el.className).toBe 'dummy-component-name'
