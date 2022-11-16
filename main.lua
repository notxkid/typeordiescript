-- script by xkid#1299 :o

local notify = false

function Notify(title,text,duration)
	if notify then
		game:GetService("StarterGui"):SetCore("SendNotification", {Title = title;Text = text;Duration = duration;})
	end
end

if not readfile or not firesignal then
    Notify("error", "yo exploit is ass https://x.synapse.to/", 30)
    return
end

-- vars
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SubmitAnswerRemote = ReplicatedStorage:WaitForChild("SubmitAnswerRemote")
local textbox = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("GameGui").AnswerFrame.TextBox
local SubmitButton = game:GetService("Players").LocalPlayer.PlayerGui:WaitForChild("GameGui").AnswerFrame.SubmitBtn

local finalAnswer = nil
local verifiedAnswer = nil
local currentTheme = nil

local activated = false
local isTyped = false
local delay = 0.1

local AnswersJson = {}

if not pcall(function() readfile('themesandanswers.json') end) then
    -- Get config from github
    local json = game:HttpGet('https://raw.githubusercontent.com/notxkid/typeordiescript/main/themesandanswers.json')
    writefile('themesandanswers.json', json)
end
AnswersJson = game:GetService('HttpService'):JSONDecode(readfile('themesandanswers.json'))

function submitAnswer(theme)
    if verifiedAnswer == nil then verifiedAnswer = '' end
    if finalAnswer == nil then finalAnswer = '' end
    
    repeat wait() until isTyped == true
    firesignal(SubmitButton.MouseButton1Click)
    
    --[[
    
    ill add incorrect answer checking later.
    
    if (#finalAnswer > #verifiedAnswer) then
        repeat wait() until isTyped == true
        local response = SubmitAnswerRemote:InvokeServer(finalAnswer)
        if response == "Incorrect" or response == "RetryIncorrect" then
            SubmitAnswerRemote:InvokeServer(finalAnswer)
            -- incorrect XD
            for i,v in pairs(AnswersJson.Main) do
                if theme == i then
                    table.remove(AnswersJson.Main, i)
                end
            end
        else
            if not AnswersJson.Main[theme] then
                AnswersJson.Main[theme] = finalAnswer
            else
            for i,v in pairs(AnswersJson.Main) do
                    if theme == i then
                        if #finalAnswer > #v then
                            AnswersJson.Main[theme] = finalAnswer
                        end
                    end
                end
            end
        end
    elseif (#verifiedAnswer >= #finalAnswer) then
        repeat wait() until isTyped == true
        local response = SubmitAnswerRemote:InvokeServer(verifiedAnswer)
        if response == "Incorrect" or response == "RetryIncorrect" then
            SubmitAnswerRemote:InvokeServer(verifiedAnswer)
            -- incorrect XD
            for i,v in pairs(AnswersJson.Main) do
                if theme == i then
                    table.remove(AnswersJson.Main, i)
                end
            end
        else
            if not AnswersJson.Main[theme] then
                AnswersJson.Main[theme] = verifiedAnswer
            else
            for i,v in pairs(AnswersJson.Main) do
                    if theme == i then
                        if #verifiedAnswer > #v then
                            AnswersJson.Main[theme] = verifiedAnswer
                        end
                    end
                end
            end
        end
    end
    
    -- save.
    writefile('themesandanswers.json', game:GetService('HttpService'):JSONEncode(AnswersJson))]]
end

-- dumb anticheat bypass lmao
function typeAnswer(answer)
    spawn(function()
        if activated then
            textbox:ReleaseFocus()
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

-- get other players answers (lmao this game is ass)
ReplicatedStorage.PlayerScoredEvent.OnClientEvent:Connect(function(...)
    local args = {...}
    local length = args[2]
    local answer = args[3]
    
    if finalAnswer == nil or length >= #finalAnswer then
        finalAnswer = answer
        if verifiedAnswer == nil then
            typeAnswer(finalAnswer)
        end
        if verifiedAnswer ~= nil then
            if finalAnswer ~= verifiedAnswer and #finalAnswer > #verifiedAnswer then
                Notify('answer found.', finalAnswer, 10)
            end
        elseif verifiedAnswer ~= nil and finalAnswer ~= verifiedAnswer and #finalAnswer > #verifiedAnswer then
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
    writefile('themesandanswers.json', game:GetService('HttpService'):JSONEncode(AnswersJson))
end)


-- detect when topic changed
ReplicatedStorage.TopicChangedEvent.OnClientEvent:Connect(function(theme, number)
    finalAnswer = nil
    isTyped = false
    
    currentTheme = theme
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

-- no more detecting if focus is lost. (xd fuck you anticheat!)
for i,v in pairs(getconnections(textbox.FocusLost)) do
    v:Disable()
end

-- ui lib stuffs
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()
local Window = Library.CreateLib("type or die (FIXED DETECTION)", "Ocean")
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

Section:NewSlider("end delay", "1 is 100 ms, so 10 = 1 second.", 100, 1, function(s)
    delay = s / 10
end)

-- loop
while wait(10) do
    writefile('themesandanswers.json', game:GetService('HttpService'):JSONEncode(AnswersJson))
end
