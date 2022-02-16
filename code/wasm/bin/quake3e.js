if(typeof global != 'undefined' && typeof global.window == 'undefined') {
  global.window = {}
}

function addressToString(addr, length) {
  let newString = ''
  for(let i = 0; i < length || 1024; i++) {
    if(Q3e['paged'][addr + i] == '0') {
      break;
    }
    newString += String.fromCharCode(Q3e['paged'][addr + i])
  }
  return newString
}

function stringsToMemory(addr, list) {
  Q3e.paged32[(addr+0)>>2] = list.length; // first set to count of strings to follow
  let posInSeries = addr + 1
  for (let i = 0; i < list.length; i++) {
    for(let j = 0; j < list[i].length; j++) {
      Q3e.paged[posInSeries+j] = list[i].charCodeAt(j)
    }
    Q3e.paged[posInSeries+list[i].length] = 0
    posInSeries += list[i].length + 1
  }
  Q3e.paged32[(addr+0)>>2] = posInSeries; // then set to total length of strings
  return posInSeries
}

function Sys_ListFiles (directory, ext, filter, numfiles, dironly) {
  let files = {
    'default.cfg': {
      mtime: 0,
      size: 1024,
      
    }
  }
  let matches = Object.keys(files).reduce(function (list, name) {
   // TODO: match directory 
   return !ext || name.lastIndexOf(ext) === (name.length - ext.length)
  }, [])
  /* let inMemory = */ stringsToMemory(Q3e.shared + Q3e.sharedCounter, matches)
  Q3e.paged32[(numfiles+0)>>2] = matches.length;
  // here's the thing, I know for a fact that all the callers copy this stuff
  //   so I don't need to increase my temporary storage because by the time it's
  //   overwritten the data won't be needed, should only keep shared storage around
  //   for events and stuff that might take more than 1 frame
  //Q3e.sharedCounter += inMemory
  return Q3e.sharedCounter + 1 // skip length because count is used
}

function Sys_Offline() {

}

function Sys_NET_MulticastLocal (net, length, data) {
  // all this does is use a dedicated server in a service worker
  window.serverWorker.postMessage([
    'net', net, Uint8Array.from(HEAP8.slice(data, data+length))])
}

function SDL_GetDesktopDisplayMode(display, mode) {
  Q3e.paged32[(mode+1)>>2] = window.innerWidth;
  Q3e.paged32[(mode+2)>>2] = window.innerHeight;
}


function SDL_GL_GetDrawableSize(display, width, height) {
  Q3e.paged32[(width+0)>>2] = Q3e.canvas.width;
  Q3e.paged32[(height+0)>>2] = Q3e.canvas.height;
}

function SDL_CreateWindow (title, x, y, w, h, flags) {
  var win = malloc(8)
  // TODO: multiple windows like a DVR?
  //   what kind of game needs two screens for one player to switch back and forth?
  /*
  SDL.windows[handle] = {
    x: x,
    y: y,
    w: w,
    h: h,
    title: title,
    flags: flags,
  }
  */
  Q3e.canvas = document.createElement("canvas");
  Q3e.canvas.width = document.body.innerWidth;
  Q3e.canvas.height = document.body.innerHeight;

  Q3e.paged32[win>>2] = 1
  window.title = addressToString(title)
  return win;
}

function SDL_GL_CreateContext(canvas) {
  let webGLContextAttributes = {
    failIfMajorPerformanceCaveat: true
  }
  let ctx = (Q3e.majorVersion > 1)
    ? Q3e.canvas.getContext("webgl2", webGLContextAttributes)
    : (Q3e.canvas.getContext("webgl", webGLContextAttributes)
      || Q3e.canvas.getContext('experimental-webgl'))
  if (!ctx) return 0
  let handle = malloc(8);
  // TODO: keep track of multiple?
  Q3e.paged32[handle>>2] = 1
  return handle
}

function SDL_GL_SetAttribute(attr, value) {
  Q3e.majorVersion = value
}

function SDL_GetError() {
  stringsToMemory(Q3e.shared + Q3e.sharedCounter, ['Unknown WebGL error.'])
  return Q3e.sharedCounter + 1
}

function SDL_SetWindowDisplayMode () { 
  // TODO: add a button or something for user
} 

function SDL_SetWindowGrab (window, grabbed) {
  // set the window to do the grabbing, when ungrabbing this doesn't really matter
  if(grabbed) {
    Q3e.canvas.requestPointerLock();
  } else {
    Q3e.canvas.exitPointerLock();
  }
}

function SDL_StopTextInput () {
  SDL.textInput = false;
}

function SDL_ShowCursor() {
  // TODO: some safety stuff?
  Q3e.canvas.exitPointerLock();
}

var Q3e = {
  DebugBreak: function () { debugger; debugger; },
  longjmp: function (id, code) { throw new Error('longjmp', id, code) },
  setjmp: function (id) { try {} catch (e) {} },
  exportMappings: {},
  SDL_GetDesktopDisplayMode: SDL_GetDesktopDisplayMode,
  SDL_GL_SetAttribute: SDL_GL_SetAttribute,
  SDL_CreateWindow: SDL_CreateWindow,
  SDL_GetError: SDL_GetError,
  SDL_SetWindowDisplayMode: SDL_SetWindowDisplayMode,
  SDL_GL_CreateContext: SDL_GL_CreateContext,
  SDL_GL_GetDrawableSize: SDL_GL_GetDrawableSize,
  SDL_WasInit: function (device) { return 1; },
  SDL_Init: function () {},
  SDL_OpenAudioDevice: function () {},
  SDL_PauseAudioDevice: function () {},
  SDL_CloseAudioDevice: function () {},
  SDL_StopTextInput: SDL_StopTextInput,
  SDL_SetWindowGrab: SDL_SetWindowGrab,
  SDL_ShowCursor: SDL_ShowCursor,
  Sys_RandomBytes: Sys_RandomBytes,
  Sys_Milliseconds: Sys_Milliseconds,
  Sys_ListFiles: Sys_ListFiles,
  Sys_Offline: Sys_Offline,
  Sys_NET_MulticastLocal: Sys_NET_MulticastLocal,
  Sys_Exit: function () {
    // TODO: was Sys_Main_PlatformExit
  },
  dlopen: function dlopen (base, gamedir, fname) {
    // TODO: download and callback
  },
  dlerror: function dlerror() { 
    let lastDlError = Q3e.lastDlError
    Q3e.lastDlError = NULL
    stringsToMemory(Q3e.shared + Q3e.sharedCounter, [lastDlError])
    return Q3e.sharedCounter + 1
  },
  dlclose: function dlclose() {
    // TODO: delete something
  },
  dlsym: function dlsym(handle, symbol) {

  },
  fprintf: function (f, err, args) {
    // TODO: rewrite va_args in JS for convenience?
    console.log(addressToString(err), 
    Array.from(Q3e['paged']
      .slice(Q3e.paged32[(args) >> 2], Q3e.paged32[(args) >> 2] + 10))
        .map(c => String.fromCharCode(c))
          .join(''));
  },
  srand: function srand() {}, // TODO: highly under-appreciated game dynamic
  atoi: parseInt,
  atof: parseFloat,
  popen: function popen() {},
  assert: console.assert,
  asctime: function () {
    // Don't really care what time it is because this is what the engine does
    //   right above this call
    return stringsToMemory(Q3e.shared + Q3e.sharedCounter, [new Date().toLocaleString()])
  },
  Sys_SockaddrToString: Sys_SockaddrToString,
  Sys_StringToSockaddr: Sys_StringToSockaddr,
  NET_GetPacket: NET_GetPacket,
  NET_Sleep: NET_Sleep,
  NET_SendPacket: NET_SendPacket,
  NET_OpenIP: NET_OpenIP,
  Sys_StringToAdr: Sys_StringToAdr,
  Sys_SendPacket: Sys_SendPacket,
  Sys_IsLANAddress: Sys_IsLANAddress
}

let maths = Object.getOwnPropertyNames(Math)
for(let j = 0; j < maths.length; j++) {
  Q3e[maths[j]] = Math[maths[j]]
}

var GL = {

}


init(Q3e, GL)

function init(env) {
  fetch('./quake3e_slim.wasm').then(function(response) {
    return response.arrayBuffer()
  }).then(function(bytes) {
    Q3e['memory'] = new WebAssembly['Memory']( {'initial': 512} )
    Q3e['paged'] = new Uint8Array( Q3e['memory'].buffer )
    Q3e['paged32'] = new Uint32Array( Q3e['memory'].buffer )
   return WebAssembly.instantiate(bytes, { env: env, GL: GL, Math: Math })
  }).then(function(program) {
    // share the game with window for hackers
    Q3e['exports'] = program.instance.exports
    let newMethods = Object.keys(Q3e['exports'])
    for(let i = 0; i < newMethods.length; i++) {
      window[newMethods[i]] = Q3e['exports'][newMethods[i]] //.apply(Q3e['exports'])
    }
    Object.assign(window, Q3e['exports'])
    // reserve some memory at the beginning for passing shit back and forth with JS
    //   not to use a complex HEAP, just loop around on bytes[b % 128] and if 
    //   something isn't cleared out, crash
    Q3e['shared'] = malloc(1024 * 1024)
    Q3e['sharedCounter'] = 0
    // Wow, look at all the unfuckery I don't have to do with startup options because
    //   I'm not using emscripten anymore.
    let startup = [
      'quake3e_web',
      '+set', 'fs_basepath', '/base',
      '+set', 'sv_pure', '0', // require for now, TODO: server side zips
    ];
    let startupArgs = stringsToMemory(Q3e.shared + Q3e.sharedCounter, startup);
    Q3e.sharedCounter += startupArgs
    return RunGame(startup.length, startupArgs)
  });
}

function Sys_Milliseconds() {
  // javascript times are bigger, so start at zero
  if (!Q3e['timeBase']) {
    Q3e['timeBase'] = Date.now();
  }

  if (window.performance.now) {
    return parseInt(window.performance.now(), 10);
  } else if (window.performance.webkitNow) {
    return parseInt(window.performance.webkitNow(), 10);
  } else {
    return Date.now() - SYS.timeBase();
  }
}

function Sys_RandomBytes (string, len) {
	if(typeof crypto != 'undefined') {
		crypto.getRandomValues(Q3e.paged.subarray(string, string+len))
	} else {
		for(var i = 0; i < len; i++) {
			Q3e.paged[string] = Math.random() * 255
		}
	}
	return true;
}

function Sys_SockaddrToString() {
  // DNS doesn't work in the browser, but UDP works with SOCKS
  //   How complicated to add DNS lookup through SOCK?
}

function Sys_StringToAdr() {

}

function Sys_StringToSockaddr() {
  
}

function Sys_SendPacket() {

}

function NET_GetPacket() {

}

function NET_Sleep() {

}

function NET_SendPacket() {

}

function NET_OpenIP() {

}

function Sys_IsLANAddress() {
  
}
