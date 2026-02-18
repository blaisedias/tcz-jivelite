--local io                    = require("io")
local oo                    = require("loop.simple")
local AppletMeta            = require("jive.AppletMeta")
--local appletManager         = appletManager
local log                   = require("jive.utils.log").logger("applet.piCorePlayer")
local jiveMain              = jiveMain
local rpi                   = require("jive.utils.rpi_bl")

module(...)
oo.class(_M, AppletMeta)

function jiveVersion(self)
   return 1, 1
end

function registerApplet(self)
    self:registerService('getBacklightBrightnessWhenOn')
    self:registerService('getBacklightBrightnessWhenOff')
    self:registerService('getEnablePowerOnButtonWhenOff')
    self:registerService('updatePersistentStore')
end

function defaultSettings(self)
    return {
        pcp_enable_power_on_button_when_off = true,
        -- pcp_pi_network_interface_name = nil,
        -- pcp_LMS_MAC_address = nil,
    }
end

function configureApplet(self)
    local icon = jiveMain:getSkinParamOrNil('piCorePlayerStyle') or 'hm_settings'
    local icon_save = jiveMain:getSkinParamOrNil('piCorePlayerSaveStyle') or 'hm_sdcard'

	-- we only register the menu her, as registerApplet is being called before the skin is initialized
    jiveMain:addItem(
    	self:menuItem(
    		'piCorePlayerApplet',
    		'settings',
    		'piCorePlayer',
    		function(applet, ...) 
    			applet:menu(...)
    		end,
    		110,
    		nil,
		icon
    	)
    )

    jiveMain:addItem(
    	self:menuItem(
    		'piCorePlayerAppletSave',
    		'settings',
    		'Save Settings to SD Card',
    		function(applet, ...) 
    			applet:saveToSDCard(...)
    		end,
    		120,
    		nil,
		icon_save
    	)
    )

	if self:getSettings()['pcp_rpi_display_brightness'] then
		local stored_brightness = self:getSettings()['pcp_rpi_display_brightness']
		log:debug("Stored Brightness = ",  stored_brightness)

		if rpi.PiDisplay() == "pitouch" then
			rpi.set_pCP_display_current_brightness(stored_brightness)
		elseif rpi.PiDisplay == "lcd" then
			-- set brightness range
			local retval = rpi.run_lcd_script_command("R")
			log:debug("Result of setting brightness range: ", retval)
			-- set brightness to stored value.  This is required not only to ensure correct brightness on reboot
			-- but also to put GPIO 13 into PWM mode, so that 'pigs GDC g' will work
			retval = rpi.run_lcd_script_command(stored_brightness)
			log:debug("Result of setting brightness value: ", retval)
		end
	else
		log:debug("Brightness setting doesn't exist")
		-- set brightness range
		local retval = rpi.run_lcd_script_command("R")
		log:debug("Result of setting brightness range: ", retval)
		-- set to full brightness.  This is required to put GPIO 13 into PWM mode, so that 'pigs GDC g' will work
		retval = rpi.run_lcd_script_command("F")
		log:debug("Result of setting brightness value: ", retval)
	end
end
