
# Quake3 Unix Makefile
#
# Nov '98 by Zoid <zoid@idsoftware.com>
#
# Loki Hacking by Bernd Kreimeier
#  and a little more by Ryan C. Gordon.
#  and a little more by Rafael Barrero
#  and a little more by the ioq3 cr3w
#
# GNU Make required
#
COMPILE_PLATFORM=$(shell uname | sed -e 's/_.*//' | tr '[:upper:]' '[:lower:]' | sed -e 's/\//_/g')
COMPILE_ARCH=$(shell uname -m | sed -e 's/i.86/x86/' | sed -e 's/^arm.*/arm/')

ifeq ($(COMPILE_PLATFORM),mingw32)
  ifeq ($(COMPILE_ARCH),i386)
    COMPILE_ARCH=x86
  endif
endif

BUILD_CLIENT     = 1
BUILD_SERVER     = 1

USE_SDL          = 1
USE_CURL         = 1
USE_LOCAL_HEADERS= 0
USE_VULKAN       = 0
USE_SYSTEM_JPEG  = 0
USE_VULKAN_API   = 1

USE_RENDERER_DLOPEN = 1

CNAME            = quake3e
DNAME            = quake3e.ded

RENDERER_PREFIX  = $(CNAME)

ifeq ($(V),1)
echo_cmd=@:
Q=
else
echo_cmd=@echo
Q=@
endif

#############################################################################
#
# If you require a different configuration from the defaults below, create a
# new file named "Makefile.local" in the same directory as this file and define
# your parameters there. This allows you to change configuration without
# causing problems with keeping up to date with the repository.
#
#############################################################################
-include Makefile.local

ifeq ($(COMPILE_PLATFORM),darwin)
  USE_SDL=1
endif

ifeq ($(COMPILE_PLATFORM),cygwin)
  PLATFORM=mingw32
endif

ifndef PLATFORM
PLATFORM=$(COMPILE_PLATFORM)
endif
export PLATFORM

ifeq ($(PLATFORM),mingw32)
  MINGW=1
endif
ifeq ($(PLATFORM),mingw64)
  MINGW=1
endif

ifeq ($(COMPILE_ARCH),i86pc)
  COMPILE_ARCH=x86
endif

ifeq ($(COMPILE_ARCH),amd64)
  COMPILE_ARCH=x86_64
endif
ifeq ($(COMPILE_ARCH),x64)
  COMPILE_ARCH=x86_64
endif

ifndef ARCH
ARCH=$(COMPILE_ARCH)
endif
ifeq ($(PLATFORM),js)
ARCH=js
endif
export ARCH

ifneq ($(PLATFORM),$(COMPILE_PLATFORM))
  CROSS_COMPILING=1
else
  CROSS_COMPILING=0

  ifneq ($(ARCH),$(COMPILE_ARCH))
    CROSS_COMPILING=1
  endif
endif
export CROSS_COMPILING

ifndef COPYDIR
COPYDIR="/usr/local/games/quake3"
endif

ifndef DESTDIR
DESTDIR=/usr/local/games/quake3
endif

ifndef MOUNT_DIR
MOUNT_DIR=code
endif

ifndef BUILD_DIR
BUILD_DIR=build
endif

ifndef GENERATE_DEPENDENCIES
GENERATE_DEPENDENCIES=1
endif

ifndef USE_CCACHE
USE_CCACHE=0
endif
export USE_CCACHE

ifndef USE_CODEC_VORBIS
USE_CODEC_VORBIS=0
endif

ifndef USE_CODEC_OPUS
USE_CODEC_OPUS=0
endif

ifndef USE_CIN_THEORA
USE_CIN_THEORA=0
endif

ifndef USE_CIN_XVID
USE_CIN_THEORA=0
endif

ifndef USE_CIN_VPX
USE_CIN_THEORA=0
endif

ifndef USE_LOCAL_HEADERS
USE_LOCAL_HEADERS=1
endif

ifndef USE_CURL
USE_CURL=1
endif

ifndef USE_CURL_DLOPEN
ifdef MINGW
  USE_CURL_DLOPEN=0
else
  USE_CURL_DLOPEN=1
endif
endif

ifneq ($(USE_RENDERER_DLOPEN),0)
USE_VULKAN=1
endif

ifneq ($(USE_VULKAN),0)
USE_VULKAN_API=1
endif


#############################################################################

BD=$(BUILD_DIR)/debug-$(PLATFORM)-$(ARCH)
BR=$(BUILD_DIR)/release-$(PLATFORM)-$(ARCH)
ADIR=$(MOUNT_DIR)/asm
CDIR=$(MOUNT_DIR)/client
SDIR=$(MOUNT_DIR)/server
TDIR=$(MOUNT_DIR)/tools
RCDIR=$(MOUNT_DIR)/renderercommon
R1DIR=$(MOUNT_DIR)/renderer
R2DIR=$(MOUNT_DIR)/renderer2
RVDIR=$(MOUNT_DIR)/renderervk
SDLDIR=$(MOUNT_DIR)/sdl

OGGDIR=$(MOUNT_DIR)/ogg
VORBISDIR=$(MOUNT_DIR)/vorbis
OPUSDIR=$(MOUNT_DIR)/opus-1.2.1
OPUSFILEDIR=$(MOUNT_DIR)/opusfile-0.9
CMDIR=$(MOUNT_DIR)/qcommon
UDIR=$(MOUNT_DIR)/unix
W32DIR=$(MOUNT_DIR)/win32
QUAKEJS=$(MOUNT_DIR)/wasm
BLIBDIR=$(MOUNT_DIR)/botlib
UIDIR=$(MOUNT_DIR)/ui
JPDIR=$(MOUNT_DIR)/libjpeg

bin_path=$(shell which $(1) 2> /dev/null)

STRIP ?= strip
  PKG_CONFIG ?= pkg-config
INSTALL=install
MKDIR=mkdir

ifneq ($(call bin_path, $(PKG_CONFIG)),)
  SDL_INCLUDE ?= $(shell $(PKG_CONFIG) --silence-errors --cflags-only-I sdl2)
  SDL_LIBS ?= $(shell $(PKG_CONFIG) --silence-errors --libs sdl2)
  X11_INCLUDE ?= $(shell $(PKG_CONFIG) --silence-errors --cflags-only-I x11)
  X11_LIBS ?= $(shell $(PKG_CONFIG) --silence-errors --libs x11)
endif

# supply some reasonable defaults for SDL/X11?
ifeq ($(X11_INCLUDE),)
X11_INCLUDE = -I/usr/X11R6/include
endif
ifeq ($(X11_LIBS),)
X11_LIBS = -lX11
endif
ifeq ($(SDL_LIBS),)
SDL_LIBS = -lSDL2
endif

# extract version info
VERSION=$(shell grep "\#define Q3_VERSION" $(CMDIR)/q_shared.h | \
  sed -e 's/.*"[^" ]* \([^" ]*\)\( MV\)*"/\1/')

# common qvm definition
ifeq ($(ARCH),x86_64)
  HAVE_VM_COMPILED = true
else
ifeq ($(ARCH),x86)
  HAVE_VM_COMPILED = true
else
  HAVE_VM_COMPILED = false
endif
endif

ifeq ($(ARCH),arm)
  HAVE_VM_COMPILED = true
endif
ifeq ($(ARCH),aarch64)
  HAVE_VM_COMPILED = true
endif

BASE_CFLAGS =

#ifndef USE_MEMORY_MAPS
#  USE_MEMORY_MAPS = 1
#  BASE_CFLAGS += -DUSE_MEMORY_MAPS
#endif

ifeq ($(USE_SYSTEM_JPEG),1)
  BASE_CFLAGS += -DUSE_SYSTEM_JPEG
endif

ifneq ($(HAVE_VM_COMPILED),true)
  BASE_CFLAGS += -DNO_VM_COMPILED
endif

ifneq ($(USE_RENDERER_DLOPEN),0)
  BASE_CFLAGS += -DUSE_RENDERER_DLOPEN
  BASE_CFLAGS += -DRENDERER_PREFIX=\\\"$(RENDERER_PREFIX)\\\"
endif

ifeq ($(USE_CODEC_VORBIS),1)
  BASE_CFLAGS += -DUSE_CODEC_VORBIS=1
endif

ifdef DEFAULT_BASEDIR
  BASE_CFLAGS += -DDEFAULT_BASEDIR=\\\"$(DEFAULT_BASEDIR)\\\"
endif

ifeq ($(USE_LOCAL_HEADERS),1)
  BASE_CFLAGS += -DUSE_LOCAL_HEADERS=1
endif

ifeq ($(USE_VULKAN_API),1)
  BASE_CFLAGS += -DUSE_VULKAN_API
endif

ifeq ($(GENERATE_DEPENDENCIES),1)
  BASE_CFLAGS += -MMD
endif

## Defaults
INSTALL=install
MKDIR=mkdir

ARCHEXT=

CLIENT_EXTRA_FILES=


#############################################################################
# SETUP AND BUILD -- MINGW32
#############################################################################

ifdef MINGW

  ifeq ($(CROSS_COMPILING),1)
    # If CC is already set to something generic, we probably want to use
    # something more specific
    ifneq ($(findstring $(strip $(CC)),cc gcc),)
      CC=
    endif

    # We need to figure out the correct gcc and windres
    ifeq ($(ARCH),x86_64)
      MINGW_PREFIXES=x86_64-w64-mingw32 amd64-mingw32msvc
      STRIP=x86_64-w64-mingw32-strip
    endif
    ifeq ($(ARCH),x86)
      MINGW_PREFIXES=i686-w64-mingw32 i586-mingw32msvc i686-pc-mingw32
    endif

    ifndef CC
      CC=$(firstword $(strip $(foreach MINGW_PREFIX, $(MINGW_PREFIXES), \
         $(call bin_path, $(MINGW_PREFIX)-gcc))))
    endif

#   STRIP=$(MINGW_PREFIX)-strip -g

    ifndef WINDRES
      WINDRES=$(firstword $(strip $(foreach MINGW_PREFIX, $(MINGW_PREFIXES), \
         $(call bin_path, $(MINGW_PREFIX)-windres))))
    endif
  else
    # Some MinGW installations define CC to cc, but don't actually provide cc,
    # so check that CC points to a real binary and use gcc if it doesn't
    ifeq ($(call bin_path, $(CC)),)
      CC=gcc
    endif

  endif

  # using generic windres if specific one is not present
  ifeq ($(WINDRES),)
    WINDRES=windres
  endif

  ifeq ($(CC),)
    $(error Cannot find a suitable cross compiler for $(PLATFORM))
  endif

  BASE_CFLAGS += -Wall -fno-strict-aliasing -Wimplicit -Wstrict-prototypes \
    -DUSE_ICON -DMINGW=1

  BASE_CFLAGS += -Wno-unused-result

  ifeq ($(ARCH),x86_64)
    ARCHEXT = .x64
    BASE_CFLAGS += -m64
    OPTIMIZE = -O2 -ffast-math -fstrength-reduce
  endif
  ifeq ($(ARCH),x86)
    BASE_CFLAGS += -m32
    OPTIMIZE = -O2 -march=i586 -mtune=i686 -ffast-math -fstrength-reduce
  endif

  SHLIBEXT = dll
  SHLIBCFLAGS = -fPIC -fvisibility=hidden
  SHLIBLDFLAGS = -shared $(LDFLAGS)

  BINEXT = .exe

  LDFLAGS = -mwindows -Wl,--dynamicbase -Wl,--nxcompat  -fvisibility=hidden
  LDFLAGS += -lwsock32 -lgdi32 -lwinmm -lole32 -lws2_32 -lpsapi -lcomctl32

  CLIENT_LDFLAGS=$(LDFLAGS)

  ifeq ($(USE_SDL),1)
    BASE_CFLAGS += -DUSE_LOCAL_HEADERS=1 -I$(MOUNT_DIR)/libsdl/windows/include/SDL2
    #CLIENT_CFLAGS += -DUSE_LOCAL_HEADERS=1
    ifeq ($(ARCH),x86)
      CLIENT_LDFLAGS += -L$(MOUNT_DIR)/libsdl/windows/mingw/lib32
      CLIENT_LDFLAGS += -lSDL2
      CLIENT_EXTRA_FILES += $(MOUNT_DIR)/libsdl/windows/mingw/lib32/SDL2.dll
    else
      CLIENT_LDFLAGS += -L$(MOUNT_DIR)/libsdl/windows/mingw/lib64
      CLIENT_LDFLAGS += -lSDL264
      CLIENT_EXTRA_FILES += $(MOUNT_DIR)/libsdl/windows/mingw/lib64/SDL264.dll
    endif
  endif

  ifeq ($(USE_CODEC_VORBIS),1)
    CLIENT_LDFLAGS += -lvorbisfile -lvorbis -logg
  endif

  ifeq ($(USE_CURL),1)
    BASE_CFLAGS += -I$(MOUNT_DIR)/libcurl/windows/include
    ifeq ($(ARCH),x86)
      CLIENT_LDFLAGS += -L$(MOUNT_DIR)/libcurl/windows/mingw/lib32
    else
      CLIENT_LDFLAGS += -L$(MOUNT_DIR)/libcurl/windows/mingw/lib64
    endif
    CLIENT_LDFLAGS += -lcurl -lwldap32 -lcrypt32
  endif

  DEBUG_CFLAGS = $(BASE_CFLAGS) -DDEBUG -D_DEBUG -g -O0
  RELEASE_CFLAGS = $(BASE_CFLAGS) -DNDEBUG $(OPTIMIZE)

else # !MINGW

ifeq ($(PLATFORM),darwin)

#############################################################################
# SETUP AND BUILD -- MACOS
#############################################################################

  BASE_CFLAGS += -Wall -fno-strict-aliasing -Wimplicit -Wstrict-prototypes -pipe

  BASE_CFLAGS += -Wno-unused-result

  OPTIMIZE = -O2 -fvisibility=hidden

  SHLIBEXT = dylib
  SHLIBCFLAGS = -fPIC -fvisibility=hidden
  SHLIBLDFLAGS = -dynamiclib $(LDFLAGS)

  LDFLAGS =

ifneq ($(SDL_INCLUDE),)
    BASE_CFLAGS += $(SDL_INCLUDE)
    CLIENT_LDFLAGS = $(SDL_LIBS)
else
    BASE_CFLAGS += -I/Library/Frameworks/SDL2.framework/Headers
  CLIENT_LDFLAGS =  -F/Library/Frameworks -framework SDL2
endif
	
#  SERVER_LDFLAGS = -DUSE_MULTIVM_SERVER
	
BASE_CFLAGS += -I$(MOUNT_DIR)/RmlUi/Include
  LDFLAGS += -L$(MOUNT_DIR)/macosx -lxml2 -lpng -lRmlCorex86_64 \
		-L$(BD) -L$(BR)
#BASE_CFLAGS += -L$(MOUNT_DIR)/macosx -I$(MOUNT_DIR)/RmlUi/Include
  CLIENT_LDFLAGS += $(MOUNT_DIR)/macosx/libxml2.2.dylib $(MOUNT_DIR)/macosx/libpng.dylib \
		$(BD)/libRmlCorex86_64.dylib
#  CLIENT_LDFLAGS += -lRmlCore -lxml2
#  CLIENT_LDFLAGS += 

  DEBUG_CFLAGS = $(BASE_CFLAGS) -DDEBUG -D_DEBUG -g -O0
  RELEASE_CFLAGS = $(BASE_CFLAGS) -DNDEBUG $(OPTIMIZE)

else

#############################################################################
# SETUP AND BUILD -- JS
#############################################################################

ifeq ($(PLATFORM),js)
  EMSDK=libs/emsdk
  NODE_JS=$(EMSDK)/node/12.9.1_64bit/bin/node
  BINARYEN_ROOT=$(EMSDK)/upstream
  EMSCRIPTEN=$(EMSDK)/upstream/emscripten
#define EM_CONFIG
#"LLVM_ROOT = '$(EMSDK)/upstream/bin';NODE_JS = '$(NODE_JS)';BINARYEN_ROOT = '$(BINARYEN_ROOT)';EMSCRIPTEN_ROOT = '$(EMSCRIPTEN)'"
#endef
ifndef EMSCRIPTEN_CACHE
  EMSCRIPTEN_CACHE=$(HOME)/.emscripten_cache
endif

  CC=$(EMSCRIPTEN)/emcc
  RANLIB=$(EMSCRIPTEN)/emranlib
  ARCH=js
  BINEXT=.js
	STRIP=echo

  DEBUG=0
  EMCC_DEBUG=0

  HAVE_VM_COMPILED=true
  BUILD_CLIENT=1
  BUILD_SERVER=0
  BUILD_GAME_QVM=1
  BUILD_GAME_SO=0
  BUILD_STANDALONE=1
  BUILD_RENDERER_OPENGL=0
  BUILD_RENDERER_JS=0
  BUILD_RENDERER_OPENGL2=1
  BUILD_RENDERER_OPENGLES=0

  USE_Q3KEY=1
  USE_IPV6=0
  USE_SDL=1
  USE_VULKAN=0
  USE_CURL=0
  USE_CURL_DLOPEN=0
  USE_CODEC_VORBIS=1
  USE_CODEC_OPUS=0
  USE_FREETYPE=0
  USE_MUMBLE=0
  USE_VOIP=0
  SDL_LOADSO_DLOPEN=0
  USE_OPENAL_DLOPEN=0
  USE_RENDERER_DLOPEN=0
  USE_LOCAL_HEADERS=0
  GL_EXT_direct_state_access=1
  GL_ARB_ES2_compatibility=1
  GL_GLEXT_PROTOTYPES=1

  BASE_CFLAGS = \
	  -Wall -Wno-unused-variable -fno-strict-aliasing -Wimplicit -Wstrict-prototypes \
		-DGL_GLEXT_PROTOTYPES=1 -DGL_ARB_ES2_compatibility=1 -DGL_EXT_direct_state_access=1 \
		-DUSE_Q3KEY -DUSE_MD5 \
		-DBUILD_SLIM_CLIENT \
    -I$(EMSCRIPTEN_CACHE)/wasm/include/SDL2 \
		-I$(EMSCRIPTEN_CACHE)/wasm/include \
		-I$(EMSCRIPTEN_CACHE)/wasm-obj/include/SDL2 \
		-I$(EMSCRIPTEN_CACHE)/wasm-obj/include \
		-I$(EMSCRIPTEN_CACHE)/wasm-lto/include \
		-I$(EMSCRIPTEN_CACHE)/wasm-lto/include/SDL2 \
		-I$(EMSCRIPTEN_CACHE)/wasm-lto-pic/include \
		-I$(EMSCRIPTEN_CACHE)/wasm-lto-pic/include/SDL2 \
		-I$(EMSCRIPTEN_CACHE)/sysroot/include \
		-I$(EMSCRIPTEN_CACHE)/sysroot/include/SDL2

  SHLIBCFLAGS = \
		-DEMSCRIPTEN \
	  -fvisibility=hidden \
		-O1 -g3 \
		-s STRICT=1 \
		-s AUTO_JS_LIBRARIES=0 \
		-s ERROR_ON_UNDEFINED_SYMBOLS=0 \
		-s SIDE_MODULE=1 \
		-s RELOCATABLE=1 \
		-s LINKABLE=1 \
		-s EXPORT_ALL=1 \
		-s EXPORTED_FUNCTIONS="['_GetRefAPI']" \
		-s ALLOW_TABLE_GROWTH=1 \
		-s ALLOW_MEMORY_GROWTH=1 \
		-s GL_UNSAFE_OPTS=0 \
		-s LEGACY_GL_EMULATION=0 \
		-s WEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 \
		-s MIN_WEBGL_VERSION=1 \
		-s MAX_WEBGL_VERSION=3 \
    -s USE_WEBGL2=1 \
    -s FULL_ES2=1 \
    -s FULL_ES3=1 \
		-s USE_SDL=2 \
		-s EXPORT_NAME=\"quake3e_opengl2_js\" \
		-s WASM=0 \
		-s MODULARIZE=0 \
    -s SAFE_HEAP=1 \
    -s DEMANGLE_SUPPORT=1 \
    -s ASSERTIONS=1 \
    -frtti \
    -fPIC

ifeq ($(USE_RENDERER_DLOPEN),1)
  CLIENT_LDFLAGS += \
		-s EXPORT_ALL=1 \
		-s RELOCATABLE=1 \
		-s DECLARE_ASM_MODULE_EXPORTS=1 \
		-s LINKABLE=1 \
		-s INCLUDE_FULL_LIBRARY=1
endif

  SHLIBEXT=js

#  --llvm-lto 3
#   -s USE_WEBGL2=1
#   -s MIN_WEBGL_VERSION=2
#   -s MAX_WEBGL_VERSION=2
#   -s USE_SDL_IMAGE=2 \
#   -s SDL2_IMAGE_FORMATS='["bmp","png","xpm"]' \
# --em-config $(EM_CONFIG) \
# --cache $(EMSCRIPTEN_CACHE) \
#    -s INITIAL_MEMORY=56MB \

  CLIENT_LDFLAGS += \
		-lbrowser.js \
		-lasync.js \
		-lidbfs.js \
		-lsdl.js \
		--js-library $(QUAKEJS)/sys_common.js \
		--js-library $(QUAKEJS)/sys_browser.js \
		--js-library $(QUAKEJS)/sys_net.js \
		--js-library $(QUAKEJS)/sys_files.js \
		--js-library $(QUAKEJS)/sys_input.js \
		--js-library $(QUAKEJS)/sys_main.js \
		--js-library $(CMDIR)/vm_js.js \
		--pre-js $(QUAKEJS)/sys_polyfill.js \
		--post-js $(QUAKEJS)/sys_overrides.js \
		-s MINIMAL_RUNTIME=0 \
		-s STRICT=1 \
		-s MAIN_MODULE=0 \
		-s AUTO_JS_LIBRARIES=1 \
		-s ALLOW_TABLE_GROWTH=1 \
		-s INITIAL_MEMORY=200MB \
    -s ALLOW_MEMORY_GROWTH=1 \
		--memory-init-file 0 \
		\
		-s DISABLE_EXCEPTION_CATCHING=0 \
    -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=1 \
    -s ERROR_ON_UNDEFINED_SYMBOLS=1 \
    -s INVOKE_RUN=1 \
    -s NO_EXIT_RUNTIME=1 \
    -s EXIT_RUNTIME=1 \
    -s EXTRA_EXPORTED_RUNTIME_METHODS="['FS', 'SYS', 'SYSC', 'SYSF', 'SYSN', 'SYSM', 'ccall', 'callMain', 'addFunction', 'dynCall']" \
    -s EXPORTED_FUNCTIONS="['_main', '_malloc', '_free', '_atof', '_strncpy', '_memset', '_memcpy', '_fopen', '_fseek', '_Com_WriteConfigToFile', '_IN_PushInit', '_IN_PushEvent', '_S_DisableSounds', '_CL_GetClientState', '_Com_Printf', '_CL_Outside_NextDownload', '_NET_SendLoopPacket', '_SOCKS_Frame_Proxy', '_Com_Frame_Proxy', '_Com_Outside_Error', '_Z_Malloc', '_Z_Free', '_S_Malloc', '_Cvar_Set', '_Cvar_SetValue', '_Cvar_Get', '_Cvar_VariableString', '_Cvar_VariableIntegerValue', '_Cbuf_ExecuteText', '_Cbuf_Execute', '_Cbuf_AddText', '_Field_CharEvent']" \
		-s GL_UNSAFE_OPTS=0 \
    -s USE_SDL=2 \
		-s USE_SDL_MIXER=2 \
		-s USE_VORBIS=1 \
		-s USE_OGG=1 \
		-s USE_PTHREADS=0 \
    -s FORCE_FILESYSTEM=1 \
    -s EXPORT_NAME=\"quake3e\"
		
ifeq ($(BUILD_RENDERER_OPENGL2),1)
  CLIENT_LDFLAGS += \
		-lwebgl.js \
		-lwebgl2.js \
		-s LEGACY_GL_EMULATION=0 \
	  -s WEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 \
		-s MIN_WEBGL_VERSION=1 \
		-s MAX_WEBGL_VERSION=3 \
	  -s USE_WEBGL2=1 \
	  -s FULL_ES2=1 \
	  -s FULL_ES3=1
endif

ifeq ($(BUILD_RENDERER_OPENGL),1)
  CLIENT_LDFLAGS += \
		-lglemu.js \
		-lwebgl.js \
		-DUSE_CLOSURE_COMPILER \
		-s LEGACY_GL_EMULATION=1 \
	  -s WEBGL2_BACKWARDS_COMPATIBILITY_EMULATION=1 \
		-s MIN_WEBGL_VERSION=1 \
		-s MAX_WEBGL_VERSION=3 \
	  -s USE_WEBGL2=1 \
	  -s FULL_ES2=0 \
	  -s FULL_ES3=0
endif

ifneq ($(USE_CODEC_VORBIS),0)
  CLIENT_LDFLAGS += -lvorbis -logg
  BASE_CFLAGS += -DUSE_CODEC_VORBIS=1 \
    -DUSE_CODEC_VORBIS=1 \
    -I$(OGGDIR)/ \
    -I$(VORBISDIR)/
endif

# debug optimize flags: --closure 0 --minify 0 -g -g4 || -O1 --closure 0 --minify 0 -g -g3
# -DDEBUG -D_DEBUG
  DEBUG_CFLAGS=$(BASE_CFLAGS) \
    -O1 -g3 \
    -frtti \
	  -flto \
    -fPIC

ifeq ($(DEBUG), 1)
  CLIENT_LDFLAGS += \
		-s WASM=1 \
		-s MODULARIZE=0 \
		-s SAFE_HEAP=0 \
		-s DEMANGLE_SUPPORT=1 \
		-s ASSERTIONS=2 \
		-s SINGLE_FILE=1
else
  CLIENT_LDFLAGS += \
		-s WASM=1 \
		-s MODULARIZE=0 \
		-s SAFE_HEAP=0 \
		-s DEMANGLE_SUPPORT=0 \
		-s ASSERTIONS=2
endif

  RELEASE_CFLAGS=$(BASE_CFLAGS) \
	  -DNDEBUG \
    -O3 -Oz \
    -flto \
    -fPIC

ifneq ($(USE_CODEC_OPUS),0)
  CLIENT_LDFLAGS += -lopus
  RELEASE_CFLAGS += \
	  -DUSE_CODEC_OPUS=1 \
    -DOPUS_BUILD -DHAVE_LRINTF -DFLOATING_POINT -DFLOAT_APPROX -DUSE_ALLOCA \
	  -I$(OPUSDIR)/include \
	  -I$(OPUSDIR)/celt \
	  -I$(OPUSDIR)/silk \
    -I$(OPUSDIR)/silk/float \
	  -I$(OPUSFILEDIR)/include 
endif

else

#############################################################################
# SETUP AND BUILD -- *NIX PLATFORMS
#############################################################################

  BASE_CFLAGS += -Wall -fno-strict-aliasing -Wimplicit -Wstrict-prototypes -pipe

  BASE_CFLAGS += -Wno-unused-result

  BASE_CFLAGS += -DUSE_ICON

  BASE_CFLAGS += -I/usr/include -I/usr/local/include

  OPTIMIZE = -O2 -fvisibility=hidden

  ifeq ($(ARCH),x86_64)
    ARCHEXT = .x64
  else
  ifeq ($(ARCH),x86)
    OPTIMIZE += -march=i586 -mtune=i686
  endif
  endif

  ifeq ($(ARCH),arm)
    OPTIMIZE += -march=armv7-a
    ARCHEXT = .arm
  endif

  ifeq ($(ARCH),aarch64)
    ARCHEXT = .aarch64
  endif

  SHLIBEXT = so
  SHLIBCFLAGS = -fPIC -fvisibility=hidden
  SHLIBLDFLAGS = -shared $(LDFLAGS)

  LDFLAGS=-lm

  ifeq ($(USE_SDL),1)
    BASE_CFLAGS += $(SDL_INCLUDE)
    CLIENT_LDFLAGS = $(SDL_LIBS)
  else
    BASE_CFLAGS += $(X11_INCLUDE)
    CLIENT_LDFLAGS = $(X11_LIBS)
  endif

  ifeq ($(USE_CODEC_VORBIS),1)
    CLIENT_LDFLAGS += -lvorbisfile -lvorbis -logg
  endif

  ifeq ($(USE_SYSTEM_JPEG),1)
    CLIENT_LDFLAGS += -ljpeg
  endif

  ifeq ($(USE_CURL),1)
    ifeq ($(USE_CURL_DLOPEN),0)
      CLIENT_LDFLAGS += -lcurl
    endif
  endif

  ifeq ($(PLATFORM),linux)
    LDFLAGS += -ldl -Wl,--hash-style=both
    ifeq ($(ARCH),x86)
      # linux32 make ...
      BASE_CFLAGS += -m32
      LDFLAGS += -m32
    endif
  endif

  DEBUG_CFLAGS = $(BASE_CFLAGS) -DDEBUG -D_DEBUG -g -O0
  RELEASE_CFLAGS = $(BASE_CFLAGS) -DNDEBUG $(OPTIMIZE)

  DEBUG_LDFLAGS = -rdynamic

endif # !EMSCRIPTEN
endif # !darwin
endif # !MINGW


TARGET_CLIENT = $(CNAME)$(ARCHEXT)$(BINEXT)

TARGET_REND1 = $(RENDERER_PREFIX)_opengl_$(SHLIBNAME)
TARGET_REND2 = $(RENDERER_PREFIX)_opengl2_$(SHLIBNAME)
TARGET_RENDV = $(RENDERER_PREFIX)_vulkan_$(SHLIBNAME)

TARGET_SERVER = $(DNAME)$(ARCHEXT)$(BINEXT)

TARGETS =

ifneq ($(BUILD_SERVER),0)
  TARGETS += $(B)/$(TARGET_SERVER)
endif

ifneq ($(BUILD_CLIENT),0)
  TARGETS += $(B)/$(TARGET_CLIENT)
endif

ifneq ($(USE_RENDERER_DLOPEN),0)
ifneq ($(PLATFORM),js)
  TARGETS += $(B)/$(TARGET_REND1)
endif
  TARGETS += $(B)/$(TARGET_REND2)
#    TARGETS += $(B)/$(TARGET_RENDV)
endif

ifneq ($(HAVE_VM_COMPILED),true)
  BASE_CFLAGS += -DNO_VM_COMPILED
endif

ifeq ($(BUILD_STANDALONE),1)
  BASE_CFLAGS += -DSTANDALONE
endif

ifeq ($(USE_Q3KEY),1)
  BASE_CFLAGS += -DUSE_Q3KEY -DUSE_MD5
endif

ifeq ($(NOFPU),1)
  BASE_CFLAGS += -DNOFPU
endif

ifeq ($(USE_CURL),1)
  BASE_CFLAGS += -DUSE_CURL
ifeq ($(USE_CURL_DLOPEN),1)
  BASE_CFLAGS += -DUSE_CURL_DLOPEN
else
ifeq ($(MINGW),1)
  BASE_CFLAGS += -DCURL_STATICLIB
endif
endif
endif

ifneq ($(USE_RENDERER_DLOPEN),0)
  BASE_CFLAGS += -DUSE_RENDERER_DLOPEN
  BASE_CFLAGS += -DRENDERER_PREFIX=\\\"$(RENDERER_PREFIX)\\\"
endif

ifeq ($(USE_CCACHE),1)
  CC := ccache $(CC)
endif

ifneq ($(USE_RENDERER_DLOPEN),0)
    RENDCFLAGS=$(SHLIBCFLAGS)
else
    RENDCFLAGS=$(NOTSHLIBCFLAGS)
endif

define DO_CC
$(echo_cmd) "CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) $(CFLAGS) -o $@ -c $<
endef

define DO_TOOLS
$(echo_cmd) "TOOLS_CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) $(CFLAGS) -I$(TDIR)/libs -I$(TDIR)/include -I$(TDIR)/common -o $@ -c $<
endef

define DO_REND_CC
$(echo_cmd) "REND_CC $<"
$(Q)$(CC) $(RENDCFLAGS) $(CFLAGS) -o $@ -c $<
endef

define DO_REF_STR
$(echo_cmd) "REF_STR $<"
$(Q)rm -f $@
$(Q)echo "const char *fallbackShader_$(notdir $(basename $<)) =" >> $@
$(Q)cat $< | sed -e 's/^/\"/;s/$$/\\n\"/' | tr -d '\r' >> $@
$(Q)echo ";" >> $@
endef

define DO_BOT_CC
$(echo_cmd) "BOT_CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) $(CFLAGS) $(BOTCFLAGS) -DBOTLIB -o $@ -c $<
endef

define DO_DED_BOT_CC
$(echo_cmd) "BOT_CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) $(CFLAGS) $(BOTCFLAGS) -DBOTLIB -o $@ -c $<
endef

ifeq ($(GENERATE_DEPENDENCIES),1)
  DO_QVM_DEP=cat $(@:%.o=%.d) | sed -e 's/\.o/\.asm/g' >> $(@:%.o=%.d)
endif

define DO_SHLIB_CC
$(echo_cmd) "SHLIB_CC $<"
$(Q)$(CC) $(CFLAGS) $(SHLIBCFLAGS) -o $@ -c $<
$(Q)$(DO_QVM_DEP)
endef

define DO_SHLIB_CC_MISSIONPACK
$(echo_cmd) "SHLIB_CC_MISSIONPACK $<"
$(Q)$(CC) -DMISSIONPACK $(CFLAGS) $(SHLIBCFLAGS) -o $@ -c $<
$(Q)$(DO_QVM_DEP)
endef

define DO_AS
$(echo_cmd) "AS $<"
$(Q)$(CC) $(CFLAGS) -DELF -x assembler-with-cpp -o $@ -c $<
endef

define DO_DED_CC
$(echo_cmd) "DED_CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) -DDEDICATED $(CFLAGS) -o $@ -c $<
endef

define DO_DED_TOOLS
$(echo_cmd) "DED_TOOLS_CC $<"
$(Q)$(CC) $(NOTSHLIBCFLAGS) -DDEDICATED $(CFLAGS) -I$(TDIR)/libs -I$(TDIR)/include -I$(TDIR)/common -o $@ -c $<
endef
define DO_WINDRES
$(echo_cmd) "WINDRES $<"
$(Q)$(WINDRES) -i $< -o $@
endef

ifndef SHLIBNAME
  SHLIBNAME=$(ARCH).$(SHLIBEXT)
endif

#############################################################################
# MAIN TARGETS
#############################################################################

default: release
all: debug release

debug:
	@$(MAKE) targets B=$(BD) CFLAGS="$(CFLAGS) $(DEBUG_CFLAGS)" LDFLAGS="$(LDFLAGS) $(DEBUG_LDFLAGS)" V=$(V)

release:
	@$(MAKE) targets B=$(BR) CFLAGS="$(CFLAGS) $(RELEASE_CFLAGS)" V=$(V)

define ADD_COPY_TARGET
TARGETS += $2
$2: $1
	$(echo_cmd) "CP $$<"
	@cp $1 $2
endef

# These functions allow us to generate rules for copying a list of files
# into the base directory of the build; this is useful for bundling libs,
# README files or whatever else
define GENERATE_COPY_TARGETS
$(foreach FILE,$1, \
  $(eval $(call ADD_COPY_TARGET, \
    $(FILE), \
    $(addprefix $(B)/,$(notdir $(FILE))))))
endef

ifneq ($(BUILD_CLIENT),0)
  $(call GENERATE_COPY_TARGETS,$(CLIENT_EXTRA_FILES))
endif

# Create the build directories and tools, print out
# an informational message, then start building
targets: makedirs tools
	@echo ""
	@echo "Building quake3 in $(B):"
	@echo ""
	@echo "  VERSION: $(VERSION)"
	@echo "  PLATFORM: $(PLATFORM)"
	@echo "  ARCH: $(ARCH)"
	@echo "  COMPILE_PLATFORM: $(COMPILE_PLATFORM)"
	@echo "  COMPILE_ARCH: $(COMPILE_ARCH)"
ifdef MINGW
	@echo "  WINDRES: $(WINDRES)"
endif
	@echo "  CC: $(CC)"
	@echo ""
	@echo "  CFLAGS:"
	@for i in $(CFLAGS); \
	do \
		echo "    $$i"; \
	done
	@echo ""
	@echo "  Output:"
	@for i in $(TARGETS); \
	do \
		echo "    $$i"; \
	done
	@echo ""
ifneq ($(TARGETS),)
	@$(MAKE) $(TARGETS) V=$(V)
endif

makedirs:
	@if [ ! -d $(BUILD_DIR) ];then $(MKDIR) $(BUILD_DIR);fi
	@if [ ! -d $(B) ];then $(MKDIR) $(B);fi
	@if [ ! -d $(B)/client ];then $(MKDIR) $(B)/client;fi
	@if [ ! -d $(B)/client/ogg ];then $(MKDIR) $(B)/client/ogg;fi
	@if [ ! -d $(B)/client/vorbis ];then $(MKDIR) $(B)/client/vorbis;fi
	@if [ ! -d $(B)/client/opus ];then $(MKDIR) $(B)/client/opus;fi
	@if [ ! -d $(B)/client/q3map2 ];then $(MKDIR) $(B)/client/q3map2;fi
	@if [ ! -d $(B)/client/tools ];then $(MKDIR) $(B)/client/tools;fi
	@if [ ! -d $(B)/client/libs ];then $(MKDIR) $(B)/client/libs;fi
	@if [ ! -d $(B)/rend1 ];then $(MKDIR) $(B)/rend1;fi
	@if [ ! -d $(B)/rend2 ];then $(MKDIR) $(B)/rend2;fi
	@if [ ! -d $(B)/rend2/glsl ];then $(MKDIR) $(B)/rend2/glsl;fi
	@if [ ! -d $(B)/rendv ];then $(MKDIR) $(B)/rendv;fi
	@if [ ! -d $(B)/ded ];then $(MKDIR) $(B)/ded;fi
	@if [ ! -d $(B)/ded/libs ];then $(MKDIR) $(B)/ded/libs;fi
	@if [ ! -d $(B)/ded/q3map2 ];then $(MKDIR) $(B)/ded/q3map2;fi
	@if [ ! -d $(B)/ded/tools ];then $(MKDIR) $(B)/ded/tools;fi

#############################################################################
# CLIENT/SERVER
#############################################################################

Q3REND1OBJ = \
  $(B)/rend1/tr_animation.o \
  $(B)/rend1/tr_arb.o \
  $(B)/rend1/tr_backend.o \
  $(B)/rend1/tr_bsp.o \
  $(B)/rend1/tr_cmds.o \
  $(B)/rend1/tr_curve.o \
  $(B)/rend1/tr_flares.o \
  $(B)/rend1/tr_font.o \
  $(B)/rend1/tr_image.o \
  $(B)/rend1/tr_image_png.o \
  $(B)/rend1/tr_image_jpg.o \
  $(B)/rend1/tr_image_bmp.o \
  $(B)/rend1/tr_image_tga.o \
  $(B)/rend1/tr_image_pcx.o \
  $(B)/rend1/tr_init.o \
  $(B)/rend1/tr_light.o \
  $(B)/rend1/tr_main.o \
  $(B)/rend1/tr_marks.o \
  $(B)/rend1/tr_mesh.o \
  $(B)/rend1/tr_model.o \
  $(B)/rend1/tr_model_iqm.o \
  $(B)/rend1/tr_noise.o \
  $(B)/rend1/tr_scene.o \
  $(B)/rend1/tr_shade.o \
  $(B)/rend1/tr_shade_calc.o \
  $(B)/rend1/tr_shader.o \
  $(B)/rend1/tr_shadows.o \
  $(B)/rend1/tr_sky.o \
  $(B)/rend1/tr_surface.o \
  $(B)/rend1/tr_vbo.o \
  $(B)/rend1/tr_world.o

Q3REND2OBJ = \
  $(B)/rend2/tr_animation.o \
  $(B)/rend2/tr_backend.o \
  $(B)/rend2/tr_bsp.o \
	$(B)/rend2/tr_bsp1.o \
	$(B)/rend2/tr_bsp2.o \
  $(B)/rend2/tr_cmds.o \
  $(B)/rend2/tr_curve.o \
  $(B)/rend2/tr_dsa.o \
  $(B)/rend2/tr_extramath.o \
  $(B)/rend2/tr_extensions.o \
  $(B)/rend2/tr_fbo.o \
  $(B)/rend2/tr_flares.o \
  $(B)/rend2/tr_font.o \
  $(B)/rend2/tr_glsl.o \
  $(B)/rend2/tr_image.o \
  $(B)/rend2/tr_image_bmp.o \
  $(B)/rend2/tr_image_jpg.o \
  $(B)/rend2/tr_image_pcx.o \
  $(B)/rend2/tr_image_png.o \
  $(B)/rend2/tr_image_tga.o \
  $(B)/rend2/tr_image_dds.o \
  $(B)/rend2/tr_init.o \
  $(B)/rend2/tr_light.o \
  $(B)/rend2/tr_main.o \
  $(B)/rend2/tr_marks.o \
  $(B)/rend2/tr_mesh.o \
  $(B)/rend2/tr_model.o \
  $(B)/rend2/tr_model_iqm.o \
  $(B)/rend2/tr_noise.o \
  $(B)/rend2/tr_postprocess.o \
  $(B)/rend2/tr_scene.o \
  $(B)/rend2/tr_shade.o \
  $(B)/rend2/tr_shade_calc.o \
  $(B)/rend2/tr_shader.o \
  $(B)/rend2/tr_shadows.o \
  $(B)/rend2/tr_sky.o \
  $(B)/rend2/tr_surface.o \
  $(B)/rend2/tr_vbo.o \
  $(B)/rend2/tr_world.o

Q3R2STRINGOBJ = \
  $(B)/rend2/glsl/bokeh_fp.o \
  $(B)/rend2/glsl/bokeh_vp.o \
  $(B)/rend2/glsl/calclevels4x_fp.o \
  $(B)/rend2/glsl/calclevels4x_vp.o \
  $(B)/rend2/glsl/depthblur_fp.o \
  $(B)/rend2/glsl/depthblur_vp.o \
  $(B)/rend2/glsl/dlight_fp.o \
  $(B)/rend2/glsl/dlight_vp.o \
  $(B)/rend2/glsl/down4x_fp.o \
  $(B)/rend2/glsl/down4x_vp.o \
  $(B)/rend2/glsl/fogpass_fp.o \
  $(B)/rend2/glsl/fogpass_vp.o \
  $(B)/rend2/glsl/generic_fp.o \
  $(B)/rend2/glsl/generic_vp.o \
  $(B)/rend2/glsl/lightall_fp.o \
  $(B)/rend2/glsl/lightall_vp.o \
  $(B)/rend2/glsl/pshadow_fp.o \
  $(B)/rend2/glsl/pshadow_vp.o \
  $(B)/rend2/glsl/shadowfill_fp.o \
  $(B)/rend2/glsl/shadowfill_vp.o \
  $(B)/rend2/glsl/shadowmask_fp.o \
  $(B)/rend2/glsl/shadowmask_vp.o \
  $(B)/rend2/glsl/ssao_fp.o \
  $(B)/rend2/glsl/ssao_vp.o \
  $(B)/rend2/glsl/texturecolor_fp.o \
  $(B)/rend2/glsl/texturecolor_vp.o \
  $(B)/rend2/glsl/tonemap_fp.o \
  $(B)/rend2/glsl/tonemap_vp.o

ifneq ($(USE_RENDERER_DLOPEN), 0)
  Q3REND1OBJ += \
    $(B)/rend1/q_shared.o \
    $(B)/rend1/puff.o \
    $(B)/rend1/q_math.o
  Q3REND2OBJ += \
    $(B)/rend2/q_shared.o \
    $(B)/rend2/puff.o \
    $(B)/rend2/q_math.o
endif

Q3RENDVOBJ = \
  $(B)/rendv/tr_animation.o \
  $(B)/rendv/tr_backend.o \
  $(B)/rendv/tr_bsp.o \
  $(B)/rendv/tr_cmds.o \
  $(B)/rendv/tr_curve.o \
  $(B)/rendv/tr_font.o \
  $(B)/rendv/tr_image.o \
  $(B)/rendv/tr_image_png.o \
  $(B)/rendv/tr_image_jpg.o \
  $(B)/rendv/tr_image_bmp.o \
  $(B)/rendv/tr_image_tga.o \
  $(B)/rendv/tr_image_pcx.o \
  $(B)/rendv/tr_init.o \
  $(B)/rendv/tr_light.o \
  $(B)/rendv/tr_main.o \
  $(B)/rendv/tr_marks.o \
  $(B)/rendv/tr_mesh.o \
  $(B)/rendv/tr_model.o \
  $(B)/rendv/tr_model_iqm.o \
  $(B)/rendv/tr_noise.o \
  $(B)/rendv/tr_scene.o \
  $(B)/rendv/tr_shade.o \
  $(B)/rendv/tr_shade_calc.o \
  $(B)/rendv/tr_shader.o \
  $(B)/rendv/tr_shadows.o \
  $(B)/rendv/tr_sky.o \
  $(B)/rendv/tr_surface.o \
  $(B)/rendv/tr_world.o \
  $(B)/rendv/vk.o \
  $(B)/rendv/vk_flares.o \
  $(B)/rendv/vk_vbo.o \

ifneq ($(USE_RENDERER_DLOPEN), 0)
  Q3RENDVOBJ += \
    $(B)/rendv/q_shared.o \
    $(B)/rendv/puff.o \
    $(B)/rendv/q_math.o
endif

Q3OBJ = \
  $(B)/client/cl_cgame.o \
  $(B)/client/cl_cin.o \
	$(B)/client/cl_cin_roq.o \
	$(B)/client/cl_cin_ogm.o \
	$(B)/client/cl_cin_vpx.o \
  $(B)/client/cl_console.o \
  $(B)/client/cl_input.o \
  $(B)/client/cl_keys.o \
  $(B)/client/cl_main.o \
  $(B)/client/cl_net_chan.o \
  $(B)/client/cl_parse.o \
  $(B)/client/cl_scrn.o \
  $(B)/client/cl_ui.o \
  $(B)/client/cl_avi.o \
  $(B)/client/cl_jpeg.o \
  \
  $(B)/client/cm_load.o \
	$(B)/client/cm_load_bsp2.o \
  $(B)/client/cm_patch.o \
  $(B)/client/cm_polylib.o \
  $(B)/client/cm_test.o \
  $(B)/client/cm_trace.o \
  \
  $(B)/client/cmd.o \
  $(B)/client/common.o \
  $(B)/client/cvar.o \
  $(B)/client/files.o \
  $(B)/client/history.o \
  $(B)/client/keys.o \
  $(B)/client/md4.o \
  $(B)/client/md5.o \
  $(B)/client/msg.o \
  $(B)/client/net_chan.o \
  $(B)/client/net_ip.o \
	$(B)/client/qrcodegen.o \
  $(B)/client/huffman.o \
  $(B)/client/huffman_static.o \
  \
  $(B)/client/snd_adpcm.o \
  $(B)/client/snd_dma.o \
  $(B)/client/snd_mem.o \
  $(B)/client/snd_mix.o \
  $(B)/client/snd_wavelet.o \
  \
  $(B)/client/snd_main.o \
  $(B)/client/snd_codec.o \
  $(B)/client/snd_codec_wav.o \
	$(B)/client/snd_codec_ogg.o \
	$(B)/client/snd_codec_opus.o \
  \
  $(B)/client/sv_bot.o \
  $(B)/client/sv_game.o \
  $(B)/client/sv_init.o \
  $(B)/client/sv_main.o \
  \
  $(B)/client/q_math.o \
  $(B)/client/q_shared.o \
  \
  $(B)/client/unzip.o \
  $(B)/client/puff.o \
  $(B)/client/vm.o \
  $(B)/client/vm_interpreted.o \
	\
  $(B)/client/be_aas_bspq3.o \
  $(B)/client/be_aas_cluster.o \
  $(B)/client/be_aas_debug.o \
  $(B)/client/be_aas_entity.o \
  $(B)/client/be_aas_file.o \
  $(B)/client/be_aas_main.o \
  $(B)/client/be_aas_move.o \
  $(B)/client/be_aas_optimize.o \
  $(B)/client/be_aas_reach.o \
  $(B)/client/be_aas_route.o \
  $(B)/client/be_aas_routealt.o \
  $(B)/client/be_aas_sample.o \
  $(B)/client/be_ai_char.o \
  $(B)/client/be_ai_chat.o \
  $(B)/client/be_ai_gen.o \
  $(B)/client/be_ai_goal.o \
  $(B)/client/be_ai_move.o \
  $(B)/client/be_ai_weap.o \
  $(B)/client/be_ai_weight.o \
  $(B)/client/be_ea.o \
  $(B)/client/be_interface.o \
  $(B)/client/l_crc.o \
  $(B)/client/l_libvar.o \
  $(B)/client/l_log.o \
  $(B)/client/l_memory.o \
  $(B)/client/l_precomp.o \
  $(B)/client/l_script.o \
  $(B)/client/l_struct.o

ifeq ($(USE_MEMORY_MAPS),1)
Q3OBJ += \
	$(B)/client/bg_misc.o \
  $(B)/client/q3map2/bsp.o \
	$(B)/client/tools/inout.o \
	$(B)/client/q3map2/portals.o \
	$(B)/client/q3map2/surface.o \
	$(B)/client/q3map2/surface_meta.o \
	$(B)/client/q3map2/surface_foliage.o \
	$(B)/client/q3map2/facebsp.o \
	$(B)/client/q3map2/brush.o \
	$(B)/client/q3map2/map.o \
	$(B)/client/tools/polylib.o \
	$(B)/client/q3map2/fog.o \
	$(B)/client/q3map2/writebsp.o \
	$(B)/client/q3map2/model.o \
	$(B)/client/q3map2/shaders.o \
	$(B)/client/libs/mathlib.o \
	$(B)/client/q3map2/brush_primit.o \
	$(B)/client/q3map2/mesh.o \
	$(B)/client/q3map2/tjunction.o \
	$(B)/client/q3map2/tree.o \
	$(B)/client/q3map2/image.o \
	$(B)/client/q3map2/light.o \
	$(B)/client/q3map2/light_ydnar.o \
	$(B)/client/q3map2/light_trace.o \
	$(B)/client/q3map2/lightmaps_ydnar.o \
	$(B)/client/tools/jpeg.o \
	$(B)/client/libs/ddslib.o \
	$(B)/client/q3map2/leakfile.o \
	$(B)/client/tools/imagelib.o \
	$(B)/client/q3map2/decals.o \
	$(B)/client/q3map2/patch.o \
	$(B)/client/libs/picomodel.o \
	$(B)/client/libs/picointernal.o \
	$(B)/client/libs/picomodules.o \
	$(B)/client/q3map2/light_bounce.o \
	$(B)/client/tools/threads.o \
	$(B)/client/q3map2/surface_extra.o \
	$(B)/client/libs/m4x4.o \
	$(B)/client/libs/md5lib.o \
	$(B)/client/libs/pm_terrain.o \
	$(B)/client/libs/pm_md3.o \
	$(B)/client/libs/pm_ase.o \
	$(B)/client/libs/pm_3ds.o \
	$(B)/client/libs/pm_md2.o \
	$(B)/client/libs/pm_fm.o \
	$(B)/client/libs/pm_lwo.o \
	$(B)/client/libs/pm_mdc.o \
	$(B)/client/libs/pm_ms3d.o \
	$(B)/client/libs/pm_obj.o \
	$(B)/client/tools/vfs.o \
	$(B)/client/libs/lwo2.o \
	$(B)/client/libs/pntspols.o \
	$(B)/client/libs/vmap.o \
	$(B)/client/libs/lwob.o \
	$(B)/client/libs/clip.o \
	$(B)/client/libs/lwio.o \
	$(B)/client/libs/surface.o \
	$(B)/client/libs/list.o \
	$(B)/client/libs/envelope.o \
	$(B)/client/q3map2/surface_fur.o \
	$(B)/client/libs/vecmath.o \
	$(B)/client/tools/scriplib.o \
	$(B)/client/q3map2/prtfile.o \
  $(B)/client/q3map2/bspfile_abstract.o \
	$(B)/client/q3map2/bspfile_rbsp.o \
	$(B)/client/q3map2/bspfile_ibsp.o
endif

ifneq ($(USE_SYSTEM_JPEG),1)
  Q3OBJ += $(JPGOBJ)
endif

ifneq ($(USE_LOCAL_HEADERS),0)
ifneq ($(USE_CODEC_VORBIS),0)
Q3OBJ += \
  $(B)/client/ogg/bitwise.o \
  $(B)/client/ogg/framing.o \
  \
  $(B)/client/vorbis/analysis.o \
  $(B)/client/vorbis/barkmel.o \
  $(B)/client/vorbis/bitrate.o \
  $(B)/client/vorbis/block.o \
  $(B)/client/vorbis/codebook.o \
  $(B)/client/vorbis/floor0.o \
  $(B)/client/vorbis/floor1.o \
  $(B)/client/vorbis/info.o \
  $(B)/client/vorbis/lookup.o \
  $(B)/client/vorbis/lpc.o \
  $(B)/client/vorbis/lsp.o \
  $(B)/client/vorbis/mapping0.o \
  $(B)/client/vorbis/mdct.o \
  $(B)/client/vorbis/misc.o \
  $(B)/client/vorbis/psy.o \
  $(B)/client/vorbis/registry.o \
  $(B)/client/vorbis/res0.o \
  $(B)/client/vorbis/sharedbook.o \
  $(B)/client/vorbis/smallft.o \
  $(B)/client/vorbis/synthesis.o \
  $(B)/client/vorbis/vorbisenc.o \
  $(B)/client/vorbis/vorbisfile.o \
  $(B)/client/vorbis/window.o
endif
endif

ifneq (,$(findstring release,$(B)))
ifneq ($(USE_CODEC_OPUS),0)
Q3OBJ += \
	$(B)/client/opus/analysis.o \
	$(B)/client/opus/mlp.o \
	$(B)/client/opus/mlp_data.o \
	$(B)/client/opus/opus.o \
	$(B)/client/opus/opus_decoder.o \
	$(B)/client/opus/opus_encoder.o \
	$(B)/client/opus/opus_multistream.o \
	$(B)/client/opus/opus_multistream_encoder.o \
	$(B)/client/opus/opus_multistream_decoder.o \
	$(B)/client/opus/repacketizer.o \
	\
	$(B)/client/opus/bands.o \
	$(B)/client/opus/celt.o \
	$(B)/client/opus/cwrs.o \
	$(B)/client/opus/entcode.o \
	$(B)/client/opus/entdec.o \
	$(B)/client/opus/entenc.o \
	$(B)/client/opus/kiss_fft.o \
	$(B)/client/opus/laplace.o \
	$(B)/client/opus/mathops.o \
	$(B)/client/opus/mdct.o \
	$(B)/client/opus/modes.o \
	$(B)/client/opus/pitch.o \
	$(B)/client/opus/celt_encoder.o \
	$(B)/client/opus/celt_decoder.o \
	$(B)/client/opus/celt_lpc.o \
	$(B)/client/opus/quant_bands.o \
	$(B)/client/opus/rate.o \
	$(B)/client/opus/vq.o \
	\
	$(B)/client/opus/CNG.o \
	$(B)/client/opus/code_signs.o \
	$(B)/client/opus/init_decoder.o \
	$(B)/client/opus/decode_core.o \
	$(B)/client/opus/decode_frame.o \
	$(B)/client/opus/decode_parameters.o \
	$(B)/client/opus/decode_indices.o \
	$(B)/client/opus/decode_pulses.o \
	$(B)/client/opus/decoder_set_fs.o \
	$(B)/client/opus/dec_API.o \
	$(B)/client/opus/enc_API.o \
	$(B)/client/opus/encode_indices.o \
	$(B)/client/opus/encode_pulses.o \
	$(B)/client/opus/gain_quant.o \
	$(B)/client/opus/interpolate.o \
	$(B)/client/opus/LP_variable_cutoff.o \
	$(B)/client/opus/NLSF_decode.o \
	$(B)/client/opus/NSQ.o \
	$(B)/client/opus/NSQ_del_dec.o \
	$(B)/client/opus/PLC.o \
	$(B)/client/opus/shell_coder.o \
	$(B)/client/opus/tables_gain.o \
	$(B)/client/opus/tables_LTP.o \
	$(B)/client/opus/tables_NLSF_CB_NB_MB.o \
	$(B)/client/opus/tables_NLSF_CB_WB.o \
	$(B)/client/opus/tables_other.o \
	$(B)/client/opus/tables_pitch_lag.o \
	$(B)/client/opus/tables_pulses_per_block.o \
	$(B)/client/opus/VAD.o \
	$(B)/client/opus/control_audio_bandwidth.o \
	$(B)/client/opus/quant_LTP_gains.o \
	$(B)/client/opus/VQ_WMat_EC.o \
	$(B)/client/opus/HP_variable_cutoff.o \
	$(B)/client/opus/NLSF_encode.o \
	$(B)/client/opus/NLSF_VQ.o \
	$(B)/client/opus/NLSF_unpack.o \
	$(B)/client/opus/NLSF_del_dec_quant.o \
	$(B)/client/opus/process_NLSFs.o \
	$(B)/client/opus/stereo_LR_to_MS.o \
	$(B)/client/opus/stereo_MS_to_LR.o \
	$(B)/client/opus/check_control_input.o \
	$(B)/client/opus/control_SNR.o \
	$(B)/client/opus/init_encoder.o \
	$(B)/client/opus/control_codec.o \
	$(B)/client/opus/A2NLSF.o \
	$(B)/client/opus/ana_filt_bank_1.o \
	$(B)/client/opus/biquad_alt.o \
	$(B)/client/opus/bwexpander_32.o \
	$(B)/client/opus/bwexpander.o \
	$(B)/client/opus/debug.o \
	$(B)/client/opus/decode_pitch.o \
	$(B)/client/opus/inner_prod_aligned.o \
	$(B)/client/opus/lin2log.o \
	$(B)/client/opus/log2lin.o \
	$(B)/client/opus/LPC_analysis_filter.o \
	$(B)/client/opus/LPC_fit.o \
	$(B)/client/opus/LPC_inv_pred_gain.o \
	$(B)/client/opus/table_LSF_cos.o \
	$(B)/client/opus/NLSF2A.o \
	$(B)/client/opus/NLSF_stabilize.o \
	$(B)/client/opus/NLSF_VQ_weights_laroia.o \
	$(B)/client/opus/pitch_est_tables.o \
	$(B)/client/opus/resampler.o \
	$(B)/client/opus/resampler_down2_3.o \
	$(B)/client/opus/resampler_down2.o \
	$(B)/client/opus/resampler_private_AR2.o \
	$(B)/client/opus/resampler_private_down_FIR.o \
	$(B)/client/opus/resampler_private_IIR_FIR.o \
	$(B)/client/opus/resampler_private_up2_HQ.o \
	$(B)/client/opus/resampler_rom.o \
	$(B)/client/opus/sigm_Q15.o \
	$(B)/client/opus/sort.o \
	$(B)/client/opus/sum_sqr_shift.o \
	$(B)/client/opus/stereo_decode_pred.o \
	$(B)/client/opus/stereo_encode_pred.o \
	$(B)/client/opus/stereo_find_predictor.o \
	$(B)/client/opus/stereo_quant_pred.o \
	\
	$(B)/client/opus/apply_sine_window_FLP.o \
	$(B)/client/opus/corrMatrix_FLP.o \
	$(B)/client/opus/encode_frame_FLP.o \
	$(B)/client/opus/find_LPC_FLP.o \
	$(B)/client/opus/find_LTP_FLP.o \
	$(B)/client/opus/find_pitch_lags_FLP.o \
	$(B)/client/opus/find_pred_coefs_FLP.o \
	$(B)/client/opus/LPC_analysis_filter_FLP.o \
	$(B)/client/opus/LTP_analysis_filter_FLP.o \
	$(B)/client/opus/LTP_scale_ctrl_FLP.o \
	$(B)/client/opus/noise_shape_analysis_FLP.o \
	$(B)/client/opus/process_gains_FLP.o \
	$(B)/client/opus/regularize_correlations_FLP.o \
	$(B)/client/opus/residual_energy_FLP.o \
	$(B)/client/opus/warped_autocorrelation_FLP.o \
	$(B)/client/opus/wrappers_FLP.o \
	$(B)/client/opus/autocorrelation_FLP.o \
	$(B)/client/opus/burg_modified_FLP.o \
	$(B)/client/opus/bwexpander_FLP.o \
	$(B)/client/opus/energy_FLP.o \
	$(B)/client/opus/inner_product_FLP.o \
	$(B)/client/opus/k2a_FLP.o \
	$(B)/client/opus/LPC_inv_pred_gain_FLP.o \
	$(B)/client/opus/pitch_analysis_core_FLP.o \
	$(B)/client/opus/scale_copy_vector_FLP.o \
	$(B)/client/opus/scale_vector_FLP.o \
	$(B)/client/opus/schur_FLP.o \
	$(B)/client/opus/sort_FLP.o \
	\
  $(B)/client/http.o \
  $(B)/client/info.o \
  $(B)/client/internal.o \
  $(B)/client/opusfile.o \
  $(B)/client/stream.o \
  $(B)/client/wincerts.o
endif
endif

ifeq ($(USE_RENDERER_DLOPEN),0)
ifeq ($(USE_VULKAN),1)
  Q3OBJ += $(Q3RENDVOBJ)
else
ifeq ($(BUILD_RENDERER_OPENGL2),1)
  Q3OBJ += $(Q3REND2OBJ) $(Q3R2STRINGOBJ)
else
  Q3OBJ += $(Q3REND1OBJ)
endif

endif # use vulcan
endif # no dlopen

ifeq ($(ARCH),x86)
ifndef MINGW
  Q3OBJ += \
    $(B)/client/snd_mix_mmx.o \
    $(B)/client/snd_mix_sse.o
endif
endif

ifeq ($(HAVE_VM_COMPILED),true)
  ifeq ($(ARCH),x86)
    Q3OBJ += $(B)/client/vm_x86.o
  endif
  ifeq ($(ARCH),x86_64)
    Q3OBJ += $(B)/client/vm_x86.o
  endif
  ifeq ($(ARCH),arm)
    Q3OBJ += $(B)/client/vm_armv7l.o
  endif
  ifeq ($(ARCH),aarch64)
    Q3OBJ += $(B)/client/vm_aarch64.o
  endif
endif

ifeq ($(USE_CURL),1)
  Q3OBJ += $(B)/client/cl_curl.o
endif

ifdef MINGW

  Q3OBJ += \
    $(B)/client/win_main.o \
    $(B)/client/win_shared.o \
    $(B)/client/win_syscon.o \
    $(B)/client/win_resource.o

ifeq ($(USE_SDL),1)
ifneq ($(PLATFORM),js)
    Q3OBJ += \
        $(B)/client/sdl_glimp.o \
        $(B)/client/sdl_gamma.o \
        $(B)/client/sdl_input.o \
        $(B)/client/sdl_snd.o
endif
else # !USE_SDL
    Q3OBJ += \
        $(B)/client/win_gamma.o \
        $(B)/client/win_glimp.o \
        $(B)/client/win_input.o \
        $(B)/client/win_minimize.o \
        $(B)/client/win_qgl.o \
        $(B)/client/win_snd.o \
        $(B)/client/win_wndproc.o
ifeq ($(USE_VULKAN_API),1)
    Q3OBJ += \
        $(B)/client/win_qvk.o
endif
endif # !USE_SDL

else # !MINGW
ifeq ($(PLATFORM),js)
Q3OBJ += \
	$(B)/client/sdl_glimp.o \
	$(B)/client/sdl_gamma.o \
	$(B)/client/sdl_snd.o \
	$(B)/client/sys_main.o \
	$(B)/client/sys_input.o

else
  Q3OBJ += \
    $(B)/client/unix_main.o \
    $(B)/client/unix_shared.o \
    $(B)/client/linux_signals.o
endif

ifeq ($(USE_SDL),1)
ifneq ($(PLATFORM),js)
    Q3OBJ += \
        $(B)/client/sdl_glimp.o \
        $(B)/client/sdl_gamma.o \
        $(B)/client/sdl_input.o \
        $(B)/client/sdl_snd.o
endif
else # !USE_SDL
    Q3OBJ += \
        $(B)/client/linux_glimp.o \
        $(B)/client/linux_qgl.o \
        $(B)/client/linux_snd.o \
        $(B)/client/x11_dga.o \
        $(B)/client/x11_randr.o \
        $(B)/client/x11_vidmode.o
ifeq ($(USE_VULKAN_API),1)
    Q3OBJ += \
        $(B)/client/linux_qvk.o
endif
endif # !USE_SDL

endif # !MINGW

# client binary

$(B)/$(TARGET_CLIENT): $(Q3OBJ)
	$(echo_cmd) "LD $@"
	$(Q)$(CC) -v -o $@ $(Q3OBJ) $(CLIENT_LDFLAGS) $(CFLAGS) \
		$(LDFLAGS)

# modular renderers

$(B)/$(TARGET_REND1): $(Q3REND1OBJ)
	$(echo_cmd) "LD $@"
	$(Q)$(CC) $(SHLIBCFLAGS) $(SHLIBLDFLAGS) -o $@ $(Q3REND1OBJ)

$(B)/$(TARGET_REND2): $(Q3REND2OBJ) $(Q3R2STRINGOBJ)
	$(echo_cmd) "LD $@"
	$(Q)$(CC) $(SHLIBCFLAGS) $(SHLIBLDFLAGS) -o $@ $(Q3REND2OBJ) $(Q3R2STRINGOBJ)

$(B)/$(TARGET_RENDV): $(Q3RENDVOBJ)
	$(echo_cmd) "LD $@"
	$(Q)$(CC) $(SHLIBCFLAGS) $(SHLIBLDFLAGS) -o $@ $(Q3RENDVOBJ)

#############################################################################
# DEDICATED SERVER
#############################################################################

Q3DOBJ = \
  $(B)/ded/sv_bot.o \
  $(B)/ded/sv_client.o \
  $(B)/ded/sv_ccmds.o \
  $(B)/ded/sv_filter.o \
	$(B)/ded/sv_demo.o \
	$(B)/ded/sv_demo_cl.o \
  $(B)/ded/sv_demo_ext.o \
	$(B)/ded/sv_demo_mv.o \
  $(B)/ded/sv_game.o \
  $(B)/ded/sv_init.o \
  $(B)/ded/sv_main.o \
  $(B)/ded/sv_net_chan.o \
  $(B)/ded/sv_snapshot.o \
  $(B)/ded/sv_world.o \
	$(B)/ded/sv_bsp.o \
	\
  $(B)/ded/cm_load.o \
	$(B)/ded/cm_load_bsp2.o \
  $(B)/ded/cm_patch.o \
  $(B)/ded/cm_polylib.o \
  $(B)/ded/cm_test.o \
  $(B)/ded/cm_trace.o \
  $(B)/ded/cmd.o \
  $(B)/ded/common.o \
  $(B)/ded/cvar.o \
  $(B)/ded/files.o \
  $(B)/ded/history.o \
  $(B)/ded/keys.o \
  $(B)/ded/md4.o \
  $(B)/ded/md5.o \
  $(B)/ded/msg.o \
  $(B)/ded/net_chan.o \
  $(B)/ded/net_ip.o \
  $(B)/ded/huffman.o \
  $(B)/ded/huffman_static.o \
  \
  $(B)/ded/q_math.o \
  $(B)/ded/q_shared.o \
  \
  $(B)/ded/unzip.o \
  $(B)/ded/vm.o \
	$(B)/ded/vm_interpreted.o \
	\
  $(B)/ded/be_aas_bspq3.o \
  $(B)/ded/be_aas_cluster.o \
  $(B)/ded/be_aas_debug.o \
  $(B)/ded/be_aas_entity.o \
  $(B)/ded/be_aas_file.o \
  $(B)/ded/be_aas_main.o \
  $(B)/ded/be_aas_move.o \
  $(B)/ded/be_aas_optimize.o \
  $(B)/ded/be_aas_reach.o \
  $(B)/ded/be_aas_route.o \
  $(B)/ded/be_aas_routealt.o \
  $(B)/ded/be_aas_sample.o \
  $(B)/ded/be_ai_char.o \
  $(B)/ded/be_ai_chat.o \
  $(B)/ded/be_ai_gen.o \
  $(B)/ded/be_ai_goal.o \
  $(B)/ded/be_ai_move.o \
  $(B)/ded/be_ai_weap.o \
  $(B)/ded/be_ai_weight.o \
  $(B)/ded/be_ea.o \
  $(B)/ded/be_interface.o \
  $(B)/ded/l_crc.o \
  $(B)/ded/l_libvar.o \
  $(B)/ded/l_log.o \
  $(B)/ded/l_memory.o \
  $(B)/ded/l_precomp.o \
  $(B)/ded/l_script.o \
  $(B)/ded/l_struct.o

ifeq ($(USE_MEMORY_MAPS),1)
Q3DOBJ += \
  $(B)/ded/bg_misc.o \
	$(B)/ded/q3map2/bsp.o \
	$(B)/ded/tools/inout.o \
	$(B)/ded/q3map2/portals.o \
	$(B)/ded/q3map2/surface.o \
	$(B)/ded/q3map2/surface_meta.o \
	$(B)/ded/q3map2/surface_foliage.o \
	$(B)/ded/q3map2/facebsp.o \
	$(B)/ded/q3map2/brush.o \
	$(B)/ded/q3map2/map.o \
	$(B)/ded/q3map2/light.o \
	$(B)/ded/q3map2/light_ydnar.o \
	$(B)/ded/q3map2/light_trace.o \
	$(B)/ded/q3map2/lightmaps_ydnar.o \
	$(B)/ded/tools/polylib.o \
	$(B)/ded/q3map2/fog.o \
	$(B)/ded/q3map2/writebsp.o \
	$(B)/ded/q3map2/model.o \
	$(B)/ded/q3map2/shaders.o \
	$(B)/ded/libs/mathlib.o \
	$(B)/ded/q3map2/brush_primit.o \
	$(B)/ded/q3map2/mesh.o \
	$(B)/ded/q3map2/tjunction.o \
	$(B)/ded/q3map2/tree.o \
	$(B)/ded/q3map2/image.o \
	$(B)/ded/libs/ddslib.o \
	$(B)/ded/q3map2/leakfile.o \
	$(B)/ded/tools/imagelib.o \
	$(B)/ded/q3map2/decals.o \
	$(B)/ded/q3map2/patch.o \
	$(B)/ded/libs/picomodel.o \
	$(B)/ded/libs/picointernal.o \
	$(B)/ded/libs/picomodules.o \
	$(B)/ded/q3map2/light_bounce.o \
	$(B)/ded/tools/threads.o \
	$(B)/ded/q3map2/surface_extra.o \
	$(B)/ded/libs/m4x4.o \
	$(B)/ded/libs/md5lib.o \
	$(B)/ded/libs/pm_terrain.o \
	$(B)/ded/libs/pm_md3.o \
	$(B)/ded/libs/pm_ase.o \
	$(B)/ded/libs/pm_3ds.o \
	$(B)/ded/libs/pm_md2.o \
	$(B)/ded/libs/pm_fm.o \
	$(B)/ded/libs/pm_lwo.o \
	$(B)/ded/libs/pm_mdc.o \
	$(B)/ded/libs/pm_ms3d.o \
	$(B)/ded/libs/pm_obj.o \
	$(B)/ded/tools/vfs.o \
	$(B)/ded/libs/lwo2.o \
	$(B)/ded/libs/pntspols.o \
	$(B)/ded/libs/vmap.o \
	$(B)/ded/libs/lwob.o \
	$(B)/ded/libs/clip.o \
	$(B)/ded/libs/lwio.o \
	$(B)/ded/libs/surface.o \
	$(B)/ded/libs/list.o \
	$(B)/ded/libs/envelope.o \
	$(B)/ded/q3map2/surface_fur.o \
	$(B)/ded/libs/vecmath.o \
	$(B)/ded/tools/scriplib.o \
	$(B)/ded/q3map2/prtfile.o \
	$(B)/ded/q3map2/bspfile_abstract.o \
	$(B)/ded/q3map2/bspfile_rbsp.o \
	$(B)/ded/q3map2/bspfile_ibsp.o
endif

ifeq ($(USE_CURL),1)
  Q3DOBJ += $(B)/ded/cl_curl.o
endif

ifdef MINGW
  Q3DOBJ += \
  $(B)/ded/win_main.o \
  $(B)/client/win_resource.o \
  $(B)/ded/win_shared.o \
  $(B)/ded/win_syscon.o
else
  Q3DOBJ += \
  $(B)/ded/linux_signals.o \
  $(B)/ded/unix_main.o \
  $(B)/ded/unix_shared.o
endif

ifeq ($(HAVE_VM_COMPILED),true)
  ifeq ($(ARCH),x86)
    Q3DOBJ += $(B)/ded/vm_x86.o
  endif
  ifeq ($(ARCH),x86_64)
    Q3DOBJ += $(B)/ded/vm_x86.o
  endif
  ifeq ($(ARCH),arm)
    Q3DOBJ += $(B)/ded/vm_armv7l.o
  endif
  ifeq ($(ARCH),aarch64)
    Q3DOBJ += $(B)/ded/vm_aarch64.o
  endif
endif

$(B)/$(TARGET_SERVER): $(Q3DOBJ)
	$(echo_cmd) "LD $@"
	$(Q)$(CC) -o $@ $(Q3DOBJ) $(SERVER_LDFLAGS) $(LDFLAGS)

#############################################################################
## CLIENT/SERVER RULES
#############################################################################

$(B)/client/%.o: $(ADIR)/%.s
	$(DO_AS)

$(B)/client/%.o: $(CDIR)/%.c
	$(DO_CC)

$(B)/client/%.o: $(SDIR)/%.c
	$(DO_CC)

$(B)/client/%.o: $(MOUNT_DIR)/game/%.c
	$(DO_TOOLS)

$(B)/client/tools/%.o: $(TDIR)/common/%.c
	$(DO_TOOLS)

$(B)/client/q3map2/%.o: $(TDIR)/q3map2/%.c
	$(DO_TOOLS)

$(B)/client/tools/%.o: $(TDIR)/q3data/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/mathlib/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/ddslib/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/md5lib/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/picomodel/%.c
	$(DO_TOOLS)

$(B)/client/libs/%.o: $(TDIR)/libs/picomodel/lwo/%.c
	$(DO_TOOLS)

$(B)/client/plugins/%.o: $(TDIR)/plugins/imagepng/%.c
	$(DO_TOOLS)

$(B)/client/%.o: $(CMDIR)/%.c
	$(DO_CC)

$(B)/client/%.o: $(BLIBDIR)/%.c
	$(DO_BOT_CC)

$(B)/client/%.o: $(JPDIR)/%.c
	$(DO_CC)

$(B)/client/ogg/%.o: $(OGGDIR)/%.c
	$(DO_CC)

$(B)/client/vorbis/%.o: $(VORBISDIR)/%.c
	$(DO_CC)

$(B)/client/opus/%.o: $(OPUSDIR)/src/%.c
	$(DO_CC)

$(B)/client/opus/%.o: $(OPUSDIR)/celt/%.c
	$(DO_CC)

$(B)/client/opus/%.o: $(OPUSDIR)/silk/%.c
	$(DO_CC)

$(B)/client/opus/%.o: $(OPUSDIR)/silk/float/%.c
	$(DO_CC)

$(B)/client/%.o: $(OPUSFILEDIR)/src/%.c
	$(DO_CC)

$(B)/client/%.o: $(SDLDIR)/%.c
	$(DO_CC)

$(B)/rend1/%.o: $(R1DIR)/%.c
	$(DO_REND_CC)

$(B)/rend1/%.o: $(RCDIR)/%.c
	$(DO_REND_CC)

$(B)/rend1/%.o: $(CMDIR)/%.c
	$(DO_REND_CC)

$(B)/rend2/glsl/%.c: $(R2DIR)/glsl/%.glsl
	$(DO_REF_STR)

$(B)/rend2/glsl/%.o: $(B)/rend2/glsl/%.c
	$(DO_REND_CC)

$(B)/rend2/%.o: $(RCDIR)/%.c
	$(DO_REND_CC)

$(B)/rend2/%.o: $(R2DIR)/%.c
	$(DO_REND_CC)

$(B)/rend2/%.o: $(CMDIR)/%.c
	$(DO_REND_CC)

$(B)/rendv/%.o: $(RVDIR)/%.c
	$(DO_REND_CC)

$(B)/rendv/%.o: $(RCDIR)/%.c
	$(DO_REND_CC)

$(B)/rendv/%.o: $(RVSDIR)/%.c
	$(DO_REND_CC)

$(B)/rendv/%.o: $(CMDIR)/%.c
	$(DO_REND_CC)

$(B)/client/%.o: $(UDIR)/%.c
	$(DO_CC)

$(B)/client/%.o: $(W32DIR)/%.c
	$(DO_CC)

$(B)/client/%.o: $(W32DIR)/%.rc
	$(DO_WINDRES)

$(B)/client/%.o: $(QUAKEJS)/%.c
	$(DO_CC)

$(B)/ded/%.o: $(ADIR)/%.s
	$(DO_AS)

$(B)/ded/cl_curl.o: $(CDIR)/cl_curl.c
	$(DO_DED_CC)

$(B)/ded/%.o: $(SDIR)/%.c
	$(DO_DED_CC)

$(B)/ded/%.o: $(MOUNT_DIR)/game/%.c
	$(DO_TOOLS)

$(B)/ded/tools/%.o: $(TDIR)/common/%.c
	$(DO_DED_TOOLS)

$(B)/ded/q3map2/%.o: $(TDIR)/q3map2/%.c
	$(DO_DED_TOOLS)

$(B)/ded/tools/%.o: $(TDIR)/q3data/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/mathlib/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/ddslib/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/md5lib/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/picomodel/%.c
	$(DO_DED_TOOLS)

$(B)/ded/libs/%.o: $(TDIR)/libs/picomodel/lwo/%.c
	$(DO_DED_TOOLS)

$(B)/ded/plugins/%.o: $(TDIR)/plugins/imagepng/%.c
	$(DO_DED_TOOLS)

$(B)/ded/%.o: $(CMDIR)/%.c
	$(DO_DED_CC)

$(B)/ded/%.o: $(BLIBDIR)/%.c
	$(DO_DED_BOT_CC)

$(B)/ded/%.o: $(UDIR)/%.c
	$(DO_DED_CC)

$(B)/ded/%.o: $(W32DIR)/%.c
	$(DO_DED_CC)

$(B)/ded/%.o: $(W32DIR)/%.rc
	$(DO_WINDRES)

#############################################################################
# MISC
#############################################################################

install: release
	@for i in $(TARGETS); do \
		if [ -f $(BR)$$i ]; then \
			$(INSTALL) -D -m 0755 "$(BR)/$$i" "$(DESTDIR)$$i"; \
			$(STRIP) "$(DESTDIR)$$i"; \
		fi \
	done

clean: clean-debug clean-release

clean2:
	@echo "CLEAN $(B)"
	@if [ -d $(B) ];then (find $(B) -name '*.d' -exec rm {} \;)fi
	@rm -f $(Q3OBJ) $(Q3DOBJ)
	@rm -f $(TARGETS)

clean-debug:
	@rm -rf $(BD)

clean-release:
	@echo $(BR)
	@rm -rf $(BR)

distclean: clean
	@rm -rf $(BUILD_DIR)

#############################################################################
# DEPENDENCIES
#############################################################################

ifdef B
D_FILES=$(shell find $(B) -name '*.d')
endif

ifneq ($(strip $(D_FILES)),)
  include $(D_FILES)
endif

.PHONY: all clean clean2 clean-debug clean-release copyfiles \
	debug default dist distclean makedirs release \
	targets tools toolsclean
