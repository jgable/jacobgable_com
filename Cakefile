fs            = require 'fs'
{print}       = require 'util'
{spawn, exec} = require 'child_process'

# ANSI Terminal Colors
bold  = '\x1B[0;1m'
red   = '\x1B[0;31m'
green = '\x1B[0;32m'
reset = '\x1B[0m'

pkg = JSON.parse fs.readFileSync('./package.json')
testCmd = pkg.scripts.test
startCmd = pkg.scripts.start
  

log = (message, color, explanation) ->
  console.log color + message + reset + ' ' + (explanation or '')

# Nothing to build here, don't need extra js files around.
build = (callback) ->
  callback?()

# mocha test
test = (callback) ->
  options = [
    '--compilers'
    'coffee:coffee-script'
    '--colors'
    '--require'
    'should'
    '--require'
    './server'
  ]
  spec = spawn 'mocha', options
  spec.stdout.pipe process.stdout 
  spec.stderr.pipe process.stderr
  spec.on 'exit', (status) -> callback?() if status is 0

task 'docs', 'Generate annotated source code with Docco', ->
  fs.readdir 'src', (err, contents) ->
    files = ("src/#{file}" for file in contents when /\.coffee$/.test file)
    docco = spawn 'docco', files
    docco.pipe process.stdout
    docco.stdout.pipe process.stdout
    docco.stderr.pipe process.stderr
    docco.on 'exit', (status) -> callback?() if status is 0


task 'build', ->
  build -> log ":)", green

task 'spec', 'Run Mocha tests', ->
  test -> log ":)", green

task 'test', 'Run Mocha tests', ->
  test -> log ":)", green

task 'data', 'Start database', ->
  options = ["--dbpath", "./data"]
  mongo = spawn 'mongod', options
  mongo.stdout.pipe process.stdout
  mongo.stderr.pipe process.stderr
  log "Started Mongo", green

task 'dev', 'start dev env', ->
  # TODO: Start mongo?

  # watch_coffee
  options = ['-c', '-b', '-w', '-o', 'lib']
  coffee = spawn './node_modules/coffee-script/bin/coffee', options
  coffee.stdout.pipe process.stdout
  coffee.stderr.pipe process.stderr
  log 'Watching coffee files', green
  # watch_js
  supervisor = spawn 'node', ['./node_modules/supervisor/lib/cli-wrapper.js','-w','app,views', '-e', 'coffee|js|jade', 'server']
  supervisor.stdout.pipe process.stdout
  supervisor.stderr.pipe process.stderr
  log 'Watching js files and running server', green

  