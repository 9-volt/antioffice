config         = require('./config/config.json').production
express        = require('express')
bodyParser     = require('body-parser')
methodOverride = require('method-override')
cron           = require('cron')
exphbs         = require('express-handlebars')
utils          = require('./helpers/utils')
statsManager   = require('./helpers/stats-manager')
parser         = require("./parsers/#{config.routerModel.toLowerCase()}")
db             = require('./models')
app            = express()

app.use(express.static(__dirname + '/public'))
app.use(bodyParser.urlencoded({extended: false}))            # pull information from html in POST
app.use(methodOverride())        # simulate DELETE and PUT

app.engine 'handlebars', exphbs
  defaultLayout: 'main'
  helpers:
    timeNow: ->
      new Date()
    parseSeconds: (seconds)->
      str = parseInt((seconds%3600)/60) + ' minutes'
      if seconds > 3600
        str = parseInt(seconds/3600) + ' hours ' + str
      return str

app.set('view engine', 'handlebars')

app.get '/', (req, res, next)->
  # Get all users and devices
  db.User.findAll({include: [db.Device]})
    .error (err)->
      console.error err
    .success (users)->
      devicesCount = users.reduce(((prev, curr)->prev + curr.devices.length), 0)

      # After data object created render page
      barrier = utils.barrier devicesCount, ->
        res.render 'home',
          pageTitle: 'Antioffice'
          online: data

      data = {}

      # For each user and device find last time session
      for user in users
        for device in user.devices
          # Create a clojure to keep user and device instance
          ((user, device)->
            device.getTimeSessions({order: [['to', 'DESC']], limit: 1})
              .error (err)->
                console.error err
                barrier()
              .success (timeSessions)->
                if timeSessions.length > 0
                  data[user.id] ?=
                    name: user.name
                    devices: []

                  device.timeSession = timeSessions[0]
                  data[user.id].devices.push
                    title: device.title
                    uptime: Math.ceil((timeSessions[0].to - timeSessions[0].from)/1000)

                barrier()
          )(user, device)

CronJob = cron.CronJob
CronJobFlag = false # Limit to 1 data process at a time

# Check for wlan stats each minute
job = new CronJob '00 * * * * *', ()->
  started_at = Date.now()

  parser.getStatusWireless (data)->
    # Process if data is fresh and no other processing takes place
    if not CronJobFlag and data? and Date.now() - started_at < 30000
      CronJobFlag = true
      statsManager.process data, ->
        CronJobFlag = false

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
