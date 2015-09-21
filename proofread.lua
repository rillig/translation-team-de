-- usage: lua proofread.lua <file>…

function proofread(msg, id, msgid, msgstr)
  if msgid:find("^[Uu]sage:") and not msgstr:find("^Aufruf:") then
    warn(msg, "usage => Aufruf")
  end
  if msgid:find("^%s") and not msgstr:find("^%s") then
    warn(msg, "leading whitespace")
  end
  if msgid:find("%s$") and not msgstr:find("%s$") then
    warn(msg, "trailing whitespace")
  end
  if msgid:find("failed") and msgstr:find("fehlgeschlagen") then
    warn(msg, "failed => fehlgeschlagen")
  end
  if msgstr:find("kann nicht") then
    warn(msg, "kann nicht")
  end
  if msgid:find("seek") and not msgstr:find("spr[iu]ng") then
    warn(msg, "seek => springen/gesprungen")
  end
  --warn(msg,"test")
end

function warn(msg, warning)
  function color(n) return os.getenv("USERPROFILE") == nil and string.char(0x1B) .. "[" .. n .. "m" or "" end
  function fmtmsg(s) return "\"" .. s:gsub("\\n(.)", "\\n\"\n\"%1") .. "\"" end
  print(color(32) .. "id: " .. msg.id .. color(0))
  print(color(32) .. "msgid: " .. fmtmsg(msg.msgid) .. color(0))
  for k, v in pairs(msg) do
    if k:find("^msgstr") then
      print(k .. ": " .. fmtmsg(msg[k]))
    end
  end
  print(color(33) .. "W: " .. warning .. color(0))
  print("")
end

function poparser(fname)
  local f = io.open(fname)
  local id = 0

  function one()
    local msg = {
      id = id,
      comments = {},
      msgid = "",
      msgstr = "",
    }
    id = id + 1

    local lastcmd

    function parseline(line)
      if line:find("^#") then
        table.insert(msg.comments, line)
        return
      end

      local s, e, cmd, str = line:find("^(%a+%S-) \"(.*)\"$")
      if s then
        lastcmd = cmd
        msg[cmd] = (msg[cmd] or "") .. str
        return
      end

      local s, e, str = line:find("^\"(.*)\"$")
      if s then
        msg[lastcmd] = msg[lastcmd] .. str
      end
    end

    for line in f:lines() do
      if line == "" then return msg end
      parseline(line)
    end
    if msg.msgid ~= "" then return msg end
  end

  return one
end

function proofreadfile(fname)
  for msg in poparser(fname) do
    proofread(msg, msg.id, msg.msgid, msg.msgstr)
  end
end

for _, fname in ipairs(arg) do
  proofreadfile(fname)
end
