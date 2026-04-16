local Gamefunc = {}

local events = game:GetService("ReplicatedStorage"):WaitForChild("Events")
local fading = events:WaitForChild("Fading")


function Gamefunc.SelectRandomByMallic()
	local Players = game:GetService("Players")
	local pool = {}
	local totalMallic = 0
	local allOptOut = true

	for _, player in pairs(Players:GetPlayers()) do
		if not player:FindFirstChild("Hiddenstats") then continue end
		if not player.Hiddenstats:FindFirstChild("Mallic") then continue end
		local mallic = player.Hiddenstats.Mallic.Value

		if mallic ~= -1 then
			allOptOut = false
		end

		if mallic < 0 then continue end

		totalMallic += mallic
		table.insert(pool, {player = player, weight = mallic})
	end

	local playersList = {}
	for _, player in pairs(Players:GetPlayers()) do
		if not player:FindFirstChild("Hiddenstats") then continue end
		if not player.Hiddenstats:FindFirstChild("Mallic") then continue end
		table.insert(playersList, player)
	end

	if #playersList == 0 then
		return nil
	end

	if allOptOut then
		for _, player in ipairs(playersList) do
			if math.random() <= 0.5 then
				return player
			end
		end
		return playersList[math.random(1, #playersList)]
	end

	if totalMallic == 0 then
		return pool[math.random(1, #pool)].player
	end

	local roll = math.random() * totalMallic
	for _, entry in ipairs(pool) do
		roll -= entry.weight
		if roll <= 0 then
			entry.player.Hiddenstats.Mallic.Value = 0
			return entry.player
		end
	end

	return pool[#pool].player
end



function Gamefunc.IncressMallic()
	local Players = game:GetService("Players")
	for _, player in pairs(Players:GetPlayers()) do
		if not player:FindFirstChild("Hiddenstats") then continue end
		if not player.Hiddenstats:FindFirstChild("Mallic") then continue end
		if player.Hiddenstats.Mallic.Value < 0 then continue end
		player.Hiddenstats.Mallic.Value += 1
	end
end

function Gamefunc.ChooseRandomMap()
	local maps = game:GetService("ReplicatedStorage").Maps:GetChildren()
	local randomMap = maps[math.random(1, #maps)]
	return randomMap
end

function Gamefunc.RenderMapSlowly(map)
	local mapClone = map:Clone()
	mapClone.Parent = workspace

	if mapClone.PrimaryPart then
		mapClone:SetPrimaryPartCFrame(CFrame.new(Vector3.new(-709.94, 9663.479, -180.509)))
	end

	local parts = {}
	for _, part in ipairs(mapClone:GetDescendants()) do
		if part:IsA("BasePart") and not part:IsDescendantOf(mapClone:FindFirstChild("SurvivorsSpawn")) and not part:IsDescendantOf(mapClone:FindFirstChild("KillerSpawn")) then
			table.insert(parts, part)
		end
	end

	local batchSize = 10
	local index = 1

	while index <= #parts do
		for i = 1, batchSize do
			if index > #parts then break end
			parts[index].Parent = mapClone
			index += 1
		end
		task.wait()
	end

	return mapClone
end



function Gamefunc.TeleportPlayersToSpawn(map, chosenPlayer)
	local SurvioursSpawnflr = map:FindFirstChild("SurvivorsSpawn")
	local Survivorspawns = SurvioursSpawnflr:GetChildren()
	local KillerSpawnflr = map:FindFirstChild("KillerSpawn")
	local Killerspawn = KillerSpawnflr:GetChildren()
	local avableSpawnsSurviours = {}
	local avableSpawnsKiller = {}
	for _, spawns in pairs(Survivorspawns) do
		if spawns:IsA("BasePart") then
			table.insert(avableSpawnsSurviours, spawns)
		end
	end
	for _, spawns in pairs(Killerspawn) do
		if spawns:IsA("BasePart") then
			table.insert(avableSpawnsKiller, spawns)
		end
	end
	for _, player in pairs(game:GetService("Players"):GetPlayers()) do
		if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			if player == chosenPlayer then
				local randomspawnn = avableSpawnsKiller[math.random(1, #avableSpawnsKiller)]
				chosenPlayer.Character.HumanoidRootPart.CFrame = randomspawnn.CFrame
			else
				local randomspawnn = avableSpawnsSurviours[math.random(1, #avableSpawnsSurviours)]
				player.Character.HumanoidRootPart.CFrame = randomspawnn.CFrame
				table.remove(avableSpawnsSurviours, table.find(avableSpawnsSurviours, randomspawnn))
			end
		end
	end
end

function Gamefunc.PlaceTeams(chosen: Player, ended: boolean)
	local Players = game:GetService("Players")
	local Teams = game:GetService("Teams")

	if ended then
		for _, player in ipairs(Players:GetPlayers()) do
			player.Team = Teams.Specators
		end
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player == chosen then
			player.Team = Teams.Killer
		else
			player.Team = Teams.Surviours
		end
	end

	if not Gamefunc._playerAddedConnected then
		Gamefunc._playerAddedConnected = true
		Players.PlayerAdded:Connect(function(player)
			player.Team = Teams.Specators
		end)
	end
end

function Gamefunc.EnableDeathSpectator()
	local Players = game:GetService("Players")
	local Teams = game:GetService("Teams")

	for _, player in ipairs(Players:GetPlayers()) do
		local character = player.Character
		if character then
			local humanoid = character:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Died:Connect(function()
					player.Team = Teams.Specators
				end)
			end
		end

		player.CharacterAdded:Connect(function(char)
			local humanoid = char:WaitForChild("Humanoid")
			humanoid.Died:Connect(function()
				player.Team = Teams.Specators
			end)
		end)
	end

	Players.PlayerAdded:Connect(function(player)
		player.CharacterAdded:Connect(function(char)
			local humanoid = char:WaitForChild("Humanoid")
			humanoid.Died:Connect(function()
				player.Team = Teams.Specators
			end)
		end)
	end)
end

function Gamefunc.EndGame()
	--add later 
end

function formattime(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = seconds % 60
	return string.format("%02d:%02d", minutes, remainingSeconds)
end
function Gamefunc.StartGame(gametime, intermationtime, strings)

	task.wait()
	local chosen = Gamefunc.SelectRandomByMallic()
	print(chosen)
	Gamefunc.PlaceTeams(chosen, false)
	Gamefunc.IncressMallic()
	local map = Gamefunc.ChooseRandomMap()
	local mapClone = Gamefunc.RenderMapSlowly(map)
	
	for i = intermationtime, 0, -1 do
		strings.Value = "Intermission: " .. formattime(i)
		task.wait(1)
	end
	strings.Value = "Starting Game"
	Gamefunc.TeleportPlayersToSpawn(mapClone, chosen)
	for i = gametime, 0, -1 do
		strings.Value = "Round: " .. formattime(i)
		task.wait(1)
	end
	strings.Value = "Starting Game"
	Gamefunc.EndGame()
	Gamefunc.PlaceTeams(chosen, true)
end

return Gamefunc
