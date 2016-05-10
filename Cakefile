exec = require('child_process').exec
fs = require('fs')

files = ['tweak', 'lib/events', 'lib/model', 'lib/view', 'lib/controller', 'lib/collection', 'lib/component', 'lib/components', 'lib/history', 'lib/router']

compile = (flags) ->
  build = []
  total = files.length
  for file, index in files
    build.push fs.readFileSync "src/#{file}.coffee", 'utf8'

  fs.mkdir 'build', ->
    fs.writeFile 'build/tweak.coffee', build.join('\n\n'), 'utf8', (err) ->
      throw err if err
      exec 'coffee '+flags+' lib build', (err, stdout, stderr) ->
        throw err if err
        console.log 'Built'
        exec 'uglifyjs lib/tweak.js -cmo lib/tweak.min.js --source-map lib/tweak.min.js.map', (err, stdout, stderr) ->
          throw err if err
          console.log 'Compressed'


task 'build', 'Compile and create minified version', ->
  compile '-cmo'