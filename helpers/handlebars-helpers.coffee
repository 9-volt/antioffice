module.exports =
  timeNow: ->
    new Date()
  parseSeconds: (seconds)->
    str = parseInt((seconds%3600)/60) + ' minutes'
    if seconds > 3600
      str = parseInt(seconds/3600) + ' hours ' + str
    return str
