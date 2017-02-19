-- usage: lua autocorrect.lua <file>…

function autocorrectmsgstr(msg, msgid, msgstr)
  if msgstr == "" or msgstr == msgid then
    return
  end
  if msg.fuzzy and msgid:find("%%qs") and msgstr:find("»%%s«") then
    msg.msgstr = msg.msgstr:gsub("»%%s«", "%%qs")
  end
  if msg.fuzzy and msgid:find("%%<") and msgstr:find("»") then
    msg.msgstr = msg.msgstr:gsub("»", "%%<"):gsub("«", "%%>")
  end
end

function autocorrectfile(fname)
  local file = require("proofread/po").File:new()
  file:parse(fname)
  for _, msg in ipairs(file.messages) do
    if msg.msgstr ~= nil then
      autocorrectmsgstr(msg, msg.msgid, msg.msgstr)
    end
  end
  file:write(fname)
end

function main(arg)
  for _, fname in ipairs(arg) do
    autocorrectfile(fname)
  end
end

main(arg)
