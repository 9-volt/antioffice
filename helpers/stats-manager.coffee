db             = require('../models')
utils          = require('../helpers/utils')

module.exports =
  process: (data, cb=->)->
    return null if not data?

    @processDevices data, =>
      @processTimeSession data, =>
        cb()

  processDevices: (data, cb=->)->
    barrier = data.length

    for record in data
      # Check if such a device exist in database
      db.Device.findOrCreateDevice record, (er, device=null)->
        barrier -= 1 # mark barrier stop

        if barrier is 0
          cb()

  processTimeSession: (data, cb=->)->
    barrier = utils.barrier data.length, ->
      cb()

    for record in data
      # Get device for each record. Do not include TimeSession as we need only one (latest) data instance
      db.Device.find({where: {mac: record.mac}})
        .error (err)->
          console.log err
          barrier()

        .then (device)->

          # Find last timetrack
          device.getTimeSessions({order: [['to', 'DESC']], limit: 1})
            .error (err)->
              console.log err
              barrier()

            .then (timeSession)->
              # If time session is active then update it
              if timeSession.length > 0 and utils.dateDiff(timeSession[0].to, new Date()).minutes < 6
                timeSession[0].to = new Date()
                timeSession[0].save()
                  .error (err)->
                    console.log err
                    barrier()
                  .success ->
                    barrier()

              # Otherwise create a new time session
              else
                db.TimeSession.create
                  from: utils.newDateMinusSeconds(60) # Assume that session started one minute ago
                  to: new Date()
                .error (err)->
                  console.log err
                  barrier()
                .success (timeSession)->
                  timeSession.setDevice(device)
                  barrier()
