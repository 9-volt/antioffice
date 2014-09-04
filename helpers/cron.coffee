config         = require('../config/config.json').production
cron           = require('cron')
statsManager   = require('../helpers/stats-manager')
parser         = require("../parsers/#{config.routerModel.toLowerCase()}")

module.exports =
  start: ()->
    # Tick each minute
    new cron.CronJob '00 * * * * *', @tick, null, true

    # First tick when app starts
    @tick()

  busy: false # Limit to 1 task at a time

  tick: ()->
    started_at = Date.now()

    parser.getWirelessConnections (data)=>
      # Process if data is fresh and no other processing takes place
      if not @bucy and data? and Date.now() - started_at < 30000
        @busy = true
        statsManager.process data, =>
          @busy = false
