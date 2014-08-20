module.exports = (sequelize, DataTypes)->
  Online = sequelize.define 'Online',
    # Do not use autoincrement because it will cause huge indexes after a while
    id:
      type: DataTypes.INTEGER
      allowNull: false
      primaryKey: true
      autoIncrement: false
    mac: DataTypes.STRING(17)
    ip: DataTypes.STRING(15)
    online: DataTypes.INTEGER
  ,
    createdAt: false
    updatedAt: false
    paranoid: false

