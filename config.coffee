module.exports =
  sitePort: if process.env.SITE_PORT? then process.env.SITE_PORT else 8080
  routerLogin: if process.env.ROUTER_LOGIN? then process.env.ROUTER_LOGIN else 'admin'
  routerPassword: if process.env.ROUTER_PASSWORD? then process.env.ROUTER_PASSWORD else 'password'
  router: if process.env.ROUTER? then process.env.ROUTER else 'DIR-300'
  dbHost: if process.env.DB_HOST? then process.env.DB_HOST else 'localhost'
  dbUser: if process.env.DB_USER? then process.env.DB_USER else 'root'
  dbPassword: if process.env.DB_PASSWORD? then process.env.DB_PASSWORD else 'password'
  dbName: if process.env.DB_NAME? then process.env.DB_NAME else 'antioffice'
