db             = require('../models')
utils          = require('../helpers/utils')

module.exports =
  process: (data, cb=->)->
    return null if not data?

    @processDevices data, =>
      @processOnline data, =>
        cb()

  processOnline: (data, cb=->)->
    # Delete all old values
    db.Online.destroy().success ->
      # Add new values
      db.Online.bulkCreate(utils.assignIds data).success ->
        cb()

  processDevices: (data, cb=->)->
    barrier = data.length

    for record in data
      # Check if such a device exist in database

      db.Device.findOrCreateDevice record, (er, device=null)->
        barrier -= 1 # mark barrier stop

        if er?
          console.log er
        else
          console.log 'Device exists ' + device.title

        if barrier is 0
          cb()
