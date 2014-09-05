config   = require('../config/config.json').production
http     = require('http')
_        = require('lodash')
xml2js   = require('xml2js')
utils    = require('../helpers/utils')

module.exports =
  headers:
    'Cookie': 'uid=' + utils.COMM_RandomStr(10)
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1989.147 Safari/537.36'
    'Content-Type': 'application/x-www-form-urlencoded'

  logIn: (cb)->
    postData = "REPORT_METHOD=xml&ACTION=login_plaintext&USER=#{config.routerLogin}&PASSWD=#{config.routerPassword}&CAPTCHA="

    logInRequest = http.request
      host: '192.168.0.1'
      port: '80'
      path: '/session.cgi'
      method: 'POST'
      headers: _.merge {}, this.headers,
        'Content-Length': postData.length

    , (res)->
      chunks = ''

      res.on 'data', (chunk)->
        chunks += chunk

      res.on 'end', ->
        if chunks.indexOf('<RESULT>SUCCESS</RESULT>') is -1
          console.log('DIR-300 Login fail')
          cb()
        else
          cb(true)

    .on 'error', =>
      console.log('DIR-300 Login error')
      cb()

    logInRequest.write(postData)
    logInRequest.end()

  logOut: (cb=->)->
    postData = "REPORT_METHOD=xml&ACTION=logout"

    logOutRequest = http.request
      host: '192.168.0.1'
      port: '80'
      path: '/session.cgi'
      method: 'POST'
      headers: _.merge {}, this.headers,
        'Content-Length': postData.length

    , (res)->
      chunks = ''

      res.on 'data', (chunk)->
        chunks += chunk

      res.on 'end', ->
        if chunks.indexOf('<RESULT>SUCCESS</RESULT>') is -1
          console.log('DIR-300 Log out fail')
          cb()
        else
          console.log('DIR-300 Log out success')
          cb(true)

    .on 'error', =>
      console.log('DIR-300 Logout error')
      cb()

    logOutRequest.write(postData)
    logOutRequest.end()

  getWirelessConnections: (cb)->
    this.logIn (loggedIn = false)=>
      if not loggedIn
        return cb(null)

      postData = 'SERVICES=RUNTIME.PHYINF.WLAN-1'

      dataRequest = http.request
        host: '192.168.0.1'
        port: 80
        path: '/getcfg.php'
        method: 'POST'
        headers: _.merge {}, this.headers,
          'Content-Length': postData.length

      , (res)=>
        res.setEncoding("utf8")

        chunks = ''
        res.on 'data', (chunk)->
          chunks += chunk

        res.on 'end', ()=>

          # Parse returned XML
          xml2js.parseString chunks, (err, result)=>
            data = []
            entries = result?.postxml?.module?[0]?.runtime?[0]?.phyinf?[0]?.media?[0]?.clients?[0]?.entry

            if entries?.length? > 0
              data = entries.map (e)->
                mac: e.macaddr[0].toUpperCase() # Normalize mac address
                uptime: e.uptime[0]

            @logOut()
            return cb(data)

      .on 'error', (e)->
        console.log('Got error when trying to get wireless status')
        cb(null)

      dataRequest.write(postData)
      dataRequest.end()

  getDevicesData: (cb)->
    this.logIn (loggedIn = false)=>
      if not loggedIn
        return cb(null)

      postData = 'SERVICES=DHCPS4.LAN-1,RUNTIME.INF.LAN-1'

      dataRequest = http.request
        host: '192.168.0.1'
        port: 80
        path: '/getcfg.php'
        method: 'POST'
        headers: _.merge {}, this.headers,
          'Content-Length': postData.length

      , (res)=>
        res.setEncoding("utf8")

        chunks = ''
        res.on 'data', (chunk)->
          chunks += chunk

        res.on 'end', ()=>
          # Parse returned XML
          xml2js.parseString chunks, (err, result)=>
            data = []
            dhcpXml = null
            lanXml = null

            if result?.postxml?.module?[0]?.service?[0] is 'DHCPS4.LAN-1'
              dhcpXml = result?.postxml?.module?[0]?.dhcps4?[0]
            else if result?.postxml?.module?[0]?.service?[0] is 'RUNTIME.INF.LAN-1'
              lanXml = result?.postxml?.module?[0]?.runtime?[0]

            if result?.postxml?.module?[1]?.service?[0] is 'DHCPS4.LAN-1'
              dhcpXml = result?.postxml?.module?[1]?.dhcps4?[0]
            else if result?.postxml?.module?[1]?.service?[0] is 'RUNTIME.INF.LAN-1'
              lanXml = result?.postxml?.module?[1]?.runtime?[0]

            if dhcpXml?.entry?
              for entry in dhcpXml.entry
                if entry?.staticleases?[0]?.entry?
                  for entry2 in entry.staticleases[0].entry
                    if entry2.hostname?[0]? and entry2.macaddr?[0]? and entry2.hostid?[0]?
                      data.push
                        title: entry2.hostname[0]
                        mac: entry2.macaddr[0].toUpperCase() # Normalize mac address
                        ip: '192.168.0.' + entry2.hostid[0]


            if lanXml.inf?[0]?.dhcps4?[0]?.leases?[0]?.entry?
              for entry in lanXml.inf[0].dhcps4[0].leases[0].entry
                if entry.hostname?[0]? and entry.macaddr?[0]? and entry.ipaddr?[0]?
                  data.push
                    title: entry.hostname[0]
                    mac: entry.macaddr[0].toUpperCase() # Normalize mac address
                    ip: entry.ipaddr[0]

            @logOut()
            return cb(data)

      .on 'error', (e)->
        console.log('Got error when trying to get devicess status')
        cb(null)

      dataRequest.write(postData)
      dataRequest.end()
