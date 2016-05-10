// Karma configuration
// Generated on Wed Jul 01 2015 09:27:25 GMT+0100 (GMT Daylight Time)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],


    // list of files / patterns to load in the browser
    files: [
      'bower_components/jquery/dist/jquery.js', 
      'bower_components/commonjs-require-definition/require.js',
      'lib/tweak.js',
      'tests/lib/template.coffee',
      'tests/tweak.coffee',
      'tests/events.coffee',
      'tests/model.coffee',
      'tests/collection.coffee',
      'tests/controller.coffee',
      'tests/view.coffee'
    ],


    // list of files to exclude
    exclude: [
    ],


    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
      'tests/lib/*.coffee': ['coffee'],
      'tests/tweak.coffee': ['coffee'],
      'tests/events.coffee': ['coffee'],
      'tests/model.coffee': ['coffee'],
      'tests/collection.coffee': ['coffee'],
      'tests/controller.coffee': ['coffee'],
      'tests/view.coffee': ['coffee']
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: [process.env.TRAVIS ? 'Firefox' : 'Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false,

    coffeePreprocessor: {
      // options passed to the coffee compiler
      options: {
        bare: true,
        sourceMap: false
      },
      // transforming the filenames
      transformPath: function(path) {
        return path.replace(/\.coffee$/, '.js');
      }
    }
  })
}
