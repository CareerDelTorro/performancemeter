--THIS IS WORK AND CODE CREATED BY LERG FOR CORONA SDK/ LUA USE.


local _M = {}
 
local mFloor = math.floor
local sGetInfo = system.getInfo
local sGetTimer = system.getTimer
 
local prevTime = 0
_M.added = true
local readableFpsDelay = 0
local readableFps = 30
local fpsArray = {}

local function createText()
    local memory = display.newText('00 00.00 000',10,0, 'Helvetica', 14);
	--memory:setFillColor(255,53,247)
	memory:setFillColor(0,0,0)
    memory.anchorY = 0
    memory.x, memory.y = display.contentCenterX, display.screenOriginY+25
    function memory:tap ()
        collectgarbage('collect')
        if _M.added then
            Runtime:removeEventListener('enterFrame', _M.labelUpdater)
            _M.added = false
		memory.alpha = .01
        else
            Runtime:addEventListener('enterFrame', _M.labelUpdater)
            _M.added = true
		memory.alpha = 1
        end
    end
    memory:addEventListener('tap', memory)
    return memory
end

local function mean( t )
  local sum = 0
  local count= 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end

function _M.labelUpdater(event)
    local curTime = sGetTimer()
    local curFps = 1000 / (curTime - prevTime)
    if (readableFpsDelay % 30 == 0 and readableFpsDelay ~= 0) then
        readableFps = mean(fpsArray)
        fpsArray = {}
    else 
        table.insert(fpsArray, curFps)
    end
    _M.text.text = 'AvgFPS: ' .. tostring(mFloor(readableFps)) .. 
                   ' | CurFPS: ' .. tostring(mFloor(curFps)) .. 
                   ' | TextureMemory: ' ..
            tostring(mFloor(sGetInfo('textureMemoryUsed') * 0.0001) * 0.01) .. 'MB' .. 
                   ' | LuaMemory: ' ..
            tostring(mFloor(collectgarbage('count'))) .. 'kB'
    _M.text:toFront()
    prevTime = curTime
    readableFpsDelay = readableFpsDelay + 1
end
 
function _M:newPerformanceMeter()
    self.text = createText(self)
    Runtime:addEventListener('enterFrame', _M.labelUpdater)
end
 
return _M
