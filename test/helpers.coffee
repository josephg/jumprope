# These are some helper methods for testing.

assert = require 'assert'
inspect = require('util').inspect

random = Math.random

exports.useRandomWithSeed = (seed = 10) ->
	r = seed
	randomInt = (n) -> Math.abs((r = (r << 2) ^ (r << 1) - r + 1) % n)
	random = -> randomInt(100) / 100

exports.randomInt = randomInt = (bound) -> Math.floor(random() * bound)

alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ '
randomChar = -> alphabet[randomInt(alphabet.length)]

# Generates a random string of length len
exports.randomStr = (len = 10) -> (randomChar() for [1...len]).join('') + ' '

# We'll make an implementation of the rope API backed by strings
exports.Str = (s = '') ->
	{
		insert: (pos, str) ->
			s = s[...pos] + str + s[pos..]
			@length = s.length
		del: (pos, len) ->
			s = s[...pos] + s[pos + len..]
			@length = s.length

		verify: ->
		toString: -> s
		print: -> console.log s
		length: s.length
	}

# Some more methods for Rope which we'll use in tests.
exports.addHelpers = (Impl) ->
	Impl::verify = ->
		nodes = (@head for [0...@head.nexts.length])
		positions = @head.nexts.map -> 0

		pos = 0
		e = @head

		while e != null
			pos += e.str?.length ? 0
			e = e.nexts[0] || null

			for i in [0...nodes.length]
				if nodes[i].subtreesize[i] + positions[i] == pos
					assert.strictEqual nodes[i].nexts[i], e

					nodes[i] = e
					positions[i] = pos
				else
					assert.ok nodes[i].subtreesize[i] + positions[i] > pos, "asdf"

		assert.strictEqual pos, @length

	Impl::stats = ->
		numElems = 0
		e = @head
		while e != null
			e = e.nexts[0]
			numElems++

		console.log "Length: #{@length}"
		console.log "Num elements: #{numElems}"
		console.log "Avg string length per element: #{@length / numElems}"

	Impl::print = ->
		console.log "Rope with string '#{@['toString']()}'"
		node = @head
		while node?
			console.log "#{inspect node}"
			node = node.nexts[0]
		
		this
	
	Impl

