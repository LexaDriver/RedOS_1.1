local screenBuffer = {}

local component = require("component")
local gpu = component.gpu
 
  function screenBuffer.load(x1, y1, x2, y2)    
    local i
    local j
    local k = 1
    local bufferArray = {}
    for i = y1, y2 do
      bufferArray[k] = ""
      for j = x1, x2 do
        if gpu.get(j, i) ~= nil then
          bufferArray[k] = bufferArray[k] .. tostring(gpu.get(j, i))
        else
          bufferArray[k] = bufferArray[k] .. " "
        end
      end
      k = k + 1
    end
	
	return bufferArray
  end

  function screenBuffer.draw(x1, y1, bufferArray)
    local i
    for i = 1, #bufferArray do
      gpu.set(x1, y1 + i - 1, bufferArray[i])
    end
  end

return screenBuffer