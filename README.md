# Antioffice stats

Shows who's in the office right now. Data is gathered from router stats.

## List of supported routers

* D-Link DIR-300

## Instalation

* Requires Node.js and MySQL database
* Install CoffeeScript `npm install -g coffee-script`
* Clone project and cd into its main folder
* Install required npm modules `npm install`
* Run project `coffee index.coffee`

You may want to pass your own options for:

* SITE_PORT - port on which site will be served
* ROUTER_LOGIN - router user login (default admin)
* ROUTER_PASSWORD - router password for given user (default password)
* ROUTER - router type (default DIR-300)
* DB_HOST - database host (default localhost)
* DB_USER - database user (default root)
* DB_PASSWORD - database password (default password)
* DB_NAME - database name (dafault antioffice)

To pass a option set it as CLI variable: `ROUTER_PASSWORD="somepassword" coffee index.coffee`

## Development

If you have a different router than you may want to develop your own parser function. Place the file in `helpers` folder.
Name your file as `routercode-parser.coffee` where `routercode` is your router type in lowercase.

You may want to install nodemon so that server will restart automatically when any file changes.
