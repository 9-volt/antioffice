db             = require('../models')
utils          = require('../helpers/utils')
session        = require('../helpers/session')

getData = (cb, filter=->true)->
  # Get all users and devices
  db.User.findAll({include: [db.Device]})
    .error (err)->
      console.error err
    .success (users)->
      devicesCount = users.reduce(((prev, curr)->prev + curr.devices.length), 0)
      data = {}

      # Render the page only afte 'data' is populated
      barrier = utils.barrier devicesCount, ->
        cb(data)

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
                if timeSessions.length > 0 and filter(timeSessions[0])
                  data[user.id] ?=
                    name: user.name
                    devices: []

                  data[user.id].devices.push
                    title: device.title
                    uptime: Math.ceil((timeSessions[0].to - timeSessions[0].from)/1000)
                    to: timeSessions[0].to
                    mac: device.mac

                barrier()
          )(user, device)

module.exports =

  online: (req, res, next)->
    clientIp = req.connection.remoteAddress

    getData (data)->
      res.render 'users-online',
        pageTitle: 'Antioffice'
        online: data
        clientMac: session.getMacByIp(clientIp)
        clientIsLocal: session.isLocalIp(clientIp)
    , (timeSession)->
      new Date() - timeSession.to < 5 * 60 * 1000

  all: (req, res)->
    clientIp = req.connection.remoteAddress

    getData (data)->
      res.render 'users-all',
        pageTitle: 'Antioffice'
        online: data
        clientMac: session.getMacByIp(clientIp)
        clientIsLocal: session.isLocalIp(clientIp)
    , (f)->
      true

