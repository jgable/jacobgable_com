require 'coffee-script'
express = require 'express'
crypto = require 'crypto'
assets = require 'connect-assets'
errorface = require "errorface"

Mottos = require "./lib/mottos"
Posts = require "./lib/Posts"
secrets = require "./lib/secrets"

MemoryStore = express.session.MemoryStore

# Settings
settings = 
  blogPageLimit: 3

# Express Config
app = express()
app.use express.bodyParser()
app.use express.cookieParser secrets.salt
app.use express.session
  key: secrets.cookieKey
  secret: secrets.salt
  store: new MemoryStore
    reapInterval: 60000 * 10 # 60 Mins
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

# Basic Auth Checking
checkLoggedIn = (req, resp, next) ->
  resp.redirect "/login" unless req.session.loggedin

  do next

# Routes
app.get '/', (req, resp) -> 
  mottoRender resp

app.get "/about", (req, resp) ->
  mottoRender resp, "about"

app.get "/projects", (req, resp) ->
  mottoRender resp, "projects"

# list posts on other pages.
app.get "/blog/page/:pageNum", blogPageRender

# Admin area
app.get "/blog/admin", checkLoggedIn, (req, resp) ->
  Posts.List (posts) ->
    resp.render 'admin',
      drafts: posts?.drafts or []
      published: posts?.published or []

app.get "/blog/draft", checkLoggedIn, (req, resp) ->
  resp.render "draft"

app.post "/blog/draft", checkLoggedIn, (req, resp) ->
  Posts.NewDraft req.param("title"), req.param("markdown"), (post) ->
    # TODO redirect to edit?
    resp.redirect "/blog/admin"

# Edit post
app.get "/blog/edit/:slug", checkLoggedIn, (req, resp) ->

  # TODO: Some sanitizing on slug?
  Posts.BySlug req.param("slug"), (post) ->
    resp.redirect "/blog/admin" unless post

    resp.render "edit",
      post: post

app.post "/blog/edit/:slug", checkLoggedIn, (req, resp) ->

  updates = 
    title: req.param("title")
    markdown: req.param("markdown")
    # TODO: Publish?
    #publish: 

  Posts.Update req.param("id"), updates, (post) ->
    resp.redirect "/blog/admin" unless post

    resp.render "edit",
      post: post

# Publish post
app.get "/blog/publish/:slug", checkLoggedIn, (req, resp) ->

  Posts.BySlug req.param("slug"), (post) ->
    Posts.Update post._id, { publish: true }, (post) ->
      resp.redirect "/blog/edit/#{req.param("slug")}" unless post

      resp.redirect "/blog/#{post.slug}"

app.get "/blog/delete/:slug", checkLoggedIn, (req, resp) ->

  Posts.DeleteBySlug req.param("slug"), ->
    resp.redirect "/blog/admin"

# post by slug
app.get "/blog/:slug", (req, resp) ->
  
  # TODO: Some sanitizing on slug?
  Posts.BySlug req.param("slug"), (post) ->
    mottoRender resp, "post",
      post: post or {}

# list posts on first page.
app.get "/blog", blogPageRender

app.get "/login", (req, resp) ->
  
  resp.redirect "/blog/admin" if req.session.loggedin

  resp.render "login"
    message: ""

app.post "/login", (req, resp) ->
  pwd = req.param["password"] or req.body["password"] or ""

  # TODO: bcrypt the hash
  pwdHash = crypto.createHash('md5').update(pwd).digest('hex')
  if pwd && pwdHash == secrets.adminPassHash
    req.session.loggedin = true
    resp.redirect "/blog/admin"
  else
    resp.render "login",
      message: "Incorrect Password"
  
app.get "/logout", (req, resp) ->
  req.session.loggedin = false
  resp.redirect "/"

app.get "/*", (req, resp) ->
  resp.send 404

port = process.env.VMC_APP_PORT or 3000

app.listen port, -> console.log "Listening... [#{ port }]"
