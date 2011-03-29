assert = require 'assert'
assert = require 'assert'

Rope = require '../src/Rope'

helpers = require './helpers'
randomInt = helpers.randomInt
randomStr = helpers.randomStr


#Rope = helpers.Str

check = (test, r, str) ->
	try
		r.verify()
		assert.strictEqual r.toString(), str
		assert.strictEqual r.length, str.length
	catch e
		console.error 'Error when checking string:'
		r.print()
		throw e

module.exports =
	'empty rope has no content': (test) ->
		r = new Rope
		check test, r, ''
		test.done()
	
	'rope initialized with a string has that string as its content': (test) ->
		str = 'Hi there'
		r = new Rope str
		check test, r, str
		test.done()

	'insert at location inserts': (test) ->
		r = new Rope

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
		r = new Rope '012345678'

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

	'del with longer strings works as expected': (test) ->
		str = "some really long string. Look at me go! Oh my god this has to be the longest string I've ever seen. Holy cow. I can see space from up here. Hi everybody - check out my amazing string!\n"
		str = new Array(1001).join str

		r = new Rope str
		test.strictEqual r.length, str.length
		test.strictEqual r.toString(), str

		r.del 1, str.length - 2
		test.strictEqual r.length, 2
		test.strictEqual r.toString(), str[0] + str[str.length - 1]

		test.done()

	'randomized test': (test) ->
		str = ''
		r = new Rope

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

				str = str[0...pos] + str[(pos + length)...]
				r.del pos, length

			check test, r, str
			assert.strictEqual str, r.toString()
			assert.strictEqual str.length, r.length

		r.stats() if r.stats?

		test.done()

