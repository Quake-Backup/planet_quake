MKFILE      := $(lastword $(MAKEFILE_LIST)) 

include make/platform.make
include make/configure.make
include make/platform_os.make

RENDERER_PREFIX  := $(CNAME)
TARGET	         := $(RENDERER_PREFIX)_opengl2_

SOURCES  := $(MOUNT_DIR)/renderer2 $(MOUNT_DIR)/renderer2/glsl $(MOUNT_DIR)/renderercommon
INCLUDES := 

#LIBS = -l
GLSLFFALLBACKS := $(foreach dir,$(SOURCES), $(wildcard $(dir)/*.glsl))
GLSLFILES      := $(addprefix glsl/,$(notdir $(GLSLFFALLBACKS)))
CFILES         := $(foreach dir,$(SOURCES), $(wildcard $(dir)/*.c)) \
	                $(MOUNT_DIR)/qcommon/q_math.c $(MOUNT_DIR)/qcommon/q_shared.c \
							    $(MOUNT_DIR)/qcommon/puff.c
OBJS          := $(CFILES:.c=.o) 
Q3R2STRINGOBJ := $(GLSLFILES:.glsl=.o)
Q3OBJ         := $(addprefix $(B)/rend2/,$(notdir $(OBJS))) \
								 $(addprefix $(B)/rend2/glsl/,$(notdir $(Q3R2STRINGOBJ)))

export INCLUDE	:= $(foreach dir,$(INCLUDES),-I$(dir))

CFLAGS   := $(INCLUDE) -fsigned-char \
             -O2 -ftree-vectorize -g -ffast-math -fno-short-enums \
						 -MMD \
						 -DUSE_RENDERER_DLOPEN \
						 -DRENDERER_PREFIX=\"$(RENDERER_PREFIX)\"

define DO_REND_CC
	$(echo_cmd) "REND_CC $<"
	$(Q)$(CC) $(SHLIBCFLAGS) $(CFLAGS) $(SDL_INCLUDE) -o $@ -c $<
endef

define DO_REF_STR
	$(echo_cmd) "REF_STR $<"
	$(Q)rm -f $@
	$(Q)echo "const char *fallbackShader_$(notdir $(basename $<)) =" >> $@
	$(Q)cat $< | sed -e 's/^/\"/;s/$$/\\n\"/' | tr -d '\r' >> $@
	$(Q)echo ";" >> $@
endef

mkdirs:
	@if [ ! -d $(BUILD_DIR) ];then $(MKDIR) $(BUILD_DIR);fi
	@if [ ! -d $(B) ];then $(MKDIR) $(B);fi
	@if [ ! -d $(B)/rend2 ];then $(MKDIR) $(B)/rend2;fi
	@if [ ! -d $(B)/rend2/glsl ];then $(MKDIR) $(B)/rend2/glsl;fi

default:
	$(MAKE) -f $(MKFILE) B=$(BD) mkdirs
	$(MAKE) -f $(MKFILE) B=$(BD) $(BD)/$(TARGET)$(SHLIBNAME)

#debug:
#	@$(MAKE) -f $(MKFILE) $(TARGETS) B=$(BD) CFLAGS="$(CFLAGS) $(BASE_CFLAGS)" \
#	  OPTIMIZE="$(DEBUG_CFLAGS)" V=$(V)

#release:
#	@$(MAKE) -f $(MKFILE) $(TARGETS) B=$(BR) CFLAGS="$(CFLAGS) $(BASE_CFLAGS)" \
#	  OPTIMIZE="-DNDEBUG $(OPTIMIZE)" V=$(V)


$(B)/rend2/%.o: code/qcommon/%.c
	$(DO_REND_CC)

$(B)/rend2/%.o: code/renderercommon/%.c
	$(DO_REND_CC)

$(B)/rend2/%.o: code/renderer2/%.c
	$(DO_REND_CC)

$(B)/rend2/glsl/%.c: code/renderer2/glsl/%.glsl
	$(DO_REF_STR)

$(B)/rend2/glsl/%.o: $(B)/rend2/glsl/%.c
	$(DO_REND_CC)

$(B)/$(TARGET)$(SHLIBNAME): $(Q3OBJ) 
	$(echo_cmd) "LD $@"
	$(Q)$(CC) $(CFLAGS) $^ $(LIBS) $(SDL_LIBS) $(SHLIBLDFLAGS) -o $@

clean:
	@rm -rf $(BD)/rend2 $(BD)/$(TARGET)$(SHLIBNAME)
	@rm -rf $(BR)/rend2 $(BR)/$(TARGET)$(SHLIBNAME)


ifdef B
D_FILES=$(shell find $(BD)/rend2 -name '*.d')
endif

ifneq ($(strip $(D_FILES)),)
include $(D_FILES)
endif

.PHONY: all clean clean2 clean-debug clean-release copyfiles \
	debug default dist distclean makedirs release \
  targets tools toolsclean mkdirs \
	$(D_FILES)

.DEFAULT_GOAL := default
