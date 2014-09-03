db             = require('../models')
utils          = require('../helpers/utils')

module.exports =

  online: (req, res, next)->

    # Get all users and devices
    db.User.findAll({include: [db.Device]})
      .error (err)->
        console.error err
      .success (users)->
        devicesCount = users.reduce(((prev, curr)->prev + curr.devices.length), 0)
        data = {}

        # Render the page only afte 'data' is populated
        barrier = utils.barrier devicesCount, ->
          res.render 'home',
            pageTitle: 'Antioffice'
            online: data

        # For each user and device find last time-session
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

  all: (req, res)->
    res.send('all')
