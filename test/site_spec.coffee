should = require "should"
mongoose = require "mongoose"
Mottos = require "../lib/mottos"
Posts = require "../lib/Posts"

testMotto = null
errIf = (condition, msg) ->
  throw new Error(msg) unless condition

describe "jacobgable.com technology stack", ->
	it "runs on node.js", -> true
	it "uses express-coffee, a coffescript based express template", -> true
	it "is using mocha", -> true
	it "is using the should module for tests", -> 
		should.exist should
	it "uses mongo and mongoose for data persistence", ->
		should.exist mongoose

describe "jacobgable.com mottos", ->
  it "has a Mottos module", ->
    should.exist Mottos
  it "can create Mottos", (done) ->
    should.exist Mottos.Create
    makeOne = (cb) ->
    	Mottos.Create "testMotto" + ((Math.random() * 100)|0), (newMotto) ->
    	  testMotto = newMotto
    	  should.exist testMotto
    	  do cb unless !cb
    	  
    makeOne makeOne makeOne done

  it "can return a random motto", (done) ->
  	should.exist Mottos.Random

  	Mottos.Random (mot) ->
  		should.exist mot
  		do done

  it "can reset test Mottos we've created", (done) ->
  	should.exist Mottos.RemoveWhere
  	
  	isTestMotto = ->
  		@text.slice(0, 4) == "test"

  	Mottos.RemoveWhere isTestMotto, done

describe "jacobgable.com content", ->
	it "has a stylish design based on Dustin Curtis' svbtl layout", -> true
	it "has a landing area with links to about, blog, projects, github", -> true
	it "shows a random motto", -> true
	it "has an about page that has my bio and link to stack overflow careers page", -> true
	it "has a projects page that lists some recent projects", -> true

describe "jacobgable.com blog data", ->
  currDraft = null

  it "has a Posts module", ->
    should.exist Posts
  
  it "can create Drafts", (done) ->
    should.exist Posts.NewDraft

    Posts.NewDraft "test New Draft", "# Post Header \n\n Some content for this post", (draft) ->
      errIf draft, "draft is null"

      currDraft = draft

      do done

  it "can publish a draft", (done) ->
    should.exist Posts.Update, "Posts.Update"
    should.exist currDraft, "currDraft"
    should.exist currDraft._id, "currDraft.id"

    postDetails = 
      markdown: "Some post content"
      publish: true
      publishDate: new Date

    Posts.Update currDraft._id, postDetails, (post) ->
      
      throw "post null" unless post
      throw "post not found" unless post != "notfound"

      throw "post not published" unless post.publish

      currDraft = post
      
      do done

  it "can return recent published posts", (done) ->
    should.exist Posts.Recent

    Posts.Recent 0, 3, (posts) ->
      throw "No recent posts found" unless posts and posts.length > 0

      do done

  it "can retrieve posts by slug", (done) ->
    should.exist Posts.BySlug

    Posts.BySlug currDraft.slug, (post) ->
      throw "Post not found" unless post

      post.slug.should.be.equal currDraft.slug, "Post and draft slugs should be same"
      do done

  it "can remove test posts", (done) ->
    should.exist Posts.RemoveWhere

    isTestPost = (post) ->
      @title.slice(0, 4) == "test"

    Posts.RemoveWhere isTestPost, done

  it "can convert markdown to html", ->
    should.exist Posts.ConvertMarkdown

    h1Html = "<h1>header</h1>\n"
    pHtml = "<p>text</p>\n"

    (Posts.ConvertMarkdown "# header").should.be.equal h1Html, "converted h1 markdown"
    (Posts.ConvertMarkdown "text").should.be.equal pHtml, "converted text markdown"

describe "jacobgable.com blog content", ->
  it "has a landing page that lists recent blog posts", -> true
  it "lets people see earlier blog posts", -> true
  it "lets users click on a post to see the post in detail", -> true
  it "has an admin area that is password protected", -> true
  it "lists all drafts on the left, and published posts on the right", -> true
  it "allows me to put blog post ideas up before publishing (drafts)", -> true
  it "allows me to create blog posts in markdown", -> true
  it "has google analytics", -> true

describe "jacobgable.com blog extras", ->
  it "can include gists in posts"
  it "lets readers give kudos"
  it "uses disqus for comments"
