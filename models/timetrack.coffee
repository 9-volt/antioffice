module.exports = (sequelize, DataTypes)->
  TimeTrack = sequelize.define 'TimeTrack',
    from: DataTypes.DATE
    to: DataTypes.DATE
  ,
    classMethods:
      associate: (models)->
        TimeTrack.belongsTo(models.Device)
