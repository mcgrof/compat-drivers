--- a/drivers/gpu/drm/drm_modes.c
+++ b/drivers/gpu/drm/drm_modes.c
@@ -35,8 +35,12 @@
 #include <linux/export.h>
 #include <drm/drmP.h>
 #include <drm/drm_crtc.h>
+#if IS_ENABLED(CONFIG_OF_VIDEOMODE)
 #include <video/of_videomode.h>
+#endif
+#if IS_ENABLED(CONFIG_VIDEOMODE)
 #include <video/videomode.h>
+#endif
 
 /**
  * drm_mode_debug_printmodeline - debug print a mode
