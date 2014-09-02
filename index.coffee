config         = require('./config')
express        = require('express')
bodyParser     = require('body-parser')
methodOverride = require('method-override')
cron           = require('cron')
exphbs         = require('express-handlebars')
statsManager   = require('./helpers/stats-manager')
parser         = require("./parsers/#{config.router.toLowerCase()}")
db             = require('./models')
app            = express()

app.use(express.static(__dirname + '/public'))
app.use(bodyParser.urlencoded({extended: false}))            # pull information from html in POST
app.use(methodOverride())        # simulate DELETE and PUT

app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');

app.get '/', (req, res, next)->
  db.Online.findAll()
    .done (err, rows)->
      res.render 'home',
        pageTitle: 'Antioffice'
        showMe: true
        online: if not err then rows else []
        helpers:
          timeNow: ->
            new Date()
          parseSeconds: (seconds)->
            str = parseInt((seconds%3600)/60) + ' minutes'
            if seconds > 3600
              str = parseInt(seconds/3600) + ' hours ' + str

            return str

CronJob = cron.CronJob

# Check for wlan stats each minute
job = new CronJob '00 * * * * *', ()->
  started_at = Date.now()

  parser.getStatusWireless (data)->
    # if response returned in less than 30 seconds
    if data? and Date.now() - started_at < 30000
      statsManager.process(data)

, null, true

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
