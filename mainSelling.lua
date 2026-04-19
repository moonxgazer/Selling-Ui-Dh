local alts = getgenv().alts
local userKey = getgenv().SCRIPT_KEY
local discordInvite = "https://discord.gg/K4PFdUhqUc"
local player = game.Players.LocalPlayer

if userKey == nil then
    setclipboard(discordInvite)
    player:Kick("no key provided, join the discord server for the full script and key: ".. discordInvite.. " (copied to your clipboard)")
    return
end

local Junkie = loadstring(game:HttpGet("https://jnkie.com/sdk/library.lua"))()
Junkie.service = "selling ui"
Junkie.identifier = "1059337" 
Junkie.provider = "selling ui"

local validation = Junkie.check_key(userKey)  

if not validation.valid then
    setclipboard(discordInvite)
    player:Kick("Wrong key, join the server to get key: ".. discordInvite .." (copied to your clipboard)")
    return
end

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local Window = Fluent:CreateWindow({
    Title = "kura selling gui",
    SubTitle = "by kura",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.Backspace -- Used when theres no MinimizeKeybind
})

local Options = Fluent.Options

local Tabs = {
    mainTab = Window:AddTab({ Title = "Main Tab", Icon = "" }),
    autoTpTab = Window:AddTab({ Title = "Auto tp when bounty", Icon = "" }),
    setBountyTab = Window:AddTab({ Title = "Set bounty", Icon = "" }),
    respectTab = Window:AddTab({ Title = "Sell respect", Icon = "" }),
}

local player = game.Players.LocalPlayer
local root = player:WaitForChild("PlayerGui")
local currentChar=0

local bountyAmount = nil

local setBountyOn = nil
local bountyTpTo = nil
local sellRespectTo = nil

player.CharacterAdded:Connect(function ()
    currentChar+=1
end)

function notify(text)
    Fluent:Notify({
        Title = "Kura selling gui",
        Content = text,
        Duration = 5 -- Set to nil to make the notification not disappear
    })
end

function checkPlayer(name,variable)

    local found = false

    for _,v in game.Players:GetChildren() do
        if name:lower() == v.Name:lower() then

            if variable == "bountyTp" then
                bountyTpTo = v

            elseif variable == "setBounty" then
                setBountyOn = v

            elseif variable == "loopTp" then
                sellRespectTo = v

            end          

            found = true
            break

        end
    end

    if not found then

        if variable == "bountyTp" then
            bountyTpTo = nil

        elseif variable == "setBounty" then
            setBountyOn = nil

        elseif variable == "loopTp" then
            sellRespectTo = nil

        end  

    end

end

function autoTpFunction()

    local deathCheck = currentChar
	while task.wait(0.1) do
        player.Character:PivotTo(bountyTpTo.Character:GetPivot() * CFrame.new(0,0,-2))
            
        if deathCheck ~= currentChar or Options.bountyTpToggle.Value == false then
            break
        end
    end

end

local function checkLabel(label)

	local text = label.Text
	local needle = "Lose Weapons for 10"

	if string.find(text, needle, 1, true) and Options.bountyTpToggle.Value == true and bountyTpTo ~= nil then
        autoTpFunction()
	end

end

root.DescendantAdded:Connect(function(descendant)

	if descendant:IsA("TextLabel") then
        checkLabel(descendant)
		descendant:GetPropertyChangedSignal("Text"):Connect(function()
			checkLabel(descendant)
		end)
    end

end)

function setBounty()

    if not setBountyOn then
        notify("Invalid player to set bounty on")
        return

    elseif setBountyOn == player then
        notify("Can't set bounty on yourself")
        return

    elseif not bountyAmount then
        notify("Wrong bounty amount (min 0.065M (65K) and max 5.2M)")
        return
    end


    local args = {
        setBountyOn.Name,
        bountyAmount,
    }

    game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("SetBounty"):InvokeServer(unpack(args))
end

local setBountyDropdown = Tabs.setBountyTab:AddDropdown("setBountyDropdown", {
    Title = "Chose customer from alts",
    Values = alts,
    Multi = false,
    Default = 1,
})

local setBountyInput = Tabs.setBountyTab:AddInput("setBountyInput", {
    Title = "Type the customer's username",
    Default = "",
    Placeholder = "Customer's username",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        checkPlayer(Value,"setBounty")       
    end
})

local bountyAmountInput = Tabs.setBountyTab:AddInput("bountyAmountInput", {
    Title = "Bounty amount (in millions)",
    Default = "",
    Placeholder = "Bounty amount",
    Numeric = true, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)

        Value = tonumber(Value)
        if Value >= 0.065 and Value <= 5.2 then
            Value = Value * 1000000
            bountyAmount = math.ceil(Value/0.65)
        else
            bountyAmount = nil
        end

    end
})

Tabs.setBountyTab:AddButton({
    Title = "Set max amount (5.2 mil)",
    Description = "",
    Callback = function()       
        bountyAmount = 5.2 * 1000000   
        bountyAmount = math.ceil(bountyAmount/0.65)
        notify("Bounty amount set to 5.2M")
    end
})

Tabs.setBountyTab:AddButton({
    Title = "Set bounty",
    Description = "",
    Callback = function()       
        setBounty()       
    end
})

local setBountyToggle = Tabs.setBountyTab:AddToggle("setBountyToggle", {Title = "Automatically set bounty", Default = false })

local sellRespectDropdown = Tabs.respectTab:AddDropdown("sellRespectDropdown", {
    Title = "Chose customer from alts",
    Values = alts,
    Multi = false,
    Default = 1,
})

local sellRespectInput = Tabs.respectTab:AddInput("sellRespectInput", {
    Title = "Type the customer's username",
    Default = "",
    Placeholder = "Customer's username",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        checkPlayer(Value,"loopTp")
    end
})

local sellRespectToggle = Tabs.respectTab:AddToggle("sellRespectToggle", {Title = "Automatically tp", Default = false })

local autoBountyTpDropdown = Tabs.autoTpTab:AddDropdown("autoBountyTpDropdown", {
    Title = "Chose customer from alts",
    Values = alts,
    Multi = false,
    Default = 1,
})

local autoBountyTpInput = Tabs.autoTpTab:AddInput("autoBountyTpInput", {
    Title = "Type the customer's username",
    Default = "",
    Placeholder = "Customer's username",
    Numeric = false, -- Only allows numbers
    Finished = false, -- Only calls callback when you press enter
    Callback = function(Value)
        checkPlayer(Value, "bountyTp")
    end
})

local bountyTpToggle = Tabs.autoTpTab:AddToggle("bountyTpToggle", {Title = "Auto tp", Default = false })

sellRespectDropdown:OnChanged(function(Value)
    if game.Players:FindFirstChild(Value) then
        sellRespectTo = game.Players:FindFirstChild(Value)
    end
end)

autoBountyTpDropdown:OnChanged(function(Value)
    if game.Players:FindFirstChild(Value) then
        bountyTpTo = game.Players:FindFirstChild(Value)
    end
end)

setBountyDropdown:OnChanged(function(Value)
    if game.Players:FindFirstChild(Value) then
        setBountyOn = game.Players:FindFirstChild(Value)
    end
end)

sellRespectToggle:OnChanged(function()

    if Options.sellRespectToggle.Value == true then

        local char = game.Workspace.Players:FindFirstChild(player.Name)
        local humanoid = char.Humanoid

        if not sellRespectTo then 
            notify("Invalid player name")
            Options.sellRespectToggle:SetValue(false)
            return
        elseif sellRespectTo == player then
            notify("Can't tp to yourself")
            Options.sellRespectToggle:SetValue(false)
            return          
        end

        while task.wait(0.1) do

            if Options.sellRespectToggle.Value == false then break end

            if not game.Workspace.Players:FindFirstChild(player.Name) then 
                char = game.Workspace.Players:WaitForChild(player.Name)
                humanoid = char:WaitForChild("Humanoid")
                task.wait(2)
            elseif not char:FindFirstChild("Humanoid") then
                humanoid = char:WaitForChild("Humanoid")
                task.wait(2)
            end

            if humanoid.Health < 40 then continue end

            char:PivotTo(sellRespectTo.Character:GetPivot() * CFrame.new(0,0,-2) )
        end

    end
end)

bountyTpToggle:OnChanged(function()

    if Options.bountyTpToggle.Value == true then

        if not bountyTpTo then 
            notify("Invalid player name")
            Options.bountyTpToggle:SetValue(false)
            return
        elseif bountyTpTo == player then
            notify("Can't tp to yourself")
            Options.bountyTpToggle:SetValue(false)
            return
        end

    end

end)

setBountyToggle:OnChanged(function()

    if Options.setBountyToggle.Value == false then return end

    if not setBountyOn then
        notify("Invalid player to set bounty on")
        Options.setBountyToggle:SetValue(false)
        return

    elseif setBountyOn == player then
        notify("Can't set bounty on yourself")
        Options.setBountyToggle:SetValue(false)
        return

    elseif not bountyAmount then
        notify("Wrong bounty amount (min 0.065M (65K) and max 5.2M)")
        Options.setBountyToggle:SetValue(false)
        return
    end

    while true do
        if Options.setBountyToggle.Value == false then break end
        setBounty()
        task.wait(0.5)
    end

end)

Window:SelectTab(1)