var system = require('system');
var args = system.args;

console.log('bar ' + args[1]);
console.log('bar ' + args[2]);
phantom.exit();
