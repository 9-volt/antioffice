module.exports = {
  up: function(migration, DataTypes, done) {
    migration.renameTable('TimeTracks', 'TimeSessions').complete(done)
  },
  down: function(migration, DataTypes, done) {
    migration.renameTable('TimeSessions', 'TimeTracks').complete(done)
  }
}
