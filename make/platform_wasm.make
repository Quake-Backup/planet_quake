HAVE_VM_COMPILED    := false
BUILD_CLIENT        ?= 0
BUILD_SERVER        := 0
BUILD_STANDALONE    := 1
USE_RENDERER_DLOPEN := 0
USE_SYSTEM_JPEG     := 0
USE_INTERNAL_JPEG   := 0
USE_INTERNAL_VORBIS := 1
USE_SYSTEM_LIBC     := 0
USE_CODEC_VORBIS    := 1
USE_CODEC_WAV       := 0
USE_ABS_MOUSE       := 1
USE_LOCAL_DED       := 0
USE_LAZY_LOAD       := 1
USE_LAZY_MEMORY     := 1
USE_MASTER_LAN      := 1
USE_CURL            := 0
USE_SDL             := 0
USE_IPV6            := 0
USE_OPENGL2         := 1
USE_VULKAN          := 0
USE_VULKAN_API      := 0
NO_MAKE_LOCAL       := 1

include make/configure.make

NODE                := node
COPY                := cp
UNLINK              := rm
MOVE                := mv
LD                  := libs/$(COMPILE_PLATFORM)/wasi-sdk-14.0/bin/wasm-ld
CC                  := libs/$(COMPILE_PLATFORM)/wasi-sdk-14.0/bin/clang
CXX                 := libs/$(COMPILE_PLATFORM)/wasi-sdk-14.0/bin/clang++
BINEXT              := .wasm

SHLIBEXT            := wasm
SHLIBCFLAGS         := -frtti -fPIC -MMD
SHLIBLDFLAGS        := -fPIC -Wl,-shared \
                       -Wl,--import-memory -Wl,--import-table -Wl,--error-limit=200 \
                       -Wl,--no-entry --no-standard-libraries -Wl,--export-dynamic
CLIENT_LDFLAGS      := -Wl,--import-memory -Wl,--import-table -Wl,--error-limit=200 \
                       -Wl,--no-entry --no-standard-libraries -Wl,--export-dynamic
RELEASE_LDFLAGS     := 
DEBUG_LDFLAGS       := -fvisibility=default -fno-inline

ifeq ($(BUILD_CLIENT),1)
SHLIBLDFLAGS        += -fvisibility=default -Wl,--allow-undefined-file=code/wasm/wasm.syms
CLIENT_LDFLAGS      += -Wl,--allow-undefined-file=code/wasm/wasm.syms
endif

ifeq ($(BUILD_RENDERER_OPENGL),1)
SHLIBLDFLAGS        += -Wl,--allow-undefined-file=code/wasm/wasm-nogl.syms
CLIENT_LDFLAGS      += -Wl,--allow-undefined-file=code/wasm/wasm-nogl.syms
endif

ifeq ($(BUILD_VORBIS),1)
SHLIBLDFLAGS        += -Wl,--allow-undefined-file=code/wasm/wasm-lib.syms
CLIENT_LDFLAGS      += -Wl,--allow-undefined-file=code/wasm/wasm-lib.syms
endif


ifndef BUILD_VORBIS
ifeq ($(USE_CODEC_VORBIS),1)
ifneq ($(USE_INTERNAL_VORBIS),1)
  CLIENT_LDFLAGS    += -L$(INSTALL_FROM) -lvorbis_$(ARCH)
endif
endif
endif

CLIENT_LDFLAGS      += code/wasm/wasi/libclang_rt.builtins-wasm32.a

# -fno-common -ffreestanding -nostdinc --no-standard-libraries
MUSL_SOURCE         := libs/musl-1.2.2
SDL_SOURCE          := libs/SDL2-2.0.14

BASE_CFLAGS         += -Wall --target=wasm32 \
                       -Wimplicit -fstrict-aliasing \
                       -ftree-vectorize -fsigned-char -MMD \
                       -ffast-math -fno-short-enums \
                       -Wno-extra-semi \
                       -D_XOPEN_SOURCE=700 \
                       -DGL_GLEXT_PROTOTYPES=1 \
                       -DGL_ARB_ES2_compatibility=1 \
                       -DGL_EXT_direct_state_access=1 \
                       -DUSE_Q3KEY \
                       -DUSE_MD5 \
                       -DUSE_ABS_MOUSE \
                       -DUSE_LAZY_LOAD \
                       -DUSE_LAZY_MEMORY \
                       -DUSE_MASTER_LAN \
                       -D__WASM__ \
                       -std=gnu11 \
                       -Icode/wasm/include \
                       -Icode/wasm/emscripten \
                       -I$(MUSL_SOURCE)/include \
											 -I$(SDL_SOURCE)/include \
                       -Icode/wasm

DEBUG_CFLAGS        := -fvisibility=default -fno-inline \
                       -DDEBUG -D_DEBUG -g -g3 -fPIC -gdwarf -gfull
RELEASE_CFLAGS      := -fvisibility=hidden \
                       -DNDEBUG -Ofast -O3 -Oz -fPIC -ffast-math
                    # -flto 



PK3_INCLUDES     := xxx-multigame-files.pk3  \
                    xxx-multigame-vms.pk3    \
                    lsdm3_v1-files.pk3       \
                    lsdm3_v1-images.pk3      \
                    xxx-multigame-sounds.pk3

ifeq ($(filter $(MAKECMDGOALS),debug),debug)
WASM_INDEX       += $(wildcard $(BD)/$(CNAME)*.wasm)
else
WASM_INDEX       += $(wildcard $(BR)/$(CNAME)*.wasm)
endif


index: $(WASM_INDEX) $(WASM_INDEX:.wasm=.html) ## create an index.html page out of the current build target
	$(Q)$(MAKE) -f make/build_package.make package \
		TARGET_REPACK="xxx-multigame-vms.do-always"
	$(Q)$(MAKE) -f make/build_package.make package \
		TARGET_REPACK="xxx-multigame-files.do-always"
	$(Q)$(MAKE) -f make/build_package.make package \
		SRCDIR="games/multigame/assets/lsdm3_v1.pk3dir" \
		TARGET_REPACK="lsdm3_v1-files.do-always"
	$(Q)$(MAKE) -f make/build_package.make index \
		WASM_VFS="xxx-multigame-vms.pk3 xxx-multigame-files.pk3 lsdm3_v1-files.pk3" \
		STARTUP_COMMAND="+devmap\\', \\'lsdm3_v1" \
		DESTDIR="$(dir $(WASM_INDEX))"


# TODO build quake 3 as a library that can be use for rendering embedded in other apps?
SDL_FLAGS := -DSDL_VIDEO_DISABLED=1 \
						 -DSDL_JOYSTICK_DISABLED=1 \
						 -DSDL_SENSOR_DISABLED=1 \
						 -DSDL_HAPTIC_DISABLED=1 \
             -D__EMSCRIPTEN__=1 \
						 -D_GNU_SOURCE=1 \
						 -DHAVE_STDLIB_H=1 \
						 -DHAVE_UNISTD_H=1 \
						 -DHAVE_MATH_H=1 \
						 -DHAVE_GETENV=1 \
						 -DHAVE_M_PI \
						 -DSDL_THREADS_DISABLED=1 \
						 -DSDL_AUDIO_DRIVER_EMSCRIPTEN=1

define DO_SDL_CC
	$(echo_cmd) "SDL_CC $<"
	$(Q)$(CC) -o $@ -Wno-macro-redefined $(SDL_FLAGS) $(CLIENT_CFLAGS) -c $<
endef


# TODO: move this to make/lib_sdl.make
ifdef B
$(B)/client/%.o: $(SDL_SOURCE)/src/audio/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/audio/emscripten/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/events/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/atomic/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/thread/generic/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/thread/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/timer/unix/%.c
	$(DO_SDL_CC)

$(B)/client/%.o: $(SDL_SOURCE)/src/%.c
	$(DO_SDL_CC)
endif




.NOTPARALLEL: index
# TODO: compile all js files into one/minify/webpack
# TODO: insert bigchars font into index page, insert all javascript and wasm into index page
# TODO: deploy index page with Actions
