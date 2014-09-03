module.exports = (sequelize, DataTypes)->
  TimeSession = sequelize.define 'TimeSession',
    from: DataTypes.DATE
    to: DataTypes.DATE
  ,
    classMethods:
      associate: (models)->
        TimeSession.belongsTo(models.Device)
