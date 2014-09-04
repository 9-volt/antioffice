userData = []

module.exports =
  isLocalIp: (ip)->
    return ip.indexOf('192.168.0.') is 0

  getMacByIp: (ip)->
    userData.reduce (prev, curr)->
      return if curr.ip is ip then curr.mac else prev
    , null

  cacheUserData: (data)->
    userData = if data? then data else []
