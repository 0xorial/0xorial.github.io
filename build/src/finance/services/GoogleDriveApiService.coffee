CLIENT_ID = '738883605733-b6bc7deeulg034sncifk1upknib3b0n0.apps.googleusercontent.com'
APP_ID = '738883605733'
API_KEY = 'AIzaSyDbiOruHeMzOa2K32MVMnK7q0WVxv-AZQY'
MIME_BASE = 'application/vnd.google-apps.drive-sdk.'
MIME = MIME_BASE + APP_ID
SCOPES = [
  'https://www.googleapis.com/auth/drive'
  'https://www.googleapis.com/auth/drive.metadata.readonly'
  'https://www.googleapis.com/auth/drive.file'
]

app.service 'GoogleDriveApiService', ->

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

  oauthToken = null

  authAndLoadApi = (async, cb)->
    progress('Loading client...')
    await loadClient(defer(error))
    if error
      cb(error)
      return
    progress('Authorizing...')
    await gapi.auth.authorize {
      'client_id': CLIENT_ID
      'scope': SCOPES.join(' ')
      'immediate': !async
    }, defer(authResult)

    if !async and authResult.error
      progress('', true)

    oauthToken = authResult.access_token

    if authResult and !authResult.error
      progress('Loading drive API...')
      await gapi.client.load 'drive', 'v2', defer()
      progress('Loading picker API...')
      await gapi.load('picker', {'callback': defer()})
      cb()
    else
      progress('Authorize error: ' + authResult.error)
      console.log('could not authorize')
      console.log(authResult)
    return

  initWaiters = []
  initFinished = false
  waitForInit = (listener) ->
    initWaiters.push listener

  initStarted = false
  init = (async) ->
    if initStarted
      return
    initStarted = true
    await authAndLoadApi(async, defer())
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
      init(loadListener.async)
      waitForInit(loadListener)

  insertFile = (name, fileData, index, callback) ->
    boundary = '-------314159265358979323846'
    delimiter = '\r\n--' + boundary + '\r\n'
    close_delim = '\r\n--' + boundary + '--'

    contentType = 'application/json'
    metadata =
      'title': name
      'mimeType': 'application/json,' + MIME
      'indexableText':
        'text': index
    base64Data = btoa(fileData)
    multipartRequestBody = delimiter +
      'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter +
      'Content-Type: ' + contentType + '\r\n' +
      'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim
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

  doUpdateFile = (id, fileData, index, callback) ->
    boundary = '-------314159265358979323846'
    delimiter = '\r\n--' + boundary + '\r\n'
    close_delim = '\r\n--' + boundary + '--'

    contentType = 'application/json'
    metadata = {
      'indexableText':
        'text': index
    }
    base64Data = btoa(fileData)
    multipartRequestBody = delimiter +
      'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter +
      'Content-Type: ' + contentType + '\r\n' +
      'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim
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

  pickerCallback = ->
    console.log arguments

  createPicker = ->
    view = new (google.picker.View)(google.picker.ViewId.DOCS)
    view.setMimeTypes MIME
    picker = (new (google.picker.PickerBuilder))
      .enableFeature(google.picker.Feature.NAV_HIDDEN)
      .enableFeature(google.picker.Feature.MULTISELECT_ENABLED)
      .setAppId('738883605733')
      .setOAuthToken(oauthToken)
      .addView(view)
      .addView(new (google.picker.DocsUploadView))
      .setDeveloperKey(API_KEY)
      .setCallback(pickerCallback)
      .build()
    picker.setVisible true

  return {
    loadFile: (id, callback, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      await downloadFile(id, defer(error, file, data), progress)
      callback(error, file, data)

    newFile: (name, data, index, done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      progress('Saving file...')
      await insertFile(name, data, index, defer(arg))
      console.log arg
      progress('File saved.')
      done(arg)

    updateFile: (id, data, index, done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      progress('Saving file...')
      await doUpdateFile(id, data, index, defer(error))
      if !error
        progress('File saved.')
      done()

    showPicker: (done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      createPicker()

    authorizeInDrive: (cb, progress) ->

  }
