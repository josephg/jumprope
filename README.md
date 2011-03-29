JumpRope
========

Jumprope is a fun little library for efficiently editing strings in Javascript. If you have long strings and you need to insert or delete into them, you should use jumprope. Its way faster than splicing strings all the time, especially if the strings are big:

    200000 random edits on an empty string, resulting in the string of size 431 206 chars long:

    Rope took 1788 ms. 0.00894 ms per iteration, or 111856.82326621923 iterations per second
	Js strings took 40962 ms. 0.20481 ms per iteration, or 4882.574093061862 iterations per second

Ropes have insertion and deletion time of O(|s| * log(N)) where
|s| is the length of the inserted / deleted region
N is the length of the string

In comparison, javascript strings have insertion time of O(N + s) and deletion time of O(N - s).

The code itself is written in coffeescript, because it was much more fun that way. It compiles down to 2.5kb for the browser.

Installing
----------

    npm install jumprope

Usage
-----

    Rope = require('jumprope');
    
    var r = new Rope('initial string');
    r.insert(4, 'some text'); // Insert 'some text' at position 4 in the string
    r.delete(4, 9); // Delete 9 characters from the string at position 4
    console.log("String contains: " + r.toString() + " length: " + r.length);


Speed
-----

At least in V8 (Node / Chrome) it seems like the cross-over point where it becomes worth using jumpropes is when you're dealing with strings longer than about 5000 characters. Until then, the overheads of jumpropes makes them slower than just dealing with normal javascript strings.

Of course, when your strings are that small it doesn't matter that much how you're using them.

Once your strings get long, jumpropes become a lot faster.
