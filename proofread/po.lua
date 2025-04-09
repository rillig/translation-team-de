local function errorf(fmt, ...)
  error(string.format(fmt, ...))
end

local function parseLiteral(str)
  if string.match(str, "^[^\"\\\n]*$") then return str end

  local i, len, result = 1, #str, ""
  while i <= len do
    local ch = str:sub(i, i)
    i = i + 1
    if ch == "\"" or ch == "\n" then
      errorf("illegal character %q in string literal \"%s\"", ch, str)
    end
    if ch == "\\" then
      if i > len then errorf("illegal backslash at end of string %q") end
      local ch = str:sub(i, i)
      i = i + 1
      if ch == "\"" or ch == "\\" or ch == "'" then
        result = result .. ch
      elseif ch == "a" then
        result = result .. "\x07"
      elseif ch == "b" then
        result = result .. "\b"
      elseif ch == "n" then
        result = result .. "\n"
      elseif ch == "r" then
        result = result .. "\r"
      elseif ch == "t" then
        result = result .. "\t"
      elseif ch == "v" then
        result = result .. "\v"
      else
        errorf("invalid escape \\%s in \"%s\"", ch, str)
      end
    else
      result = result .. ch
    end
  end
  return result
end

local function wrap(name, line, force)
  local maxLength = 0x7fffffff
  local result = ""
  local resultLine = ""
  local inEscape = false
  local seenSpace = false
  for i = 1, #line do
    local ch = line:sub(i, i)
    resultLine = resultLine .. ch
    if inEscape and ch == "n" and i ~= #line - 1 then
      result = result .. resultLine .. "\"\n"
      resultLine = "\""
    elseif ch == " " then
      if not seenSpace and (force or #line > maxLength) then
        seenSpace = true
        result = resultLine .. "\"\"\n"
        resultLine = ""
      end
      local nextSpace = #resultLine + (line:find(" ", i + 1, true) or #line + 1) - i
      if nextSpace > maxLength then
        result = result .. resultLine .. "\"\n"
        resultLine = "\""
      end
    end
    inEscape = not inEscape and ch == "\\"
  end
  if resultLine ~= "" then
    result = result .. resultLine
  end
  return result
end

local function formatLine(name, value)
  local subst = {
    ["\x07"] = "\\a",
    ["\b"] = "\\b",
    ["\n"] = "\\n",
    ["\r"] = "\\r",
    ["\t"] = "\\t",
    ["\v"] = "\\v",
    ["\""] = "\\\"",
    ["\\"] = "\\\\",
  }
  local singleLine = name .. " \"" .. value:gsub(".", subst) .. "\""
  return wrap(name, singleLine, value:find("\n.")) .. "\n"
end

local Message = {}
Message.__index = Message

function Message:new(file, id)
  return setmetatable({
    file = file,
    id = id,
    comments = {},
    fuzzy = false,
    msgid = nil,
    msgstr = nil,
    raw = "",
  }, Message)
end

function Message:format()
  local s = ""

  for _, comment in ipairs(self.comments) do
    s = s .. comment .. "\n"
  end

  local function writeIf(name)
    local value = self[name]
    if value ~= nil then
      s = s .. formatLine(name, value)
    end
  end

  writeIf("msgctxt")
  writeIf("msgid")
  writeIf("msgid_plural")
  writeIf("msgstr")
  writeIf("msgstr[0]")
  writeIf("msgstr[1]")
  writeIf("msgstr[2]")
  writeIf("msgstr[3]")
  writeIf("msgstr[4]")
  writeIf("msgstr[5]")
  writeIf("msgstr[6]")

  return s
end

local File = {}
File.__index = File

function File:new()
  return setmetatable({
    messages = {}
  }, File)
end

function File:parse(input)
  local id = 0
  local lastcmd

  local lines
  if type(input) == "string" then
    lines = {}
    for line in io.lines(input) do
      table.insert(lines, line)
    end
  elseif type(input) == "table" then
    lines = input
  else
    error("invalid input type")
  end

  local function parseLine(msg, line)
    if line:find("^#") then
      table.insert(msg.comments, line)
      if line:find("^#,.*fuzzy") then
        msg.fuzzy = true
      end
      if line:find("^#,.*gcc-internal-format") then
        msg.gcc_internal_format = true
      end
      if line:find("^#,.*c-format") then
        msg.c_format = true
      end
      return
    end

    local s, _, cmd, str = line:find("^(%a+%S+) \"(.*)\"$")
    if s then
      lastcmd = cmd
      msg[cmd] = (msg[cmd] or "") .. parseLiteral(str)
      return
    end

    local s, _, str = line:find("^\"(.*)\"$")
    if s then
      msg[lastcmd] = msg[lastcmd] .. parseLiteral(str)
    end
  end

  local lineno = 1
  local function messages()
    local msg = Message:new(input, id)
    id = id + 1

    while lineno <= #lines do
      local line = lines[lineno]
      lineno = lineno + 1
      msg.raw = msg.raw .. line .. "\n"
      if line == "" then return msg end
      parseLine(msg, line)
    end
    if msg.msgid ~= nil or #msg.comments ~= 0 then return msg end
  end

  for message in messages do
    table.insert(self.messages, message)
  end
end

function File:write(filename)
  local f = assert(io.open(filename .. ".tmp", "wb"))
  local separator = ""
  for _, message in ipairs(self.messages) do
    f:write(separator)
    f:write(message:format())
    separator = "\n"
  end
  f:close()
  local oldname = filename .. ".old"
  os.remove(oldname)
  os.rename(filename, oldname)
  os.rename(filename .. ".tmp", filename)
  os.remove(oldname)
end

return {
  File = File,
  Message = Message,
  visibleForTesting = {
    parseLiteral = parseLiteral,
    formatLine = formatLine,
    wrap = wrap,
  },
}
