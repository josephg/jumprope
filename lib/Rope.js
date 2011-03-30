(function() {
  var Rope, bias, each, randomHeight, splitSize;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  splitSize = 512;
  bias = 0.7;
  randomHeight = function() {
    var length;
    length = 1;
    while (Math.random() > bias) {
      length++;
    }
    return length;
  };
  module['exports'] = Rope = function(str) {
    if (!(this instanceof Rope)) {
      return new Rope(str);
    }
    this.head = {
      nexts: [],
      subtreesize: []
    };
    this.length = 0;
    if (str != null) {
      this['insert'](0, str);
    }
    return this;
  };
  Rope.prototype['each'] = each = function(fn) {
    var e, _results;
    e = this.head.nexts[0];
    _results = [];
    while (e != null) {
      fn(e.str);
      _results.push(e = e.nexts[0]);
    }
    return _results;
  };
  Rope.prototype['toString'] = function() {
    var strings;
    strings = [];
    this['each'](function(str) {
      return strings.push(str);
    });
    return strings.join('');
  };
  Rope.prototype['insert'] = function(insertPos, str) {
    var e, end, h, i, insert, nodes, offset, subtreesize, updateSubtreeSizes, _ref, _ref2;
    if (typeof insertPos !== 'number') {
      throw new Error('pos must be a number');
    }
    if (!((0 <= insertPos && insertPos <= this.length))) {
      throw new Error("pos must be within the rope (" + this.length + ")");
    }
    if (typeof str !== 'string') {
      throw new Error('inserted text must be a string');
    }
    e = this.head;
    nodes = new Array(this.head.nexts.length);
    subtreesize = new Array(this.head.nexts.length);
    offset = insertPos;
    if (e.nexts.length > 0) {
      for (h = _ref = this.head.nexts.length - 1; (_ref <= 0 ? h <= 0 : h >= 0); (_ref <= 0 ? h += 1 : h -= 1)) {
        while (offset > e.subtreesize[h]) {
          offset -= e.subtreesize[h];
          e = e.nexts[h];
        }
        subtreesize[h] = offset;
        nodes[h] = e;
      }
    }
    updateSubtreeSizes = function(amt) {
      var i, _ref, _results;
      _results = [];
      for (i = 0, _ref = nodes.length; (0 <= _ref ? i < _ref : i > _ref); (0 <= _ref ? i += 1 : i -= 1)) {
        _results.push(nodes[i].subtreesize[i] += amt);
      }
      return _results;
    };
    if ((e.str != null) && e.str.length + str.length < splitSize) {
      e.str = e.str.slice(0, offset) + str + e.str.slice(offset);
      updateSubtreeSizes(str.length);
      this.length += str.length;
    } else {
      insert = __bind(function(str) {
        var height, i, newE, _ref;
        height = randomHeight();
        newE = {
          str: str,
          nexts: new Array(height),
          subtreesize: new Array(height)
        };
        for (i = 0; (0 <= height ? i < height : i > height); (0 <= height ? i += 1 : i -= 1)) {
          if (i < this.head.nexts.length) {
            newE.nexts[i] = nodes[i].nexts[i];
            nodes[i].nexts[i] = newE;
            newE.subtreesize[i] = str.length + nodes[i].subtreesize[i] - subtreesize[i];
            nodes[i].subtreesize[i] = subtreesize[i];
          } else {
            newE.nexts[i] = null;
            newE.subtreesize[i] = this.length - insertPos + str.length;
            this.head.nexts.push(newE);
            this.head.subtreesize.push(insertPos);
          }
          nodes[i] = newE;
          subtreesize[i] = str.length;
        }
        if (height < nodes.length) {
          for (i = height, _ref = nodes.length; (height <= _ref ? i < _ref : i > _ref); (height <= _ref ? i += 1 : i -= 1)) {
            nodes[i].subtreesize[i] += str.length;
            subtreesize[i] += str.length;
          }
        }
        insertPos += str.length;
        this.length += str.length;
        if (Rope.p) {
          return this.print();
        }
      }, this);
      if ((e.str != null) && e.str.length > offset) {
        end = e.str.slice(offset);
        e.str = e.str.slice(0, offset);
        updateSubtreeSizes(-end.length);
        this.length -= end.length;
        if (Rope.p) {
          this.print();
        }
      }
      for (i = 0, _ref2 = str.length; (0 <= _ref2 ? i < _ref2 : i > _ref2); i += splitSize) {
        insert(str.slice(i, i + splitSize));
      }
      if (end != null) {
        insert(end);
      }
    }
    return this;
  };
  Rope.prototype['del'] = function(delPos, length, callback) {
    var e, h, i, nodes, offset, removed, strings, _ref, _ref2, _ref3, _ref4;
    if (typeof delPos !== 'number') {
      throw new Error('pos must be a number');
    }
    if (!((0 <= delPos && delPos <= this.length))) {
      throw new Error("pos " + delPos + " must be within the rope (" + this.length + ")");
    }
    if (!((0 <= (_ref = delPos + length) && _ref <= this.length))) {
      throw new Error("pos " + (delPos + length) + " must be within the rope (" + this.length + ")");
    }
    e = this.head;
    nodes = new Array(this.head.nexts.length);
    if (callback != null) {
      strings = [];
    }
    if (Rope.p) {
      this.print();
    }
    offset = delPos;
    if (e.nexts.length > 0) {
      for (h = _ref2 = e.nexts.length - 1; (_ref2 <= 0 ? h <= 0 : h >= 0); (_ref2 <= 0 ? h += 1 : h -= 1)) {
        while (offset > e.subtreesize[h]) {
          offset -= e.subtreesize[h];
          e = e.nexts[h];
        }
        nodes[h] = e;
      }
    }
    this.length -= length;
    while (length > 0) {
      if (!(e.str != null) || offset === e.str.length) {
        e = nodes[0].nexts[0];
        offset = 0;
      }
      removed = Math.min(length, e.str.length - offset);
      if (removed < e.str.length) {
        if (strings != null) {
          strings.push(e.str.slice(offset, offset + removed));
        }
        e.str = e.str.slice(0, offset) + e.str.slice(offset + removed);
        for (i = 0, _ref3 = nodes.length; (0 <= _ref3 ? i < _ref3 : i > _ref3); (0 <= _ref3 ? i += 1 : i -= 1)) {
          if (i < e.nexts.length) {
            e.subtreesize[i] -= removed;
          } else {
            nodes[i].subtreesize[i] -= removed;
          }
        }
      } else {
        if (callback != null) {
          strings.push(e.str);
        }
        for (i = 0, _ref4 = nodes.length; (0 <= _ref4 ? i < _ref4 : i > _ref4); (0 <= _ref4 ? i += 1 : i -= 1)) {
          if (i < e.nexts.length) {
            nodes[i].subtreesize[i] = nodes[i].subtreesize[i] + e.subtreesize[i] - removed;
            nodes[i].nexts[i] = e.nexts[i];
          } else {
            nodes[i].subtreesize[i] -= removed;
          }
        }
        e = e.nexts[0];
      }
      length -= removed;
    }
    if (callback != null) {
      callback(strings.join(''));
    }
    return this;
  };
}).call(this);
