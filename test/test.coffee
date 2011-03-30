assert = require 'assert'
assert = require 'assert'

Rope = require '../src/Rope'

helpers = require './helpers'
helpers.addHelpers Rope

randomInt = helpers.randomInt
randomStr = helpers.randomStr

RopeCompiled = try
	require '../Rope.min'
catch e
	null

#Rope = helpers.Str

check = (test, r, str) ->
	try
		r.verify() if r.verify
		assert.strictEqual r.toString(), str
		assert.strictEqual r.length, str.length

		strings = []
		r.each (s) -> strings.push s
		test.strictEqual strings.join(''), str
	catch e
		console.error 'Error when checking string:'
		r.print() if r.print
		throw e

# I want to run the tests with both the normal rope implementation and the
# closure compiled version (since closure is run with advanced settings, it can add
# problems).
tests = (Impl) ->
	'empty rope has no content': (test) ->
		r = new Impl
		check test, r, ''
		test.done()
	
	'rope initialized with a string has that string as its content': (test) ->
		str = 'Hi there'
		r = new Impl str
		check test, r, str
		test.done()

	'insert at location inserts': (test) ->
		r = new Impl

		r.insert 0, 'AAA'
		check test, r, 'AAA'

		r.insert 0, 'BBB'
		check test, r, 'BBBAAA'

		r.insert 6, 'CCC'
		check test, r, 'BBBAAACCC'

		r.insert 5, 'DDD'
		check test, r, 'BBBAADDDACCC'

		test.done()
	
	'delete at location deletes': (test) ->
		r = new Impl '012345678'

		r.del 8, 1
		check test, r, '01234567'

		r.del 0, 1
		check test, r, '1234567'

		r.del 5, 1
		check test, r, '123457'

		r.del 5, 1
		check test, r, '12345'

		r.del 0, 5
		check test, r, ''

		test.done()

	'delete calls callback with deleted text': (test) ->
		r = new Impl 'abcde'
		r.del 1, 3, (str) -> test.strictEqual str, 'bcd'

		test.expect 1
		test.done()

	'each with empty string': (test) ->
		r = new Impl
		# This probably won't call the method at all...
		r.each (str) ->
			test.strictEqual str, ''

		test.done()

	'each with small string': (test) ->
		str = 'howdy doody'
		r = new Impl str

		strings = []
		r.each (s) -> strings.push s
		test.strictEqual strings.join(''), str

		test.done()
	
	'substring with an empty string': (test) ->
		r = new Impl
		s = r.substring 0, 0
		test.strictEqual s, ''

		test.done()

	'substring': (test) ->
		r = new Impl '0123456'

		test.strictEqual '0', r.substring 0, 1
		test.strictEqual '1', r.substring 1, 1
		test.strictEqual '01', r.substring 0, 2
		test.strictEqual '0123456', r.substring 0, 7
		test.strictEqual '456', r.substring 4, 3

		test.done()

	'delete and insert with long strings works as expected': (test) ->
		str = "some really long string. Look at me go! Oh my god this has to be the longest string I've ever seen. Holy cow. I can see space from up here. Hi everybody - check out my amazing string!\n"
		str = new Array(1001).join str

		r = new Impl str
		test.strictEqual r.length, str.length
		test.strictEqual r.toString(), str

		r.del 1, str.length - 2
		test.strictEqual r.length, 2
		test.strictEqual r.toString(), str[0] + str[str.length - 1]

		test.done()

	'randomized test': (test) ->
		str = ''
		r = new Impl

		for [1..1000]
			if Math.random() < 0.9
				# Insert.
				text = randomStr(100)
				pos = randomInt(str.length + 1)

#				console.log "Inserting '#{text}' at #{pos}"

				r.insert pos, text
				str = str[0...pos] + text + str[pos..]
			else
				# Delete
				pos = randomInt(str.length)
				length = Math.min(str.length - pos, Math.floor(Math.random() * 10))

#				console.log "Deleting #{length} chars (#{str[pos...pos + length]}) at #{pos}"

				deletedText = str[pos...pos + length]
				test.strictEqual deletedText, r.substring pos, length

				callbackCalled = no
				r.del pos, length, (s) ->
					assert.strictEqual s, deletedText
					callbackCalled = yes

				str = str[0...pos] + str[(pos + length)...]

				test.strictEqual callbackCalled, yes, 'didnt call the delete callback'

			check test, r, str
			assert.strictEqual str, r.toString()
			assert.strictEqual str.length, r.length

		r.stats() if r.stats?

		test.done()
		
exports.normal = tests Rope
if RopeCompiled?
	exports.compiled = tests RopeCompiled
else
	console.error 'Warning: Skipping tests on closure compiled code because I cant load it'
