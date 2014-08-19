express        = require('express')
bodyParser     = require('body-parser')
methodOverride = require('method-override')
cron           = require('cron')
exphbs         = require('express-handlebars')
mysql          = require('mysql')
app            = express()

app.use(express.static(__dirname + '/public'))
app.use(bodyParser.urlencoded({extended: false}))            # pull information from html in POST
app.use(methodOverride())        # simulate DELETE and PUT

app.engine('handlebars', exphbs({defaultLayout: 'main'}));
app.set('view engine', 'handlebars');

connection = mysql.createConnection
  host: 'localhost'
  user: 'root'
  password: 'password'
connection.query('USE antioffice')

app.get '/', (req, res, next)->
  connection.query 'SELECT * FROM online', (err, rows)->
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

job = new CronJob '00 * * * * *', ()->
  console.log(1)
, null, true

app.listen(8080)
