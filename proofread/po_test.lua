local po = require("po")
local u = require("luaunit")

function test_Message_new()
  local msg = po.Message:new(13)

  u.assertEquals(msg.id, 13)
  u.assertEquals(#msg.comments, 0)
  u.assertEquals(msg.fuzzy, false)
  u.assertEquals(msg.msgid, nil)
  u.assertEquals(msg.msgstr, nil)
  u.assertEquals(msg.raw, "")
end

function test_Message_format()
  local msg = po.Message:new(13)
  msg.msgid = ""

  u.assertEquals(msg:format(), "msgid \"\"\n")

  table.insert(msg.comments, "#,fuzzy")
  msg.msgid = "hello\"\n"
  msg.msgstr = "hallo\"\n"

  u.assertEquals(msg:format(), [[
#,fuzzy
msgid "hello\"\n"
msgstr "hallo\"\n"
]])
end

function test_File_parse()
  local file = po.File:new()

  file:parse({
    "# header comment",
    "msgid \"hello, world\"",
    "msgstr \"Hallo, Welt\"",
  })

  u.assertEquals(#file.messages, 1)
  u.assertEquals(file.messages[1].msgid, "hello, world")
  u.assertEquals(file.messages[1].msgstr, "Hallo, Welt")
end

function test_formatLine()
  local formatLine = po.visibleForTesting.formatLine
  local function assertFormatted(name, value, lines)
    u.assertEquals(formatLine(name, value), table.concat(lines, "\n") .. "\n")
  end

  assertFormatted("msgfmt", "", {[[msgfmt ""]]})
  assertFormatted("msgfmt", "hello", {[[msgfmt "hello"]]})
  assertFormatted("msgfmt", "1\n2", {[[msgfmt ""]], [["1\n"]], [["2"]]})
  assertFormatted("msgfmt", ("901234567 "):rep(10), {[[msgfmt ""]], [["901234567 901234567 901234567 901234567 901234567 901234567 901234567 "]], [["901234567 901234567 901234567 "]]})
end

os.exit(u.LuaUnit.run() == 0)
