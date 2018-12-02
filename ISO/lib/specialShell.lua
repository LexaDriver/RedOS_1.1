local specialShell = {}

local term = require("term")
local os = require("os")
local component = require("component")
local filesystem = require("filesystem")

local gpu = component.gpu

function specialShell.finder(path)

  local name = ""
  local success = true
  local index = 0
  local page = 0  

  local allFiles = {}

  local e = 1
  local i = 0
  local j

  term.setCursor(1, 1)
  print(">> Input the name of file or folder")
  print(">> You want to find")
  print("<<")
  term.setCursor(4, 3)
  term.read()

  while (gpu.get(4 + i, 3) ~= " ") and (i < 33) do

    name = name .. tostring(gpu.get(4 + i, 3))

    if i == 32 then  
      
      success = false
      print(">> Error : name is too long")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    if gpu.get(4 + i, 3)  == "#" or
       gpu.get(4 + i, 3)  == "%" or
       gpu.get(4 + i, 3)  == "{" or
       gpu.get(4 + i, 3)  == "}" or 
       gpu.get(4 + i, 3)  == "<" or 
       gpu.get(4 + i, 3)  == ">" or
       gpu.get(4 + i, 3)  == "*" or
       gpu.get(4 + i, 3)  == "?" or 
       gpu.get(4 + i, 3)  == "$" or
       gpu.get(4 + i, 3)  == "!" or
       gpu.get(4 + i, 3)  == "'" or 
       gpu.get(4 + i, 3)  == ":" or
       gpu.get(4 + i, 3)  == "@" or
       gpu.get(4 + i, 3)  == "+" or
       gpu.get(4 + i, 3)  == "`" or
       gpu.get(4 + i, 3)  == "|" or
       gpu.get(4 + i, 3)  == "=" then

      success = false
      print(">> Error : invalid character")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    i = i + 1
    
  end   

  if name == "" then

    success = false
    print(">> Error : empty field")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)
  
  elseif success then

    print(">> Searching")
    os.sleep(1)  
    success = false    

    if filesystem.exists(path .. name) then
    
      for j in filesystem.list(path) do
        allFiles[e] = j
        e = e + 1
      end

      i = 1

      table.sort(allFiles)      
      
      while i <= #allFiles do
        
        if allFiles[i] == name then
          index = i
          success = true          
          print(">> Success")
          os.sleep(1)

          page = index / 12
          page = math.ceil(page)  
          index = index - ((page - 1) * 12)

          break 
        end
      
        i = i + 1

      end   
    end

    if success == false then
      print(">> Failed")
      os.sleep(1)
    end
  end

  return index, page, success

end

function specialShell.input(type, path)

  local name = ""
  local success = true

  local i = 0

  term.setCursor(1, 1)
  print(">> Input name of the " .. type)
  print("<<")
  term.setCursor(4, 2)
  term.read()

  while (gpu.get(4 + i, 2) ~= " ") and (i < 33) do

    name = name .. tostring(gpu.get(4 + i, 2))

    if i == 32 then  
      
      success = false
      print(">> Error : name is too long")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    if gpu.get(4 + i, 2)  == "#" or
       gpu.get(4 + i, 2)  == "%" or
       gpu.get(4 + i, 2)  == "{" or
       gpu.get(4 + i, 2)  == "}" or 
       gpu.get(4 + i, 2)  == "<" or 
       gpu.get(4 + i, 2)  == ">" or
       gpu.get(4 + i, 2)  == "*" or
       gpu.get(4 + i, 2)  == "?" or 
       gpu.get(4 + i, 2)  == "/" or
       gpu.get(4 + i, 2)  == "$" or
       gpu.get(4 + i, 2)  == "!" or
       gpu.get(4 + i, 2)  == "'" or 
       gpu.get(4 + i, 2)  == ":" or
       gpu.get(4 + i, 2)  == "@" or
       gpu.get(4 + i, 2)  == "+" or
       gpu.get(4 + i, 2)  == "`" or
       gpu.get(4 + i, 2)  == "|" or
       gpu.get(4 + i, 2)  == "=" then
    
      success = false
      print(">> Error : invalid character")
      os.sleep(1)
      print(">> Returning to worktable")
      os.sleep(1)
      break

    end

    i = i + 1
    
  end   

  if name == "" then

    success = false
    print(">> Error : empty field")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)

  elseif filesystem.exists(path .. name) == true then

    success = false
    print(">> Error : already exists")
    os.sleep(1)
    print(">> Returning to worktable")
    os.sleep(1)
  
  elseif success then

    print(">> Success")
    os.sleep(1)  
    print(">> Go to " .. type)
    os.sleep(1)

  end

  return name, success

end

function specialShell.folderCopy(toPath, fromPath, folderName)
  filesystem.makeDirectory(toPath ..  folderName)  
 
  local i

  local files = {}

  local j = 1  
  local k = 1

  for i in filesystem.list(fromPath .. folderName) do

    gpu.fill(14, 7, 23, 1, " ")
    
      if k == 1 then
        gpu.set(14, 7, "        Copying        ")
        k = 2    
      elseif k == 2 then
        gpu.set(14, 7, "        Copying .      ")
        k = 3    
      elseif k == 3 then
        gpu.set(14, 7, "        Copying . .    ")
        k = 4
      else
        gpu.set(14, 7, "        Copying . . .  ")
        k = 1
      end

    if #i < 23 then
      gpu.fill(14, 9, 23, 1, " ") 
      gpu.set(14, 9, tostring(i))
    end

    if filesystem.isDirectory(fromPath .. folderName .. i) then
      specialShell.folderCopy(toPath .. folderName, fromPath .. folderName, i)
    else
      filesystem.copy(fromPath .. folderName .. i, toPath .. folderName .. i)  
    end
  end
end

return specialShell