db             = require('../models')
utils          = require('../helpers/utils')

module.exports =
  process: (data, cb=->)->
    return null if not data?

    @processDevices data, =>
      @processTimeTrack data, =>
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

  processTimeTrack: (data, cb=->)->
    barrier = utils.barrier data.length, ->
      cb()

    for record in data
      # Get device for each record. Do not include TimeTrack as we need only one (latest) data instance
      db.Device.find({where: {mac: record.mac}})
        .error (err)->
          console.log err
          barrier()

        .then (device)->

          # Find last timetrack
          device.getTimeTracks({order: [['to', 'DESC']], limit: 1})
            .error (err)->
              console.log err
              barrier()

            .then (timeTrack)->
              # If time session is active then update it
              if timeTrack.length > 0 and utils.dateDiff(timeTrack[0].to, new Date()).minutes < 6
                timeTrack[0].to = new Date()
                timeTrack[0].save()
                  .error (err)->
                    console.log err
                    barrier()
                  .success ->
                    barrier()

              # Otherwise create a new time session
              else
                db.TimeTrack.create
                  from: utils.newDateMinusSeconds(60) # Assume that session started one minute ago
                  to: new Date()
                .error (err)->
                  console.log err
                  barrier()
                .success (timeTrack)->
                  timeTrack.setDevice(device)
                  barrier()
