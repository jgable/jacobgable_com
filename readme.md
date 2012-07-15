# jacobgable.com

This is my personal sites source code.  It's based on Dustin Curtis' Svbtle layout and markdown based blogging platform.  It uses some of the styles from the Obtvse clone.

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
- BCrypt for pass hashing

## Dev Notes

- Use `mongod --dbpath ./data` to start the mongo database.
- To run tests use `npm test` or `mocha`
- To add some default "mottos" (tag lines in the header), try `node data.js mottos`
- To initialize some test posts that will be deleted by the unit tests, try `node data.js posts`
- Here's how I made the `secrets.coffee` untracked `git update-index --assume-unchanged ./lib/secrets.coffee` after adding it to `.gitignore`

I've also added some things to the `secrets.coffee` after I set it to ignore and I don't want to go back and figure out how to re-check that file in.  Add three keys; `cookieKey`, `salt` and `adminPassHash`.  The `adminPassHash` should be an md5 hash of your admin password (I know, md5 is bad, bcrypt is in the plans).