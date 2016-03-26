assert = require 'assert'

Rope = require '../rope'

helpers = require './helpers'
helpers.addHelpers Rope

{randomInt, randomStr} = helpers

RopeCompiled = try
  require '../Rope.min'
catch e
  null

#Rope = helpers.Str

check = (r, str) ->
  try
    r.verify() if r.verify
    assert.strictEqual r.toString(), str
    assert.strictEqual r.length, str.length

    strings = []
    r.each (s) -> strings.push s
    assert.strictEqual strings.join(''), str
  catch e
    console.error 'Error when checking string:'
    r.print() if r.print
    throw e


describe 'Rope', ->
  it 'has no content when empty', ->
    r = new Rope
    check r, ''
  
  it 'rope initialized with a string has that string as its content', ->
    str = 'Hi there'
    r = new Rope str
    check r, str

  it 'inserts at location', ->
    r = new Rope

    r.insert 0, 'AAA'
    check r, 'AAA'

    r.insert 0, 'BBB'
    check r, 'BBBAAA'

    r.insert 6, 'CCC'
    check r, 'BBBAAACCC'

    r.insert 5, 'DDD'
    check r, 'BBBAADDDACCC'
  
  it 'deletes at location', ->
    r = new Rope '012345678'

    r.del 8, 1
    check r, '01234567'

    r.del 0, 1
    check r, '1234567'

    r.del 5, 1
    check r, '123457'

    r.del 5, 1
    check r, '12345'

    r.del 0, 5
    check r, ''

  it 'delete calls callback with deleted text', ->
    r = new Rope 'abcde'
    called = false
    r.del 1, 3, (str) ->
      called = true
      assert.strictEqual str, 'bcd'

    assert called

  it 'does not call forEach with an empty string', ->
    r = new Rope
    # This probably won't call the method at all...
    r.forEach (str) ->
      throw Error 'should not be called'
      #assert.strictEqual str, ''

  it 'runs each correctly with small strings', ->
    str = 'howdy doody'
    r = new Rope str

    strings = []
    r.each (s) -> strings.push s
    assert.strictEqual strings.join(''), str

  it 'substring with an empty string', ->
    r = new Rope
    s = r.substring 0, 0
    assert.strictEqual s, ''

  it 'substring', ->
    r = new Rope '0123456'

    assert.strictEqual '0', r.substring 0, 1
    assert.strictEqual '1', r.substring 1, 1
    assert.strictEqual '01', r.substring 0, 2
    assert.strictEqual '0123456', r.substring 0, 7
    assert.strictEqual '456', r.substring 4, 3

  it 'delete and insert with long strings works as expected', ->
    str = "some really long string. Look at me go! Oh my god this has to be the longest string I've ever seen. Holy cow. I can see space from up here. Hi everybody - check out my amazing string!\n"
    str = new Array(1001).join str

    r = new Rope str
    assert.strictEqual r.length, str.length
    assert.strictEqual r.toString(), str

    r.del 1, str.length - 2
    assert.strictEqual r.length, 2
    assert.strictEqual r.toString(), str[0] + str[str.length - 1]

  it 'randomized test', ->
    str = ''
    r = new Rope

    for [1..1000]
      if Math.random() < 0.9
        # Insert.
        text = randomStr(100)
        pos = randomInt(str.length + 1)

#        console.log "Inserting '#{text}' at #{pos}"

        r.insert pos, text
        str = str[0...pos] + text + str[pos..]
      else
        # Delete
        pos = randomInt(str.length)
        length = Math.min(str.length - pos, Math.floor(Math.random() * 10))

#        console.log "Deleting #{length} chars (#{str[pos...pos + length]}) at #{pos}"

        deletedText = str[pos...pos + length]
        assert.strictEqual deletedText, r.substring pos, length

        callbackCalled = no
        r.del pos, length, (s) ->
          assert.strictEqual s, deletedText
          callbackCalled = yes

        str = str[0...pos] + str[(pos + length)...]

        assert.strictEqual callbackCalled, yes, 'didnt call the delete callback'

      check r, str
      assert.strictEqual str, r.toString()
      assert.strictEqual str.length, r.length

    r.stats() if r.stats?

