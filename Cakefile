task 'test', () ->
	nodeunit = require 'nodeunit'
	
	nodeunit.on 'done', () -> process.nextTick process.exit
	nodeunit.reporters.default.run ['test']