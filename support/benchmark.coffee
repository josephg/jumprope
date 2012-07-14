helpers = require '../test/helpers'
{randomInt, randomStr, addHelpers} = helpers

Rope = addHelpers(require '../src/Rope')
Compiled = require '../Rope.min'
#helpers.addHelpers(Rope)

time = (fn, iterations) ->
	start = Date.now()
	fn() for [0...iterations]
	Date.now() - start

timeprint = (fn, iterations, name) ->
	console.log "Benchmarking #{iterations} iterations of #{name}..."
	result = time fn, iterations
	console.log "#{name} took #{result} ms. #{result / iterations} ms per iteration, #{iterations/result * 1000} iterations per second"

permute = (r) ->
	random = helpers.useRandomWithSeed 100

	->
		if random() < 0.95
			# Insert.
			text = randomStr(randomInt 2)
			pos = randomInt(r.length + 1)

			r.insert pos, text
		else
			# Delete
			pos = randomInt(r.length)
			length = Math.min(r.length - pos, randomInt(10))

			r.del pos, length

testToString = ->
	r = new Rope randomStr(20000)
	console.log r.length
	timeprint (-> r.toString()), 100000, 'toString'

testSizes = ->
	throw new Error "You need to uncomment the setSpliceSize line in Rope.coffee to use this test" unless Rope.setSpliceSize?
	size = 4
	while size < 20000
		Rope.setSplitSize size

		console.log "Split size #{size}"
		r = new Rope()
		timeprint permute(r), 100000, 'Rope'
		r.stats()

		size *= 2

testBias = ->
	throw new Error "You need to uncomment the setBias line in Rope.coffee to use this test" unless Rope.setBias?
	for bias in [0.1..0.99] by 0.02
		Rope.setBias bias

		r = new Rope()
		timeprint permute(r), 300000, "Bias #{bias}"
		console.log ""

naiveTest = ->
	r = new Rope()
	iterations = 100000
	timeprint permute(r), iterations, 'Rope'
#	timeprint permute(helpers.Str()), iterations, 'Str'
	r.stats()

#testBias()
naiveTest()
testToString()

