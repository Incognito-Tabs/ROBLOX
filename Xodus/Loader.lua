local List = {
    [4282985734] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Blackout%Warriors.lua",
    [4588604953] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Criminality.lua",
    [8767500166] = "https://raw.githubusercontent.com/Incognito-RBX/Roblox/refs/heads/main/Xodus/Blackout.lua",
}

if List[game.GameId] then
    return loadstring(game:HttpGet(List[game.GameId]))()
else
    return game.Players.LocalPlayer:Kick("Game Not Supported.")
end
