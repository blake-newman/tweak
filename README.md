# Tweak.js - A lightweight [Component](http://docs.tweakjs.com/class/Tweak/Component.html) driven [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) framework.

## Introduction

```
NOTE - This is an abstraction of my work at Ignition Online. This is for demonstration purposes and is no longer supported.
```

Tweak.js is a [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) framework built to help developers' structure code; for use in Web Applications and Web Components. Tweak.js is also accompanied with extra features that advances typical [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) concepts. JavaScripters can take advantage of class features through Tweak.js, this makes OOP JavaScript easy to use even for JavaScipt purists. Tweak.js becomes even more powerful with JavaScript task runners such as Brunch, Grunt and Gulp. With the use of task runners structuring code into appropriate files/directories is extremely simple and effective.

In addition to common [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) concepts Tweak.js introduces features like Components. Components are used to dynamically create a set of linking modules like the typical [Models](http://docs.tweakjs.com/class/Tweak/Model.html), [Views](http://docs.tweakjs.com/class/Tweak/View.html) and [Controllers](http://docs.tweakjs.com/class/Tweak/Controller.html); that can be configured, extended, reused and organised. Tweak.js also includes [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) and [Router](http://docs.tweakjs.com/class/Tweak/Router.html) modules like that of typical frameworks. Furthermore, to enhance the relationship between modules Tweak.js includes a powerful event system. The event system is simple and designed to extend modules/classes/objects with functionality to link actions between the individual modules.

For a full understanding to the framework please look at the [documentation](http://docs.tweakjs.com) or the source code.

## Use
### Installation
BOWER: `bower install tweakjs`

NPM: `npm install tweakjs`

### Dependencies
* Depends on a **CommonJS based loader** see [description on module loaders](http://addyosmani.com/writing-modular-js/)
* Depends on a **DOM engine** like [jquery](http://jquery.com/) or [zepto](http://zeptojs.com/)
* An optional dependency of a **template engine** like [handlebars.js](http://handlebarsjs.com/) can be used if you wish the View to render a template to the DOM. Views don't need a template engine as you can specify a static 'view area'.

### Tags
[[CommonJS loader]](http://addyosmani.com/writing-modular-js/) - List of module/script loaders.

[[template engine]](http://garann.github.io/template-chooser/) - list of template engines.

[[template engine]](http://garann.github.io/template-chooser/) - list of template engines.

```html
<!-- truncated -->
  <script src="js/[CommonJS loader].js"></script>
  <script src="js/[template engine].js"></script>
  <script src="js/[DOM engine].js"></script>
  <script src="js/tweak.js"></script>
</body>
<!-- truncated -->
```

### Templates/Skeletons
A skeleton for Grunt, Brunch a Gulp will shortly be created

### Extensions/Plug-ins
As Tweak.js is built with CoffeeScript; which utilises OOP Classes, extending the framework is as easy as eating some pie. For example applying different template engines can be applied by an extension/plug-in.

When creating an extension/plug-in to a framework, please use the naming convention of [name]-tweaked (lower case), example jade-tweaked. This will make it easy for people to find extensions/plug-ins to the framework. This isn't a required naming convention, just a preference, so don't worry if the name is already taken.

For a list of extensions/plug-ins look at EXTENSIONS.md. Please fork and add to the EXTENSIONS.md if you wish to submit an extension. An example extension will be supplied, along with how to apply it to the Framework.

## Concepts
Below is a rough guide to the concepts used within Tweak.js. Additional information can be found on the web to help your understanding on [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) concepts. For more in-depth details on what Tweak.js can do, look at the relevant module in the [documentation](http://docs.tweakjs.com/) or look at the source code for line by line comments. Better yet just get stuck in and mess around with it; its versatile for lots of needs.  

### [Model](http://docs.tweakjs.com/class/Tweak/Model.html)
A [Model](http://docs.tweakjs.com/class/Tweak/Model.html) is used to store, retrieve and listen to attributes. Tweak.js will call events through its [Event System](http://docs.tweakjs.com/class/Tweak/Events.html), when the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) is updated when it will trigger a 'changed' event. By listening to change events, you can action functionality upon changes to the [Model](http://docs.tweakjs.com/class/Tweak/Model.html)'s attributes. The [Model](http://docs.tweakjs.com/class/Tweak/Model.html)’s attributes are not persistent, as such it is not a storage medium, but a layer for actioning functionality upon changes. The [Model](http://docs.tweakjs.com/class/Tweak/Model.html)'s data can be exported as a JSON representation which can be used to store/retrieve data form persistent storage sources. The main difference between a [Model](http://docs.tweakjs.com/class/Tweak/Model.html) and [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) it the base of its attributes. The [Model](http://docs.tweakjs.com/class/Tweak/Model.html) uses an Object as its attributes base and a [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) uses an Array as its attributes base, to add the Collection Class extends the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) Class.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) section.

### [View](http://docs.tweakjs.com/class/Tweak/View.html)
A [View](http://docs.tweakjs.com/class/Tweak/View.html) is a module to clearly define and separate the user interface functionality. A [View](http://docs.tweakjs.com/class/Tweak/View.html) is primarily used to render, manipulate and to listen to actions on a user interface. The [View](http://docs.tweakjs.com/class/Tweak/View.html) keeps data logic separated away from the UI, this is to leverage better code structure to prevent Data and the UI becoming tangled together.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [View](http://docs.tweakjs.com/class/Tweak/View.html).

### [Controller](http://docs.tweakjs.com/class/Tweak/Controller.html)
A [Controller](http://docs.tweakjs.com/class/Tweak/Controller.html) defines the business logic between other modules. It can be used to control data flow, logic and more. It should process the data from the [Model](http://docs.tweakjs.com/class/Tweak/Model.html), interactions and responses from the [View](http://docs.tweakjs.com/class/Tweak/View.html), and control the logic between other modules.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Controller](http://docs.tweakjs.com/class/Tweak/Controller.html) section.

### [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html)
A [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) is an extension to the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) Class. The main difference being that there the base to the attributes is an Array for a [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html). As [Collections'](http://docs.tweakjs.com/class/Tweak/Collection.html) base type is an Array there is extra methods available such as; push, splice, slice and many more. The [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) can take advantage of all the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) based methods like setters and getters. Please see the [Model](http://docs.tweakjs.com/class/Tweak/Model.html) class for more information on the methods inherited to the [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html).

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Collection](http://docs.tweakjs.com/class/Tweak/Collection.html) and [Model](http://docs.tweakjs.com/class/Tweak/Model.html) sections.

### [Router](http://docs.tweakjs.com/class/Tweak/Router.html)
The [Router](http://docs.tweakjs.com/class/Tweak/Router.html) which hooks into the Tweak.[History](http://docs.tweakjs.com/class/Tweak/History.html) change events which provides information back from the URL. The [Router](http://docs.tweakjs.com/class/Tweak/Router.html) module provides routing to events which can control the application and its modules.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Router](http://docs.tweakjs.com/class/Tweak/Router.html) section.

### [History](http://docs.tweakjs.com/class/Tweak/History.html)
The [History](http://docs.tweakjs.com/class/Tweak/History.html) is a cross-browser friendly version of the HTML5 history API. When available it uses the HTML5 pushState else it provides a backwards compatible solution to having a stored history, either hashState or an interval that checks at a set rate. The [History](http://docs.tweakjs.com/class/Tweak/History.html) provides routes to your application/component which updates the application/components based on the URL information. The current URL location can also be set to provide a shareable/linkable/bookmark-able URL to specific places in your application.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [History](http://docs.tweakjs.com/class/Tweak/History.html) section.

### [Event System](http://docs.tweakjs.com/class/Tweak/Event.html)
Tweak.js has an [Event System](http://docs.tweakjs.com/class/Tweak/Events.html) class, this provides functionality to extending classes to communicate simply and effectively while maintaining an organised structure to your code and applications. Each object can extend the [Tweak.Events](http://docs.tweakjs.com/class/Tweak/Events.html) class to provide event functionality. Majority of Tweak.js modules/classes already extend the [Event System](http://docs.tweakjs.com/class/Tweak/Events.html) class, however when creating custom objects/classes you can extend the class using the [Tweak.Events](http://docs.tweakjs.com/class/Tweak/Events.html) method, please see [Class](http://docs.tweakjs.com/class/Tweak/Class.html) class in the [documentation](http://docs.tweakjs.com).

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Events](http://docs.tweakjs.com/class/Tweak/Events.html) class.

### [Components](http://docs.tweakjs.com/class/Tweak/Component.html)
[Components](http://docs.tweakjs.com/class/Tweak/Component.html) are used to dynamically create a set of linking modules like the typical [Models](http://docs.tweakjs.com/class/Tweak/Model.html), [Views](http://docs.tweakjs.com/class/Tweak/View.html) and Controllers; that can be configured, extended, reused and organised. A Component will build and tie together modules.

[Components](http://docs.tweakjs.com/class/Tweak/Component.html) will automatically detect inherited modules through a module loader. It is recommended to use a [module loader](https://github.com/brunch/commonjs-require-definition) that is based on CommonJS. This increases versatility of Tweak.js, by creating an eco-system of reusable, configurable and organised [Components](http://docs.tweakjs.com/class/Tweak/Components.html). This is a unique twist to common [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) frameworks as it provides a wrapper that helps make understanding the links between the concepts of [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) clearer. It is also brilliant for saving development time.

[Components](http://docs.tweakjs.com/class/Tweak/Component.html) bring Object Oriented Programming (OOP) concepts into [M](http://docs.tweakjs.com/class/Tweak/Model.html)[V](http://docs.tweakjs.com/class/Tweak/View.html)[C](http://docs.tweakjs.com/class/Tweak/Controller.html) and JavaScript. Which acts as a powerful structuring mechanism to web applications.

For more information please look at the [documentation](http://docs.tweakjs.com) under the [Component](http://docs.tweakjs.com/class/Tweak/Component.html) and [Component](http://docs.tweakjs.com/class/Tweak/Component.html) sections.

### Classes
Classes are core to Tweak.js as it provides a solution to keep code organised, reusable and extend-able. If using CoffeeScript you should be well adapted the OOP concepts and its functionalities. JavaScript purists can take advantage of Tweak.js' built in methods to embed OOP concepts; please look at the documentation/source for more information - [documentation](http://docs.tweakjs.com).

### Templates
A template, written in a template language, describes the user interface of your application. Tweak.js doesn't limit you to how you create your templates, however as a rough guide; a template normally will be generated from a template engine like handlebars. Template engines will typically tie to a object to use as its construction, in Tweak.js this is normally a relating Model. Templates are generated through the [View](http://docs.tweakjs.com/class/Tweak/View.html)module upon the render process, for more information on how this works look at the [View](http://docs.tweakjs.com/class/Tweak/View.html) modules documentation.

## Tests
Tests are run with Jasmine and Karma. There are multiple karma config files for variations in dependencies. This ensures maximum compatibility across multiple dependencies such as jQuery/Zepto ect.

## Contribution
Feel free to contribute in any way you can. Whether it is contributing to the source code or [donating](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=648D6YUPB88XG) to help development. Tweak.js will always remain open source and I will never ask for your personal details.

## License

The MIT License (MIT)

Copyright (c) 2014 Blake Newman

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A ARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE

[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/tweak-js/tweak/trend.png)](https://bitdeli.com/free "Bitdeli Badge")
