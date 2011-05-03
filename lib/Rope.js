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
    while (e) {
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
  Rope.prototype.search = function(offset) {
    var e, h, nodes, subtreesize, _ref;
    if (typeof offset !== 'number') {
      throw new Error('position must be a number');
    }
    if (!((0 <= offset && offset <= this.length))) {
      throw new Error("pos " + offset + " must be within the rope (" + this.length + ")");
    }
    e = this.head;
    nodes = new Array(this.head.nexts.length);
    subtreesize = new Array(this.head.nexts.length);
    if (e.nexts.length > 0) {
      for (h = _ref = e.nexts.length - 1; _ref <= 0 ? h <= 0 : h >= 0; _ref <= 0 ? h++ : h--) {
        while (offset > e.subtreesize[h]) {
          offset -= e.subtreesize[h];
          e = e.nexts[h];
        }
        subtreesize[h] = offset;
        nodes[h] = e;
      }
    }
    return [e, offset, nodes, subtreesize];
  };
  Rope.prototype['insert'] = function(insertPos, str) {
    var e, end, i, insert, nodes, offset, subtreesize, updateSubtreeSizes, _ref, _ref2;
    if (typeof str !== 'string') {
      throw new Error('inserted text must be a string');
    }
    _ref = this.search(insertPos), e = _ref[0], offset = _ref[1], nodes = _ref[2], subtreesize = _ref[3];
    updateSubtreeSizes = function(amt) {
      var i, _ref2, _results;
      _results = [];
      for (i = 0, _ref2 = nodes.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; 0 <= _ref2 ? i++ : i--) {
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
        var height, i, newE, _ref2;
        height = randomHeight();
        newE = {
          str: str,
          nexts: new Array(height),
          subtreesize: new Array(height)
        };
        for (i = 0; 0 <= height ? i < height : i > height; 0 <= height ? i++ : i--) {
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
          for (i = height, _ref2 = nodes.length; height <= _ref2 ? i < _ref2 : i > _ref2; height <= _ref2 ? i++ : i--) {
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
      for (i = 0, _ref2 = str.length; 0 <= _ref2 ? i < _ref2 : i > _ref2; i += splitSize) {
        insert(str.slice(i, i + splitSize));
      }
      if (end != null) {
        insert(end);
      }
    }
    return this;
  };
  Rope.prototype['del'] = function(delPos, length, callback) {
    var e, i, nodes, offset, removed, strings, _ref, _ref2, _ref3, _ref4;
    if (!((0 <= (_ref = delPos + length) && _ref <= this.length))) {
      throw new Error("pos " + (delPos + length) + " must be within the rope (" + this.length + ")");
    }
    if (callback != null) {
      strings = [];
    }
    if (Rope.p) {
      this.print();
    }
    _ref2 = this.search(delPos), e = _ref2[0], offset = _ref2[1], nodes = _ref2[2];
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
        for (i = 0, _ref3 = nodes.length; 0 <= _ref3 ? i < _ref3 : i > _ref3; 0 <= _ref3 ? i++ : i--) {
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
        for (i = 0, _ref4 = nodes.length; 0 <= _ref4 ? i < _ref4 : i > _ref4; 0 <= _ref4 ? i++ : i--) {
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
  Rope.prototype['substring'] = function(offset, length) {
    var e, s, strings, _ref, _ref2;
    if (!((0 <= (_ref = offset + length) && _ref <= this.length))) {
      throw new Error("pos " + (offset + length) + " must be within the rope (" + this.length + ")");
    }
    _ref2 = this.search(offset), e = _ref2[0], offset = _ref2[1];
    strings = [];
    if (e.str == null) {
      e = e.nexts[0];
    }
    while (e && length > 0) {
      s = e.str.slice(offset, offset + length);
      strings.push(s);
      offset = 0;
      length -= s.length;
      e = e.nexts[0];
    }
    return strings.join('');
  };
}).call(this);
