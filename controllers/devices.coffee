db             = require('../models')
utils          = require('../helpers/utils')
session        = require('../helpers/session')

module.exports =

  post: (req, res)->
    if req.params?.id? and req.params.id > 0 and req.body?.value?
      db.Device.find(req.params.id)
        .error (err)->
          res.status(404).send('DB error')
        .success (device)->
          mac = session.getMacByIp(req.connection.remoteAddress)
          ## Check if client tries to edit its own name
          isSameClient = device.mac is mac

          if isSameClient?
            device.title = req.body.value
            device.save()
            res.send('OK')
          else
            res.status(404).send('You are not authorized to alter this entity')
    else
      res.status(404).send('ID parameter or Value argument is wrong')
