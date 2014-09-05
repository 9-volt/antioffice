Users = require('./controllers/users')
Devices = require('./controllers/devices')

module.exports =
  bindRoutes: (app)->
    app.get '/', Users.online
    app.get '/users', Users.all
    app.post '/users/:id', Users.post

    app.post '/devices/:id', Devices.post
