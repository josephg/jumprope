{exec} = require 'child_process'

task 'test', 'Run the tests', ->
	reporter = require('nodeunit').reporters.default
	reporter.run ['test/test.coffee']

task 'build:coffee', 'Build the .coffeescript files into .js', (options) ->
	exec "coffee --compile --output lib/ src/", (err, stdout, stderr) ->
		throw err if err
		console.log stdout + stderr

task 'build', 'Run the closure compiler over the javascript', ->
	invoke 'build:coffee'

	closure = require './support/closure'
	fs = require 'fs'
	file = fs.readFileSync 'lib/Rope.js'

	closure.compile file, (err, code) ->
		throw err if err?

		smaller = Math.round((1 - (code.length / file.length)) * 100)

		output = 'Rope.min.js'
		fs.writeFileSync output, code

		console.log "Closure compiled: #{smaller}% smaller (#{code.length} bytes} written to #{output}"
	
