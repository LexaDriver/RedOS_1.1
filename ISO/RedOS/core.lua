local shell = require("shell")
local term = require("term")
local event = require("event")
local component = require("component")
local computer = require("computer")
local filesystem = require("filesystem")
local computer = require("computer")

local gpu = component.gpu

local screenBuffer = require("screenBuffer")
local fileList = require("fileList")
local cursor = require("cursor")

local menuEditor = require("menuEditor")
local menuSystem = require("menuSystem")
local menuChoice = require("menuChoice")

local menuFolder = require("menuFolder")
local menuFile = require("menuFile")

local specialShell = require("specialShell")

local work = true

local buffer = {}

local path = "/home/"
local files = {}
local tree = {}
local oldIndex = {}
local oldPage = {}
local AllPages = 0
local item
local index = 1
local target
local targetPage
local menu
local page = 1
local oldName

local copyPath = ""
local copyFile = ""
local name
local success
local length = 1

tree[1] = "/"
oldIndex[1] = 6
oldPage[1] = 1
local k = 2
local i = 1

local function pageDraw(path)
  AllPages = fileList.pages(path)
  gpu.set(44, 16, "/ " .. tostring(AllPages))
end

local function position(page)
  local pose = tostring(page)
  gpu.fill(39, 16, 5, 1, " ")
  gpu.set(43 - #pose, 16, pose)
end

local function pathDraw(path)
  gpu.fill(1, 16, 37, 1, " ")
  local reduction = {}
  length = #path
  if length > 19 then
    reduction = filesystem.segments(path)
    path = "/../" .. reduction[#reduction] .. "/"
    length = #reduction[#reduction] + 5
  end
  gpu.set(1, 16, tostring(path))
end

local function itemDraw()
  gpu.fill(length + 1, 16, 37 - length, 1, " ")
  if (#item + length) > 37 then
    buffer = screenBuffer.load(38, 16, 50, 16)
    gpu.set(length + 1, 16, tostring(item))
    screenBuffer.draw(38, 16, buffer)
    gpu.set(36, 16, "..")
  else
    gpu.set(length + 1, 16, tostring(item))
  end
end

local function startUp()
  gpu.setResolution(50, 16)
  shell.execute("/RedOS/workspace.lua")
  shell.execute("/RedOS/info.lua")
  files = fileList.list(path, page)
  if #files > 0 then
    item = cursor.fileSelect(files, index)
  else
    item = ""
  end 
  pathDraw(path)
  itemDraw()
  pageDraw(path)
  position(page)  
end

local function system()
  buffer = screenBuffer.load(38, 2, 50, 10)
  shell.execute("/RedOS/system.lua")
  menu = menuSystem.openMenu()
  screenBuffer.draw(38, 2, buffer) 
  if #files > 0 then
    cursor.fileSelect(files, index)
  end    
  if menu == 1 then
    buffer = screenBuffer.load(15, 5, 35, 11)
    menu = menuChoice.AreYouSure(" Shutdown computer ")
    if menu then
      computer.shutdown(false)
    else
      screenBuffer.draw(15, 5, buffer)
      if #files > 0 then
        cursor.fileSelect(files, index)
      end    
    end  
  elseif menu == 2 then
    buffer = screenBuffer.load(15, 5, 35, 11)
    menu = menuChoice.AreYouSure("  Reboot computer  ")
    if menu then
      computer.shutdown(true)
    else
      screenBuffer.draw(15, 5, buffer)
      if #files > 0 then
        cursor.fileSelect(files, index)
      end    
    end
  elseif menu == 3 then
    buffer = screenBuffer.load(15, 5, 35, 11)
    menu = menuChoice.AreYouSure("  Return to shell  ")
    if menu then
      term.setCursor(1,1)
      term.clear()
      work = false
    else
      screenBuffer.draw(15, 5, buffer)
      if #files > 0 then
        cursor.fileSelect(files, index)
      end
    end        
  end
end

local function editor()
  buffer = screenBuffer.load(1, 2, 14, 12)
  shell.execute("/RedOS/editor.lua")
  menu = menuEditor.openMenu()
  screenBuffer.draw(1, 2, buffer) 
  if #files > 0 then
    cursor.fileSelect(files, index)
  end    
  if menu == 1 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    name, success = specialShell.input("file", path)
    if success then
      os.execute("edit " .. path  .. name)
      startUp()
      buffer = {}  
    end
    screenBuffer.draw(1, 1, buffer)
    if #files > 0 then
      cursor.fileSelect(files, index)
    end    
  elseif menu == 2 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    name, success = specialShell.input("folder", path)
    if success then
      filesystem.makeDirectory(path .. name)
      index = 1
      page = 1
      i = 1
      tree[k] = path
      oldIndex[k] = 13
      oldName = name .. "/"
      k = k + 1
      path = path .. name .. "/"
      startUp()
      buffer = {}  
    end
    screenBuffer.draw(1, 1, buffer)
    if #files > 0 then
      cursor.fileSelect(files, index)
    end    
  elseif menu == 3 then
    gpu.fill(1, 3, 24, 12, " ")
    gpu.set(25, 2 + index, "╎")
    gpu.fill(26, 3, 12, 12, " ")
    gpu.set(38, 2 + index, "╎")
    gpu.fill(39, 3, 12, 12, " ")
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    target, targetPage, success = specialShell.finder(path, files)
    if success then
      index = target
      if page ~= targetPage then
        page = targetPage     
        position(page)
      end
    end    
    screenBuffer.draw(1, 1, buffer)
    files = fileList.list(path, page)
    if #files > 0 then
      item = cursor.fileSelect(files, index)
    end              
  elseif menu == 4 then
    if copyFile == "" then
      buffer = screenBuffer.load(12, 6, 39, 10)
      shell.execute("/RedOS/copy_1.lua")
      while true do
        local name, _, _, key, _, _ = event.pull()
        if name == "key_down" then
          if key == 28 then
            break
          end
        end
      end
      screenBuffer.draw(12, 6, buffer)
      if #files > 0 then
        item = cursor.fileSelect(files, index)
      end 
    elseif filesystem.exists(path .. copyFile) then
      buffer = screenBuffer.load(12, 6, 39, 10)
      shell.execute("/RedOS/copy_2.lua")
      while true do
        local name, _, _, key, _, _ = event.pull()
        if name == "key_down" then
          if key == 28 then
            break
          end
        end
      end
      screenBuffer.draw(12, 6, buffer)
      if #files > 0 then
        item = cursor.fileSelect(files, index)
      end 
    elseif filesystem.isDirectory(copyPath .. copyFile) then
      if string.find(path, copyPath .. copyFile) == nill then   
        shell.execute("/RedOS/copy_3.lua")
        gpu.set(14, 9, copyFile)
        specialShell.folderCopy(path, copyPath, copyFile)
        os.sleep(0.5) 
        copyPath = ""
        copyFile = ""      
        gpu.fill(1, 3, 24, 12, " ")
        gpu.set(25, 2 + index, "╎")
        gpu.fill(26, 3, 12, 12, " ")
        gpu.set(38, 2 + index, "╎")
        gpu.fill(39, 3, 12, 12, " ")
        gpu.fill(25, 6, 1, 5, "╎")
        page = 1
        index = 1
        files = fileList.list(path, page)
        item = cursor.fileSelect(files, index)
        pageDraw(path)
        position(page)
        itemDraw()
      else
        buffer = screenBuffer.load(12, 6, 39, 10)
        shell.execute("/RedOS/copy_4.lua")
        while true do
          local name, _, _, key, _, _ = event.pull()
          if name == "key_down" then
            if key == 28 then
              break
            end
          end
        end
        screenBuffer.draw(12, 6, buffer)
        if #files > 0 then
          item = cursor.fileSelect(files, index)
        end 
      end
    else
      filesystem.copy(copyPath .. copyFile, path .. copyFile)
      copyPath = ""
      copyFile = ""      
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      page = 1
      index = 1
      files = fileList.list(path, page)
      item = cursor.fileSelect(files, index)
      pageDraw(path)
      position(page)
      itemDraw()
    end    
  end
end

local function file()
buffer = screenBuffer.load(19, 2, 31, 14)
  shell.execute("/RedOS/file.lua")
  menu = menuFile.openMenu()
  screenBuffer.draw(19, 2, buffer) 
  if #files > 0 then
    cursor.fileSelect(files, index)
  end    
  if menu == 1 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    os.execute(path .. item)
    os.sleep(2)
    screenBuffer.draw(1, 1, buffer)
    cursor.fileSelect(files, index)    
  elseif menu == 2 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    os.execute("edit " .. path  .. item)
    screenBuffer.draw(1, 1, buffer)
    cursor.fileSelect(files, index)
  elseif menu == 3 then
    copyPath = path
    copyFile = item
  elseif menu == 4 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    name, success = specialShell.input("file", path)
    if success then
      if copyPath .. copyFile == path .. item then
        copyPath = ""
        copyFile = ""
      end
      filesystem.rename(path .. item, path .. name)
      startUp()
      buffer = {}  
    end
    screenBuffer.draw(1, 1, buffer)
    if #files > 0 then
      cursor.fileSelect(files, index)
    end        
  elseif menu == 5 then
    buffer = screenBuffer.load(15, 5, 35, 11)
    menu = menuChoice.AreYouSure("    Delete file    ")
    if menu then
      filesystem.remove(path .. item)
      screenBuffer.draw(15, 5, buffer)
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      page = 1
      index = 1
      files = fileList.list(path, page)
      if #files > 0 then
        item = cursor.fileSelect(files, index)
      else      
        item = ""
      end
      pageDraw(path)
      position(page)
      itemDraw()
    else
      screenBuffer.draw(15, 5, buffer)
      if #files > 0 then
        cursor.fileSelect(files, index)
      end    
    end  
  end
end

local function folder()
  buffer = screenBuffer.load(19, 3, 31, 13)
  shell.execute("/RedOS/folder.lua")
  menu = menuFolder.openMenu()
  screenBuffer.draw(19, 3, buffer) 
  if #files > 0 then
    cursor.fileSelect(files, index)
  end    
  if menu == 1 then
    gpu.fill(1, 3, 24, 12, " ")
    gpu.set(25, 2 + index, "╎")
    gpu.fill(26, 3, 12, 12, " ")
    gpu.set(38, 2 + index, "╎")
    gpu.fill(39, 3, 12, 12, " ")
    tree[k] = path
    oldIndex[k] = index
    oldPage[k] = page 
    path = path .. item
    page = 1
    index = 1
    files = fileList.list(path, page)
    if #files > 0 then
      item = cursor.fileSelect(files, index)
    else
      item = ""
    end
    pathDraw(path)
    itemDraw()
    pageDraw(path)
    position(page)  
    k = k + 1
  elseif menu == 2 then
    copyPath = path
    copyFile = item
  elseif menu == 3 then
    buffer = screenBuffer.load(1, 1, 50, 16)
    term.clear()
    name, success = specialShell.input("folder", path)
    if success then
      filesystem.rename(path .. item, path .. name .. "/")
      startUp()
      buffer = {}  
    end
    screenBuffer.draw(1, 1, buffer)
    if #files > 0 then
      cursor.fileSelect(files, index)
    end     
  elseif menu == 4 then
    buffer = screenBuffer.load(15, 5, 35, 11)
    menu = menuChoice.AreYouSure("   Delete folder   ")
    if menu then
      filesystem.remove(path .. item)
      screenBuffer.draw(15, 5, buffer)
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      page = 1
      index = 1
      files = fileList.list(path, page)
      if #files > 0 then
        item = cursor.fileSelect(files, index)
      else      
        item = ""
      end
      pageDraw(path)
      position(page)
      itemDraw()
    else
      screenBuffer.draw(15, 5, buffer)
      if #files > 0 then
        cursor.fileSelect(files, index)
      end    
    end  
  end
end

startUp()

while work do
  local name, _, _, key, _, _ = event.pull()
  if name == "key_down" then

    if key == 28 then
      
      if (filesystem.isDirectory(path .. item)) and (item ~= "") then
        folder()
      elseif item ~= "" then 
        file()
      end

    elseif key == 2 then
      editor()
    elseif key == 3 then
      system()       
    elseif key == 200 then
      
      if index > 1 then

        buffer = screenBuffer.load(1, index + 2, 50, index + 2)
        screenBuffer.draw(1, index + 2, buffer)        
        index = index - 1
        item = cursor.fileSelect(files, index)
        itemDraw()

      end
      
    elseif key == 208 then

      if #files > index then
      
        buffer = screenBuffer.load(1, index + 2, 50, index + 2)
        screenBuffer.draw(1, index + 2, buffer)        
        index = index + 1
        item = cursor.fileSelect(files, index)
        itemDraw()
        
      end

    elseif (key == 205) and (page < AllPages) then
      
      page = page + 1
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      files = fileList.list(path, page)
      index = 1
      item = cursor.fileSelect(files, index)
      itemDraw()
      position(page)

    elseif (key == 203) and (page > 1) then

      page = page - 1
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      files = fileList.list(path, page)
      index = 1
      item = cursor.fileSelect(files, index)
      itemDraw()
      position(page)

    elseif (key == 14) and (k > 1) then
      
      k = k - 1      
      gpu.fill(1, 3, 24, 12, " ")
      gpu.set(25, 2 + index, "╎")
      gpu.fill(26, 3, 12, 12, " ")
      gpu.set(38, 2 + index, "╎")
      gpu.fill(39, 3, 12, 12, " ")
      path = tree[k]
      if oldIndex[k] == 13 then
        local old = false
        local j = 1
        while old == false do
          for i = 1, 12 do
            files = fileList.list(path, j)
            if files[i] == oldName then
              index = i
              page = j
              old = true
              break
            end
          end
          j = j + 1
        end
      else
        index = oldIndex[k]
        page = oldPage[k]
        files = fileList.list(path, page)
      end
      if #files > 0 then
        item = cursor.fileSelect(files, index)
      end 
      pathDraw(path)
      itemDraw()
      position(page)
      pageDraw(path)  

    end
  end
end

print("Log : RedOS has been closed, returning to shell")