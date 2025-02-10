local io    = require("io")
local os    = require("os")
local log   = require("jive.utils.log").logger("piCorePlayer")

local tonumber = tonumber

module(...)

local initialised = false
--local backlightpath = "/"
local brightness = "/brightness"
local max_brightness = "/max_brightness"
local bl_power = "/bl_power"
local pCP_lcdscript = "/home/tc/lcd-brightness.sh"
local pidisplay = nil
local touchChecked = false
local hasTouch = nil

function PiDisplay()
    if initialised == false then
        -- Find Raspberry display driver backlight links
        local ret = _read_capture("readlink /sys/class/backlight/*")
        local tmp = "/sys/class/backlight/" .. ret
        local backlightpath = tmp:gsub("[\n\r]", "")
        brightness = backlightpath .. "/brightness"
        max_brightness = backlightpath .. "/max_brightness"
        bl_power = backlightpath .. "/bl_power"
        log:debug("brightness: " .. brightness)
        log:debug("maxbrightness: " .. max_brightness)
        log:debug("power: " .. bl_power)

        if _file_exists(brightness) then
            pidisplay = "pitouch"
        elseif _file_exists(pCP_lcdscript) then
            pidisplay = "lcd"
        end

        log:info("Setting touchscreen to: " .. pidisplay)
        initialised = true
    end
    log:info("display is : " .. pidisplay)
    return pidisplay
end

function set_backlight_power(power)
    local on = "0"
    local off = "1"
    log:debug("Turning Display: " .. power)
    if PiDisplay() == "pitouch" then
        if power == on then
            log:debug("0-bl_power: " .. _read(bl_power)) 
            if tonumber(_read(bl_power)) == tonumber(off) then
                _write(bl_power, power)
            end
        elseif power == off then
            log:debug("1-bl_power: " .. _read(bl_power)) 
            if tonumber(_read(bl_power)) == tonumber(on) then
                _write(bl_power, power)
            end
        end
    end
end

function run_lcd_script_command(command)
    if PiDisplay() == "lcd" then
        local cmd = pCP_lcdscript .. " " .. command
        log:debug(cmd)
        local retval = _read_capture(cmd)
        return retval
    end
    return nil
end

function get_lcd_current_brightness()
    local ret = _read_capture(pCP_lcdscript .. " C")
    return ret
end

function set_lcd_current_brightness(br)
    os.execute(pCP_lcdscript .. " " .. br)
end
        
function set_pCP_display_current_brightness( BlBr )
    log:debug("Setting " .. PiDisplay() .. " brightness: " .. BlBr)
    --RPi 7" Touchscreen
    if PiDisplay() == "pitouch" then
        _write(brightness, BlBr)
    --Generic brightness script
    elseif PiDisplay() == "lcd" then
        local cmd = pCP_lcdscript .. " " .. BlBr
        log:debug(cmd)
        os.execute(cmd)
    end
end

function get_pCP_display_current_brightness()
    if PiDisplay() == "pitouch" then
        return _read(brightness)
    elseif PiDisplay() == "lcd" then
        return _read_capture(pCP_lcdscript .. " C")
    end
end 

function get_pCP_display_max_brightness()
    if PiDisplay() == "pitouch" then
        return _read(max_brightness)
    elseif PiDisplay() == "lcd" then
        return _read_capture(pCP_lcdscript .. " M")
    end
end

function isTouch()
    if touchChecked == false then
        local cmd = "udevadm info --export-db | grep ID_INPUT_TOUCHSCREEN"
        local ret = _read_capture(cmd)
        log:debug("udev found: " .. ret)
        touchChecked = true
        hasTouch = ret
    end
    return hasTouch
end

function _file_exists(name)
   local f=io.open(name,"r")
   if io.type(f) == nil then return false end
   if io.type(f) == "file" then io.close(f) return true end
   -- for completeness --
   if io.type(f) == "closed file" then return true end
end

function _write(file, val)
        local fh, err = io.open(file, "w")
        if err then
                return
        end
        fh:write(val)
        fh:close()
end

function _read(file)
    local fh, err = io.open(file, "r")
    if err then
        return nil
    end
    local fc = fh:read("*all")
    fh:close()
    return fc
end

-- allows output of shell scripts to be captured.
function _read_capture(cmd)
    local fh, err = io.popen(cmd, "r")
    if err then
        return nil
    end
    local fc = fh:read("*a")
    fh:close()
    return fc
end
