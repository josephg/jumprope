var Rope = require('jumprope');

var r = new Rope("G'day");
r.insert(0, 'Hi there\n')
console.log(r.toString());

r.del(9, 5);
console.log(r.toString());
