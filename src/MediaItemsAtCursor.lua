-- Function to get media items at the cursor position
function getMediaItemsAtCursorPosition()
    local playState = reaper.GetPlayState()
    local cursor_position
    if playState == 1 then
        cursor_position = reaper.GetPlayPosition()
    else
        cursor_position = reaper.GetCursorPosition()
    end
    local items = {}
    local num_tracks = reaper.CountTracks(0)
    for i = 0, num_tracks - 1 do
        local track = reaper.GetTrack(0, i)
        local num_items = reaper.CountTrackMediaItems(track)
        for j = 0, num_items - 1 do
            local item = reaper.GetTrackMediaItem(track, j)
            local item_pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION")
            local item_length = reaper.GetMediaItemInfo_Value(item, "D_LENGTH")
            if cursor_position >= item_pos and cursor_position <= item_pos + item_length then
                table.insert(items, item)
            end
        end
    end
    return items
end

function displayMediaItems(items)
    local message = ""
    for i, item in ipairs(items) do
        local take = reaper.GetActiveTake(item)
        local _, itemName = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
        local itemVolume = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
        message = message .. "Name: " .. itemName .. ", Volume: " .. itemVolume .. "\n"
    end
    reaper.ClearConsole()
    reaper.ShowConsoleMsg(message)
end

function writeResults(items)
    local message = ""
    for i, item in ipairs(items) do
        local take = reaper.GetActiveTake(item)
        local _, itemName = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
        local itemVolume = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")
        message = message .. "Name: " .. itemName .. ", Volume: " .. itemVolume .. "\n"
    end
    local mediaListFile = io.open("C:\\Users\\vince\\AppData\\Roaming\\REAPER\\reaper_www_root\\LuaResults\\mediaListFile.html",'w+')
    mediaListFile:write(message)
    mediaListFile:close()
end


local interval = 1000 -- Interval in milliseconds (adjust as needed)
local timerID = reaper.time_precise() + interval / 1000

local function loop()
    if reaper.time_precise() >= timerID then
        local mediaList = getMediaItemsAtCursorPosition()
        displayMediaItems(mediaList)
        writeResults(mediaList)
        timerID = reaper.time_precise() + interval / 1000
    end
    reaper.defer(loop)
end

loop()