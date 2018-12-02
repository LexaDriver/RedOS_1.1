local fileList = {}

local filesystem = require("filesystem")
local component = require("component")
local gpu = component.gpu

function fileList.list(path, page)

  local e = 1
  local k = 1
  local j = 1

  local i 
  local files = {}
  local allFiles = {}

  for i in filesystem.list(path) do
    allFiles[e] = i
    e = e + 1
  end

  table.sort(allFiles)

  for i = 1, #allFiles do
    if (k > ((page - 1) * 12)) and (k <= (page * 12)) then
      files[j] = allFiles[i]
      j = j + 1
    end
    k = k + 1
  end  

  for i = 1, 12 do
    if i > #files then break
    else  
      gpu.set(1, 2 + i, files[i])
      if #files[i] > 24 then
        gpu.set(23, i + 2, "..╎            ╎            ")
      end
      if filesystem.isDirectory(path .. files[i]) then
        gpu.set(27, 2 + i, "Folder")
      elseif string.find(files[i], ".lua") then
        gpu.set(27, 2 + i, "Program")
      elseif string.find(files[i], ".txt") then
        gpu.set(27, 2 + i, "Text")
      elseif string.sub(files[i], 1, 1) == "." then
        gpu.set(27, 2 + i, "Protected")
      else
        gpu.set(27, 2 + i, "File")
      end
      gpu.set(40, 2 + i, size(path, files[i]))
    end
  end
  
  return files  

end

function fileList.pages(path)

  local pages
  local i
  local k = 0

  for i in filesystem.list(path) do
    k = k + 1
  end

  pages = k / 12
  pages = math.ceil(pages)  

  return pages  

end

function size(path, item)

  local size = ""  

  if filesystem.isDirectory(path .. item) then
    local i
    local k = 0
    for i in filesystem.list(path .. item) do
      k = k + 1
    end
    if k == 0 then
      size = "Empty"
    else
      size = tostring(k) .. " Items"
    end  
  else
    local byte = filesystem.size(path .. item)
    if byte > 1024 then
      byte = math.ceil(byte / 1024)
      size = byte .. " KBytes"
    elseif (byte < 1024) and (byte > 0) then
      size = byte .. " Bytes"
    else
      size = "Empty"
    end
  end

  return size
end

return fileList