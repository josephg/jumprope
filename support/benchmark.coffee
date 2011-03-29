helpers = require './helpers'
randomInt = helpers.randomInt
randomStr = helpers.randomStr

Rope = require '../src/Rope'
Compiled = require '../lib/Rope-compiled'

time = (fn, iterations) ->
	start = Date.now()
	fn() for [0...iterations]
	Date.now() - start

timeprint = (fn, iterations, name) ->
	console.log "Benchmarking #{iterations} iterations of #{name}..."
	result = time fn, iterations
	console.log "#{name} took #{result} ms, or #{result / iterations} ms per iteration"

permute = (r) ->
	random = helpers.useRandomWithSeed 100

	->
		if random() < 0.95
			# Insert.
			text = randomStr(2)
			pos = randomInt(r.length + 1)

			r.insert pos, text
		else
			# Delete
			pos = randomInt(r.length)
			length = Math.min(r.length - pos, randomInt(10))

			r.del pos, length

#timeprint permute(helpers.Str()), 200000, 'Str'

testSizes = ->
	size = 4
	while size < 20000
		Rope.setSplitSize size

		console.log "Split size #{size}"
		r = new Rope()
		timeprint permute(r), 100000, 'Rope'
		r.stats()

		size *= 2

testBias = ->
	for bias in [0.1..0.99] by 0.02
		Rope.setBias bias

		r = new Rope()
		timeprint permute(r), 300000, "Bias #{bias}"
		console.log ""

naiveTest = ->
	r = new Rope()
	timeprint permute(r), 200000, 'Rope'
	r.stats()

testBias()
#naiveTest()

