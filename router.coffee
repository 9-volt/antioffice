Users = require('./controllers/users')

module.exports =
  bindRoutes: (app)->
    app.get '/', Users.online
    app.get '/users', Users.all
