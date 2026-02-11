files["utils/platform.lua"] = {
   globals = {
       "getVersion",
       "getPlatformName",
       "getPersistentStorageRoot",
       "getfd",
       "hasTouch",
       "setDefaultBrightnessValues",
       "setBrightness",
       "setReducedBrightness",
       "forceLocalPlayer",
       "screenSaverAllowAllActions",
   },
   read_globals = {
   }
}

files["utils/rpi_bl.lua"] = {
   globals = {
       "PiDisplay",
       "set_backlight_power",
       "run_lcd_script",
       "get_lcd_current_brightness",
       "set_lcd_current_brightness",
       "set_pCP_display_current_brightness",
       "get_pCP_display_current_brightness",
       "get_pCP_display_max_brightness",
       "isTouch",
   },
   read_globals = {
       "pCP_version_file_location",
   }
}

files["piCorePlayer/piCorePlayerApplet.lua"] = {
   globals = {
       "registerApplet",
       "defaultSettings",
       "configureApplet",
       "updatePersistentStore",
       "getEnablePowerOnButtonWhenOff",
       "getBacklightBrightnessWhenOff",
       "getBacklightBrightnessWhenOn",
       "piCorePlayerMenu"
   },
   read_globals = {
   }
}

files["piCorePlayer/piCorePlayerMeta.lua"] = {
   globals = {
       "jiveVersion",
       "registerApplet",
       "defaultSettings",
       "configureApplet",
   },
   read_globals = {
   }
}
