"use strict";
// Rope implemented with skip lists!
//
// Each element in the skip list contains a string, an array of next pointers
// and an array of subtree sizes.
//
// The next pointers work like normal skip lists. Here's some google results:
// http://en.wikipedia.org/wiki/Skip_list
// http://igoro.com/archive/skip-lists-are-fascinating/
//
// The subtree size is the number of characters between the start of the current
// element and the start of the next element at that level in the list.
//
// So, e.subtreesize[4] == e.str.length + no. chars between e and e.nexts[4].
//
//
// I use foo['bar'] syntax in a bunch of places to stop the closure compiler renaming
// exported methods.


// The split size is the maximum number of characters to have in each element
// in the list before splitting it out into multiple elements.
// Benchmarking reveals 512 to be a pretty good number for this.
const SPLIT_SIZE = 512

// Each skip list element has height >= H with P=bias^(H-1).
//
// I ran some benchmarks, expecting 0.5 to get the best speed. But, for some reason,
// the speed is a bit better around 0.62
const bias = 0.62

//inspect = require('util').inspect

const randomHeight = () => {
  let length = 1

  // This method uses successive bits of a random number to figure out whick skip lists
  // to be part of. It is faster than the method below, but doesn't support weird biases.
  // It turns out, it is slightly faster to have non-0.5 bias and that offsets the cost of
  // calling random() more times (at least in v8)
//  r = Math.random() * 2
//  while r > 1
//    r = (r - 1) * 2
//    length++

  while (Math.random() > bias) length++

  return length
}

class Rope {
  constructor(str) {
    if (!(this instanceof Rope)) return new Rope(str)

    this.head = {
      nexts: [],
      subtreesize: []
    }
    this.length = 0

    if (str != null) this.insert(0, str)
  }

  forEach(fn) {
    for (const s of this) fn(s)
  }

  toString() {
    const strings = []
    this.forEach(str => strings.push(str))
    return strings.join('')
  }

  *[Symbol.iterator]() {
    // Skip the head, since it has no string.
    let e = this.head.nexts[0]

    while (e) {
      yield e.str
      e = e.nexts[0]
    }
  }

  // Navigate to a particular position in the string. Returns a cursor at that position.
  seek(offset) {
    if (typeof offset !== 'number') throw new Error('position must be a number')
    if (offset < 0 || offset > this.length) {
      throw new Error("pos " + offset + " must be within the rope (" + this.length + ")")
    }

    let e = this.head
    const nodes = new Array(this.head.nexts.length)
    const subtreesize = new Array(this.head.nexts.length)
    if (e.nexts.length > 0) {
      // Iterate backwards through the list.
      let h = e.nexts.length
      while (h--) {
        while (offset > e.subtreesize[h]) {
          offset -= e.subtreesize[h]
          e = e.nexts[h]
        }
        subtreesize[h] = offset
        nodes[h] = e
      }
    }
    return [e, offset, nodes, subtreesize]
  }

  _spliceIn(nodes, subtreesize, insertPos, str) {
    // This function splices the given string into the rope at the specified
    // cursor. The cursor is moved to the end of the string.
    const height = randomHeight()
    const newE = {
      str: str,
      nexts: new Array(height),
      subtreesize: new Array(height)
    }

    for (let i = 0; i < height; i++) {
      if (i < this.head.nexts.length) {
        newE.nexts[i] = nodes[i].nexts[i]
        nodes[i].nexts[i] = newE
        newE.subtreesize[i] = str.length + nodes[i].subtreesize[i] - subtreesize[i]
        nodes[i].subtreesize[i] = subtreesize[i]
      } else {
        newE.nexts[i] = null
        newE.subtreesize[i] = this.length - insertPos + str.length
        this.head.nexts.push(newE)
        this.head.subtreesize.push(insertPos)
      }
      nodes[i] = newE
      subtreesize[i] = str.length
    }

    if (height < nodes.length) {
      for (let i = height; i < nodes.length; i++) {
        nodes[i].subtreesize[i] += str.length
        subtreesize[i] += str.length
      }
    }

    insertPos += str.length
    this.length += str.length

    return insertPos;
  }

  _updateLength(nodes, length) {
    for (let i = 0; i < nodes.length; i++) {
      nodes[i].subtreesize[i] += length
    }
    this.length += length
  }

  insert(insertPos, str) {
    if (typeof str !== 'string') throw new Error('inserted text must be a string')

    // The spread operator isn't in nodejs yet.
    const cursor = this.seek(insertPos)
    const [e, offset, nodes, subtreesize] = cursor

    if (e.str != null && e.str.length + str.length < SPLIT_SIZE) {
      // The new string will fit in the end of the current item
      e.str = e.str.slice(0, offset) + str + e.str.slice(offset)
      this._updateLength(nodes, str.length)
    } else {
      // Insert a new item

      // If there's stuff at the end of the current item, we'll remove it for now:
      let end = ''
      if (e.str != null && e.str.length > offset) {
        end = e.str.slice(offset)
        e.str = e.str.slice(0, offset)
        this._updateLength(nodes, -end.length)
      }

      // Split up the new string based on SPLIT_SIZE and insert each chunk.
      for (let i = 0; i < str.length; i += SPLIT_SIZE) {
        insertPos = this._spliceIn(nodes, subtreesize, insertPos, str.slice(i, i + SPLIT_SIZE))
      }
      if (end !== '') this._spliceIn(nodes, subtreesize, insertPos, end)
    }

    // For chaining.
    return this
  }

  // Delete characters at the specified position. This function returns this
  // for chaining, but if you want the deleted characters back you can pass a
  // function to recieve them. It'll get called syncronously.
  del(delPos, length, getDeleted) {
    if (delPos < 0 || delPos + length > this.length) {
      throw new Error(`positions #{delPos} and #{delPos + length} must be within the rope (#{this.length})`)
    }
    
    // Only collect strings if we need to.
    let strings = getDeleted != null ? [] : null

    const cursor = this.seek(delPos)
    let e = cursor[0], offset = cursor[1], nodes = cursor[2]

    this.length -= length
    while (length > 0) {
      // Delete up to length from e.
      
      if (e.str == null || offset === e.str.length) {
        // Move along to the next node.
        e = nodes[0].nexts[0]
        offset = 0
      }

      let removed = Math.min(length, e.str.length - offset)
      if (removed < e.str.length) {
        // We aren't removing the whole node.
        
        if (strings != null) strings.push(e.str.slice(offset, offset + removed))

        // Splice out the string
        e.str = e.str.slice(0, offset) + e.str.slice(offset + removed)
        for (let i = 0; i < nodes.length; i++) {
          if (i < e.nexts.length) {
            e.subtreesize[i] -= removed
          } else {
            nodes[i].subtreesize[i] -= removed
          }
        }
      } else {
        // Remove the whole node.
        
        if (strings != null) strings.push(e.str)

        // Unlink the element.
        for (let i = 0; i < nodes.length; i++) {
          let node = nodes[i]
          if (i < e.nexts.length) {
            node.subtreesize[i] = nodes[i].subtreesize[i] + e.subtreesize[i] - removed
            node.nexts[i] = e.nexts[i]
          } else {
            node.subtreesize[i] -= removed
          }
        }

        // It would probably be better to make a little object pool here.
        e = e.nexts[0]
      }
      length -= removed
    }
    if (getDeleted) getDeleted(strings.join(''))
    return this;
  }

  // Extract a substring at the specified offset and of the specified length
  substring(offsetIn, length) {
    if (offsetIn < 0 || offsetIn + length > this.length) {
      throw new Error(`Substring (#{offsetIn}-#{offsetIn+length} outside rope (length #{this.length})`);
    }

    let [e, offset] = this.seek(offsetIn)

    const strings = []
    if (e.str == null) e = e.nexts[0]

    while (e && length > 0) {
      let s = e.str.slice(offset, offset + length)
      strings.push(s)
      offset = 0
      length -= s.length
      e = e.nexts[0]
    }
    return strings.join('')
  }

  // For backwards compatibility.
  each(fn) { this.forEach(fn) }
  search(offset) { return this.seek(offset) }
}

module.exports = Rope;

// Uncomment these functions in order to run the split size test or the bias test.
// They have been removed to keep the compiled size down.
// Rope.setSplitSize = s => splitSize = s
// Rope.setBias = n => bias = n

