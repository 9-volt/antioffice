config         = require('../config/config.json').production
cron           = require('cron')
statsManager   = require('../helpers/stats-manager')
parser         = require("../parsers/#{config.routerModel.toLowerCase()}")

module.exports =
  start: ()->
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
