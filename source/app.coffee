require 'coffee-script'
express = require 'express'
crypto = require 'crypto'
assets = require 'connect-assets'
Mottos = require "./lib/mottos"
Posts = require "./lib/Posts"
secrets = require "./lib/secrets"

MemoryStore = express.session.MemoryStore

# Settings
settings = 
  blogPageLimit: 3

# Express Config
app = express()
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
checkLoggedIn = (req, resp) ->
  resp.redirect "/login" unless req.session.loggedin

# Routes
app.get '/', (req, resp) -> 
  mottoRender resp

app.get "/about", (req, resp) ->
  mottoRender resp, "about"

app.get "/projects", (req, resp) ->
  mottoRender resp, "projects"

app.get "/blog", blogPageRender

app.get "/blog/page/:pageNum", blogPageRender

app.get "/blog/admin", checkLoggedIn, (req, resp) ->
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

app.get "/login", (req, resp) ->
  
  # Keep the return_url if passed in; but we're ignoring it below.
  if req.param["return_url"]
    req.session.return_url = req.param["return_url"]

  resp.render "login"
    message: ""

app.post "/login", (req, resp) ->
  pwd = req.param["password"]
  # TODO: bcrypt the hash
  if pwd && crypto.createHash('md5').update(pwd).digest('hex') == secrets.adminPassHash
    req.session.loggedin = true
    resp.render "admin"
  else
    resp.render "login",
      message: "Incorrect Password"
  
app.get "/logout", (req, resp) ->
  req.session.loggedin = false
  resp.redirect "/"

port = process.env.VMC_APP_PORT or 3000

app.listen port, -> console.log "Listening... [#{ port }]"
