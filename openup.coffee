flatiron = require 'flatiron'
app = flatiron.app
http = require 'http'
url = require 'url'

parseUrl = (uriString)->
  uri = url.parse uriString
  opt = {
    host: uri.hostname
    port: 80
    path: uri.pathname
    method: 'GET'
  }

app.use flatiron.plugins.http

app.router.get '/', ()->
  @res.writeHead 200, { 'Content-Type': 'text/plain' }
  @res.end 'open-up\n'

app.router.get '/datasets/snsDataZoneLookup', ()->
  thisRequest = @req
  ourResponse = @res
  options = parseUrl 'http://www.scotland.gov.uk/Resource/Doc/933/0112765.txt'
  options.headers = thisRequest.headers
  req = http.request options, (theirResponse)->
    ourResponse.writeHead theirResponse.statusCode, theirResponse.headers
    theirResponse.pipe ourResponse

  req.end()


app.start 9200

