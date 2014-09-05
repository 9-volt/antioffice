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
                    id: user.id

                  data[user.id].devices.push
                    title: device.title
                    uptime: Math.ceil((timeSessions[0].to - timeSessions[0].from)/1000)
                    to: timeSessions[0].to
                    mac: device.mac
                    id: device.id

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

  post: (req, res)->
    if req.params?.id? and req.params.id > 0 and req.body?.value?
      db.User.find({where: {id: req.params.id}, include: [db.Device]})
        .error (err)->
          res.status(404).send('DB error')
        .success (user)->
          mac = session.getMacByIp(req.connection.remoteAddress)

          ## Check if client tries to edit its own name
          isSameClient = user.devices.reduce (prev, curr)->
            return if curr.mac is mac then true else prev
          , false

          if isSameClient?
            user.name = req.body.value
            user.save()
            res.send('OK')
          else
            res.status(404).send('You are not authorized to alter this entity')
    else
      res.status(404).send('ID parameter or Value argument is wrong')
