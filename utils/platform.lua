-----------------------------------------------------------------------------
-- platform.lua
-----------------------------------------------------------------------------

--[[
=head1 NAME

jive.util.platform_target - piCorePlayer platform timplemenetation

=head1 DESCRIPTION

piCorePlayer platform implementation

=head1 SYNOPSIS

This module implements functionality required for jivelite on piCorePlayer

=cut
--]]

local pcall = pcall
local lfs   = require("lfs")
local io    = require("io")
local log   = require("jive.utils.log").logger("jivelite.platform")

local loaded_rpi_bl, rpi = pcall(require, "jive.utils.rpi_bl")

module(...)

local version = 1.0
pCP_version_file_location = "/usr/local/etc/pcp/pcpversion.cfg"

-- ========================
--  { visImage interface
-- ======================
function getPersistentStorageRoot(_)
    local psr = io.popen('readlink /etc/sysconfig/tcedir'):read()
    log:debug("getPersisentStorageRoot: persistent storage root is ", psr)
    return psr
end
--  } visImage interface

-- ========================
--  { Process interface
-- ======================
function getfd(_, fh)
    log:debug("getfd: return fh:fileno() = ", fh:fileno())
    return fh:fileno()
end
--  } Process interface

-- ========================
--  { System interface
-- ======================
function hasTouch(_, cap)
    if loaded_rpi_bl then
        log:debug("hasTouch: rpi.isTouch()=", rpi.isTouch())
        if rpi.isTouch() ~= nil then
            return true
        else
            return false
        end
    else
        log:warn("hasTouch: rpi_bl not loaded!")
        return cap ~= nil
    end
end
--  } System interface

-- ========================
--  { JiveMain interface
-- ======================
-- brightness control
local backlightBrightness
local reducedBacklightBrightness

function setDefaultBrightnessValues(_, appletManager)
    log:debug("setDefaultBrightnessValues: appletManager=", appletManager)
    if appletManager == nil then
        log:warn("setDefaultBrightnessValues: appletManager=", appletManager)
        return
    end
    -- set default values
    backlightBrightness = appletManager:callService("getBacklightBrightnessWhenOn")
    if backlightBrightness == nil then
        backlightBrightness = "255"
    end

    reducedBacklightBrightness = appletManager:callService("getBacklightBrightnessWhenOff")
    if reducedBacklightBrightness == nil then
        reducedBacklightBrightness = "130"
    end
    log:debug("setDefaultBrightnessValues using rpi module.",
               " backlightBrightness=", backlightBrightness,
               " reducedBacklightBrightness=", reducedBacklightBrightness)
end

function setReducedBrightness(_)
    if not loaded_rpi_bl then
        log:warn("setReducedBrightness: rpi_bl not loaded!")
    else
        log:debug("setReducedBrightness: using rpi module, brighness = ", reducedBacklightBrightness)
        rpi.set_pCP_display_current_brightness(reducedBacklightBrightness)
    end
end

function setBrightness(_)
    if not loaded_rpi_bl then
        log:warn("setBrightness: rpi_bl not loaded!")
    else
        log:debug("setBrightness: using rpi module, brightness = ", backlightBrightness)
        rpi.set_pCP_display_current_brightness(backlightBrightness)
    end
end
--  } JiveMain interface for brightness control

-- ========================
-- ScreenSavers interface {
-- ========================
-- return if platform requires to be treated as local player regardless
function forceLocalPlayer(_)
    local ret_value = true
    log:debug("forceLocalPlayer() = ", ret_value)
    return ret_value
end

-- return if platform allows all actions when screen saver is activated
function screenSaverAllowAllActions(_, appletManager)
    local ret_value = true
    if appletManager == nil then
        log:warn("screenSaverAllowAllActions: appletManager=", appletManager)
    else
        ret_value = appletManager:callService('getEnablePowerOnButtonWhenOff')
    end
    log:debug("screenSaverAllowAllActions: ", ret_value)
    return ret_value
end
-- } ScreenSavers interface

-- platform check
function getVersion()
    -- TODO unify with other pcp code
    local pcp_version_file = "/usr/local/etc/pcp/pcpversion.cfg"
    local mode = lfs.attributes(pcp_version_file, "mode")
    if mode ~= "file" then
        log:warn("not running on piCorePlayer, unable to find file ", pcp_version_file)
        return nil
    end
    log:debug("platform implementation version ", version)
    return version
end
