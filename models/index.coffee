config    = require('../config')
fs        = require('fs')
path      = require('path')
Sequelize = require('sequelize')
lodash    = require('lodash')
sequelize = new Sequelize config.dbName, config.dbUser, config.dbPassword,
  sync:
    force: false
db        = {}

fs
  .readdirSync __dirname
  .filter (file)->
    return (file.indexOf('.') isnt 0) and (file isnt 'index.coffee')
  .forEach (file)->
    model = sequelize.import(path.join(__dirname, file))
    db[model.name] = model

Object.keys(db).forEach (modelName)->
  # Keep db instance in each model
  db[modelName].db = db

  # Check for associations
  if db[modelName].hasOwnProperty('associate')
    db[modelName].associate(db)

module.exports = lodash.extend
  sequelize: sequelize
  Sequelize: Sequelize
, db
