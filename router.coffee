Users = require('./controllers/users')
Devices = require('./controllers/devices')
utils = require('./helpers/utils')

module.exports =
  bindRoutes: (app)->
    app.get '/', utils.nocache, Users.online
    app.get '/users', Users.all
    app.post '/users/:id', Users.post

    app.post '/devices/:id', Devices.post
