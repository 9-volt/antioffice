config   = require('../config')
http     = require('http')
_        = require('lodash')

module.exports =
  headers:
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/36.0.1989.147 Safari/537.36'
    'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'

  logIn: (cb)->
    postData = "ACTION_POST=LOGIN&FILECODE=&VERIFICATION_CODE=&LOGIN_USER=#{config.routerLogin}&LOGIN_PASSWD=#{config.routerPassword}&login=Log+In+&VER_CODE="

    logInRequest = http.request
      host: '192.168.0.1'
      port: '80'
      path: '/login.php'
      method: 'POST'
      headers: _.merge {}, this.headers,
        'Content-Type': 'application/x-www-form-urlencoded'
        'Content-Length': postData.length
    , (res)->
      chunks = ''

      res.on 'data', (chunk)->
        chunks += chunk

      res.on 'end', ->
        if chunks.indexOf('url=login_fail.php') isnt -1
          console.log('DIR-300 Login fail')
          cb()
        else
          cb(true)

    .on 'error', =>
      console.log('DIR-300 Login error')
      cb()

    logInRequest.write(postData)
    logInRequest.end()

  statusWirelessR: /\<td class\=c_tb width=\d+\%\>(.*)\<\/td\>/gi

  timeR: /\(\'(\d+)\'\)/gi

  getStatusWireless: (cb)->
    this.logIn (loggedIn = false)=>
      if not loggedIn
        return cb(null)

      http.get
        host: '192.168.0.1',
        port: 80,
        path: '/st_wlan.php',
        headers: this.headers
      , (res)=>
        res.setEncoding("utf8")

        chunks = ''
        res.on 'data', (chunk)->
          chunks += chunk

        res.on 'end', ()=>
          match = null
          data = []
          obj = {}
          index = 0

          while match = this.statusWirelessR.exec chunks
            index += 1

            if index % 6 is 1
              # parse time from string <script>show_conn_time('658');</script>
              localMatch = this.timeR.exec match[1]
              # reset regexp
              this.timeR.lastIndex = 0

              if localMatch?
                obj.uptime = localMatch[1]
              else
                obj.uptime = 0
            else if index % 6 is 2
              obj.mac = match[1]
            else if index % 6 is 3
              obj.ip = match[1]
            else if index % 6 is 0
              # Push assembled object into data
              data.push obj
              obj = {}

          cb(data)

      .on 'error', (e)->
        console.log('Got error when trying to get wireless status')
        cb(null)
