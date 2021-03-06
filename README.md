JumpRope
========

Jumprope is a fun little library for efficiently editing strings in Javascript. If you have long strings and you need to insert or delete into them, you should use jumprope. Its faster than splicing strings all the time if the strings are big:

    5000000 random inserts on an empty string, resulting in the string of size 6M chars long:

    Rope took 5610 ms. 0.001122 ms per iteration, 891k iterations per second
    JS toString took 3463 ms. 0.003463 ms per iteration, 288k iterations per second

    (Tested on node v10.13.0)


Ropes have insertion and deletion time of O(|s| * log(N)) where
|s| is the length of the inserted / deleted region
N is the length of the string

In comparison, naive strings have insertion time of O(N + s) and deletion time of O(N - s). Javascript strings are special and complicated, and much fancier than naive strings. This library was written several years ago. NodeJS strings have gotten faster in the intervening time, and using pure JS strings is a reasonable choice for recent applications.


Installing
----------

    npm install jumprope

Usage
-----

```javascript
Rope = require('jumprope');

var r = new Rope('initial string');
r.insert(4, 'some text'); // Insert 'some text' at position 4 in the string
r.del(4, 9); // Delete 9 characters from the string at position 4
console.log("String contains: " + r.toString() + " length: " + r.length);
```

Output:

    String contains: 'initial string' length: 14

API
---

* `new Rope([initial text])`

Create a new rope, optionally with the specified initial text.

```javascript
Rope = require('jumprope');

var r = new Rope(); // Create a new Rope
var r = new Rope('str'); // Create a new Rope with initial string 'str'
```

* `r.insert(position, text)`

Insert text into the rope at the specified position.

```javascript
r.insert(4, 'some text'); // Insert 'some text' at position 4. Position must be inside the string.
```

* `r.del(position, count, [callback])`

Delete `count` characters from the rope at `position`. Delete can optionally take a callback, which is called with the deleted substring.

```javascript
r.del(4, 10); // Delete 10 characters at position 4
r.del(4, 10, function(str) { console.log(str); }); // Delete 10 characters, and print them out.
```

* `r.forEach(callback)`

Iterate through the rope. The callback will be passed the whole string, a few characters at a time. This is the fastest way to read the string if you want to write it over a network stream, for example.

```javascript
// Print the string out, a few characters at a time.
r.forEach(function(str) { console.log(str); })
```

* `r.toString()`

Convert the rope into a javascript string.

Internally, this just calls `forEach()` and `.join`'s the result.

```javascript
console.log(r.toString());
```

* `r.length`

Get the number of characters in the rope.

```javascript
r.del(r.length - 4, 4); // Delete the last 4 characters in the string.
```

* `r.substring(position, length)`

Get a substring of the string. Kinda like splice, I guess. Maybe I should copy the JS API.

```javascript
console.log(r.substring(4, 10)); // Print out 10 characters from position 4 onwards.
```

Speed
-----

At least in V8 (Node / Chrome) it seems like the cross-over point where it becomes worth using jumpropes is when you're dealing with strings longer than about 5000 characters. Until then, the overheads of jumpropes makes them slower than just dealing with normal javascript strings.

Of course, when your strings are that small it doesn't matter that much how you're using them.

Once your strings get long, jumpropes become a lot faster.


License
-------

MIT licensed, so do what you want with it.


Acknowledgements
----------------

Thanks to Ben Weaver for his node [closure library](https://github.com/weaver/scribbles/tree/master/node/google-closure/)
