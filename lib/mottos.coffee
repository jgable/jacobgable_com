# mottos.coffee

# Dependencies
mongoose = require "mongoose"
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

# Defining the Motto model and schema.
MottoSchema = new Schema
  id: ObjectId,
  text: String

Motto = mongoose.model "Motto", MottoSchema

# Connecting to mongoose.
mongoose.connect "mongodb://127.0.0.1/jacobgable_com"

# Some Helper functions...
random = (min = 0, max = 1) ->
  (Math.random() * (max - min) + min)|0

# Public API
Mottos = 
  Create: (txt, cb) ->
    newMotto = new Motto()
    newMotto.text = txt

    newMotto.save (err) ->
      throw err if err

      # callBack with newMotto
      cb newMotto

  All: (cb) ->
    Motto.find {}, (err, mots) ->
      throw err if err
      
      # Callback with returned mottos
      cb mots

  Random: (cb) ->
    Mottos.All (mots) ->
      randIdx = random 0, mots.length
      
      return cb mots[randIdx] unless mots.length < 1

      cb null

  RemoveWhere: (pred, cb) ->
    Motto.find().$where(pred).remove (err) ->
      throw err if err

      cb()

# Export our public API
module.exports = Mottos
