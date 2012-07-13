flatiron = require 'flatiron'
app = flatiron.app

app.use flatiron.plugins.http

app.router.get '/', ()->
  this.res.writeHead 200, { 'Content-Type': 'text/plain' }
  this.res.end 'open-up\n'

app.start 9200