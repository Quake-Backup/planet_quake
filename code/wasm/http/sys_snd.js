
var SND = {
	context: null,
	paused: true,
	timer: null,
  nextPlayTime: 0,
  bufferingDelay: 50 / 1000,
	freq: 0,
	format: 0,
	channels: 2,
	silence: 0,
	samples: 0,
	callback: 0,
	userdata: 0,
	numSimultaneouslyQueuedBuffers: 5,
  SNDDMA_Init: SNDDMA_Init,
  SNDDMA_Shutdown: SNDDMA_Shutdown,
  SNDDMA_BeginPainting: SNDDMA_BeginPainting,
  SNDDMA_Submit: SNDDMA_Submit,
  SNDDMA_GetDMAPos: SNDDMA_GetDMAPos,

}

const AUDIO_U8      = 0x0008  /**< Unsigned 8-bit samples */
const AUDIO_S8      = 0x8008  /**< Signed 8-bit samples */
const AUDIO_U16LSB  = 0x0010  /**< Unsigned 16-bit samples */
const AUDIO_S16LSB  = 0x8010  /**< Signed 16-bit samples */
const AUDIO_U16MSB  = 0x1010  /**< As above, but big-endian byte order */
const AUDIO_S16MSB  = 0x9010  /**< As above, but big-endian byte order */
const AUDIO_U16     = AUDIO_U16LSB
const AUDIO_S16     = AUDIO_S16LSB
const AUDIO_S32LSB  = 0x8020  /**< 32-bit integer samples */
const AUDIO_S32MSB  = 0x9020  /**< As above, but big-endian byte order */
const AUDIO_S32     = AUDIO_S32LSB
const AUDIO_F32LSB  = 0x8120  /**< 32-bit floating point samples */
const AUDIO_F32MSB  = 0x9120  /**< As above, but big-endian byte order */
const AUDIO_F32     = AUDIO_F32LSB
const AUDIO_U16SYS  = AUDIO_U16LSB
const AUDIO_S16SYS  = AUDIO_S16LSB
const AUDIO_S32SYS  = AUDIO_S32LSB
const AUDIO_F32SYS  = AUDIO_F32LSB


const smoothingInterval = 0.02
//const beepLengthInSeconds = 0.5
//const beeps = [220,440,880]

function SNDDMA_Shutdown() {
  //if(SND.interval) {
  //  clearInterval(SND.interval)
  //}
	SDL_CloseAudio()
  //SND.oscillator.disconnect(SND.gainNode);
}

function SNDDMA_BeginPainting() {
  
}

function SNDDMA_Submit() {

}

function log2pad( v, roundup )
{
	let x = 1;

	while ( x < v ) x <<= 1;

	if ( roundup == 0 ) {
		if ( x > v ) {
			x >>= 1;
		}
	}

	return x;
}

function SNDDMA_GetDMAPos() {
	return dmapos
/*
	if ( !SND.inited )
		return 0;

		if ( dma.samples )
		samples = dmapos % dma.samples;
	else
		samples = 0;

	return samples
*/
}

let dmapos = 0
let dmasize = 0x100000

function SNDDMA_KHzToHz( khz )
{
	switch ( khz )
	{
		default:
		case 22: return 22050;
		case 48: return 48000;
		case 44: return 44100;
		case 11: return 11025;
	}
}


function SNDDMA_Init() {
  SND.audioOutput = new Audio()
  // can't start sound until user clicks on the page
  if(INPUT.firstClick) {
    return 0
  }

	if(SND.inited) {
		return 0
	}

  SND.nextPlayTime = 0
  let channelsName = stringToAddress('s_sdlChannels')
  Cvar_CheckRange( Cvar_Get( channelsName, stringToAddress('2'), 
    CVAR_ARCHIVE_ND | CVAR_LATCH ), stringToAddress('1'), 
    stringToAddress('2'), CV_INTEGER );
  SND.channels = Cvar_VariableIntegerValue(channelsName)
  Cvar_CheckRange( Cvar_Get( stringToAddress('s_sdlBits'), stringToAddress('16'), 
    CVAR_ARCHIVE_ND | CVAR_LATCH ), stringToAddress('8'), 
    stringToAddress('16'), CV_INTEGER );

	console.log( "SDL_Init( SDL_INIT_AUDIO )... " );

	try {
		openAudioContext();
		if (!SND.context) throw 'Web Audio API is not available!';
	} catch (e) {
		console.log( "FAILED (%s)\n", e );
		return false;
	}

	console.log( "OK\n" );
	console.log( "SDL audio driver is \"%s\".\n", 'Web Audio' );

	SND.freq = SNDDMA_KHzToHz( Cvar_VariableIntegerValue(stringToAddress('s_khz')) );
	if ( SND.freq == 0 )
		SND.freq = 22050;

	tmp = Cvar_VariableIntegerValue(stringToAddress('s_sdlBits'));
	if ( tmp < 16 )
		tmp = 8;

	SND.format = ((tmp == 16) ? AUDIO_S16SYS : AUDIO_U8);

	// I dunno if this is the best idea, but I'll give it a try...
	//  should probably check a cvar for this...
	if ( Cvar_VariableIntegerValue(stringToAddress('s_sdlDevSamps')) )
		SND.samples = Cvar_VariableValue(stringToAddress('s_sdlDevSamps'));
	else
	{
		// just pick a sane default.
		if (SND.freq <= 11025)
			SND.samples = 256;
		else if (SND.freq <= 22050)
			SND.samples = 512;
		else if (SND.freq <= 44100)
			SND.samples = 1024;
		else
			SND.samples = 2048;  // (*shrug*)
	}

	SND.channels = Cvar_VariableIntegerValue(stringToAddress('s_sdlChannels'));

	try {
		if (SND.format == 0x0008 /*AUDIO_U8*/) {
			SND.silence = 128; // Audio ranges in [0, 255], so silence is half-way in between.
		} else if (SND.format == 0x8010 /*AUDIO_S16LSB*/) {
			SND.silence = 0; // Signed data in range [-32768, 32767], silence is 0.
		} else if (SND.format == 0x8120 /*AUDIO_F32*/) {
			SND.silence = 0.0; // Float data in range [-1.0, 1.0], silence is 0.0
		} else {
			throw 'Invalid SDL audio format ' + SND.format + '!';
		}
	
		SND.scriptProcessorNode = SND.context['createScriptProcessor'](SND.samples, 0, SND.channels);
		SND.scriptProcessorNode['onaudioprocess'] = SNDDMA_AudioCallback
		SND.scriptProcessorNode.connect(SND.context.destination);
		
	}
	catch (e) {
		console.log( "SDL_OpenAudioDevice() failed: %s\n", e );
		SDL_CloseAudio()
		return false;
	}

	tmp = Cvar_VariableIntegerValue(stringToAddress('s_sdlMixSamps'));
	if ( !tmp )
		tmp = (SND.samples * SND.channels) * 10;

	// samples must be divisible by number of channels
	tmp -= tmp % SND.channels;
	// round up to next power of 2
	tmp = log2pad( tmp, 1 );

	/*

  SND.oscillator = SND.context.createOscillator()
  SND.oscillator.frequency.value = Math.random() * 2 - 1
  if(!SND.interval) {
    SND.interval = setInterval(SNDDMA_AudioCallback_Test.bind(null, SND.gainNode.gain, SND.oscillator), 50)
  }
  SND.oscillator.connect(SND.gainNode)
  SND.oscillator.start()
*/
	dmapos = 0;
/*
	dma.samplebits = SDL_AUDIO_BITSIZE( obtained.format );
	dma.isfloat = SDL_AUDIO_ISFLOAT( obtained.format );
	dma.channels = obtained.channels;
	dma.samples = tmp;
	dma.fullsamples = dma.samples / dma.channels;
	dma.submission_chunk = 1;
	dma.speed = obtained.freq;
	dmasize = (dma.samples * (dma.samplebits/8));
	dma.buffer = calloc(1, dmasize);
*/
  HEAP32[(dma >> 2) + 0] /* channels */ = SND.channels
  HEAP32[(dma >> 2) + 1] /* samples */ = tmp
  HEAP32[(dma >> 2) + 2] /* fullsamples */ = HEAPU32[(dma >> 2) + 1] / HEAPU32[(dma >> 2) + 0]
  HEAP32[(dma >> 2) + 3] /* submission_chunk */ = 1
  HEAP32[(dma >> 2) + 4] /* samplebits */ = SND.format & 0xFF
  HEAP32[(dma >> 2) + 5] /* isfloat */ = SND.format & (1<<8)
  HEAP32[(dma >> 2) + 6] /* speed */ = SND.freq // SND.context.sampleRate
	dmasize = SND.samples * (HEAPU32[(dma >> 2) + 1] * (HEAPU32[(dma >> 2) + 4]/8));
	HEAPU32[(dma >> 2) + 7] /* buffer */ = calloc(1, dmasize);
  //HEAPU32[(dma >> 2) + 7] /* buffer */ = dma_buffer2
  HEAP32[(dma >> 2) + 8] /* driver */ = stringToAddress('Web Audio')

	console.log("Starting SDL audio callback...\n");
	SDL_PauseAudio(0);  // start callback.

	console.log("SDL audio initialized.\n");
	SND.inited = true;

  return 1
}

/*
===============
SNDDMA_AudioCallback
===============
*/
function SNDDMA_AudioCallback(e)
{
	let frameLen = ((SND.format & 0xFF) * 8) * SND.channels * 2
	/* Only do something if audio is enabled */
	if (!SND.inited || SND.paused) {
		//SDL_memset(HEAPU32[(dma >> 2) + 7], SND.silence, dmasize);
		//FeedAudioDevice(HEAPU32[(dma >> 2) + 7], dmasize);
		return;
	}

	let setStream = function ($0, $1) {
		let numChannels = e.outputBuffer.numberOfChannels
		for (let c = 0; c < numChannels; ++c) {
			let channelData = e.outputBuffer.getChannelData(c);
			if (channelData.length != $1) {
				throw new Error('Web Audio output buffer length mismatch! Destination size: ' + channelData.length + ' samples vs expected ' + $1 + ' samples!');
			}
			//SND.callback(channelData, 0, channelData.length)
			for (let j = 0; j < frameLen; ++j) {
				//channelData[j] = HEAPF32[($0 + ((j*numChannels + c) << 2)) >> 2];
				let tune = (Math.sin((0+j)*0.1)*20000.0*256.0) >> 8
				if (tune > 0x7fff)
					tune = 0x7fff;
				else if (tune < -32768)
					tune = -32768;
				channelData[j % SND.samples] = 32768.0 / tune
			}
		}
	}

	


	let pos = (dmapos * (HEAPU32[(dma >> 2) + 4]/8));
	if (pos >= dmasize)
		dmapos = pos = 0;

	let tobufend = dmasize - pos;  /* bytes to buffer's end. */
	let len1 = SND.samples;
	let len2 = 0;

	if (len1 > tobufend)
	{
		len1 = tobufend;
		len2 = SND.samples - len1;
	}
	
	setStream(HEAPU32[(dma >> 2) + 7] + pos, frameLen)
	//memcpy(stream, HEAPU32[(dma >> 2) + 7] + pos, len1);
	if (len2 <= 0)
		dmapos += (len1 / (HEAPU32[(dma >> 2) + 4]/8));
	else  /* wraparound? */
	{
		setStream(HEAPU32[(dma >> 2) + 7], frameLen)
		//memcpy(stream+len1, HEAPU32[(dma >> 2) + 7], len2);
		dmapos = (len2 / (HEAPU32[(dma >> 2) + 4]/8));
	}

	if (dmapos >= dmasize)
		dmapos = 0;

}


function openAudioContext() {

	SND.audioOutput = new Audio();

	// Initialize Web Audio API if we haven't done so yet. Note: Only initialize Web Audio context ever once on the web page,
	// since initializing multiple times fails on Chrome saying 'audio resources have been exhausted'.
	if (!SND.context) {
		if (typeof(AudioContext) !== 'undefined') 
			SND.context = new AudioContext();
		else if (typeof(webkitAudioContext) !== 'undefined') 
			SND.context = new webkitAudioContext();
	}
}


function SDL_PauseAudio(pauseOn) {
	SND.paused = pauseOn;
}

function SDL_CloseAudio() {
	if (SND.scriptProcessorNode != undefined) {
		SND.scriptProcessorNode.disconnect();
		SND.scriptProcessorNode = undefined;
	}
	if(SND.context) {
		SND.context.close();
		SND.context = undefined;
	}
}

function SDL_AudioQuit() {
	for (let i = 0; i < SDL.numChannels; ++i) {
		if (SDL.channels[i].audio) {
			SDL.channels[i].audio.pause();
			SDL.channels[i].audio = undefined;
		}
	}
	if (SDL.music.audio) SDL.music.audio.pause();
	SDL.music.audio = undefined;
}


function SDL_LockAudio() {}
function SDL_UnlockAudio() {}
