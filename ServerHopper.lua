-- Server Hop Script
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local PlaceId = game.PlaceId

local function serverHop()
    -- Get list of public servers
    local servers = HttpService:JSONDecode(game:HttpGetAsync("https://games.roblox.com/v1/games/" .. PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"))
    local serverList = servers.data

    -- Filter out full servers and the current server
    local availableServers = {}
    for _, server in ipairs(serverList) do
        if server.playing < server.maxPlayers and server.id ~= game.JobId then
            table.insert(availableServers, server)
        end
    end

    if #availableServers > 0 then
        local chosenServer = availableServers[math.random(1, #availableServers)]
        print("Hopping to server: " .. chosenServer.id .. " (" .. chosenServer.playing .. "/" .. chosenServer.maxPlayers .. ")")
        TeleportService:TeleportToPlaceInstance(PlaceId, chosenServer.id, game.Players.LocalPlayer)
    else
        print("No available servers found, trying again in 5 seconds...")
        wait(5)
        serverHop()
    end
end

serverHop()
