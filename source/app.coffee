express = require 'express'
stylus = require 'stylus'
assets = require 'connect-assets'
Mottos = require "./lib/mottos"
Posts = require "./lib/Posts"

# Settings
settings = 
  blogPageLimit: 3

# Express Config
app = express()
app.use express.cookieParser()
app.use express.session({ secret: "Salty Dog" })
app.use express.static(__dirname + '/public')
app.use assets()

app.set 'view engine', 'jade'

# Render Helpers
mottoRender = (resp, vw = "index", data = {}) ->
  # Get Mottos from Mongoose.
  Mottos.Random (mot) ->
    data.motto = mot?.text or "has nothing interesting to say."
    resp.render vw, data

blogPageRender = (req, resp) ->
  pageNum = req.param("pageNum") or 1

  # Zero check for the pages.
  if pageNum < 1
    pageNum = 1

  Posts.Recent (pageNum - 1), settings.blogPageLimit, (posts) ->
    mottoRender resp, "blog",
      posts: posts or []
      pageNum: pageNum

# Routes
app.get '/', (req, resp) -> 
  mottoRender resp

app.get "/about", (req, resp) ->
  mottoRender resp, "about"

app.get "/projects", (req, resp) ->
  mottoRender resp, "projects"

app.get "/blog", blogPageRender

app.get "/blog/page/:pageNum", blogPageRender

app.get "/blog/admin", (req, resp) ->
  # TODO: Authenticate
  Posts.List (posts) ->
    resp.render 'admin',
      drafts: posts?.drafts or []
      published: posts?.published or []

app.get "/blog/:slug", (req, resp) ->
  
  # TODO: Some sanitizing on slug?
  Posts.BySlug req.param("slug"), (post) ->
    mottoRender resp, "post",
      post: post or {}

port = process.env.VMC_APP_PORT or 3000

app.listen port, -> console.log "Listening... [#{ port }]"
