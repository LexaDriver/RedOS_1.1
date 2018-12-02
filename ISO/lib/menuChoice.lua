local menuChoice = {}

local component = require("component")
local shell = require("shell")
local event = require("event")

local gpu = component.gpu 

local cursor = require("cursor")
local screenBuffer = require("screenBuffer")

function menuChoice.AreYouSure(text)

  shell.execute("/RedOS/choice.lua")

  gpu.set(16, 8, text)

  local choice = false
  
  cursor.choice(choice)

  while true do          
    local name, _, _, key, _, _ = event.pull()
    if name == "key_down" then

      if key == 28  then

        break

      elseif key == 205 then

        choice = false
        cursor.choice(choice)        

      elseif key == 203 then

        choice = true
        cursor.choice(choice)

      end
    end
  end

  return choice

end

return menuChoice