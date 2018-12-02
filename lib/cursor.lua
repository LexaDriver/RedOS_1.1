cursor = {}

local component = require("component")
local gpu = component.gpu

function cursor.fileSelect(files, line)  

  local bufferLine = ""
  local i
  local k

  for i = 1, 50 do
    k = gpu.get(i, line + 2)
    if k == nill then 
      bufferLine = bufferLine .. " "
    else
      bufferLine = bufferLine .. tostring(k)
    end
  end
  
  gpu.setBackground(0xffffff)
  gpu.setForeground(0x000000)
  
  gpu.set(1, line + 2, bufferLine)

  gpu.setBackground(0x000000)
  gpu.setForeground(0xffffff)

  return files[line]

end

function cursor.menuSelect(x1, x2, index)

  local bufferLine = ""
  local i
  local k

  for i = x1, x2 do
    k = gpu.get(i, (index * 2) + 1)
    if k == nill then 
      bufferLine = bufferLine .. " "
    else
      bufferLine = bufferLine .. tostring(k)
    end
  end
  
  gpu.setBackground(0xffffff)
  gpu.setForeground(0x000000)
  
  gpu.set(x1, (index * 2) + 1, bufferLine)

  gpu.setBackground(0x000000)
  gpu.setForeground(0xffffff)

end

function cursor.choice(variant)

  positive = "   Yes   "
  negative = "    No   "

  gpu.setBackground(0xffffff)
  gpu.setForeground(0x000000)

  if variant then

    gpu.set(16, 10, positive)  

  else
    
    gpu.set(26, 10, negative)

  end

  gpu.setBackground(0x000000)
  gpu.setForeground(0xffffff)
  
  if variant then

    gpu.set(26, 10, negative)  

  else
    
    gpu.set(16, 10, positive)

  end


end

return cursor