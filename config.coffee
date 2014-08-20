module.exports =
  routerLogin: if process.env.ROUTER_LOGIN? then process.env.ROUTER_LOGIN else 'admin'
  routerPassword: if process.env.ROUTER_PASSWORD? then process.env.ROUTER_PASSWORD else 'password'
