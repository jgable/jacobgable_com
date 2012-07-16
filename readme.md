# jacobgable.com

This is my personal sites source code.  It's based on Dustin Curtis' Svbtle layout and markdown based blogging platform.  It uses some of the styles from the Obtvse clone.

[![Build Status](https://secure.travis-ci.org/jgable/jacobgable_com.png)](http://travis-ci.org/jgable/jacobgable_com)

## Technologies

- Node.js
- Express
- Coffee Script
- Mocha (BDD, Coffee Script)
- Mongoose
- Stylus
- Less
- Jade Templates
- Markdown for blog posts

## Installing for Development

- [Install Node.js](https://github.com/joyent/node/wiki/Installation)
- Clone this repo: `git clone https://github.com/jgable/jacobgable_com.git`
- Install the packages: `npm install`
- Start the mongoDB: `cake data`
- Run the tests: `cake test`
- Start the server: `cake dev`

## Dev Notes

- Use `mongod --dbpath ./data` to start the mongo database.
- To run tests use `npm test` or `mocha`
- To add some default "mottos" (tag lines in the header), try `node data.js mottos`
- To initialize some test posts that will be deleted by the unit tests, try `node data.js posts`
- Here's how I made the `secrets.coffee` untracked `git update-index --assume-unchanged ./lib/secrets.coffee` after adding it to `.gitignore`

I've also added some things to the `secrets.coffee` after I set it to ignore and I don't want to go back and figure out how to re-check that file in.  Add three keys; `cookieKey`, `salt` and `adminPassHash`.  The `adminPassHash` should be an md5 hash of your admin password (I know, md5 is bad, bcrypt is in the plans).