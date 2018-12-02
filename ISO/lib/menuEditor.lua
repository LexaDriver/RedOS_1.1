local menuEditor = {}

local event = require("event")
local computer = require("computer")

local cursor = require("cursor")
local screenBuffer = require("screenBuffer")

function menuEditor.openMenu()

  local variants = 5

  local index = 5

  local x1 = 1
  local x2 = 12

  cursor.menuSelect(x1, x2, index)

  while true do

    local name, _, _, key, _, _ = event.pull()
    if name == "key_down" then
  
      if key == 28 then
  
        break
               
      elseif key == 200 then
      
        if index > 1 then
          
          buffer = screenBuffer.load(x1, (index * 2) + 1, x2, (index * 2) + 1)
          screenBuffer.draw(x1, (index * 2) + 1, buffer)
          index = index - 1
          cursor.menuSelect(x1, x2, index)

        end
      
      elseif key == 208 then

        if variants > index then

          buffer = screenBuffer.load(x1, (index * 2) + 1, x2, (index * 2) + 1)
          screenBuffer.draw(x1, (index * 2) + 1, buffer)
          index = index + 1 
          cursor.menuSelect(x1, x2, index)
     
        end
      end
    end
  end

  return index

end


return menuEditor