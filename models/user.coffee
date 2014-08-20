module.exports = (sequelize, DataTypes)->
  User = sequelize.define 'User',
    name: DataTypes.STRING(32)
  ,
    classMethods:
      associate: (models)->
        User.hasMany(models.Device)
