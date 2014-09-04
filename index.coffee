config         = require('./config/config.json').production
express        = require('express')
bodyParser     = require('body-parser')
methodOverride = require('method-override')
exphbs         = require('express-handlebars')
db             = require('./models')
Router         = require('./router')
Cron           = require('./helpers/cron')
app            = express()

app.use(express.static(__dirname + '/public'))
app.use(bodyParser.urlencoded({extended: false}))            # pull information from html in POST
app.use(methodOverride())        # simulate DELETE and PUT

app.engine 'handlebars', exphbs
  defaultLayout: 'main'
  helpers: require('./helpers/handlebars-helpers')

app.set('view engine', 'handlebars')

Router.bindRoutes(app)

# Startup database connection and start app
db
  .sequelize
  .sync
    force: false
  .complete (err)->
    if err
      throw err[0]
    else
      app.listen(config.sitePort)
      Cron.start()

      console.log 'App started on port ' + config.sitePort
