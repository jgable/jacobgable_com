
# Dependencies
mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId
slug = require "slug"
log = (require "logging").from "Posts"
marked = require "marked"

PostSchema = new Schema
  id: ObjectId
  slug: String
  title: String
  trackBack: String
  content: String
  markdown: String
  publish: Boolean
  publishDate: Date

Post = mongoose.model "Post", PostSchema

# Connecting to mongoose.
mongoose.connect "mongodb://127.0.0.1/jacobgable_com"

# Helpers
createSlug = (text) ->
  slug text

Posts = 
  NewDraft: (title, markdown, cb) ->
    draft = new Post
    draft.title = title
    draft.slug = createSlug title
    draft.markdown = markdown or title

    draft.content = marked draft.markdown

    draft.publish = false

    draft.save (err) ->
      throw err unless !err

      cb draft

  Update: (id, opts, cb) ->
    
    Post.findOne { _id: id }, (err, foundPost) ->
      throw err unless !err

      # Bug out early if we didn't find the post.
      cb "notfound" unless foundPost

      # Update the values with the data we passed.
      for own key, val of opts
        # Skip internal Mongo columns (_id)
        continue if key.slice(0,1) == "_"

        foundPost[key] = val

        # Update the slug if we update the title
        if key == "title"
          foundPost.slug = createSlug val

        # Update the content if we update the markdown
        if key == "markdown"
          foundPost.content = marked val

        if key == "publish" and val is true
          foundPost.publishDate = new Date

      # Save the post with the updated values.
      foundPost.save (err) ->
        throw err unless !err

        cb foundPost


  Recent: (page, num, cb) ->
    page = page || 0
    num = num || 3

    qry = Post.find {}

    now = new Date
    today = new Date now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(), 23, 59

    qry.where 'publish', true
    qry.where('publishDate').lte(today)

    qry.sort "publishDate", -1

    qry.limit(num).skip(num * page)

    qry.exec (err, posts) ->
      throw err unless !err

      cb posts

  BySlug: (slug, cb) ->
    Post.findOne { slug: slug }, (err, post) ->
      throw err unless !err

      cb post

  List: (cb) ->
    Post.find {}, (err, posts) ->
      throw err unless !err

      result = 
        drafts:    []
        published: []

      for post in posts
        if post.publish
          result.published.push post
        else
          result.drafts.push post

      cb result

  RemoveWhere: (pred, cb) ->
    Post.find().$where(pred).remove (err) ->
      throw err unless !err

      do cb

  DeleteBySlug: (slug, cb) ->
    Post.find({slug: slug}).remove (err) ->
      throw err if err

      do cb

  ConvertMarkdown: (text) ->
    marked text

module.exports = Posts
