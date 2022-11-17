-- script by xkid#1299, msg me if you get an error message.
-- do not take ANY of my code without my permission. I most likely will find out if you try to profit off of my code.
-- This has been open sourced for the sole purpose of educating new scripters.

local notify = false
local placeversion = 253

function Notify(title,text,duration, important)
	if notify or important == true then
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = title;Text = text;Duration = duration;})
	end
end

if not readfile or not firesignal then
    Notify("error", "yo exploit is ass https://x.synapse.to/", 30, true)
    return
end

-- detect updates
if game.PlaceVersion ~= placeversion then
    Notify("the game developer might have updated the game!", "(ignore if in pro server) please autofarm with caution.", 30, true)
end

-- vars
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SubmitAnswerRemote = ReplicatedStorage:WaitForChild("SubmitAnswerRemote")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local GameGui = LocalPlayer.PlayerGui:WaitForChild("GameGui")
local textbox = GameGui.AnswerFrame:FindFirstChild("TextBox")
local SubmitButton = GameGui.AnswerFrame:FindFirstChild("SubmitBtn")
local questionFrame = GameGui:FindFirstChild("QuestionFrame")

-- checker
if textbox == nil or SubmitButton == nil or questionFrame == nil then
    Notify("the game developer temporarily patched", "wait for the script to update or smth", 30, true)
    return
end

Notify("Warning", "It is reccomended that you use the script on an alt account!", 10, true)

local finalAnswer = nil
local verifiedAnswer = nil
local currentTheme = nil

local activated = false
local isTyped = false
local delay = 0.1

local AnswersJson = {}

if not pcall(function() readfile('newthemesandanswers.json') end) then
    -- Get config from github
    local json = game:HttpGet('https://raw.githubusercontent.com/notxkid/typeordiescript/main/themesandanswers.json')
    writefile('newthemesandanswers.json', json)
end
AnswersJson = game:GetService('HttpService'):JSONDecode(readfile('newthemesandanswers.json'))

function trim(s)
    return string.match(s,'^()%s*$') and '' or string.match(s,'^%s*(.*%S)')
end

function submitAnswer(theme)
    if verifiedAnswer == nil then verifiedAnswer = '' end
    if finalAnswer == nil then finalAnswer = '' end
    
    repeat wait() until isTyped == true
    firesignal(SubmitButton.MouseButton1Click)
end

-- dumb anticheat bypass lmao
function typeAnswer(answer)
    spawn(function()
        if activated then
            for i = 1, #answer do
                task.wait(0.08)
                textbox.Text = string.sub(answer, 1, i)
            end
            isTyped = true
        end
    end)
end

function getAnswer(theme) -- get answers from file
    for i,v in pairs(AnswersJson.Main) do
        if theme == i then
            return v
        end
    end
    return nil
end

function validate(id)
    if id == -1 then return false end
    local Player = Players:GetPlayerByUserId(id)
    if Player then
        return true
    end
    return false
end

-- Hello game develoepr
ReplicatedStorage.PlayerScoredEvent.OnClientEvent:Connect(function(...)
    local args = {...}
    local userId = args[1]
    local length = args[2]
    local answer = args[3]
    
    if validate(userId) == false or trim(answer) == '' then
        return
    end
    
    if finalAnswer == nil or length >= #finalAnswer then
        finalAnswer = answer
        if verifiedAnswer == nil then
            typeAnswer(finalAnswer)
        end
        if verifiedAnswer ~= nil then
            if finalAnswer ~= verifiedAnswer and #finalAnswer > #verifiedAnswer and finalAnswer ~= '' then
                Notify('answer found.', finalAnswer, 10)
            end
        elseif verifiedAnswer ~= nil and finalAnswer ~= verifiedAnswer and #finalAnswer > #verifiedAnswer and finalAnswer ~= '' then
            Notify('answer found.', finalAnswer, 10)
        end
    end
    
    if currentTheme ~= nil then
        if not AnswersJson.Main[currentTheme] then
            AnswersJson.Main[currentTheme] = answer
        else
            for i,v in pairs(AnswersJson.Main) do
                if currentTheme == i then
                    if #answer > #v then
                        AnswersJson.Main[currentTheme] = answer
                    end
                end
            end
        end
    end
    writefile('newthemesandanswers.json', game:GetService('HttpService'):JSONEncode(AnswersJson))
end)


-- detect when topic changed
ReplicatedStorage.TopicChangedEvent.OnClientEvent:Connect(function(theme, number)
    finalAnswer = nil
    currentTheme = nil
    isTyped = false
    
    repeat wait() until currentTheme ~= nil
    theme = currentTheme
    
    verifiedAnswer = getAnswer(theme)
    if verifiedAnswer ~= nil then
        typeAnswer(verifiedAnswer)
        Notify('instant answer found.', verifiedAnswer, 15)
    end
    
    task.wait(number - delay)
    
    if activated then
        submitAnswer(theme)
    end
end)

-- reset when round starts
ReplicatedStorage.StartRoundEvent.OnClientEvent:Connect(function()
    finalAnswer = nil
    isTyped = false
end)

-- bypass
for i,v in pairs(getconnections(textbox.FocusLost)) do
    v:Disable()
end

textbox.Focused:Connect(function()
    if activated then
        task.wait()
        textbox:ReleaseFocus()
    end
end)

-- Detect text change
questionFrame.TextLabel:GetPropertyChangedSignal("Text"):Connect(function()
    local text = questionFrame:FindFirstChildWhichIsA("TextLabel").Text
    if trim(text) ~= '' then
        currentTheme = trim(text)
    end
end)

-- ui lib stuffs
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("type or die (fixed!)", "Ocean")
local Tab = Window:NewTab("script by xkid")
local Section = Tab:NewSection('Main / Autofarm')

local toggle = Section:NewToggle("auto type / autowin", "automatically type the longest word", function(state)
    activated = state
end)

Section:NewToggle("notify answer", "send a notification telling you the longest found answer", function(state)
    notify = state
end)

Section:NewKeybind("send longest answer", "bro how do you need further help with this.", Enum.KeyCode.Minus, function()
	if currentTheme and isTyped == true then
	    submitAnswer(currentTheme)
	end
end)

Section:NewSlider("end delay", "1 is 100 ms, so 10 = 1 second.", 150, 1, function(s)
    delay = s / 10
end)

-- loop
while wait(10) do
    writefile('newthemesandanswers.json', game:GetService('HttpService'):JSONEncode(AnswersJson))
end
