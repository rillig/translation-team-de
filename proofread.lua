-- usage: lua proofread.lua <file>…

function proofread(msg, id, msgid, msgstr)
  if msgstr == "" or msgstr == msgid or msg.fuzzy then
    return
  end
  if msgid:find("^[Uu]sage:") and not msgstr:find("^Aufruf:") then
    warn(msg, "»usage« sollte mit »Aufruf« übersetzt werden.")
  end
  if msgid:find("^%s") and not msgstr:find("^%s") then
    warn(msg, "Da im englischen Text Leerzeichen am Zeilenanfang sind, sollte das im deutschen Text auch so sein.")
  end
  if msgid:find("%s$") and not msgstr:find("%s$") then
    warn(msg, "Da im englischen Text Leerzeichen am Zeilenende sind, sollte das im deutschen Text auch so sein.")
  end
  if msgid:find("seek") and msgstr:find("[Ss]uch") and not msgstr:find("[Ss]pr[iu]ng") and not msgstr:find("[Ss]eek") then
    warn(msg, "»seek« sollte mit »springen/gesprungen« übersetzt werden. (Nicht mit »suchen«, da das zu viele andere Bedeutungen hat.)")
  end
  if msgstr:find("\"") then
    warn(msg, "Im deutschen Text sollten keine \"geraden\", sondern „diese“ oder »jene« Anführungszeichen benutzt werden.")
  end
  if msgstr:find("%f[%l]the%f[%L]") then
    warn(msg, "»the« gefunden – möglicherweise nicht vollständig übersetzt.")
  end
  --warn(msg,"test")
end

function warn(msg, warning)
  function color(n) return os.getenv("TERM") ~= nil and string.char(0x1B) .. "[" .. n .. "m" or "" end
  function fmtmsg(s) return "\"" .. s:gsub("\\n(.)", "\\n\"\n\"%1") .. "\"" end
  print(color(32) .. "id: " .. msg.id .. color(0))
  for i, comment in ipairs(msg.comments) do
    print(color(37) .. comment .. color(0))
  end
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
      fuzzy = false,
      msgid = "",
      msgstr = "",
    }
    id = id + 1

    local lastcmd

    function parseline(line)
      if line:find("^#") then
        table.insert(msg.comments, line)
        if line:find("^#,.*fuzzy") then
          msg.fuzzy = true
        end
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

function main(arg)
  if os.getenv("USERPROFILE") ~= nil then os.execute("chcp 65001 > nul") end
  for _, fname in ipairs(arg) do
    proofreadfile(fname)
  end
end

main(arg)
