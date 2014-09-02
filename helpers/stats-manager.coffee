db             = require('../models')
utils          = require('../helpers/utils')

module.exports =
  process: (data)->
    return null if not data?

    @processDevices(data)
    @processOnline(data)

  processOnline: (data)->
    # Delete all old values
    db.Online.destroy().success ->
      # Add new values
      db.Online.bulkCreate utils.assignIds data

  processDevices: (data)->
    for record in data
      # Check if such a device exist in database

      db.Device.findOrCreateDevice record, (er, device=null)->
        if er?
          console.log er
        else
          console.log 'Device exists ' + device.title
