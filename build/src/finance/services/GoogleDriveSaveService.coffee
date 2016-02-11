CLIENT_ID = '738883605733-b6bc7deeulg034sncifk1upknib3b0n0.apps.googleusercontent.com'
SCOPES = [
  'https://www.googleapis.com/auth/drive.metadata.readonly'
  'https://www.googleapis.com/auth/drive.file'
]

app.service 'GoogleDriveSaveService', ->

  loadClient = (cb) ->
    if g_gapiClientLoaded
      cb()
    else
      window.g_gapiClientLoadedCb = ->
        cb()
        window.g_gapiClientLoadedCb = null

  authAndLoadApi = (cb)->
    progress('Loading client...')
    await loadClient(defer())
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

  downloadFile = (id, callback, progress) ->
    request = gapi.client.drive.files.get('fileId': id)
    await request.execute defer(file)
    url = file.downloadUrl
    accessToken = gapi.auth.getToken().access_token
    xhr = new XMLHttpRequest
    xhr.open 'GET', url
    xhr.setRequestHeader 'Authorization', 'Bearer ' + accessToken
    progress('Downloading file...')
    xhr.onload = ->
      callback file, xhr.responseText
      return
    xhr.onerror = ->
      console.log(arguments)
      progress('Error downloading file')
      return
    xhr.send()

  return {
    loadFile: (id, callback, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      await downloadFile(id, defer(file, data), progress)
      callback(file, data)
    newFile: (name, data, done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      progress('Saving file...')
      await insertFile(name, data, defer(arg))
      console.log arg
      progress('File saved.')
      done(arg)
  }
