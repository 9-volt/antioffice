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
        Device.hasMany(models.TimeTrack)
