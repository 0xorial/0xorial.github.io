(function() {
  var CLIENT_ID, SCOPES, appendPre, handleAuthResult, listFiles, loadDriveApi;

  CLIENT_ID = '738883605733-b6bc7deeulg034sncifk1upknib3b0n0.apps.googleusercontent.com';

  SCOPES = ['https://www.googleapis.com/auth/drive.metadata.readonly', 'https://www.googleapis.com/auth/drive.file'];


  /**
  * Check if current user has authorized this application.
   */

  window.checkAuth = function() {
    gapi.auth.authorize({
      'client_id': CLIENT_ID,
      'scope': SCOPES.join(' '),
      'immediate': true
    }, handleAuthResult);
  };


  /**
  * Handle response from authorization server.
  *
  * @param {Object} authResult Authorization result.
   */

  handleAuthResult = function(authResult) {
    var authorizeDiv;
    authorizeDiv = document.getElementById('authorize-div');
    if (authResult && !authResult.error) {
      authorizeDiv.style.display = 'none';
      loadDriveApi();
    } else {
      authorizeDiv.style.display = 'inline';
    }
  };


  /**
  * Initiate auth flow in response to user clicking authorize button.
  *
  * @param {Event} event Button click event.
   */

  window.handleAuthClick = function(event) {
    gapi.auth.authorize({
      client_id: CLIENT_ID,
      scope: SCOPES,
      immediate: false
    }, handleAuthResult);
    return false;
  };


  /**
  * Load Drive API client library.
   */

  loadDriveApi = function() {
    gapi.client.load('drive', 'v2', listFiles);
  };


  /**
  * Print files.
   */

  listFiles = function() {
    var request;
    request = gapi.client.drive.files.list({
      'maxResults': 10
    });
    request.execute(function(resp) {
      var file, files, i;
      appendPre('Files:');
      files = resp.items;
      if (files && files.length > 0) {
        i = 0;
        while (i < files.length) {
          file = files[i];
          appendPre(file.title + ' (' + file.id + ')');
          i++;
        }
      } else {
        appendPre('No files found.');
      }
    });
  };


  /**
  * Append a pre element to the body containing the given message
  * as its text node.
  *
  * @param {string} message Text to be placed in pre element.
   */

  appendPre = function(message) {
    var pre, textContent;
    pre = document.getElementById('output');
    textContent = document.createTextNode(message + '\\n');
    pre.appendChild(textContent);
  };


  /**
   * Insert new file.
  #
   * @param {File} fileData File object to read data from.
   * @param {Function} callback Function to call when the request is complete.
   */

  window.insertFile = function(name, data, callback) {
    var base64Data, boundary, close_delim, contentType, delimiter, metadata, multipartRequestBody, request;
    boundary = '-------314159265358979323846';
    delimiter = '\r\n--' + boundary + '\r\n';
    close_delim = '\r\n--' + boundary + '--';
    contentType = 'application/json';
    metadata = {
      'title': name
    };
    base64Data = btoa(JSON.stringify(data));
    multipartRequestBody = delimiter + 'Content-Type: application/json\r\n\r\n' + JSON.stringify(metadata) + delimiter + 'Content-Type: ' + contentType + '\r\n' + 'Content-Transfer-Encoding: base64\r\n' + '\r\n' + base64Data + close_delim;
    request = gapi.client.request({
      'path': '/upload/drive/v2/files',
      'method': 'POST',
      'params': {
        'uploadType': 'multipart'
      },
      'headers': {
        'Content-Type': 'multipart/mixed; boundary="' + boundary + '"'
      },
      'body': multipartRequestBody
    });
    if (!callback) {
      callback = function(file) {
        console.log(file);
      };
    }
    request.execute(callback);
    return;
  };

}).call(this);
