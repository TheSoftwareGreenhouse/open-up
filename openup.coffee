flatiron = require 'flatiron'
app = flatiron.app
http = require 'http'
url = require 'url'
csv = require 'csv'
zlib = require 'zlib'

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
  @res.writeHead 200, { 'Content-Type': 'text/plain' }
  @res.end 'what is this dataset all about?\n'

app.router.get '/datasets/snsDataZoneLookup/original', ()->
  thisRequest = @req
  ourResponse = @res
  options = parseUrl 'http://www.scotland.gov.uk/Resource/Doc/933/0112765.txt'
  options.headers = thisRequest.headers
  req = http.request options, (theirResponse)->
    ourResponse.writeHead theirResponse.statusCode, theirResponse.headers
    theirResponse.pipe ourResponse

  req.end()


app.router.get '/datasets/snsDataZoneLookup/original.json', ()->
  thisRequest = @req
  ourResponse = @res
  options = parseUrl 'http://www.scotland.gov.uk/Resource/Doc/933/0112765.txt'
  options.headers = thisRequest.headers
  req = http.request options, (theirResponse)->
    gunzip = zlib.createGunzip()
    headers = {
      'content-type':'application/json;charset=utf-8'
      'connection':'close'
      'date': theirResponse.headers['date']
      'last-modified': theirResponse.headers['last-modified']
    }
    ourResponse.writeHead theirResponse.statusCode, headers
    csv()
    .fromStream(theirResponse.pipe(gunzip), {columns:true})
    .on 'data', (data,index)->
      data['LOCATION'] = {EASTING:data.EASTING, NORTHING:data.NORTHING}
      delete data.EASTING
      delete data.NORTHING
      ourResponse.write("[#{JSON.stringify(data)}") if index is 0
      ourResponse.write(",#{JSON.stringify(data)}") if index isnt 0
    .on 'end', ()->
      ourResponse.write "]"
      ourResponse.end()

  req.end()


app.start 9200

