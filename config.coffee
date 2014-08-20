module.exports =
  routerLogin: if process.env.ROUTER_LOGIN? then process.env.ROUTER_LOGIN else 'admin'
  routerPassword: if process.env.ROUTER_PASSWORD? then process.env.ROUTER_PASSWORD else 'password'
  router: if process.env.ROUTER? then process.env.ROUTER else 'DIR-300'
  dbHost: if process.env.DB_HOST? then process.env.DB_HOST else 'localhost'
  dbUser: if process.env.DB_USER? then process.env.DB_USER else 'root'
  dbPassword: if process.env.DB_PASSWORD? then process.env.DB_PASSWORD else 'password'
  dbTable: if process.env.DB_TABLE? then process.env.DB_TABLE else 'antioffice'
