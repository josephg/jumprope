
# Benchmarking reveals this to be the fastest
splitSize = 512
bias = 0.7

#inspect = require('util').inspect

randomInt = do ->
	r = 10
	(n) -> Math.abs((r = (r << 2) ^ (r << 1) - r + 1) % n)

#Math.random = -> randomInt(100) / 100

randomHeight = ->
	length = 1

	# This method uses successive bits of a random number to figure out whick skip lists
	# to be part of. It is faster than the method below, but doesn't support weird biases.
	# It turns out, it is slightly faster to have non-0.5 bias and that offsets the cost of
	# calling random() more times (at least in v8)
#	r = Math.random() * 2
#	while r > 1
#		r = (r - 1) * 2
#		length++

	length++ while Math.random() > bias

	length

module['exports'] = Rope = (str) ->
	return new Rope(str) if !(this instanceof Rope)

	@head = {nexts:[], subtreesize:[]}
	@length = 0

	@['insert'] 0, str if str?
	this

Rope.prototype['toString'] = ->
	e = @head
	strings = []

	while e?
		strings.push e.str
		e = e.nexts[0]
	
	strings.join ''

Rope.prototype['insert'] = (insertPos, str) ->
	throw new Error('pos must be a number') unless typeof insertPos == 'number'
	throw new Error("pos must be within the rope (#{@length})") unless 0 <= insertPos <= @length
	throw new Error('inserted text must be a string') unless typeof str == 'string'

#	console.log "Inserting '#{str}' at #{insertPos} in '#{@toString()}'" if Rope.p

	e = @head
	nodes = new Array @head.nexts.length
	subtreesize = new Array @head.nexts.length
	
	offset = insertPos
	if e.nexts.length > 0
		for h in [@head.nexts.length - 1..0]
			while offset > e.subtreesize[h]
				offset -= e.subtreesize[h]
				e = e.nexts[h]

			subtreesize[h] = offset
			nodes[h] = e
	
	updateSubtreeSizes = (amt) ->
		for i in [0...nodes.length]
			nodes[i].subtreesize[i] += amt
#			subtreesize[i] += amt

	if e.str? and e.str.length + str.length < splitSize
		# Insert the string into the current element
		e.str = e.str[...offset] + str + e.str[offset..]
		updateSubtreeSizes str.length
		@length += str.length
#		console.log "injected '#{str}'" if Rope.p
	else
		insert = (str) =>
			height = randomHeight()
#			console.log "ins '#{str}' height: #{height} after '#{nodes[0]?.str}'" if Rope.p
#			console.log "subtreesize: #{inspect subtreesize}" if Rope.p
#			console.log "nodes: #{inspect (nodes.map (n) -> n.str)}" if Rope.p
			newE = {str:str, nexts:new Array(height), subtreesize:new Array(height)}
			for i in [0...height]
				if i < @head.nexts.length
					newE.nexts[i] = nodes[i].nexts[i]
					nodes[i].nexts[i] = newE
					newE.subtreesize[i] = str.length + nodes[i].subtreesize[i] - subtreesize[i]
					nodes[i].subtreesize[i] = subtreesize[i]
				else
					newE.nexts[i] = null
					newE.subtreesize[i] = @length - insertPos + str.length
					@head.nexts.push newE
					@head.subtreesize.push insertPos

				nodes[i] = newE
#				subtreesize[i] = nodes[i].subtreesize[i]
				subtreesize[i] = str.length

			if height < nodes.length
				for i in [height...nodes.length]
					nodes[i].subtreesize[i] += str.length
					subtreesize[i] += str.length

			insertPos += str.length
			@length += str.length

			@print() if Rope.p

		if e.str? and e.str.length > offset
#			console.log "peeling out '#{e.str[offset..]}' from #{inspect e}" if Rope.p
			end = e.str[offset..]
			e.str = e.str[...offset]
			updateSubtreeSizes -end.length
			@length -= end.length
			
			@print() if Rope.p

		insert str[i...i + splitSize] for i in [0...str.length] by splitSize
		insert end if end?
	
#	console.log "Resulting string: '#{@toString()}'" if Rope.p
	this

Rope.prototype['del'] = (delPos, length) ->
	throw new Error('pos must be a number') unless typeof delPos == 'number'
	throw new Error("pos #{delPos} must be within the rope (#{@length})") unless 0 <= delPos <= @length
	throw new Error("pos #{delPos + length} must be within the rope (#{@length})") unless 0 <= delPos + length <= @length

#	console.log "Deleting '#{@toString()[delPos...delPos+length]}' at #{delPos}" if Rope.p

	e = @head
	nodes = new Array @head.nexts.length
	
	@print() if Rope.p
	offset = delPos
	if e.nexts.length > 0
		for h in [e.nexts.length - 1..0]
			while offset > e.subtreesize[h]
				offset -= e.subtreesize[h]
				e = e.nexts[h]

			nodes[h] = e

	@length -= length
	while length > 0
		# Delete up to length from e

		if !e.str? or offset == e.str.length
			e = nodes[0].nexts[0]
			offset = 0
		
		removed = Math.min length, e.str.length - offset
#		console.log "#{length} #{offset}"
#		console.log (inspect e)
#		console.log "#{e.str?} #{e.str.length}"

		if removed < e.str.length
			# Splice out the text.
			e.str = e.str[...offset] + e.str[offset + removed..]
			for i in [0...nodes.length]
				if i < e.nexts.length
					e.subtreesize[i] -= removed
				else
					nodes[i].subtreesize[i] -= removed
		else
			# Unlink the element
			for i in [0...nodes.length]
				if i < e.nexts.length
					nodes[i].subtreesize[i] = nodes[i].subtreesize[i] + e.subtreesize[i] - removed
					nodes[i].nexts[i] = e.nexts[i]
				else
					nodes[i].subtreesize[i] -= removed

			e = e.nexts[0]

		length -= removed

	this


# Uncomment these functions in order to run the split size test or the bias test.
# They have been removed to keep the compiled size down.
#Rope.setSplitSize = (s) -> splitSize = s
#Rope.setBias = (n) -> bias = n
