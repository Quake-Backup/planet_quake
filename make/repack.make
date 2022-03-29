
# most .make files are the format 
# 1) PLATFORM
# 2) BUILD OBJS
# 3) DEFINES
# 4) GOALS
#this make file adds an additional BUILD OBJS and defined down below

ifeq ($(V),1)
echo_cmd=@:
Q=
else
echo_cmd=@echo
Q=@
endif
_                 = $() $()

ifndef SRCDIR
SRCDIR           := games/multigame/assets
endif

ifndef PK3_PREFIX
PK3_PREFIX       := $(subst $(_),\space,$(subst .pk3dir,,$(notdir $(SRCDIR))))
endif

ifeq ($(SRCDIR),games/multigame/assets)
PK3_PREFIX       := xxx-multigame
endif

ifeq ($(PK3_PREFIX),multigame)
PK3_PREFIX       := xxx-multigame
endif

ifeq ($(SRCDIR),)
$(error No SRCDIR!)
endif

ifndef DESTDIR
DESTDIR          := build
endif

ifeq ($(DESTDIR),)
$(error No SRCDIR!)
endif

ifndef RPK_EXT
RPK_EXT          := pk3
endif

ifeq ($(NO_REPACK),1)
RPK_EXT          := pk3dir
endif


################ PLATFORM SPECIFIC COMMANDS 


# TODO: make script for repack files, just like repack.js but no graphing
# TODO: use _hi _lo formats and the renderer and same directory to load converted web content
# TODO: figure out how this fits in with AMP file-naming style
NODE             := node
MKFILE           := $(lastword $(MAKEFILE_LIST))
ZIP              := zip
CONVERT          := convert -strip -interlace Plane -sampling-factor 4:2:0 -quality 15% -auto-orient 
ENCODE           := oggenc -q 7 --downmix --resample 11025 --quiet 
FFMPEG           := ffmpeg 
UNZIP            := unzip -n 
IDENTIFY         := identify -format '%[opaque]'
REPACK_MOD       := 1
NO_OVERWRITE     ?= 1
GETEXT            = $(if $(filter "%True%",$(shell $(IDENTIFY) "$1")),jpg,png)
GETMPGA           = $(filter "%True%",$(shell $(NODE) -e "if(fs.readFileSync('$1', 'binary').includes('\x2E\x3D')) {console.log('True')}"))
FILTER_EXT        = $(foreach ext,$1, $(filter %.$(ext),$2))
LVLS4            := * */* */*/* */*/*/* */*/*/*/*
LVLS3            := * */* */*/* */*/*/*
LEVELS            = $(subst \pathsep,,$(subst \space\pathsep, ,$(foreach lvl,$(LVLS4), $(subst $(_),\space,$(subst $1/,\pathsep,$(wildcard $(subst $(_),\ ,$1)/$(lvl)))))))
LEVELS_PK3        = $(subst \pathsep,,$(subst \space\pathsep, ,$(foreach lvl,$(LVLS3), $(subst $(_),\space,$(subst $1/,\pathsep,$(wildcard $(subst $(_),\ ,$1)/*.pk3dir/$(lvl)))))))
REPLACE_EXT       = $(foreach ext,$1, $(subst .$(ext),.%,$2))
COPY             := cp
UNLINK           := rm
MOVE             := mv
MKDIR            ?= mkdir -p


RPK_TARGET       := $(PK3_PREFIX).pk3
RPK_GOAL         := $(DESTDIR)/$(RPK_TARGET)
RPK_CONVERT      := $(subst .pk3,-converted,$(RPK_TARGET))
RPK_ENCODE       := $(subst .pk3,-encoded,$(RPK_TARGET))
#RPK_UNPACK      := $(subst \pathsep,,$(subst \space\pathsep, ,$(subst $(_),\space,$(subst $(SRCDIR)/,\pathsep,$(wildcard $(SRCDIR)/*.pk3)))))
RPK_PK3DIRS      := $(subst .pk3dir,.pk3,$(subst \pathsep,,$(subst \space\pathsep, ,$(subst $(_),\space,$(subst $(SRCDIR)/,\pathsep,$(wildcard $(SRCDIR)/*.pk3dir))))))
RPK_TARGETS      := $(RPK_TARGET) $(RPK_UNPACK) $(RPK_PK3DIRS)
RPK_WORKDIRS     := $(addsuffix dir,$(RPK_TARGETS))
RPK_REPLACE       = $(subst \space, ,$(subst $(RPK_GOAL)dir/,$(SRCDIR)/,$1))
RPK_LOCAL         = $(subst \space, ,$(subst $(RPK_GOAL)-packed/,,$1))
RPK_COPY          = $(subst \space, ,$(subst $(DESTDIR)/$(PK3_PREFIX)-copied/,$(SRCDIR)/,$1))
RPK_COPIED        = $(subst \space, ,$(subst $(DESTDIR)/$(PK3_PREFIX)-copied/,$(RPK_GOAL)dir/,$1))
RPK_GETEXT        = $(basename $1).$(call GETEXT,$(call RPK_REPLACE,$1))
RPK_PK3DIR        = $(subst $(DESTDIR)/,$(SRCDIR)/,$(subst -repack,.pk3dir,$1))


ifeq ($(filter-out $(_),$(RPK_TARGETS)),)
$(error directory missing)
endif


################ BUILD OBJS / DIFF FILES 

ifneq ($(filter %.pk3dir,$(SRCDIR)),)

# must convert files in 2 seperate steps because of images 
#   we don't know what format we end up with until after the
#   conversion so we don't repeat the the GETEXT command excessively
FILES_SRCPK3     := $(call LEVELS_PK3,$(subst \space, ,$(SRCDIR)))
FILES_SRC        := $(call LEVELS,$(subst \space, ,$(SRCDIR)))
ALL_FILES        := $(filter-out $(FILES_SRCPK3),$(FILES_SRC))
FILES_DONEPK3    := $(call LEVELS_PK3,$(subst \space, ,$(RPK_GOAL)dir))
FILES_DONE       := $(call LEVELS,$(subst \space, ,$(RPK_GOAL)dir))
ALL_DONE         := $(filter-out $(FILES_DONEPK3),$(FILES_DONE))


ifeq ($(filter-out $(_),$(ALL_FILES)),)
$(error no files in source directory $(FILES_SRC))
endif

endif

IMAGE_VALID_EXTS := jpg png
IMAGE_CONV_EXTS  := dds tga bmp pcx
IMAGE_ALL_EXTS   := $(IMAGE_CONV_EXTS) $(IMAGE_VALID_EXTS)
AUDIO_VALID_EXTS := ogg
AUDIO_CONV_EXTS  := wav mp3 opus mpga
AUDIO_ALL_EXTS   := $(AUDIO_CONV_EXTS) $(AUDIO_VALID_EXTS)
FILE_ALL_EXT     := cfg skin menu shaderx mtr arena bot txt shader




################ DO WORK DEFINES

define DO_CONVERT
	$(echo_cmd) "CONVERT $(call RPK_REPLACE,$@) -> $@"
	$(Q)$(MKDIR) "$(subst \space, ,$(dir $@))"
	$(Q)$(CONVERT) "$(call RPK_REPLACE,$@)" "$(subst \space, ,$(call RPK_GETEXT,$@))"
endef

define DO_UNPACK
	$(echo_cmd) "UNPACK $<"
	$(Q)$(UNZIP) "$<" -d "$@dir/" > /dev/null
endef

define DO_ENCODE
	$(echo_cmd) "ENCODE $(call RPK_REPLACE,$@) -> $@"
	$(Q)$(MKDIR) "$(subst \space, ,$(dir $@))"
	$(Q)$(ENCODE) "$(call RPK_REPLACE,$@)" -n "$(subst \space, ,$(basename $@)).ogg"
endef

define DO_FFMPEG
	$(echo_cmd) "FFMPEG $(call RPK_REPLACE,$@) -> $@"
	$(Q)$(MKDIR) "$(subst \space, ,$(dir $@))"
	$(Q)$(FFMPEG) -i "$(call RPK_REPLACE,$@)" -c:a libvorbis -q:a 4 "$(subst \space, ,$(basename $@)).ogg"
endef

define DO_COPY
	$(echo_cmd) "COPY $(call RPK_COPY,$@) -> $@"
	$(Q)$(MKDIR) "$(call RPK_COPIED,$(dir $@))"
	$(Q)$(COPY) -n "$(call RPK_COPY,$@)" "$(call RPK_COPIED,$@)" ||:
endef

define DO_ARCHIVE
	$(echo_cmd) "ARCHIVE $@"
	$(Q)pushd "$(RPK_GOAL)dir" > /dev/null && \
	$(ZIP) -o ../$(subst \space, ,$(PK3_PREFIX)).zip "$(subst \space, ,$(subst -packed,dir,$(call RPK_LOCAL,$@)))" > /dev/null && \
	popd > /dev/null
endef



################### TARGETS / GOALS



ifdef TARGET_CONVERT

# list images with converted pathname then check for existing alt-name in 
#   defined script
# convert jpg from source dirs in case there is a quality conversion
IMAGE_SRC        := $(call FILTER_EXT,$(IMAGE_ALL_EXTS),$(ALL_FILES))
IMAGE_DONE       := $(call FILTER_EXT,$(IMAGE_VALID_EXTS),$(ALL_DONE))
IMAGE_DONE_WILD  := $(call REPLACE_EXT,$(IMAGE_VALID_EXTS),$(IMAGE_DONE))
IMAGE_NEEDED     := $(filter-out $(IMAGE_DONE_WILD),$(IMAGE_SRC))
IMAGE_OBJS       := $(addprefix $(RPK_GOAL)dir/,$(IMAGE_NEEDED))

convert: $(TARGET_CONVERT)
	@:

$(RPK_GOAL)dir/%.tga:
	$(NODE) -e "let wrong=fs.readFileSync('$(call RPK_REPLACE,$@)', 'binary');if(wrong.includes('created using ImageLib by SkyLine Tools')){wrong=wrong.replace('created using ImageLib by SkyLine Tools', '');wrong=wrong.replace(/^\(/, '\0');fs.writeFileSync('$(call RPK_REPLACE,$@)', wrong)}"
	$(DO_CONVERT)

$(RPK_GOAL)dir/%:
	$(DO_CONVERT)

ifeq ($(IMAGE_OBJS),)

$(DESTDIR)/$(PK3_PREFIX)-converted:
	$(echo_cmd) "NOTHING TO CONVERT"

else

$(DESTDIR)/$(PK3_PREFIX)-converted: $(IMAGE_OBJS)
	$(echo_cmd) "CONVERTED $<"

endif

endif # TARGET_CONVERT

ifeq ($(TARGET_CONVERT),)

convert:
	$(echo_cmd) "NOTHING TO CONVERT"

endif




ifdef TARGET_ENCODE

# list images with converted pathname then check for existing alt-name in 
#   defined script
# convert jpg from source dirs in case there is a quality conversion
AUDIO_SRC        := $(call FILTER_EXT,$(AUDIO_CONV_EXTS),$(ALL_FILES))
AUDIO_SRCDONE    := $(addprefix $(DESTDIR)/$(PK3_PREFIX)-copied/,$(call FILTER_EXT,$(AUDIO_VALID_EXTS),$(ALL_FILES)))
AUDIO_DONE       := $(call FILTER_EXT,$(AUDIO_VALID_EXTS),$(ALL_DONE))
AUDIO_DONE_WILD  := $(call REPLACE_EXT,$(AUDIO_VALID_EXTS),$(AUDIO_DONE))
AUDIO_NEEDED     := $(filter-out $(AUDIO_DONE_WILD),$(AUDIO_SRC))
AUDIO_OBJS       := $(addprefix $(RPK_GOAL)dir/,$(AUDIO_NEEDED))

encode: $(TARGET_ENCODE)
	@:

$(RPK_GOAL)dir/%.mp3:
	$(DO_FFMPEG)

$(RPK_GOAL)dir/%.mpga:
	$(DO_FFMPEG)

$(RPK_GOAL)dir/%.wav:
	$(if $(call GETMPGA,$(call RPK_REPLACE,$@)),$(DO_ENCODE),$(DO_FFMPEG))

$(RPK_GOAL)dir/%:
	$(DO_ENCODE)

$(DESTDIR)/$(PK3_PREFIX)-copied/%:
	$(DO_COPY)

$(DESTDIR)/$(PK3_PREFIX)-encoded: $(AUDIO_OBJS) $(AUDIO_SRCDONE)
	$(echo_cmd) "ENCODED $<"

endif # TARGET_ENCODE





ifdef TARGET_UNPACK

unpack: $(TARGET_UNPACK)
	$(echo_cmd) "UNPACKED $<"

# have to do this first and it runs with no replace 
#   so it's not expensive to repeat every time
$(DESTDIR)/%.pk3: $(SRCDIR)/%.pk3
	$(DO_UNPACK)

endif


ifeq ($(TARGET_UNPACK),)

unpack:
	$(echo_cmd) "NOTHING TO UNPACK"

endif



ifdef TARGET_MKDIRS

mkdirs: $(TARGET_MKDIRS)
	$(echo_cmd) "MADEDIRS $<"

$(DESTDIR)/%.pk3dir: 
	@if [ ! -d "$(subst \space, ,$(DESTDIR))/" ];then $(MKDIR) "$(subst \space, ,$(DESTDIR))";fi
	@if [ ! -d "$(subst \space, ,$@)" ];then $(MKDIR) "$(subst \space, ,$@)";fi

endif







ifdef TARGET_REPACK

IMAGE_SRC        := $(call FILTER_EXT,$(IMAGE_ALL_EXTS),$(ALL_FILES))
IMAGE_SRCWILD    := $(call REPLACE_EXT,$(IMAGE_ALL_EXTS),$(IMAGE_SRC))
IMAGE_DESTINED   := $(addprefix $(RPK_GOAL)-packed/,$(filter $(IMAGE_SRCWILD),$(ALL_DONE)))

$(DESTDIR)/%-repack:
	+$(Q)$(MAKE) -f $(MKFILE) V=$(V) repack \
		SRCDIR="$(subst \space, ,$(call RPK_PK3DIR,$@))" DESTDIR="$(DESTDIR)"

package-pk3dirs: $(TARGET_REPACK)
	@:

package: $(TARGET_REPACK)
	$(echo_cmd) "PACKAGED $<"
	-@$(MOVE) $(RPK_GOAL) $(RPK_GOAL).bak > /dev/null
	$(Q)$(MOVE) $(DESTDIR)/$(PK3_PREFIX).zip $(RPK_GOAL)
	-@$(UNLINK) $(RPK_GOAL).bak > /dev/null

$(RPK_GOAL)-packed/%:
	$(DO_ARCHIVE)

$(DESTDIR)/$(PK3_PREFIX)-packed: $(IMAGE_DESTINED)
	@:

endif

ifeq ($(TARGET_REPACK),)

package-pk3dirs:
	$(echo_cmd) "NOTHING TO PACKAGE"

endif






################### MAIN / REPACK!

repack:
	$(echo_cmd) "REPACK $(SRCDIR) -> $(RPK_WORKDIRS)"
	$(Q)$(MAKE) -f $(MKFILE) V=$(V) mkdirs \
		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
		TARGET_MKDIRS="$(addprefix $(DESTDIR)/,$(RPK_WORKDIRS))"
#	$(Q)$(MAKE) -f $(MKFILE) V=$(V) unpack \
#		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
#		TARGET_UNPACK="$(addprefix $(DESTDIR)/,$(RPK_UNPACK))"
	$(Q)$(MAKE) -f $(MKFILE) V=$(V) convert \
		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
		TARGET_CONVERT="$(addprefix $(DESTDIR)/,$(RPK_CONVERT))"
	$(Q)$(MAKE) -f $(MKFILE) V=$(V) encode \
		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
		TARGET_ENCODE="$(addprefix $(DESTDIR)/,$(RPK_ENCODE))"
#	+$(Q)$(MAKE) -f $(MKFILE) V=$(V) package -j 1 \
#		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
#		TARGET_REPACK="$(DESTDIR)/$(PK3_PREFIX)-packed"
	$(Q)$(MAKE) -f $(MKFILE) V=$(V) package-pk3dirs \
		SRCDIR="$(SRCDIR)" DESTDIR="$(DESTDIR)" \
		TARGET_REPACK="$(addprefix $(DESTDIR)/,$(subst .pk3,-repack,$(RPK_PK3DIRS)))"

.DEFAULT_GOAL := repack
