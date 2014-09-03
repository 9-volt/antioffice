module.exports = {
  up: function(migration, DataTypes, done) {
    migration.dropTable('Onlines').complete(done)
  },
  down: function(migration, DataTypes, done) {
    migration.createTable(
      'Onlines',
      {
        id: {
          type: DataTypes.INTEGER
          allowNull: false
          primaryKey: true
          autoIncrement: false
        },
        mac: DataTypes.STRING(17),
        ip: DataTypes.STRING(15),
        uptime: DataTypes.INTEGER
      },
      {
        createdAt: false,
        updatedAt: false,
        paranoid: false
      }
    ).complete(done)
  }
}
