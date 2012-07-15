# initMottos.coffee

Mottos = require "./lib/mottos"
Posts = require "./lib/Posts"
log = (require "logging").from(__filename)

# Get the arguments passed in, we splice from 2 because the first is path to node js and second is path to executing file
args = process.argv.splice 2

# Load from parameters or fall back to posts
initType = args[0] or "posts"

init = 
  mottos: ->
    # Jacob Gable ...
    txts = [
      "sees angels in the architecture.", 
      "just wants to love you.", 
      "is a trendy catch phrase generator.", 
      "is a young punk.", 
      "is audacious.",
      "can see a million miles tonight.",
      "is not a tourist.",
      "rocks the mic.",
      "is an amateur philosopher.",
      "slings code for a living.",
      "doesn't always drink beer..."
    ]

    count = txts.length

    txts.forEach (el) ->
      Mottos.Create el, ->
        log "Created: #{el}"
        process.exit(0) unless count-- > 0

  posts: ->
    count = 10
    for idx in [1..count + 1]
      Posts.NewDraft "test Post #{idx}", (draft) ->
        
        updates = 
          publish: true
          publishDate: new Date

        Posts.Update draft._id, updates, (post) ->
          log "Post Published: #{post.title}"
          process.exit 0 unless count-- > 0

do init[initType]