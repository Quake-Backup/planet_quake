
function Sys_SockaddrToString() {
  // DNS doesn't work in the browser, but UDP works with SOCKS
  //   How complicated to add DNS lookup through SOCK?
}

function Sys_StringToAdr() {

}

function Sys_StringToSockaddr() {
  
}

function Sys_SendPacket() {
  debugger
}

function NET_GetPacket() {
  debugger
}

function NET_Sleep() {

}

function NET_OpenIP() {

}

function NET_Close() {

}

function Sys_IsLANAddress() {
  
}

function Sys_Offline() {

}

function Sys_NET_MulticastLocal (net, length, data) {
  debugger
  // all this does is use a dedicated server in a service worker
  window.serverWorker.postMessage([
    'net', net, Uint8Array.from(HEAP8.slice(data, data+length))])
}

function CL_Download(cmd, name, auto) {
  if(!FS.database) {
    openDatabase()
  }
  if(AbortController && !NET.controller) {
    NET.controller = new AbortController()
  }
  if(NET.downloadCount > 5) {
    return false // delay like cl_curl does
  }

  // TODO: make a utility for Cvar stuff?
  let dlURL = addressToString(Cvar_VariableString(stringToAddress("cl_dlURL")))
  let gamedir = addressToString(FS_GetCurrentGameDir())
  let nameStr = addressToString(name)
  let localName = nameStr
  if(localName[0] == '/')
    localName = localName.substring(1)
  if(localName.startsWith(gamedir))
    localName = localName.substring(gamedir.length)
  if(localName[0] == '/')
    localName = localName.substring(1)

  let remoteURL
  if(dlURL.includes('%1')) {
    remoteURL = dlURL.replace('%1', localName.replace(/\//ig, '%2F'))
  } else {
    remoteURL = dlURL + '/' + localName
  }
  if(remoteURL.includes('.googleapis.com')) {
    if(nameStr.endsWith('/')) {
      remoteURL = 'https://www.googleapis.com/storage/v1/b/'
        + remoteURL.match(/\/b\/(.*?)\/o\//)[1]
        + '/o/?includeTrailingDelimiter=true&maxResults=100&delimiter=%2f&prefix='
        + remoteURL.match(/\/o\/(.*)/)[1]
    } else if (!remoteURL.includes('?')) {
      remoteURL += '?alt=media'
    }
  }
  try {
  NET.downloadCount++
  fetch(remoteURL, {
    mode: 'cors',
    responseType: 'arraybuffer',
    credentials: 'omit',
    signal: NET.controller ? NET.controller.signal : null
  })
  .catch(function (error) {
    return
  })
  .then(function (response) {
    //let type = response.headers.get('Content-Type')
    if (!response || !(response.status >= 200 && response.status < 300 || response.status === 304)) {
      Sys_FileReady(stringToAddress(localName), null) // failed state, not to retry
      //throw new Error('Couldn\'t load ' + response.url + '. Status: ' + (response || {}).statusCode)
      response.body.getReader().cancel()
      //if(controller)
        //controller.abort()
      return
    }
    return response.arrayBuffer()
  })
  .catch(function (error) {
    return
  })
  .then(function (responseData) {
    NET.downloadCount--
    if(!responseData) {
      // already responded with null data
      return
    }
    // don't store any index files, redownload every start
    if(nameStr[nameStr.length - 1] == '/') {
      let tempName = nameStr + '.' // yes this is where it always looks for temp files
        + Math.round(Math.random() * 0xFFFFFFFF).toString(16) + '.tmp'
      FS_CreatePath(stringToAddress('/home/' + nameStr + '/'))
      FS.virtual[tempName] = {
        timestamp: new Date(),
        mode: 33206,
        contents: new Uint8Array(responseData)
      }
      /*
      let storeDirectory = objStore.put({
        timestamp: new Date(),
        mode: 16895
      }, key)
      */
      Sys_FileReady(stringToAddress(localName), stringToAddress(tempName));
    } else {
      // TODO: JSON.parse
      // save the file in memory for now
      if(!nameStr.includes(gamedir)) {
        debugger
        throw new Error('something wrong')
      }
      FS_CreatePath(stringToAddress('/home/' + nameStr))
      FS.virtual[nameStr] = {
        timestamp: new Date(),
        mode: 33206,
        contents: new Uint8Array(responseData)
      }
      // async to filesystem
      // does it REALLY matter if it makes it? wont it just redownload?
      writeStore(FS.virtual[nameStr], '/base/' + nameStr)
      Sys_FileReady(stringToAddress(localName), stringToAddress(nameStr));
    }

  })
  } catch (e) {
    
  }
  return true
}

var NET = {
  downloadCount: 0,
  controller: null,
  Sys_Offline: Sys_Offline,
  Sys_SockaddrToString: Sys_SockaddrToString,
  Sys_StringToSockaddr: Sys_StringToSockaddr,
  NET_GetPacket: NET_GetPacket,
  NET_Sleep: NET_Sleep,
  NET_OpenIP: NET_OpenIP,
  NET_Close: NET_Close,
  Sys_StringToAdr: Sys_StringToAdr,
  Sys_SendPacket: Sys_SendPacket,
  Sys_IsLANAddress: Sys_IsLANAddress,
  Sys_NET_MulticastLocal: Sys_NET_MulticastLocal,
  CL_Download: CL_Download,

}