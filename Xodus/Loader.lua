local List = {
    [1390601379] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Blackout%Warriors.lua",
    [1494262959] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Criminality.lua",
    [3326279937] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Blackout.lua",
}

if List[game.GameId] then
    return loadstring(game:HttpGet(List[game.GameId]))()
else
    return game.Players.LocalPlayer:Kick("Game Not Supported.")
end
