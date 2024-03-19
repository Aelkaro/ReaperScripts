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

function setMediaFromRequest()
    --{"id":"{2AFCD754-4BB1-476A-A6BB-951A36CF1630}","name": "Click source","volume": 1.0}
    local MediaListText = reaper.GetExtState("requests","MediaList");
    if MediaListText ~= "" then
        local MediaInfo = {}
        for token in string.gmatch(MediaListText, "[^%s]+") do
            table.insert(MediaInfo,token)
        end
        local take = reaper.GetMediaItemTakeByGUID(0, MediaInfo[1])
        reaper.SetMediaItemTakeInfo_Value(take, 'D_VOL', MediaInfo[2])
        reaper.SetExtState("requests","MediaList", "",false);
    end
    
end

function getMediaListInfo(items)
    local message = "{\"medias\":["
    local firstItem = true
    for i, item in ipairs(items) do

        if not firstItem then
            message = message .. ","
        else
            firstItem = false
        end

        local take = reaper.GetActiveTake(item)
        local _, GUID = reaper.GetSetMediaItemTakeInfo_String(take, "GUID", "", 0);
        local _, itemName = reaper.GetSetMediaItemTakeInfo_String(take, "P_NAME", "", false)
        local itemVolume = reaper.GetMediaItemTakeInfo_Value(take, "D_VOL")

        message = message .. "{\"id\":\"".. GUID .."\",\"name\": \"" .. itemName .. "\",\"volume\": " .. itemVolume .. "}"
    end
    message = message .. "]}"
    reaper.SetExtState("results","MediaList", message,false);
end

local interval = 500 -- Interval in milliseconds (adjust as needed)
local timerID = reaper.time_precise() + interval / 1000

local function loop()
    if reaper.time_precise() >= timerID then
        local mediaList = getMediaItemsAtCursorPosition()
        setMediaFromRequest()
        getMediaListInfo(mediaList)
        timerID = reaper.time_precise() + interval / 1000
    end
    reaper.defer(loop)
end
reaper.ShowConsoleMsg("Running")
loop()