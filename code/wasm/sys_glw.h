/*
===========================================================================
Copyright (C) 1999-2005 Id Software, Inc.

This file is part of Quake III Arena source code.

Quake III Arena source code is free software; you can redistribute it
and/or modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of the License,
or (at your option) any later version.

Quake III Arena source code is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with Quake III Arena source code; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
===========================================================================
*/

#ifndef __GLW_LINUX_H__
#define __GLW_LINUX_H__

typedef intptr_t SDL_Window;

typedef struct
{
  uint32_t format;              /**< pixel format */
  int w;                      /**< width */
  int h;                      /**< height */
  int refresh_rate;           /**< refresh rate (or zero for unspecified) */
  void *driverdata;           /**< driver-specific data, initialize to 0 */
} SDL_DisplayMode;

/**
 *  \brief The flags on a window
 *
 *  \sa SDL_GetWindowFlags()
 */
typedef enum
{
    /* !!! FIXME: change this to name = (1<<x). */
    SDL_WINDOW_FULLSCREEN = 0x00000001,         /**< fullscreen window */
    SDL_WINDOW_OPENGL = 0x00000002,             /**< window usable with OpenGL context */
    SDL_WINDOW_SHOWN = 0x00000004,              /**< window is visible */
    SDL_WINDOW_HIDDEN = 0x00000008,             /**< window is not visible */
    SDL_WINDOW_BORDERLESS = 0x00000010,         /**< no window decoration */
    SDL_WINDOW_RESIZABLE = 0x00000020,          /**< window can be resized */
    SDL_WINDOW_MINIMIZED = 0x00000040,          /**< window is minimized */
    SDL_WINDOW_MAXIMIZED = 0x00000080,          /**< window is maximized */
    SDL_WINDOW_INPUT_GRABBED = 0x00000100,      /**< window has grabbed input focus */
    SDL_WINDOW_INPUT_FOCUS = 0x00000200,        /**< window has input focus */
    SDL_WINDOW_MOUSE_FOCUS = 0x00000400,        /**< window has mouse focus */
    SDL_WINDOW_FULLSCREEN_DESKTOP = ( SDL_WINDOW_FULLSCREEN | 0x00001000 ),
    SDL_WINDOW_FOREIGN = 0x00000800,            /**< window not created by SDL */
    SDL_WINDOW_ALLOW_HIGHDPI = 0x00002000,      /**< window should be created in high-DPI mode if supported.
                                                     On macOS NSHighResolutionCapable must be set true in the
                                                     application's Info.plist for this to have any effect. */
    SDL_WINDOW_MOUSE_CAPTURE = 0x00004000,      /**< window has mouse captured (unrelated to INPUT_GRABBED) */
    SDL_WINDOW_ALWAYS_ON_TOP = 0x00008000,      /**< window should always be above others */
    SDL_WINDOW_SKIP_TASKBAR  = 0x00010000,      /**< window should not be added to the taskbar */
    SDL_WINDOW_UTILITY       = 0x00020000,      /**< window should be treated as a utility window */
    SDL_WINDOW_TOOLTIP       = 0x00040000,      /**< window should be treated as a tooltip */
    SDL_WINDOW_POPUP_MENU    = 0x00080000,      /**< window should be treated as a popup menu */
    SDL_WINDOW_VULKAN        = 0x10000000       /**< window usable for Vulkan surface */
} SDL_WindowFlags;

/**
 *  \brief OpenGL configuration attributes
 */
typedef enum
{
    SDL_GL_RED_SIZE,
    SDL_GL_GREEN_SIZE,
    SDL_GL_BLUE_SIZE,
    SDL_GL_ALPHA_SIZE,
    SDL_GL_BUFFER_SIZE,
    SDL_GL_DOUBLEBUFFER,
    SDL_GL_DEPTH_SIZE,
    SDL_GL_STENCIL_SIZE,
    SDL_GL_ACCUM_RED_SIZE,
    SDL_GL_ACCUM_GREEN_SIZE,
    SDL_GL_ACCUM_BLUE_SIZE,
    SDL_GL_ACCUM_ALPHA_SIZE,
    SDL_GL_STEREO,
    SDL_GL_MULTISAMPLEBUFFERS,
    SDL_GL_MULTISAMPLESAMPLES,
    SDL_GL_ACCELERATED_VISUAL,
    SDL_GL_RETAINED_BACKING,
    SDL_GL_CONTEXT_MAJOR_VERSION,
    SDL_GL_CONTEXT_MINOR_VERSION,
    SDL_GL_CONTEXT_EGL,
    SDL_GL_CONTEXT_FLAGS,
    SDL_GL_CONTEXT_PROFILE_MASK,
    SDL_GL_SHARE_WITH_CURRENT_CONTEXT,
    SDL_GL_FRAMEBUFFER_SRGB_CAPABLE,
    SDL_GL_CONTEXT_RELEASE_BEHAVIOR,
    SDL_GL_CONTEXT_RESET_NOTIFICATION,
    SDL_GL_CONTEXT_NO_ERROR
} SDL_GLattr;

typedef enum
{
    SDL_GL_CONTEXT_PROFILE_CORE           = 0x0001,
    SDL_GL_CONTEXT_PROFILE_COMPATIBILITY  = 0x0002,
    SDL_GL_CONTEXT_PROFILE_ES             = 0x0004 /**< GLX_CONTEXT_ES2_PROFILE_BIT_EXT */
} SDL_GLprofile;

#define SDL_INIT_TIMER          0x00000001
#define SDL_INIT_AUDIO          0x00000010
#define SDL_INIT_VIDEO          0x00000020
#define SDL_INIT_JOYSTICK       0x00000200
#define SDL_INIT_HAPTIC         0x00001000
#define SDL_INIT_NOPARACHUTE    0x00100000      /**< Don't catch fatal signals */
#define SDL_INIT_EVERYTHING     0x0000FFFF

extern void  SDL_MinimizeWindow( void *window );
extern int   SDL_GetWindowDisplayIndex(void *window);
extern void  SDL_GL_DeleteContext(void *ctx);
extern char *SDL_GetError( void );
extern int   SDL_GetDesktopDisplayMode(int displayIndex, SDL_DisplayMode *mode);
extern int   SDL_GL_SetAttribute(int attr, int value);
extern void *SDL_CreateWindow(const char *title,
                              int x, int y, int w,
                              int h, uint32_t flags);
extern int   SDL_SetWindowDisplayMode(void *window, const SDL_DisplayMode *mode);
extern int   SDL_GetWindowDisplayMode(void *window, SDL_DisplayMode *mode);
extern void *SDL_GL_CreateContext(void *window);
extern void  SDL_DestroyWindow(void *window);
extern int   GL_SetSwapInterval(int interval);
extern void  SDL_GL_GetDrawableSize(void *window, int *w, int *h);
extern void  SDL_WarpMouseInWindow(void *window, int x, int y);
extern const char *SDL_GetCurrentVideoDriver(void);
extern int   SDL_GL_SetSwapInterval(int interval);
extern uint32_t SDL_WasInit(uint32_t flags);
extern int   SDL_Init(uint32_t flags);
extern void  SDL_GL_SwapWindow(void *window);
extern void *Sys_LoadLibrary(const char *f);
extern int   SDL_ShowCursor(int toggle);
extern void  SDL_SetWindowGrab(void *window, qboolean grabbed);
extern int   SDL_SetRelativeMouseMode(qboolean enabled);
extern uint32_t SDL_GetWindowFlags(void *window);
extern void  SDL_StartTextInput(void);
extern void  SDL_StopTextInput(void);

void HandleEvents( void );

//#define USE_JOYSTICK

typedef struct
{
	FILE *log_fp;

	qboolean isFullscreen;

	glconfig_t *config; // feedback to renderer module

	int desktop_width;
	int desktop_height;

	int window_width;
	int window_height;

	int monitorCount;

} glwstate_t;

extern SDL_Window *SDL_window;
extern glwstate_t glw_state;

extern cvar_t *in_nograb;

void IN_Init( void );
void IN_Shutdown( void );

// signals.c
void InitSig( void );

#endif
