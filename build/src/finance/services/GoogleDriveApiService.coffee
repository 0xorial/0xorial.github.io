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

  progress = null
  oauthToken = null
  loadClient = ->
    return new Promise (resolve, reject) ->
      window.onGapiClientLoaded = ->
        window.onGapiClientLoaded = null
        resolve()

      $.ajax({
        url: 'https://apis.google.com/js/client.js?onload=onGapiClientLoaded'
        dataType: 'script'
        cache: true
      })
      .fail ->
        window.onGapiClientLoaded = null
        console.log arguments
        reject(arguments)


  authAndLoadApi = ->
    progress('Loading client...')
    loadClient()
    .then ->
      progress('Authorizing...')
      return Promise.resolve (gapi.auth.authorize {
          'client_id': CLIENT_ID
          'scope': SCOPES.join(' ')
          'immediate': true
        })
    .then (authResult) ->
      if authResult.error
        progress '', true
        return

      oauthToken = authResult.access_token
      progress('Loading drive API...')
      return Promise.resolve(gapi.client.load('drive', 'v2'))
    .then ->
      progress('Loading picker API...')
      return Promise.resolve(gapi.load('picker'))

  initPromise = null
  ensureInitCompleted = () ->
    if initPromise
      return initPromise
    initPromise = authAndLoadApi()
    initPromise.catch ->
      initPromise = null
    return initPromise

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

    return new Promise (resolve, reject) ->
      request.execute -> resolve(arguments)

  doUpdateFile = (id, fileData, index) ->
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

    return Promise.resolve(request)

  downloadFile = (id) ->
    file = null
    requestPromise = Promise.resolve(gapi.client.drive.files.get('fileId': id))
    progress('Opening file...')
    requestPromise.catch (e) ->
      console.log(e)
    downloadPromise = requestPromise.then (result) ->
      progress('Downloading file...')
      file = result.result
      url = file.downloadUrl
      # accessToken = gapi.auth.getToken().access_token
      headers = {'Authorization': 'Bearer ' + oauthToken }
      return ajaxGet(url, headers)
    .then (data) ->
      return {file: file, data: data}

    return downloadPromise

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
    loadFile: (options) ->
      id = options.id
      progress = options.progress
      ensureInitCompleted()
      .then ->
        return downloadFile(id)

    newFile: (options) ->
      {name, data, index, progress} = options
      ensureInitCompleted()
      .then ->
        progress('Saving file...')
        return insertFile(name, data, index)
      .then (arg) ->
        console.log arg
        progress('File saved.')
        return arg

    updateFile: (options) ->
      {id, name, data, index, progress1} = options
      ensureInitCompleted()
      .then ->
        progress('Saving file...')
        return doUpdateFile(id, data, index)
      .then ->
        progress('File saved.')

    showPicker: (done, progress) ->
      await ensureInitCompleted({done: defer(), progress: progress})
      createPicker()

    authorizeInDrive: (cb, progress) ->

  }
