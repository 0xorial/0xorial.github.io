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
    await loadClient(defer())
    await gapi.auth.authorize {
      'client_id': CLIENT_ID
      'scope': SCOPES.join(' ')
      'immediate': true
    }, defer(authResult)
    if authResult and !authResult.error
      await gapi.client.load 'drive', 'v2', defer()
      cb()
    else
      console.log('could not authorise')
      console.log(authResult)
    return

  initWaiters = []
  initFinished = false
  waitForInit = (cb) ->
    initWaiters.push cb

  initStarted = false
  init = ->
    if initStarted
      return
    initStarted = true
    await authAndLoadApi(defer())
    for cb in initWaiters
      cb()

  ensureInitCompleted = (cb) ->
    if initFinished
      cb()
    else
      init()
      waitForInit(cb)

  return {
    loadFile: (path, callback) ->
      await ensureInitCompleted(defer())
      request = gapi.client.drive.files.list()
      await request.execute(defer(r))
      console.log r
  }
