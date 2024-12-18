script_name("guardnear")
script_author("akacross")
script_version("0.0.1") -- Current version of the script

require "lib.moonloader"
require "lib.sampfuncs"
local json = require("lib.json") -- To parse JSON if needed

local update_url = "https://raw.githubusercontent.com/Valdichi/BHT-Autovest/refs/heads/main/autovest%20update.lua"
local script_path = thisScript().path -- Path to the current script file

local Activate = false

function cmd()
    Activate = not Activate
    sampAddChatMessage(string.format("{F8F9F9}Auto Vest is %s", Activate))
end

function main()
    if not isSampLoaded() or not isSampfuncsLoaded() then return end
    while not isSampAvailable() do wait(100) end

    sampAddChatMessage("{808080}(Autovest for BHT/LS/TFF/NPA/PE - /avest)")
    sampRegisterChatCommand("avest", cmd)

    -- Check for updates
    check_for_update()

    while true do
        wait(100)
        if isKeyControlAvailable() and Activate then
            local playerid = getClosestPlayerId(7, true)
            if sampIsPlayerConnected(playerid) then 
                sampSendChat(string.format("/guard %d 200", playerid))
                wait(12000)
            end
        end
    end
end

-- Check for updates
function check_for_update()
    local response, status, headers = downloadUrl(update_url)
    if status == 200 and response then
        local remote_script_version = get_remote_version(response)
        if remote_script_version and remote_script_version ~= script_version then
            sampAddChatMessage("{FF0000}[Auto-Update] A new version is available. Updating...")
            update_script(response)
        else
            sampAddChatMessage("{00FF00}[Auto-Update] No updates found. You're on the latest version!")
        end
    else
        sampAddChatMessage("{FF0000}[Auto-Update] Failed to check for updates.")
    end
end

-- Extract version from the remote script
function get_remote_version(script_content)
    local version_match = string.match(script_content, 'script_version%("(.-)"%)')
    return version_match
end

-- Update the script
function update_script(new_script_content)
    local file = io.open(script_path, "w")
    if file then
        file:write(new_script_content)
        file:close()
        sampAddChatMessage("{00FF00}[Auto-Update] Update complete. Please restart the game or reload the script.")
    else
        sampAddChatMessage("{FF0000}[Auto-Update] Failed to write the updated script!")
    end
end
