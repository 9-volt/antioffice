module.exports = (sequelize, DataTypes)->
  TimeSummary = sequelize.define 'TimeSummary',
    date: DataTypes.DATE
    hours: DataTypes.INTEGER
  ,
    classMethods:
      associate: (models)->
        TimeSummary.belongsTo(models.User)
