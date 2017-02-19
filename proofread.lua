-- usage: lua proofread.lua <file>…

function proofread(msg, msgid, msgstr)
  if msgstr == "" or msgstr == msgid or msg.fuzzy then
    return
  end
  --[[
  if msgid:find("^[Uu]sage:") and not msgstr:find("^Aufruf:") then
    warn(msg, "»usage« sollte mit »Aufruf« übersetzt werden.", "^%a+")
  end
  if msgid:find("^%s") and not msgstr:find("^%s") then
    warn(msg, "Da im englischen Text Leerzeichen am Zeilenanfang sind, sollte das im deutschen Text auch so sein.")
  end
  if msgid:find("%s$") and not msgstr:find("%s$") then
    warn(msg, "Da im englischen Text Leerzeichen am Zeilenende sind, sollte das im deutschen Text auch so sein.")
  end
  if msgid:find("seek") and msgstr:find("[Ss]uch") and not msgstr:find("[Ss]pr[iu]ng") and not msgstr:find("[Ss]eek") then
    warn(msg, "»seek« sollte mit »springen/gesprungen« übersetzt werden. (Nicht mit »suchen«, da das zu viele andere Bedeutungen hat.)", "[Ss]uch%a*")
  end
  if msgstr:find("\"") then
    warn(msg, "Im deutschen Text sollten keine \"geraden\", sondern „diese“ oder »jene« Anführungszeichen benutzt werden.", "\\\"")
    local corrected = autocorrectQuotes(msgstr)
    if false and corrected ~= msgstr and promptCorrect() then
    end
  end
  if msgstr:find("%f[%l]the%f[%L]") then
    warn(msg, "»the« gefunden – möglicherweise nicht vollständig übersetzt.")
  end--]]
  if not msgid:find("%%[0-9]*[$]*[sdf]") ~= not msgstr:find("%%[0-9]*[$]*[sdf]") then
    warn(msg, "Prozent")
  end
end

local haveColor = os.getenv("TERM") ~= nil

function color(n)
  return haveColor and string.char(0x1B) .. "[" .. n .. "m" or ""
end

function autocorrectQuotes(s)
  return s:gsub("\\\"([%a%%][^\"]*%a)\\\"", "»%1«")
end

function promptCorrect()
  io.write("Korrigieren [j]? ")
  io.flush()
  local answer = io.read("*line")
  if answer == "" then
    io.write("GEHT NOCH NICHT\n")
    return true
  end
end

function highlight(s, n)
  return color(n) .. s .. color(0)
end

function markred(s, redpattern)
  if not redpattern then return s end
  return s:gsub(redpattern, color(31) .. color(4) .. "%1" .. color(0))
end

function warn(msg, warning, redpattern)
  local function fmtmsg(s)
    return "\"" .. s:gsub("\\n(.)", "\\n\"\n\"%1") .. "\""
  end

  print(color(32) .. "file: " .. msg.file .. color(0))
  print(color(32) .. "id: " .. msg.id .. color(0))
  for _, comment in ipairs(msg.comments) do
    print(color(37) .. comment .. color(0))
  end
  print(color(32) .. "msgid: " .. fmtmsg(msg.msgid) .. color(0))
  for k, v in pairs(msg) do
    if k:find("^msgstr") then
      print(k .. ": " .. markred(fmtmsg(msg[k]), redpattern))
    end
  end
  print(color(33) .. "W: " .. warning .. color(0))
  print("")
end

function proofreadfile(fname)
  local file = require("proofread/po").File:new()
  file:parse(fname)
  for _, msg in ipairs(file.messages) do
    if msg.msgstr ~= nil then
      proofread(msg, msg.msgid, msg.msgstr)
    end
  end
  --file:write(fname .. "c")
end

function main(arg)
  if os.getenv("USERPROFILE") ~= nil then os.execute("chcp 65001 > nul") end
  for _, fname in ipairs(arg) do
    proofreadfile(fname)
  end
end

main(arg)
