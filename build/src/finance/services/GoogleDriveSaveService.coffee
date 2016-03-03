CLIENT_ID = '738883605733-b6bc7deeulg034sncifk1upknib3b0n0.apps.googleusercontent.com'
SCOPES = [
  'https://www.googleapis.com/auth/drive.metadata.readonly'
  'https://www.googleapis.com/auth/drive.file'
]

app.service 'GoogleDriveSaveService', ->

  gapiClientLoaded = false
  gapiClientLoadedCb = ->
  window.onGapiClientloaded = ->
    gapiClientLoaded = true;
    gapiClientLoadedCb()


  loadClient = (cb) ->
    if gapiClientLoaded
      cb(null)
    else
      gapiClientLoadedCb = ->
        gapiClientLoaded = true
        cb(null)
        gapiClientLoadedCb = null
      $.ajax({
        url: 'https://apis.google.com/js/client.js?onload=onGapiClientloaded'
        dataType: 'script'
        cache: true
      })
      .fail ->
        console.log arguments
        cb('Error loading drive client')


  authAndLoadApi = (cb)->
    progress('Loading client...')
    await loadClient(defer(error))
    if error
      cb(error)
      return
    progress('Authorizing...')
    await gapi.auth.authorize {
      'client_id': CLIENT_ID
      'scope': SCOPES.join(' ')
      'immediate': true
    }, defer(authResult)
    if authResult and !authResult.error
      progress('Loading drive API...')
      await gapi.client.load 'drive', 'v2', defer()
      cb()
    else
      progress('Authorize error: ' + authResult.error)
      console.log('could not authorise')
      console.log(authResult)
    return

  initWaiters = []
  initFinished = false
  waitForInit = (listener) ->
    initWaiters.push listener

  initStarted = false
  init = ->
    if initStarted
      return
    initStarted = true
    await authAndLoadApi(defer())
    initFinished = true
    for waiter in initWaiters
      waiter.done()

  progress = (m) ->
    for waiter in initWaiters
      waiter.progress(m)
    return

  ensureInitCompleted = (loadListener) ->
    if initFinished
      loadListener.done()
    else
      init()
      waitForInit(loadListener)

  insertFile = (name, fileData, callback) ->
    boundary = '-------314159265358979323846'
    delimiter = '\r\n--' + boundary + '\r\n'
    close_delim = '\r\n--' + boundary + '--'

    contentType = 'application/json'
    metadata =
      'title': name
      'mimeType': contentType
    base64Data = btoa(fileData)
    multipartRequestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter + 'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim
    request = gapi.client.request(
      'path': '/upload/drive/v2/files'
      'method': 'POST'
      'params': 'uploadType': 'multipart'
      'headers': 'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
      'body': multipartRequestBody)
    if !callback
      callback = (file) ->
        console.log file
        return

    request.execute callback
    return

  doUpdateFile = (id, fileData, callback) ->
    boundary = '-------314159265358979323846'
    delimiter = '\r\n--' + boundary + '\r\n'
    close_delim = '\r\n--' + boundary + '--'

    contentType = 'application/json'
    metadata = {}
    base64Data = btoa(fileData)
    multipartRequestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter + 'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim
    request = gapi.client.request(
      'path': '/upload/drive/v2/files/' + id
      'method': 'PUT'
      'params': {'uploadType': 'multipart', 'alt': 'json'}
      'headers': 'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
      'body': multipartRequestBody)

    request.then(
      (response) ->
        callback()
      (reason) ->
        console.log reason
        callback(reason)
    )

    return

  downloadFile = (id, callback, progress) ->
    request = gapi.client.drive.files.get('fileId': id)
    progress('Opening file...')
    await request.then defer(result), (e) ->
      console.log(e)
      callback(e)
    file = result.result
    url = file.downloadUrl
    accessToken = gapi.auth.getToken().access_token
    xhr = new XMLHttpRequest
    xhr.open 'GET', url
    xhr.setRequestHeader 'Authorization', 'Bearer ' + accessToken
    progress('Downloading file...')
    xhr.onload = ->
      callback null, file, xhr.responseText
      return
    xhr.onerror = (e) ->
      console.log(arguments)
      callback(e)
      return
    xhr.send()

  return {
    loadFile: (id, callback, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      await downloadFile(id, defer(error, file, data), progress)
      callback(error, file, data)

    newFile: (name, data, done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      progress('Saving file...')
      await insertFile(name, data, defer(arg))
      console.log arg
      progress('File saved.')
      done(arg)

    updateFile: (id, data, done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      progress('Saving file...')
      await doUpdateFile(id, data, defer(error))
      if !error
        progress('File saved.')
      done()
  }
