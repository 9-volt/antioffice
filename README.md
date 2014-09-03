# Antioffice stats

Shows who's in the office right now. Data is gathered from router stats.

## List of supported routers

* D-Link DIR-300 (v2.02)
* D-Link DIR-300 (v2.15)

## Instalation

* Requires Node.js and MySQL database
* Install CoffeeScript `npm install -g coffee-script`
* Clone project and cd into its main folder
* Install required npm modules `npm install`
* Rename `config.json.sample` to `config.json` and edit file
* Run project `coffee index.coffee`

## Development

If you have a different router than you may want to develop your own parser function. Place the file in `parsers` folder.
Name your file as `routercode-version.coffee` where `routercode` is your router type in lowercase.

You may want to install nodemon so that server will restart automatically when any file changes.
