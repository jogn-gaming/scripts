local positionNotes
local client = {}

for i,v in pairs(getconnections(game:GetService("RunService").RenderStepped)) do
    if v.Function then
        positionNotes = debug.getupvalues(v.Function)[5]
        if type(positionNotes) == "function" then
            local t = debug.getupvalue(positionNotes, 4)
            if rawget(t, "appearedNotes") then
                client = t
                break
            end
        end
    end
end

local keyDown = debug.getupvalue(positionNotes, 17)
local keyUp = debug.getupvalue(positionNotes, 18)

local function hit(arrow, isSlider, sliderTime)
    keyDown(arrow.pos)
    if isSlider then
        task.wait(sliderTime)    
    end
    keyUp(arrow.pos)
end

local fenv = getfenv(positionNotes)
setfenv(positionNotes, setmetatable({
    table = setmetatable({
        insert = function(t, v)
            table.insert(t, v)
            
            local song = debug.getupvalue(2, 10)
            
            if t ~= client.appearedNotes and type(v) == "table" and not v.landmine and math.ceil(v.pos / song.keys) == client.player then
                if v.dodge then
                    v.hit = true
                    return
                end
                
                local currentTime = debug.getupvalue(2, 4)
                local noteTime = debug.getstack(2, 6)
                
                task.delay(noteTime - currentTime, hit, v, v.sliderTime ~= nil, v.sliderTime ~= nil and v.sliderTime * (60 / song.bpm) - noteTime)
            end
        end
    }, {__index = getrenv().table})
}, {__index = fenv, __metatable = "The metatable is locked"}))
