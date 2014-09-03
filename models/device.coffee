module.exports = (sequelize, DataTypes)->
  Device = sequelize.define 'Device',
    mac: DataTypes.STRING(17)
    title:
      type: DataTypes.STRING(32)
      defaultValue: 'Unknown'
    trackable:
      type: DataTypes.BOOLEAN
      defaultValue: true
  ,
    classMethods:
      associate: (models)->
        Device.belongsTo(models.User)
        Device.hasMany(models.TimeSession)

      findOrCreateDevice: (data, cb = ->)->
        Device.find({where: {mac: data.mac}})
          .error (error)->
            cb error
          .then (device)=>
            # If no device found, create one
            if device is null

              # First create a user
              @db.User.create
                name: ''
              .error (error)->
                cb error
              .success (user)->

                # Now create the device
                Device.create
                  mac: data.mac
                  trackable: true
                .error (error)->
                  cb error
                .success (device)->

                  # Link device with user
                  device.setUser(user)
                    .error (error)->
                      cb error
                    .success ->
                      cb null, device

            # If device found, nothing created, no errors
            else
              cb null, device
