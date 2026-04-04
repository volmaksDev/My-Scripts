local a = debug
local b = debug.sethook
local c = debug.getinfo
local d = debug.traceback
local e = load
local f = loadstring or load
local g = pcall
local h = xpcall
local i = error
local j = type
local k = getmetatable
local l = rawequal
local m = tostring
local n = tonumber
local o = {
    open = function(name, mode)
        return {
            write = function(_, data)
                writefile(name, data)
            end,
            close = function() end
        }
    end
}
local p = os
local q = {}
q.__index = q

local r = {
    OUTPUT_FILE = "output.lua",
    VERBOSE = false,
    MAX_OUTPUT_SIZE = 10 * 1024 * 1024,
    MAX_REPEATED_LINES = 100,
    MAX_DEPTH = 5,
    MAX_TABLE_ITEMS = 100,
    MAX_OPS = 2000000,
    MAX_WHILE_COUNT = 50000,
    TIMEOUT_SECONDS = 17
}

_G.LuraphContinue = function() end

local ExecEnv = {"game";"workspace";"script";"Instance";"Enum";"Vector3";"Vector2";"Vector3int16";"Vector2int16";"UDim";"UDim2";"CFrame";"Color3";"BrickColor";"Ray";"Axes";"Faces";"Region3";"Region3int16";"Rect";"NumberRange";"PhysicalProperties";"cache";"cloneref";"compareinstances";"checkcaller";"clonefunction";"getcallingscript";"getscriptclosure";"hookfunction";"hookmetamethod";"iscclosure";"islclosure";"isexecutorclosure";"loadstring";"newcclosure";"rconsoleclear";"rconsolecreate";"rconsoledestroy";"rconsoleinput";"rconsoleprint";"rconsolesettitle";"crypt";"debug";"readfile";"listfiles";"writefile";"makefolder";"appendfile";"isfile";"isfolder";"delfolder";"delfile";"loadfile";"dofile";"isrbxactive";"mouse1click";"mouse1press";"mouse1release";"mouse2click";"mouse2press";"mouse2release";"mousemoveabs";"mousemoverel";"mousescroll";"fireclickdetector";"getcallbackvalue";"getconnections";"getcustomasset";"gethiddenproperty";"sethiddenproperty";"syn";"gethui";"getinstances";"getnilinstances";"isscriptable";"setscriptable";"setrbxclipboard";"getrawmetatable";"setrawmetatable";"getnamecallmethod";"setnamecallmethod";"isreadonly";"setrawmetatable";"setreadonly";"identifyexecutor";"lz4compress";"lz4decompress";"messagebox";"request";"setclipboard";"setfpscap";"getgc";"getgenv";"getloadedmodules";"getrenv";"getrunningscripts";"getscriptbytecode";"getscripthash";"getscripts";"getsenv";"getthreadidentity";"setthreadidentity";"Drawing";"isrenderobj";"getrenderproperty";"setrenderproperty";"cleardrawcache";"WebSocket";"getfenv";"coroutine";"math";"string";"table";"os";"utf8";"bit32";"buffer";"TweenInfo";"RaycastParams";"OverlapParams";"Random";"ColorSequence";"ColorSequenceKeypoint";"NumberSequenceKeypoint";"NumberSequence";"SharedTable";"shared";"Font";"elapsedTime";"settings";"tick";"time";"typeof";"UserSettings";"version";"warn";"plugin";"shared";"assert";"error";"gcinfo";"getmetatable";"ipairs";"newproxy";"next";"pairs";"pcall";"print";"rawequal";"rawget";"rawlen";"rawset";"require";"select";"setmetatable";"tostring";"unpack";"xpcall";"_G";"_VERSION";"Game";"Workspace";"gethwid";"delay"; "stats"}

local function FindInExecEnv(name)
    if type(name) ~= "string" then return false end
    for _, v in ipairs(ExecEnv) do
        if v == name then return true end
    end
    return false
end

local s = arg and arg[3]
if s then
    print("[*] auto-input key: " .. tostring(s))
end

local t = {
    output = {},
    indent = 0,
    names_used = {},
    registry = {},
    reverse_registry = {},
    variable_types = {},
    parent_map = {},
    property_store = {},
    string_refs = {},
    current_size = 0,
    repetition_count = 0,
    last_emitted_line = nil,
    limit_reached = false,
    pending_iterator = false,
    lar_counter = 0,
    fake_time = 0,
    heartbeat_count = 0,
    op_count = 0,
    link_spy = {},
    cache = {},
    message_out_listeners = {},
    in_message_out = false,
    loop_count = 0,
    logged_links = {},
    last_namecall_method = "HttpGet"
}

local JSON_NIL = {} -- sentinel for explicit nil in property_store

local s = arg[3] or "NoKey"
local u = tonumber(arg[4]) or tonumber(arg[3]) or 123456789
local v = {}

local function w(x)
    if j(x) ~= "table" then
        return false
    end
    local y, z = pcall(function()
        return x[v] == true
    end)
    return y and z
end

local function A(x)
    if j(x) == "number" then
        return x
    end
    if w(x) then
        return rawget(x, "__value") or 0
    end
    return 0
end

local e = loadstring or load
local B = print
local C = warn or function() end
local D = pairs
local E = ipairs
local D = pairs
local E = ipairs
local F = {}

local function at(O, au)
    if t.limit_reached or t.silent_mode then
        return
    end
    if O == nil then
        return
    end
    local av = au and "" or string.rep("    ", t.indent)
    local aw = av .. m(O)
    local ax = #aw + 1
    if t.current_size + ax > r.MAX_OUTPUT_SIZE then
        t.limit_reached = true
        local ay = "-- [CRITICAL] Dump stopped: File size exceeded 100MB limit."
        table.insert(t.output, ay)
        t.current_size = t.current_size + #ay
        error("DUMP_LIMIT_EXCEEDED")
    end
    if aw == t.last_emitted_line then
        t.repetition_count = t.repetition_count + 1
        if t.repetition_count <= r.MAX_REPEATED_LINES then
            table.insert(t.output, aw)
            t.current_size = t.current_size + ax
        elseif t.repetition_count == r.MAX_REPEATED_LINES + 1 then
            local ay = av .. "-- [Repeated lines suppressed...]"
            table.insert(t.output, ay)
            t.current_size = t.current_size + #ay
        end
    else
        t.last_emitted_line = aw
        t.repetition_count = 0
        table.insert(t.output, aw)
        t.current_size = t.current_size + ax
    end
    if r.VERBOSE and t.repetition_count <= 1 then
        B(aw)
    end
end

local function az(O)
    at("-- " .. m(O or ""))
end

local function _log_link(url, from, method)
    if not url or #url < 5 then return end
    
    -- Normalize for deduplication: check without protocol
    local clean_url = url:gsub("^https?://", ""):gsub("^www%.", "")
    if t.logged_links[clean_url] then return end
    t.logged_links[clean_url] = true
    
    table.insert(t.link_spy, {url = url, method = method or "LinkSpy", from = from or "unknown"})
    B("[!] link found (" .. (from or "?") .. "): " .. url)
end

local function sniff(source, methodHint)
    if not source or type(source) ~= "string" then return end
    if #source < 4 then return end
    -- Full URLs (http/https)
    for url in source:gmatch('https?://[%w%-_%.%~%:%/%?#%[%]@!%$%&\'%(%)%*%+,;%%=]+') do
        _log_link(url, methodHint)
    end
    -- discord.gg/xxx (without https)
    for code in source:gmatch('discord%.gg/([%w%-_]+)') do
        _log_link("https://discord.gg/" .. code, methodHint)
    end
    -- discord.com/invite/xxx
    for code in source:gmatch('discord%.com/invite/([%w%-_]+)') do
        _log_link("https://discord.gg/" .. code, methodHint)
    end
    -- dsc.gg/xxx
    for code in source:gmatch('dsc%.gg/([%w%-_]+)') do
        _log_link("https://dsc.gg/" .. code, methodHint)
    end
    -- Discord webhook URLs
    for url in source:gmatch('discord%.com/api/webhooks/[%w%-_/]+') do
        _log_link("https://" .. url, methodHint, "Webhook")
    end
    for url in source:gmatch('discordapp%.com/api/webhooks/[%w%-_/]+') do
        _log_link("https://" .. url, methodHint, "Webhook")
    end
    -- Pastebin raw
    for code in source:gmatch('pastebin%.com/raw/([%w]+)') do
        _log_link("https://pastebin.com/raw/" .. code, methodHint)
    end
    -- General domains (simple domain detection)
    for domain in source:gmatch('([%w%-_%.]+%.%a%a+)') do
        if not domain:match("^%d+%.%d+%.%d+%.%d+$") then -- avoid IPs
             -- Noise reduction: filter out common Roblox/Lua property patterns
             local first_part = domain:match("^([^%.]+)")
             local blacklist = {
                 game = true, workspace = true, script = true, Instance = true,
                 Drawing = true, Enum = true, task = true, math = true,
                 table = true, string = true, debug = true, os = true,
                 coroutine = true, Vector3 = true, Vector2 = true, CFrame = true,
                 Color3 = true, UDim2 = true, UDim = true, Ray = true,
                 BrickColor = true, Region3 = true, Axes = true, Faces = true
             }
             if not blacklist[first_part] then
                 _log_link("http://" .. domain, methodHint, "Domain")
             end
        end
    end
end

local function G(x)
    if j(x) ~= "table" then
        return false
    end
    local y, z = pcall(function()
        return rawget(x, F) == true
    end)
    return y and z
end

local function H(x)
    if not G(x) then
        return nil
    end
    return rawget(x, "__proxy_id")
end

local function I(J)
    if j(J) ~= "string" then
        return '"'
    end
    local K = {}
    local L, M = 1, #J
    local function N(O)
        O = O:gsub("\\z%s*", "")
        local res = ""
        local i = 1
        while i <= #O do
            local c = O:sub(i, i)
            if c == "\\" then
                if i + 1 > #O then res = res .. "\\" break end
                local next_c = O:sub(i + 1, i + 1)
                if next_c == "x" then
                    local hex = O:match("^x%x%x", i + 1)
                    if hex then
                        res = res .. "\\" .. hex
                        i = i + 1 + #hex
                    else
                        res = res .. "\\"
                        i = i + 1
                    end
                elseif next_c == "u" and O:sub(i + 2, i + 2) == "{" then
                    local closing = O:find("}", i + 3, true)
                    if closing then
                        res = res .. O:sub(i, closing)
                        i = closing + 1
                    else
                        res = res .. "\\"
                        i = i + 1
                    end
                elseif next_c:match("%d") then
                    local digits = O:match("^%d%d?%d?", i + 1)
                    res = res .. "\\" .. digits
                    i = i + 1 + #digits
                elseif next_c:match("[abfnrtv\\\"'%[%]]") then
                    res = res .. "\\" .. next_c
                    i = i + 2
                else
                    res = res .. next_c
                    i = i + 2
                end
            else
                res = res .. c
                i = i + 1
            end
        end
        return res
    end
    local function Q(R)
        if not R or R == '"' then
            return ""
        end
        -- Binary literal conversion
        R = R:gsub("0[bB]([01_]+)", function(S)
            local T = S:gsub("_", "")
            local U = n(T, 2)
            return U and m(U) or "0"
        end)
        -- Hex underscore cleanup
        R = R:gsub("0[xX]([%x_]+)", function(S)
            local T = S:gsub("_", "")
            return "0x" .. T
        end)
        -- Numeric underscore cleanup
        while R:match("%d_+%d") do
            R = R:gsub("(%d)_+(%d)", "%1%2")
        end
        -- Compound assignment conversion (Luau -> Lua 5.1)
        local V = {{"+=", "+"}, {"-=", "-"}, {"*=", "*"}, {"/=", "/"}, {"%=", "%"}, {"^=", "^"}, {"..=", ".."}}
        for W, X in ipairs(V) do
            local Y, Z = X[1], X[2]
            local escaped_Y = Y:gsub("([%^%$%%%.%*%+%-?%[%]])", "%%%1")
            R = R:gsub("([%a_][%w_]*)%s*" .. escaped_Y, function(_)
                return _ .. " = " .. _ .. " " .. Z .. " "
            end)
            R = R:gsub("([%a_][%w_]*%.[%a_][%w_%.]+)%s*" .. escaped_Y, function(_)
                return _ .. " = " .. _ .. " " .. Z .. " "
            end)
            R = R:gsub("([%a_][%w_]*%b[])%s*" .. escaped_Y, function(_)
                return _ .. " = " .. _ .. " " .. Z .. " "
            end)
        end
        -- Integer division conversion (Luau // -> math.floor())
        -- Handle: expr // expr  ->  math.floor(expr / expr)
        -- Simple cases: var // var, var // number, etc.
        R = R:gsub("([%a_][%w_%[%]\"\\%.%(%)]-)%s*//%s*([%a_][%w_%[%]\"\\%.%(%)]-)", function(lhs, rhs)
            return "math.floor(" .. lhs .. " / " .. rhs .. ")"
        end)
        -- continue keyword conversion
        R = R:gsub("([^%w_])continue([^%w_])", "%1_G.LuraphContinue()%2")
        R = R:gsub("^continue([^%w_])", "_G.LuraphContinue()%1")
        R = R:gsub("([^%w_])continue$", "%1_G.LuraphContinue()")
        return R
    end
    local function a0(a1)
        local a2 = 0
        while a1 <= M and J:byte(a1) == 61 do
            a2 = a2 + 1
            a1 = a1 + 1
        end
        return a2, a1
    end
    local function a3(a4, a5)
        local a6 = "]" .. string.rep("=", a5) .. "]"
        local a7, a8 = J:find(a6, a4, true)
        return a8 or M
    end
    local a9 = 1
    while L <= M do
        local aa = J:byte(L)
        if aa == 91 then
            local a5, ab = a0(L + 1)
            if ab <= M and J:byte(ab) == 91 then
                table.insert(K, Q(J:sub(a9, L - 1)))
                local ac = L
                local ad = a3(ab + 1, a5)
                table.insert(K, J:sub(ac, ad))
                L = ad
                a9 = L + 1
            end
        elseif aa == 45 and L + 1 <= M and J:byte(L + 1) == 45 then
            table.insert(K, Q(J:sub(a9, L - 1)))
            local ae = L
            local is_block = false
            if L + 2 <= M and J:byte(L + 2) == 91 then
                local a5, ab = a0(L + 3)
                if ab <= M and J:byte(ab) == 91 then
                    local ad = a3(ab + 1, a5)
                    table.insert(K, J:sub(ae, ad))
                    L = ad
                    a9 = L + 1
                    is_block = true
                end
            end
            if not is_block then
                local af = J:find("\n", L + 2, true)
                if af then
                    L = af
                else
                    L = M
                end
                table.insert(K, J:sub(ae, L))
                a9 = L + 1
            end
        elseif aa == 34 or aa == 39 or aa == 96 then
            table.insert(K, Q(J:sub(a9, L - 1)))
            local ag = aa
            local ac = L
            L = L + 1
            while L <= M do
                local ah = J:byte(L)
                if ah == 92 then
                    L = L + 1
                elseif ah == ag then
                    break
                end
                L = L + 1
            end
            local ai = J:sub(ac + 1, L - 1)
            ai = N(ai)
            if ag == 96 then
                table.insert(K, '"' .. ai:gsub('"', '\\"') .. '"')
            else
                local aj = string.char(ag)
                table.insert(K, aj .. ai .. aj)
            end
            a9 = L + 1
        end
        L = L + 1
    end
    table.insert(K, Q(J:sub(a9)))
    local result = table.concat(K)
    
    -- Protect string literals and comments from post-processing regexes
    -- Uses proper parsing (not regex) to handle long strings with matching = counts
    local protected = {}
    local pcount = 0
    local function make_placeholder()
        pcount = pcount + 1
        -- Use ASCII chars unlikely to appear in code as delimiter
        return "\0P" .. pcount .. "\0"
    end
    
    local out_parts = {}
    local ri = 1
    local rlen = #result
    while ri <= rlen do
        local ch = result:byte(ri)
        if ch == 91 then -- '['
            -- Check for long string [=*[
            local eq_count = 0
            local scan = ri + 1
            while scan <= rlen and result:byte(scan) == 61 do -- '='
                eq_count = eq_count + 1
                scan = scan + 1
            end
            if scan <= rlen and result:byte(scan) == 91 then -- second '['
                -- Found long string opener [=*[, find matching ]=*]
                local closer = "]" .. string.rep("=", eq_count) .. "]"
                local close_pos = result:find(closer, scan + 1, true)
                if close_pos then
                    local long_str = result:sub(ri, close_pos + #closer - 1)
                    local ph = make_placeholder()
                    protected[ph] = long_str
                    table.insert(out_parts, ph)
                    ri = close_pos + #closer
                else
                    -- No matching closer, treat as regular code
                    table.insert(out_parts, result:sub(ri, ri))
                    ri = ri + 1
                end
            else
                table.insert(out_parts, result:sub(ri, ri))
                ri = ri + 1
            end
        elseif ch == 34 or ch == 39 then -- '"' or "'"
            -- Short string: find matching unescaped quote
            local quote = ch
            local start = ri
            ri = ri + 1
            while ri <= rlen do
                local c = result:byte(ri)
                if c == 92 then -- backslash
                    ri = ri + 1 -- skip escaped char
                elseif c == quote then
                    break
                end
                ri = ri + 1
            end
            local short_str = result:sub(start, ri)
            local ph = make_placeholder()
            protected[ph] = short_str
            table.insert(out_parts, ph)
            ri = ri + 1
        elseif ch == 45 and ri + 1 <= rlen and result:byte(ri + 1) == 45 then -- '--'
            -- Comment: check for block comment or line comment
            if ri + 2 <= rlen and result:byte(ri + 2) == 91 then
                -- Possible block comment --[=*[
                local eq_count = 0
                local scan = ri + 3
                while scan <= rlen and result:byte(scan) == 61 do
                    eq_count = eq_count + 1
                    scan = scan + 1
                end
                if scan <= rlen and result:byte(scan) == 91 then
                    local closer = "]" .. string.rep("=", eq_count) .. "]"
                    local close_pos = result:find(closer, scan + 1, true)
                    if close_pos then
                        local block_comment = result:sub(ri, close_pos + #closer - 1)
                        local ph = make_placeholder()
                        protected[ph] = block_comment
                        table.insert(out_parts, ph)
                        ri = close_pos + #closer
                    else
                        table.insert(out_parts, result:sub(ri, ri))
                        ri = ri + 1
                    end
                else
                    -- Line comment
                    local eol = result:find("\n", ri + 2, true)
                    local comment_end = eol and eol - 1 or rlen
                    local line_comment = result:sub(ri, comment_end)
                    local ph = make_placeholder()
                    protected[ph] = line_comment
                    table.insert(out_parts, ph)
                    ri = comment_end + 1
                end
            else
                -- Line comment
                local eol = result:find("\n", ri + 2, true)
                local comment_end = eol and eol - 1 or rlen
                local line_comment = result:sub(ri, comment_end)
                local ph = make_placeholder()
                protected[ph] = line_comment
                table.insert(out_parts, ph)
                ri = comment_end + 1
            end
        else
            table.insert(out_parts, result:sub(ri, ri))
            ri = ri + 1
        end
    end
    result = table.concat(out_parts)
    
    -- Robust compound assignment conversion using backwards-scan for complex LHS
    local function convert_compound_assignments(code)
        local compound_ops = {{"..=", ".."}, {"+=", "+"}, {"-=", "-"}, {"*=", "*"}, {"/=", "/"}, {"%%=", "%%"}, {"^=", "^"}, {"//=", "//"}}
        for _, op in ipairs(compound_ops) do
            local assign_op, base_op = op[1], op[2]
            local search_pos = 1
            while true do
                local i = code:find(assign_op, search_pos, true)
                if not i then break end
                -- Make sure this isn't inside a string (simplified: check for odd number of quotes)
                -- Skip if preceded by another operator char (like ==, ~=, <=, >=)
                local prev_char = (i > 1) and code:sub(i-1, i-1) or ""
                if prev_char == "=" or prev_char == "~" or prev_char == "<" or prev_char == ">" then
                    search_pos = i + #assign_op
                else
                    -- Find the LHS by scanning backwards from position i-1
                    local lhs_end = i - 1
                    -- Skip any whitespace
                    while lhs_end >= 1 and code:sub(lhs_end, lhs_end):match("%s") do
                        lhs_end = lhs_end - 1
                    end
                    local lhs_start = lhs_end
                    local last_char = code:sub(lhs_end, lhs_end)
                    if last_char == "]" then
                        -- Scan backwards for balanced brackets
                        local bracket_count = 0
                        for j = lhs_end, 1, -1 do
                            local c = code:sub(j, j)
                            if c == "]" then bracket_count = bracket_count + 1
                            elseif c == "[" then bracket_count = bracket_count - 1 end
                            if bracket_count == 0 then
                                lhs_start = j
                                break
                            end
                        end
                        -- Check for prefix before [: could be identifier, ), or another ]
                        if lhs_start > 1 then
                            local prefix_end = lhs_start - 1
                            local prefix_char = code:sub(prefix_end, prefix_end)
                            if prefix_char == ")" then
                                -- Scan backwards for balanced parentheses
                                local paren_count = 0
                                for j = prefix_end, 1, -1 do
                                    local c = code:sub(j, j)
                                    if c == ")" then paren_count = paren_count + 1
                                    elseif c == "(" then paren_count = paren_count - 1 end
                                    if paren_count == 0 then
                                        lhs_start = j
                                        break
                                    end
                                end
                            elseif prefix_char == "]" then
                                -- Another bracket index, scan backwards again
                                local br2 = 0
                                for j = prefix_end, 1, -1 do
                                    local c = code:sub(j, j)
                                    if c == "]" then br2 = br2 + 1
                                    elseif c == "[" then br2 = br2 - 1 end
                                    if br2 == 0 then
                                        lhs_start = j
                                        break
                                    end
                                end
                            end
                            -- Include any identifier prefix
                            while lhs_start > 1 and code:sub(lhs_start-1, lhs_start-1):match("[%w_%.]") do
                                lhs_start = lhs_start - 1
                            end
                        end
                    elseif last_char:match("[%w_]") then
                        -- Simple identifier, scan backwards
                        while lhs_start > 1 and code:sub(lhs_start-1, lhs_start-1):match("[%w_%.]") do
                            lhs_start = lhs_start - 1
                        end
                    else
                        -- Can't determine LHS, skip
                        search_pos = i + #assign_op
                        lhs_start = nil -- signal to skip
                    end
                    if lhs_start then
                    local lhs = code:sub(lhs_start, lhs_end)
                    if #lhs > 0 then
                        code = code:sub(1, lhs_start - 1) .. lhs .. " = " .. lhs .. " " .. base_op .. " " .. code:sub(i + #assign_op)
                        search_pos = lhs_start + #lhs * 2 + #base_op + 6
                    else
                        search_pos = i + #assign_op
                    end
                    end
                end
            end
        end
        return code
    end
    result = convert_compound_assignments(result)
    -- Remove Luau type casts and annotations (Luau -> Lua 5.1)
    -- First, protect method calls (:identifier() from being treated as type annotations
    local method_placeholders = {}
    local mcount = 0
    result = result:gsub("(:%s*[%a_][%w_]*)(%s*%()", function(colon_id, paren)
        mcount = mcount + 1
        local mph = "\0M" .. mcount .. "\0"
        method_placeholders[mph] = colon_id .. paren
        return mph
    end)
    -- 1. Remove type casts: expr :: type
    result = result:gsub("::%s*[%a_][%w_%.%s]*", "")
    -- 2. Remove return type annotations: function(...) : type
    result = result:gsub("(%)%s*):%s*([%a_][%w_]*)", "%1")
    -- 3. Remove variable/parameter annotations: identifier : type
    -- Target :type followed by =, ,, ), }, do, in, then
    result = result:gsub("(:%s*[%a_][%w_]*)%s*([=,%)%}])", "%2")
    result = result:gsub("(:%s*[%a_][%w_]*)%s+(do%f[%W])", " %2")
    result = result:gsub("(:%s*[%a_][%w_]*)%s+(in%f[%W])", " %2")
    result = result:gsub("(:%s*[%a_][%w_]*)%s+(then%f[%W])", " %2")
    -- Restore protected method calls
    for mph, original in pairs(method_placeholders) do
        local pos = result:find(mph, 1, true)
        if pos then
            result = result:sub(1, pos - 1) .. original .. result:sub(pos + #mph)
        end
    end

    -- Integer division conversion: a // b -> math.floor(a / b)
    result = result:gsub("([%w_%)%]\"]+)%s*//%s*([%w_%(\"]+)", function(lhs, rhs)
        return "math.floor(" .. lhs .. " / " .. rhs .. ")"
    end)
    --typeof() -> type() for Lua 5.1
    result = result:gsub("typeof%(", "type(")

    -- Inject CHECKWHILE into loops (Anti-loop protection)
    -- result = result:gsub("(%f[%w_])while(%s+.-%s+)do(%f[%W])", "%1while CHECKWHILE(%2) do%3")
    -- result = result:gsub("(%f[%w_])until(%s+)(.-)(%s*[%c;]*)", "%1until CHECKWHILE(%3)%2%4")

    -- Luau generalized iteration: for k,v in tbl do -> for k,v in pairs(tbl) do
    -- Must handle: "for q,q in Z.HR(q)do" (function call, already OK)
    --              "for q,n in p do" (bare variable, needs pairs())
    --              "for q,n in A do" (bare variable, needs pairs())
    -- Strategy: find all "for...in EXPR do" where EXPR is a bare identifier (not a function call)
    -- Use %s* before do to handle both spaced and unspaced variants
    result = result:gsub("(for%s+[%w_,%s]+%s+in%s+)([%a_][%w_]*)(%s*do[^%w_])", function(prefix, expr, suffix)
        if expr == "pairs" or expr == "ipairs" or expr == "next" then
            return prefix .. expr .. suffix
        end
        -- Check if this is actually part of a longer expression (like a function call Z.HR(...))
        -- by looking at the character after the match — but we already matched up to "do"
        -- so expr is just the bare identifier before "do"
        return prefix .. "pairs(" .. expr .. ")" .. suffix
    end)
    
    -- Restore protected strings and comments using plain string find (no regex)
    for ph, original in pairs(protected) do
        local pos = result:find(ph, 1, true)
        if pos then
            result = result:sub(1, pos - 1) .. original .. result:sub(pos + #ph)
        end
    end
    
    return result
end

local function ak(al, am)
    local R, an = e(al, am)
    if R then
        return R
    end
    B("\n[CRITICAL ERROR] Failed to load script!")
    B("[LUA_LOAD_FAIL] " .. m(an))
    local ao = tonumber(an:match(":(%d+):"))
    local ap = an:match("near '([^']+)'")
    if ap then
        local a1 = al:find(ap, 1, true)
        if a1 then
            local aq = math.max(1, a1 - 50)
            local ar = math.min(#al, a1 + 50)
            B("Context around error:")
            B("..." .. al:sub(aq, ar) .. "...")
        end
    end
    local as = o.open("DEBUG_FAILED_TRANSPILE.lua", "w")
    if as then
        as:write(al)
        as:close()
        B("[*] Saved to 'DEBUG_FAILED_TRANSPILE.lua' for inspection")
    end
    return nil, an
end


local function aA()
    t.last_emitted_line = nil
    table.insert(t.output, "")
end

local function aB()
    return table.concat(t.output, "\n")
end

local function aC(aD)
    writefile(aD or "output.lua", aB())
    return true
end

local function aE(aF)
    if aF == nil then
        return "nil"
    end
    if j(aF) == "string" then
        return aF
    end
    if j(aF) == "number" or j(aF) == "boolean" then
        return m(aF)
    end
    if j(aF) == "table" then
        if t.registry[aF] then
            return t.registry[aF]
        end
        if G(aF) then
            local aG = H(aF)
            return aG and "proxy_" .. aG or "proxy"
        end
    end
    local y, O = pcall(m, aF)
    return y and O or "unknown"
end

local function aH(aF)
    local O = aE(aF)
    if type(O) ~= "string" then O = tostring(O) end
    local aI = O:gsub("\\", "\\\\")
    aI = aI:gsub("[\n\b\t\v\f\"\r]", {
        ["\n"] = "\\n", ["\b"] = "\\b", ["\t"] = "\\t", ["\v"] = "\\v", ["\f"] = "\\f", ["\""] = "\\\"", ["\r"] = "\\r"
    })
    return '"' .. aI .. '"'
end

local aJ = {
    Players = "Players",
    Workspace = "Workspace",
    ReplicatedStorage = "ReplicatedStorage",
    ServerStorage = "ServerStorage",
    ServerScriptService = "ServerScriptService",
    StarterGui = "StarterGui",
    StarterPack = "StarterPack",
    StarterPlayer = "StarterPlayer",
    Lighting = "Lighting",
    SoundService = "SoundService",
    Chat = "Chat",
    RunService = "RunService",
    UserInputService = "UserInputService",
    TweenService = "TweenService",
    HttpService = "HttpService",
    MarketplaceService = "MarketplaceService",
    TeleportService = "TeleportService",
    PathfindingService = "PathfindingService",
    CollectionService = "CollectionService",
    PhysicsService = "PhysicsService",
    ProximityPromptService = "ProximityPromptService",
    ContextActionService = "ContextActionService",
    GuiService = "GuiService",
    HapticService = "HapticService",
    VRService = "VRService",
    CoreGui = "CoreGui",
    Teams = "Teams",
    InsertService = "InsertService",
    DataStoreService = "DataStoreService",
    MessagingService = "MessagingService",
    TextService = "TextService",
    TextChatService = "TextChatService",
    ContentProvider = "ContentProvider",
    Debris = "Debris"
}

local aK = {
    -- Services & Roblox Core
    Players = "Players", UserInputService = "UserInputService", RunService = "RunService",
    ReplicatedStorage = "ReplicatedStorage", TweenService = "TweenService", Workspace = "Workspace",
    Lighting = "Lighting", StarterGui = "StarterGui", CoreGui = "CoreGui", HttpService = "HttpService",
    MarketplaceService = "MarketplaceService", DataStoreService = "DataStoreService", TeleportService = "TeleportService",
    SoundService = "SoundService", Chat = "Chat", Teams = "Teams", ProximityPromptService = "ProximityPromptService",
    ContextActionService = "ContextActionService", CollectionService = "CollectionService", PathfindingService = "PathfindingService",
    Debris = "Debris", game = "game", workspace = "workspace", script = "script", Instance = "Instance", Enum = "Enum",
    Vector3 = "Vector3", Vector2 = "Vector2", Vector3int16 = "Vector3int16", Vector2int16 = "Vector2int16", 
    UDim = "UDim", UDim2 = "UDim2", CFrame = "CFrame", Color3 = "Color3", BrickColor = "BrickColor", Ray = "Ray",
    Axes = "Axes", Faces = "Faces", Region3 = "Region3", Region3int16 = "Region3int16", Rect = "Rect",
    NumberRange = "NumberRange", PhysicalProperties = "PhysicalProperties", TweenInfo = "TweenInfo",
    RaycastParams = "RaycastParams", OverlapParams = "OverlapParams", Random = "Random",
    ColorSequence = "ColorSequence", ColorSequenceKeypoint = "ColorSequenceKeypoint", 
    NumberSequenceKeypoint = "NumberSequenceKeypoint", NumberSequence = "NumberSequence", 
    SharedTable = "SharedTable", Font = "Font", elapsedTime = "elapsedTime", settings = "settings",
    tick = "tick", time = "time", typeof = "typeof", UserSettings = "UserSettings", version = "version",
    warn = "warn", plugin = "plugin", delay = "delay", Game = "Game",

    -- Lua Core Libraries & Functions
    math = "math", string = "string", table = "table", os = "os", coroutine = "coroutine",
    utf8 = "utf8", bit32 = "bit32", buffer = "buffer", shared = "shared", assert = "assert",
    error = "error", gcinfo = "gcinfo", getmetatable = "getmetatable", ipairs = "ipairs",
    newproxy = "newproxy", next = "next", pairs = "pairs", pcall = "pcall", print = "print",
    rawequal = "rawequal", rawget = "rawget", rawlen = "rawlen", rawset = "rawset", require = "require",
    select = "select", setmetatable = "setmetatable", tostring = "tostring", unpack = "unpack",
    xpcall = "xpcall", _G = "_G", _VERSION = "_VERSION",

    -- Executor Environment / Hooks
    getgenv = "getgenv", getrenv = "getrenv", getreg = "getreg", getgc = "getgc",
    getinstances = "getinstances", getnilinstances = "getnilinstances", getscripts = "getscripts",
    getloadedmodules = "getloadedmodules", getconnections = "getconnections", firesignal = "firesignal",
    fireclickdetector = "fireclickdetector", firetouchinterest = "firetouchinterest", getsenv = "getsenv",
    getcallingscript = "getcallingscript", hookfunction = "hookfunction", hookmetamethod = "hookmetamethod",
    clonefunction = "clonefunction", newcclosure = "newcclosure", setstackhidden = "setstackhidden",
    isfunctionhooked = "isfunctionhooked", restorefunction = "restorefunction", mouse1click = "mouse1click",
    mouse1press = "mouse1press", mouse1release = "mouse1release", mouse2click = "mouse2click",
    mouse2press = "mouse2press", mouse2release = "mouse2release", mousemoveabs = "mousemoveabs",
    mousemoverel = "mousemoverel", mousescroll = "mousescroll", keypress = "keypress", keyrelease = "keyrelease",
    readfile = "readfile", writefile = "writefile", appendfile = "appendfile", loadfile = "loadfile",
    listfiles = "listfiles", isfile = "isfile", isfolder = "isfolder", makefolder = "makefolder",
    delfolder = "delfolder", delfile = "delfile", setclipboard = "setclipboard", setrbxclipboard = "setrbxclipboard",
    getnamecallmethod = "getnamecallmethod", setnamecallmethod = "setnamecallmethod", saveinstance = "saveinstance",
    gethiddenproperty = "gethiddenproperty", sethiddenproperty = "sethiddenproperty", setsimulationradius = "setsimulationradius",
    syn = "syn", crypt = "crypt", cache = "cache", http = "http", Drawing = "Drawing", WebSocket = "WebSocket",
    cloneref = "cloneref", compareinstances = "compareinstances", checkcaller = "checkcaller",
    getscriptclosure = "getscriptclosure", iscclosure = "iscclosure", islclosure = "islclosure",
    isexecutorclosure = "isexecutorclosure", loadstring = "loadstring", rconsoleclear = "rconsoleclear",
    rconsolecreate = "rconsolecreate", rconsoledestroy = "rconsoledestroy", rconsoleinput = "rconsoleinput",
    rconsoleprint = "rconsoleprint", rconsolesettitle = "rconsolesettitle", debug = "debug", dofile = "dofile",
    isrbxactive = "isrbxactive", getcallbackvalue = "getcallbackvalue", getcustomasset = "getcustomasset",
    gethui = "gethui", isscriptable = "isscriptable", setscriptable = "setscriptable", getrawmetatable = "getrawmetatable",
    isreadonly = "isreadonly", setrawmetatable = "setrawmetatable", setreadonly = "setreadonly",
    identifyexecutor = "identifyexecutor", lz4compress = "lz4compress", lz4decompress = "lz4decompress",
    messagebox = "messagebox", request = "request", setfpscap = "setfpscap", getrunningscripts = "getrunningscripts",
    getscriptbytecode = "getscriptbytecode", getscripthash = "getscripthash", getthreadidentity = "getthreadidentity",
    setthreadidentity = "setthreadidentity", isrenderobj = "isrenderobj", getrenderproperty = "getrenderproperty",
    setrenderproperty = "setrenderproperty", cleardrawcache = "cleardrawcache", getfenv = "getfenv", gethwid = "gethwid"
}

local aL = {
    {pattern = "window", prefix = "Window", counter = "window"},
    {pattern = "tab", prefix = "Tab", counter = "tab"},
    {pattern = "section", prefix = "Section", counter = "section"},
    {pattern = "button", prefix = "Button", counter = "button"},
    {pattern = "toggle", prefix = "Toggle", counter = "toggle"},
    {pattern = "slider", prefix = "Slider", counter = "slider"},
    {pattern = "dropdown", prefix = "Dropdown", counter = "dropdown"},
    {pattern = "textbox", prefix = "Textbox", counter = "textbox"},
    {pattern = "input", prefix = "Input", counter = "input"},
    {pattern = "label", prefix = "Label", counter = "label"},
    {pattern = "keybind", prefix = "Keybind", counter = "keybind"},
    {pattern = "colorpicker", prefix = "ColorPicker", counter = "colorpicker"},
    {pattern = "paragraph", prefix = "Paragraph", counter = "paragraph"},
    {pattern = "notification", prefix = "Notification", counter = "notification"},
    {pattern = "divider", prefix = "Divider", counter = "divider"},
    {pattern = "bind", prefix = "Bind", counter = "bind"},
    {pattern = "picker", prefix = "Picker", counter = "picker"}
}

local aM = {}

local function aN(aO)
    aM[aO] = (aM[aO] or 0) + 1
    return aM[aO]
end

local function aP(aQ, aR, aS)
    if not aQ then
        aQ = "var"
    end
    local aT = aE(aQ)
    if aK[aT] then
        return aK[aT]
    end
    if aS then
        local aU = aS:lower()
        for W, aV in ipairs(aL) do
            if aU:find(aV.pattern) then
                local a2 = aN(aV.counter)
                return a2 == 1 and aV.prefix or aV.prefix .. a2
            end
        end
    end
    if aT == "LocalPlayer" then
        return "LocalPlayer"
    end
    if aT == "Character" then
        return "Character"
    end
    if aT == "Humanoid" then
        return "Humanoid"
    end
    if aT == "HumanoidRootPart" then
        return "HumanoidRootPart"
    end
    if aT == "Head" then
        return "Head"
    end
    if aT == "Torso" or aT == "UpperTorso" then
        return "Torso"
    end
    if aT == "Camera" then
        return "Camera"
    end
    if aT == "PlayerGui" then
        return "PlayerGui"
    end
    if aT == "Backpack" then
        return "Backpack"
    end
    if aT == "PlayerScripts" then
        return "PlayerScripts"
    end
    if aT == "Position" then
        return "HRP_Position"
    end
    if aT == "Highlight" then
        return "PlayerHighlight"
    end
    if aT == "Heartbeat" then
        return "HeartbeatConnection"
    end
    if aT == "InputBegan" then
        return "InputConnection"
    end
    if aT == "InputEnded" then
        return "InputEndedConnection"
    end
    if aT == "ChildAdded" then
        return "ChildAddedConnection"
    end
    if aT == "ChildRemoved" then
        return "ChildRemovedConnection"
    end
    if aT == "Touched" then
        return "TouchedConnection"
    end
    if aT == "TouchEnded" then
        return "TouchEndedConnection"
    end
    if aT == "Changed" then
        return "ChangedConnection"
    end
    if aT == "RenderStepped" then
        return "RenderSteppedConnection"
    end
    if aT == "Stepped" then
        return "SteppedConnection"
    end
    if aT == "CharacterAdded" then
        return "CharacterAddedConnection"
    end
    if aT == "PlayerAdded" then
        return "PlayerAddedConnection"
    end
    if aT == "PlayerRemoving" then
        return "PlayerRemovingConnection"
    end
    if aT == "MouseButton1Click" then
        return "MouseButton1ClickConnection"
    end
    if aT == "MouseButton1Down" then
        return "MouseButton1DownConnection"
    end
    if aT == "MouseButton1Up" then
        return "MouseButton1UpConnection"
    end
    if aT == "MouseEnter" then
        return "MouseEnterConnection"
    end
    if aT == "MouseLeave" then
        return "MouseLeaveConnection"
    end
    if aT == "FocusLost" then
        return "FocusLostConnection"
    end
    if aT == "Activated" then
        return "ActivatedConnection"
    end
    if aT == "Deactivated" then
        return "DeactivatedConnection"
    end
    if aT == "Triggered" then
        return "TriggeredConnection"
    end
    if aT == "TriggerEnded" then
        return "TriggerEndedConnection"
    end
    if aT == "Died" then
        return "DiedConnection"
    end
    if aT == "HealthChanged" then
        return "HealthChangedConnection"
    end
    if aT == "StateChanged" then
        return "StateChangedConnection"
    end
    if aT == "MoveToFinished" then
        return "MoveToFinishedConnection"
    end
    if aT == "OnClientEvent" then
        return "OnClientEventConnection"
    end
    if aT == "OnServerEvent" then
        return "OnServerEventConnection"
    end
    if aT == "OnClientInvoke" then
        return "OnClientInvokeConnection"
    end
    if aT == "OnServerInvoke" then
        return "OnServerInvokeConnection"
    end
    if aT:match("^Enum%.") then
        return aT:gsub("%.", "_")
    end
    local T = aT:gsub("[^%w_]", "_"):gsub("^%d+", "v%1")
    if T == "" or T == "Object" or T == "Value" or T == "result" then
        T = "var"
    end
    return T
end

local function aW(x, aQ, aX, aS)
    local aY = t.registry[x]
    if aY and not aY:match("^v%d+$") and not aY:match("^conn$") and not aY:match("%.") then
        return aY
    end
    local am = aP(aQ, nil, aS)
    if am == "var" or am == "object" or am == "result" or am == "proxy" or am == "conn" or am == "connection" or t.names_used[am] then
        t.lar_counter = (t.lar_counter or 0) + 1
        am = "v" .. t.lar_counter
    end
    t.names_used[am] = true
    t.registry[x] = am
    t.reverse_registry[am] = x
    t.variable_types[am] = aX or j(x)
    return am
end

local function aZ(aF, a_, b0, b1)
    a_ = a_ or 0
    b0 = b0 or {}
    if a_ > r.MAX_DEPTH then
        return "{ --[[max depth]] }"
    end
    if G(aF) and t.registry[aF] then
        return t.registry[aF]
    end
    local b2 = j(aF)
    if w(aF) then
        local b3 = rawget(aF, "__value")
        return m(b3 or 0)
    end
    if b2 == "table" and t.registry[aF] then
        return t.registry[aF]
    end
    if b2 == "nil" then
        return "nil"
    elseif b2 == "string" then
        sniff(aF, "aZ")
        if #aF > 10000 then
            table.insert(t.string_refs, {value = aF:sub(1, 50) .. "...", hint = "large_string", full_length = #aF})
            return string.format("--[[ Large string truncated (%d bytes) ]] %s", #aF, aH(aF:sub(1, 1000) .. "..."))
        end
        if #aF > 100 and aF:match("^[A-Za-z0-9+/=]+$") then
            table.insert(t.string_refs, {value = aF:sub(1, 50) .. "...", hint = "base64", full_length = #aF})
        elseif aF:match("https?://") then
            table.insert(t.string_refs, {value = aF, hint = "URL"})
        elseif aF:match("rbxasset://") or aF:match("rbxassetid://") then
            table.insert(t.string_refs, {value = aF, hint = "Asset"})
        end
        return aH(aF)
    elseif b2 == "number" then
        if aF ~= aF then
            return "0/0"
        end
        if aF == math.huge then
            return "math.huge"
        end
        if aF == -math.huge then
            return "-math.huge"
        end
        if aF == math.floor(aF) then
            return m(math.floor(aF))
        end
        return string.format("%.6g", aF)
    elseif b2 == "boolean" then
        return m(aF)
    elseif b2 == "function" then
        if t.registry[aF] then
            return t.registry[aF]
        end
        return "function() end"
    elseif b2 == "table" then
        if G(aF) then
            return t.registry[aF] or "proxy"
        end
        if b0[aF] then
            return "{ --[[circular]] }"
        end
        b0[aF] = true
        local a2 = 0
        for b4, b5 in D(aF) do
            if b4 ~= F and b4 ~= "__proxy_id" then
                a2 = a2 + 1
            end
        end
        if a2 == 0 then
            return "{}"
        end
        local b6 = true
        local b7 = 0
        for b4, b5 in D(aF) do
            if b4 ~= F and b4 ~= "__proxy_id" then
                if j(b4) ~= "number" or b4 < 1 or b4 ~= math.floor(b4) then
                    b6 = false
                    break
                else
                    b7 = math.max(b7, b4)
                end
            end
        end
        b6 = b6 and b7 == a2
        if b6 and a2 <= 8 and b1 ~= false then
            local b8 = {}
            for L = 1, a2 do
                local b5 = aF[L]
                if j(b5) ~= "table" or G(b5) then
                    table.insert(b8, aZ(b5, a_ + 1, b0, true))
                else
                    b6 = false
                    break
                end
            end
            if b6 and #b8 == a2 then
                return "{" .. table.concat(b8, ", ") .. "}"
            end
        end
        -- Sort keys: strings alphabetically first, then numbers
        local sortedKeys = {}
        for b4, _ in D(aF) do
            if b4 ~= F and b4 ~= "__proxy_id" then
                table.insert(sortedKeys, b4)
            end
        end
        table.sort(sortedKeys, function(x, y)
            local tx, ty = j(x), j(y)
            if tx == ty then
                if tx == "string" then return x < y end
                if tx == "number" then return x < y end
                return m(x) < m(y)
            end
            if tx == "string" then return true end
            if ty == "string" then return false end
            if tx == "number" then return true end
            return false
        end)
        local b9 = {}
        local ba = 0
        local bb = string.rep("    ", t.indent + a_ + 1)
        local bc = string.rep("    ", t.indent + a_)
        for _, b4 in ipairs(sortedKeys) do
            local b5 = aF[b4]
            ba = ba + 1
            if ba > r.MAX_TABLE_ITEMS then
                table.insert(b9, bb .. "-- ..." .. a2 - ba + 1 .. " more items")
                break
            end
            local bd
            if b6 then
                bd = nil
            elseif j(b4) == "string" and b4:match("^[%a_][%w_]*$") then
                bd = b4
            else
                bd = "[" .. aZ(b4, a_ + 1, b0) .. "]"
            end
            local be = aZ(b5, a_ + 1, b0)
            -- Add type hint comment for nested tables/functions
            local typeHint = ""
            if j(b5) == "table" and not G(b5) and a_ + 1 >= r.MAX_DEPTH then
                local subCount = 0
                for _ in D(b5) do subCount = subCount + 1 end
                typeHint = " --[[" .. subCount .. " items]]"
            elseif j(b5) == "function" then
                typeHint = " --[[function]]"
            elseif j(b5) == "userdata" then
                local ok, cn = pcall(function() return b5.ClassName end)
                if ok and cn then
                    typeHint = " --[[" .. m(cn) .. "]]"
                end
            end
            if bd then
                table.insert(b9, bb .. bd .. " = " .. be .. typeHint)
            else
                table.insert(b9, bb .. be .. typeHint)
            end
        end
        if #b9 == 0 then
            return "{}"
        end
        -- Show metatable hint
        local mtHint = ""
        local ok, mt = pcall(getmetatable, aF)
        if ok and mt then
            mtHint = " -- has metatable"
        end
        return "{ --[[" .. a2 .. " items]]" .. mtHint .. "\n" .. table.concat(b9, ",\n") .. "\n" .. bc .. "}"
    elseif b2 == "userdata" then
        if t.registry[aF] then
            return t.registry[aF]
        end
        local y, O = pcall(m, aF)
        return y and O or "userdata"
    elseif b2 == "thread" then
        return "coroutine.create(function() end)"
    else
        local y, O = pcall(m, aF)
        return y and O or "nil"
    end
end

local bf = {}
setmetatable(bf, {__mode = "k"})

local function bg(locked)
    local bh = {}
    local bi = {
        __metatable = (locked ~= false) and "The metatable is locked" or nil,
        __call = function()
            error("attempt to call a userdata value", 0)
        end,
        __concat = function(a, b)
            local sa = aZ(a)
            local sb = aZ(b)
            local bh, bi = bg()
            t.registry[bh] = sa .. " .. " .. sb
            return bh
        end
    }
    setmetatable(bh, bi)
    bf[bh] = true
    return bh, bi
end

local function G(x)
    return bf[x] == true
end

local bj
local bk

local function bl(bm)
    local bh, bi = bg()
    rawset(bh, v, true)
    rawset(bh, "__value", bm)
    t.registry[bh] = tostring(bm)
    bi.__tostring = function()
        return tostring(bm)
    end
    bi.__index = function(b2, b4)
        if b4 == F or b4 == "__proxy_id" or b4 == v or b4 == "__value" then
            return rawget(b2, b4)
        end
        return bl(0)
    end
    bi.__newindex = function()
    end
    bi.__call = function()
        return bm
    end
    local function bn(X)
        return function(bo, aa)
            local bp = type(bo) == "table" and rawget(bo, "__value") or bo or 0
            local bq = type(aa) == "table" and rawget(aa, "__value") or aa or 0
            local z
            if X == "+" then
                z = bp + bq
            elseif X == "-" then
                z = bp - bq
            elseif X == "*" then
                z = bp * bq
            elseif X == "/" then
                z = bq ~= 0 and bp / bq or 0
            elseif X == "%" then
                z = bq ~= 0 and bp % bq or 0
            elseif X == "^" then
                z = bp ^ bq
            else
                z = 0
            end
            return bl(z)
        end
    end
    bi.__add = bn("+")
    bi.__sub = bn("-")
    bi.__mul = bn("*")
    bi.__div = bn("/")
    bi.__mod = bn("%")
    bi.__pow = bn("^")
    bi.__unm = function(bo)
        return bl(-(rawget(bo, "__value") or 0))
    end
    bi.__eq = function(bo, aa)
        local bp = type(bo) == "table" and rawget(bo, "__value") or bo
        local bq = type(aa) == "table" and rawget(aa, "__value") or aa
        return bp == bq
    end
    bi.__lt = function(bo, aa)
        local bp = type(bo) == "table" and rawget(bo, "__value") or bo
        local bq = type(aa) == "table" and rawget(aa, "__value") or aa
        return bp < bq
    end
    bi.__le = function(bo, aa)
        local bp = type(bo) == "table" and rawget(bo, "__value") or bo
        local bq = type(aa) == "table" and rawget(aa, "__value") or aa
        return bp <= bq
    end
    bi.__len = function()
        return 0
    end
    return bh
end

local function br(bs, bt)
    if j(bs) ~= "function" then
        return {}
    end
    local a4 = #t.output
    local bu = t.pending_iterator
    t.pending_iterator = false
    xpcall(function()
        bs(table.unpack(bt or {}))
    end, function()
    end)
    while t.pending_iterator do
        t.indent = t.indent - 1
        at("end")
        t.pending_iterator = false
    end
    t.pending_iterator = bu
    local bv = {}
    for L = a4 + 1, #t.output do
        table.insert(bv, t.output[L])
    end
    for L = #t.output, a4 + 1, -1 do
        table.remove(t.output, L)
    end
    return bv
end



bj = function(aQ, bO, bw, locked)
    local aT = aE(aQ)
    if type(aT) == "string" then sniff(aT, "Proxy Name") end
    
    -- Compute cache path: only cache top-level named objects and child lookups
    local path = nil
    if bO and type(aT) == "string" then
        path = aT
    elseif bw then
        local parentPath = t.registry[bw]
        if type(parentPath) == "string" and type(aT) == "string" then
            path = parentPath .. "." .. aT
        end
    end
    
    local bh, bi = bg(locked)
    rawset(bh, F, true)
    t.property_store[bh] = {}
    if path and type(path) == "string" then
        if not t.cache[path] then
            t.cache[path] = bh
        else
            return t.cache[path]
        end
    end

    
    if bO then
        t.registry[bh] = aT
        t.names_used[aT] = true
    elseif bw then
        t.parent_map[bh] = bw
        if path then
            t.registry[bh] = path
        else
            local fallback = tostring(t.registry[bw] or "object") .. "." .. aT
            t.registry[bh] = fallback
        end
    end

    local bP = {}

    -- ENHANCED: Heartbeat event with multi-execution bypass (registered as proxy for typeof)
    local heartbeatProxy, heartbeatMeta = bg()
    t.registry[heartbeatProxy] = (aT or "RunService") .. ".Heartbeat"
    heartbeatMeta.__index = function(self, key)
        if key == F or key == "__proxy_id" then
            return rawget(heartbeatProxy, key)
        end
        if key == "Connect" then
            return function(_, callback)
                local c1 = bj("connection", false, nil, false)
                local c2 = aW(c1, "HeartbeatConnection")
                
                at(string.format("local %s = RunService.Heartbeat:Connect(function(deltaTime)", c2))
                t.indent = t.indent + 1
                
                -- CRITICAL: Execute callback 15 times to bypass count >= 10 check
                for i = 1, 15 do
                    xpcall(function()
                        callback(0.016)
                    end, function(err)
                        -- Ignore errors during simulation
                    end)
                end
                
                t.indent = t.indent - 1
                at("end)")
                
                -- Return connection proxy with working Disconnect
                local connMeta = {
                    __index = function(self, key)
                        if key == v then return true end
                        if key == "Disconnect" then
                            return function()
                                at(string.format("%s:Disconnect()", c2))
                            end
                        end
                        return nil
                    end,
                    __tostring = function()
                        return c2
                    end
                }
                setmetatable(c1, connMeta)
                return c1
            end
        elseif key == "Wait" then
            return function()
                at("RunService.Heartbeat:Wait() -- returned 0.016")
                t.fake_time = t.fake_time + 0.016
                return 0.016 -- Return deltaTime
            end
        end
        return nil
    end
    heartbeatMeta.__tostring = function()
        return "RunService.Heartbeat"
    end
    bP.Heartbeat = heartbeatProxy

    bP.GetService = function(self, bQ)
        local bR = aE(bQ)
        local x = bj(bR, false, bh)
        local _ = aW(x, bR)
        local bS = t.registry[bh] or "game"
        at(string.format("local %s = %s:GetService(%s)", _, bS, aH(bR)))
        return x
    end

    bP.IsLoaded = function(self)
        local bS = t.registry[bh] or "game"
        at(string.format("%s:IsLoaded()", bS))
        return true
    end

    bP.GetObjects = function(self, bT)
        local bV = aE(bT)
        local x = bj("Objects", false, bh)
        local _ = aW(x, "Objects")
        local bS = t.registry[bh] or "game"
        at(string.format("local %s = %s:GetObjects(%s)", _, bS, aZ(bV)))
        return {x}
    end

    bP.WaitForChild = function(self, bT, bU)
        local bV = aE(bT)
        local x = bj(bV, false, bh)
        local parentName = t.registry[bh]
        if not parentName or parentName == "object" then
            local grandparent = t.parent_map[bh]
            if grandparent then
                local gpName = t.registry[grandparent]
                if gpName and gpName ~= "object" then
                    parentName = gpName .. "." .. (aT or "object")
                end
            end
        end
        local bS = parentName or "object"
        local _ = aW(x, bV, nil, bV)
        if bU then
            at(string.format("local %s = %s:WaitForChild(%s, %s)", _, bS, aH(bV), aZ(bU)))
        else
            at(string.format("local %s = %s:WaitForChild(%s)", _, bS, aH(bV)))
        end
        return x
    end

    bP.FindFirstChild = function(self, bT, bW)
        local bV = aE(bT)
        local x = bj(bV, false, bh)
        local _ = aW(x, bV)
        local bS = t.registry[bh] or "object"
        if bW then
            at(string.format("local %s = %s:FindFirstChild(%s, true)", _, bS, aH(bV)))
        else
            at(string.format("local %s = %s:FindFirstChild(%s)", _, bS, aH(bV)))
        end
        return x
    end

    bP.FindFirstChildOfClass = function(self, bX)
        local bY = aE(bX)
        local x = bj(bY, false, bh)
        local _ = aW(x, bY)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstChildOfClass(%s)", _, bS, aH(bY)))
        return x
    end

    bP.FindFirstChildWhichIsA = function(self, bX)
        local bY = aE(bX)
        local x = bj(bY, false, bh)
        local _ = aW(x, bY)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstChildWhichIsA(%s)", _, bS, aH(bY)))
        return x
    end

    bP.FindFirstAncestor = function(self, am)
        local bZ = aE(am)
        local x = bj(bZ, false, bh)
        local _ = aW(x, bZ)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstAncestor(%s)", _, bS, aH(bZ)))
        return x
    end

    bP.FindFirstAncestorOfClass = function(self, bX)
        local bY = aE(bX)
        local x = bj(bY, false, bh)
        local _ = aW(x, bY)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstAncestorOfClass(%s)", _, bS, aH(bY)))
        return x
    end

    bP.FindFirstAncestorWhichIsA = function(self, bX)
        local bY = aE(bX)
        local x = bj(bY, false, bh)
        local _ = aW(x, bY)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstAncestorWhichIsA(%s)", _, bS, aH(bY)))
        return x
    end

    bP.GetChildren = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("for _, child in %s:GetChildren() do", bS))
        t.indent = t.indent + 1
        t.pending_iterator = true
        return {}
    end

    bP.GetDescendants = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("for _, obj in %s:GetDescendants() do", bS))
        t.indent = t.indent + 1
        local b_ = bj("obj", false)
        t.registry[b_] = "obj"
        t.property_store[b_] = {Name = "Ball", ClassName = "Part", Size = Vector3.new(1, 1, 1)}
        local c0 = false
        return function()
            if not c0 then
                c0 = true
                return 1, b_
            else
                t.indent = t.indent - 1
                at("end")
                return nil
            end
        end, nil, 0
    end

    bP.Clone = function(self)
        local bS = t.registry[bh] or "object"
        local cloneName = (aT or "object") .. "Clone"
        local x = bj(cloneName, false)
        local _ = aW(x, cloneName)
        at(string.format("local %s = %s:Clone()", _, bS))
        
        -- Copy all stored properties (except Parent and _destroyed)
        if t.property_store[bh] then
            t.property_store[x] = t.property_store[x] or {}
            for k, v in D(t.property_store[bh]) do
                if k ~= "Parent" and k ~= "_destroyed" then
                    t.property_store[x][k] = v
                end
            end
        end
        -- Clone has nil Parent (Roblox behavior)
        t.parent_map[x] = nil
        t.property_store[x] = t.property_store[x] or {}
        t.property_store[x]._destroyed = false
        return x
    end

    bP.Destroy = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:Destroy()", bS))
        
        -- Mark as destroyed
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh]._destroyed = true
        
        -- Clear parent
        t.parent_map[bh] = nil
        
        -- Recursively destroy children
        local children_to_destroy = {}
        for child, parent in D(t.parent_map) do
            if rawequal(parent, bh) then
                table.insert(children_to_destroy, child)
            end
        end
        for _, child in E(children_to_destroy) do
            t.parent_map[child] = nil
            if t.property_store[child] then
                t.property_store[child]._destroyed = true
            end
        end
        
        -- Clear from cache
        local regName = t.registry[bh]
        if regName and t.cache[regName] then
            t.cache[regName] = nil
        end
    end

    -- Remove is deprecated alias for Destroy (authentic Roblox)
    bP.Remove = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:Remove()", bS))
        -- Same behavior as Destroy
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh]._destroyed = true
        t.parent_map[bh] = nil
    end

    bP.ClearAllChildren = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:ClearAllChildren()", bS))
        -- Destroy all children
        local children_to_destroy = {}
        for child, parent in D(t.parent_map) do
            if rawequal(parent, bh) then
                table.insert(children_to_destroy, child)
            end
        end
        for _, child in E(children_to_destroy) do
            t.parent_map[child] = nil
            if t.property_store[child] then
                t.property_store[child]._destroyed = true
            end
        end
    end

    -- IsA with class hierarchy (authentic Roblox behavior)
    bP.IsA = function(self, className)
        local bS = t.registry[bh] or "object"
        local cn = aE(className)
        at(string.format("%s:IsA(%s)", bS, aH(cn)))
        -- Check stored ClassName
        local props = t.property_store[bh]
        local myClass = props and props.ClassName or aT or "Instance"
        -- SimpleCla hierarchy: Part inherits BasePart, BasePart inherits PVInstance, etc.
        local hierarchy = {
            Part = {"Part", "BasePart", "PVInstance", "Instance"},
            WedgePart = {"WedgePart", "BasePart", "PVInstance", "Instance"},
            MeshPart = {"MeshPart", "TriangleMeshPart", "BasePart", "PVInstance", "Instance"},
            UnionOperation = {"UnionOperation", "TriangleMeshPart", "BasePart", "PVInstance", "Instance"},
            TrussPart = {"TrussPart", "BasePart", "PVInstance", "Instance"},
            SpawnLocation = {"SpawnLocation", "Part", "BasePart", "PVInstance", "Instance"},
            Seat = {"Seat", "Part", "BasePart", "PVInstance", "Instance"},
            VehicleSeat = {"VehicleSeat", "Part", "BasePart", "PVInstance", "Instance"},
            Model = {"Model", "PVInstance", "Instance"},
            Folder = {"Folder", "Instance"},
            Frame = {"Frame", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            TextLabel = {"TextLabel", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            TextButton = {"TextButton", "GuiButton", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            TextBox = {"TextBox", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            ImageLabel = {"ImageLabel", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            ImageButton = {"ImageButton", "GuiButton", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            ScreenGui = {"ScreenGui", "LayerCollector", "GuiBase2d", "GuiBase", "Instance"},
            BillboardGui = {"BillboardGui", "LayerCollector", "GuiBase2d", "GuiBase", "Instance"},
            SurfaceGui = {"SurfaceGui", "LayerCollector", "GuiBase2d", "GuiBase", "Instance"},
            ScrollingFrame = {"ScrollingFrame", "GuiObject", "GuiBase2d", "GuiBase", "Instance"},
            Sound = {"Sound", "Instance"},
            Humanoid = {"Humanoid", "Instance"},
            Weld = {"Weld", "JointInstance", "Instance"},
            WeldConstraint = {"WeldConstraint", "Instance"},
            Motor6D = {"Motor6D", "JointInstance", "Instance"},
            RemoteEvent = {"RemoteEvent", "Instance"},
            RemoteFunction = {"RemoteFunction", "Instance"},
            BindableEvent = {"BindableEvent", "Instance"},
            BindableFunction = {"BindableFunction", "Instance"},
            StringValue = {"StringValue", "ValueBase", "Instance"},
            IntValue = {"IntValue", "ValueBase", "Instance"},
            NumberValue = {"NumberValue", "ValueBase", "Instance"},
            BoolValue = {"BoolValue", "ValueBase", "Instance"},
            ObjectValue = {"ObjectValue", "ValueBase", "Instance"},
            Tool = {"Tool", "BackpackItem", "Instance"},
            LocalScript = {"LocalScript", "BaseScript", "LuaSourceContainer", "Instance"},
            Script = {"Script", "BaseScript", "LuaSourceContainer", "Instance"},
            ModuleScript = {"ModuleScript", "LuaSourceContainer", "Instance"},
            Camera = {"Camera", "Instance"},
            PointLight = {"PointLight", "Light", "Instance"},
            SpotLight = {"SpotLight", "Light", "Instance"},
            SurfaceLight = {"SurfaceLight", "Light", "Instance"},
            Fire = {"Fire", "Instance"},
            Smoke = {"Smoke", "Instance"},
            ParticleEmitter = {"ParticleEmitter", "Instance"},
            Attachment = {"Attachment", "Instance"},
            Beam = {"Beam", "Instance"},
            Trail = {"Trail", "Instance"},
            ClickDetector = {"ClickDetector", "Instance"},
            ProximityPrompt = {"ProximityPrompt", "Instance"},
            Decal = {"Decal", "FaceInstance", "Instance"},
            Texture = {"Texture", "Decal", "FaceInstance", "Instance"},
            Animation = {"Animation", "Instance"},
            Explosion = {"Explosion", "Instance"},
            BodyVelocity = {"BodyVelocity", "BodyMover", "Instance"},
            BodyPosition = {"BodyPosition", "BodyMover", "Instance"},
            BodyGyro = {"BodyGyro", "BodyMover", "Instance"},
            BodyForce = {"BodyForce", "BodyMover", "Instance"},
            UIListLayout = {"UIListLayout", "UIGridStyleLayout", "UILayout", "UIComponent", "UIBase", "Instance"},
            UIGridLayout = {"UIGridLayout", "UIGridStyleLayout", "UILayout", "UIComponent", "UIBase", "Instance"},
            UIPadding = {"UIPadding", "UIComponent", "UIBase", "Instance"},
            UICorner = {"UICorner", "UIComponent", "UIBase", "Instance"},
            UIStroke = {"UIStroke", "UIComponent", "UIBase", "Instance"},
            UIScale = {"UIScale", "UIComponent", "UIBase", "Instance"},
            UIGradient = {"UIGradient", "UIComponent", "UIBase", "Instance"},
        }
        local chain = hierarchy[myClass] or {myClass, "Instance"}
        for _, c in ipairs(chain) do
            if c == cn then return true end
        end
        return false
    end

    -- IsDescendantOf: walk parent_map chain
    bP.IsDescendantOf = function(self, ancestor)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:IsDescendantOf(%s)", bS, aZ(ancestor)))
        local current = t.parent_map[bh]
        local depth = 0
        while current and depth < 100 do
            if rawequal(current, ancestor) then return true end
            current = t.parent_map[current]
            depth = depth + 1
        end
        return false
    end

    -- IsAncestorOf: check if target is descendant of self
    bP.IsAncestorOf = function(self, descendant)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:IsAncestorOf(%s)", bS, aZ(descendant)))
        if not G(descendant) then return false end
        local current = t.parent_map[descendant]
        local depth = 0
        while current and depth < 100 do
            if rawequal(current, bh) then return true end
            current = t.parent_map[current]
            depth = depth + 1
        end
        return false
    end

    -- SetAttribute / GetAttribute / GetAttributes with attribute storage
    bP.SetAttribute = function(self, attrName, attrValue)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:SetAttribute(%s, %s)", bS, aH(aE(attrName)), aZ(attrValue)))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh]._attributes = t.property_store[bh]._attributes or {}
        t.property_store[bh]._attributes[attrName] = attrValue
    end

    bP.GetAttribute = function(self, attrName)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:GetAttribute(%s)", bS, aH(aE(attrName))))
        local ps = t.property_store[bh]
        if ps and ps._attributes and ps._attributes[attrName] ~= nil then
            return ps._attributes[attrName]
        end
        return nil
    end

    bP.GetAttributes = function(self)
        local bS = t.registry[bh] or "object"
        at(string.format("%s:GetAttributes()", bS))
        local ps = t.property_store[bh]
        if ps and ps._attributes then
            local copy = {}
            for k, v in pairs(ps._attributes) do
                copy[k] = v
            end
            return copy
        end
        return {}
    end

    -- FindFirstDescendant (searches recursively)
    bP.FindFirstDescendant = function(self, name)
        local bV = aE(name)
        local x = bj(bV, false, bh)
        local _ = aW(x, bV)
        local bS = t.registry[bh] or "object"
        at(string.format("local %s = %s:FindFirstDescendant(%s)", _, bS, aH(bV)))
        return x
    end

    -- GetDebugId (returns unique ID string)
    bP.GetDebugId = function(self, scopeLength)
        local bS = t.registry[bh] or "object"
        local id = string.format("%08X", math.random(0, 0xFFFFFFFF))
        at(string.format("%s:GetDebugId()", bS))
        return id
    end

    bP.Connect = function(self, bs)
        local bS = t.registry[bh] or "signal"
        local c1 = bj("connection", false, nil, false)
        local c3 = bS:match("%.([^%.]+)$") or bS
        
        if c3:match("MessageOut") then
            table.insert(t.message_out_listeners, bs)
        end
        
        local connName = "conn"
        if c3:match("Heartbeat") then connName = "HeartbeatConnection"
        elseif c3:match("RenderStepped") then connName = "RenderSteppedConnection"
        elseif c3:match("Stepped") then connName = "SteppedConnection"
        elseif c3:match("InputBegan") then connName = "InputBeganConnection"
        elseif c3:match("InputEnded") then connName = "InputEndedConnection"
        elseif c3:match("InputChanged") then connName = "InputChangedConnection"
        elseif c3:match("CharacterAdded") then connName = "CharacterAddedConnection"
        elseif c3:match("CharacterRemoving") then connName = "CharacterRemovingConnection"
        elseif c3:match("PlayerAdded") then connName = "PlayerAddedConnection"
        elseif c3:match("PlayerRemoving") then connName = "PlayerRemovingConnection"
        elseif c3:match("Died") then connName = "DiedConnection"
        elseif c3:match("HealthChanged") then connName = "HealthChangedConnection"
        elseif c3:match("Touched") then connName = "TouchedConnection"
        elseif c3:match("TouchEnded") then connName = "TouchEndedConnection"
        elseif c3:match("Changed") then connName = "ChangedConnection"
        elseif c3:match("ChildAdded") then connName = "ChildAddedConnection"
        elseif c3:match("ChildRemoved") then connName = "ChildRemovedConnection"
        elseif c3:match("DescendantAdded") then connName = "DescendantAddedConnection"
        elseif c3:match("DescendantRemoving") then connName = "DescendantRemovingConnection"
        elseif c3:match("MouseButton1Click") then connName = "MouseButton1ClickConnection"
        elseif c3:match("MouseButton1Down") then connName = "MouseButton1DownConnection"
        elseif c3:match("MouseButton1Up") then connName = "MouseButton1UpConnection"
        elseif c3:match("MouseEnter") then connName = "MouseEnterConnection"
        elseif c3:match("MouseLeave") then connName = "MouseLeaveConnection"
        elseif c3:match("FocusLost") then connName = "FocusLostConnection"
        elseif c3:match("FocusGained") then connName = "FocusGainedConnection"
        elseif c3:match("Activated") then connName = "ActivatedConnection"
        elseif c3:match("Deactivated") then connName = "DeactivatedConnection"
        elseif c3:match("Triggered") then connName = "TriggeredConnection"
        elseif c3:match("TriggerEnded") then connName = "TriggerEndedConnection"
        elseif c3:match("StateChanged") then connName = "StateChangedConnection"
        elseif c3:match("MoveToFinished") then connName = "MoveToFinishedConnection"
        elseif c3:match("FreeFalling") then connName = "FreeFallingConnection"
        elseif c3:match("Jumping") then connName = "JumpingConnection"
        elseif c3:match("Running") then connName = "RunningConnection"
        elseif c3:match("Seated") then connName = "SeatedConnection"
        elseif c3:match("Swimming") then connName = "SwimmingConnection"
        elseif c3:match("GettingUp") then connName = "GettingUpConnection"
        elseif c3:match("OnClientEvent") then connName = "OnClientEventConnection"
        elseif c3:match("OnServerEvent") then connName = "OnServerEventConnection"
        elseif c3:match("OnClientInvoke") then connName = "OnClientInvokeConnection"
        elseif c3:match("OnServerInvoke") then connName = "OnServerInvokeConnection"
        end
        
        local c2 = aW(c1, connName)
        
        local c4 = {"..."}
        if c3:match("InputBegan") or c3:match("InputEnded") or c3:match("InputChanged") then
            c4 = {"input", "gameProcessed"}
        elseif c3:match("CharacterAdded") or c3:match("CharacterRemoving") then
            c4 = {"character"}
        elseif c3:match("PlayerAdded") or c3:match("PlayerRemoving") then
            c4 = {"player"}
        elseif c3:match("Touched") then
            c4 = {"hit"}
        elseif c3:match("Heartbeat") or c3:match("RenderStepped") then
            c4 = {"deltaTime"}
        elseif c3:match("Stepped") then
            c4 = {"time", "deltaTime"}
        elseif c3:match("Changed") then
            c4 = {"property"}
        elseif c3:match("ChildAdded") or c3:match("ChildRemoved") then
            c4 = {"child"}
        elseif c3:match("DescendantAdded") or c3:match("DescendantRemoving") then
            c4 = {"descendant"}
        elseif c3:match("Died") or c3:match("MouseButton") or c3:match("Activated") then
            c4 = {}
        elseif c3:match("FocusLost") then
            c4 = {"enterPressed", "inputObject"}
        elseif c3:match("MessageOut") then
            c4 = {"message", "messageType"}
        end
        
        at(string.format("local %s = %s:Connect(function(%s)", c2, bS, table.concat(c4, ", ")))
        t.indent = t.indent + 1
        
        -- CRITICAL: For Heartbeat, execute callback multiple times
        local isHeartbeat = c3:match("Heartbeat") or bS:match("Heartbeat")
        if isHeartbeat and type(bs) == "function" then
            _G.heartbeat_listeners = _G.heartbeat_listeners or {}
            table.insert(_G.heartbeat_listeners, bs)
            for i = 1, 15 do
                xpcall(function()
                    bs(0.016)
                end, function() end)
            end
        elseif type(bs) == "function" then
            local isLoopingSignal = c3:match("Heartbeat") or c3:match("Stepped") or c3:match("RenderStepped") or c3:match("Changed")
            local args = {}
            if c4 then
                for i = 1, #c4 do
                    local argName = c4[i]
                    if argName == "message" then
                        args[i] = "RandomMessage"
                    elseif argName == "messageType" then
                        args[i] = Enum.MessageType.MessageOutput
                    else
                        args[i] = bj(argName, false)
                    end
                end
            end
            local iterations = isLoopingSignal and 5 or 1
            for i = 1, iterations do
                xpcall(function()
                    bs(table.unpack(args))
                end, function() end)
            end
        end
        
        while t.pending_iterator do
            t.indent = t.indent - 1
            at("end")
            t.pending_iterator = false
        end
        
        t.indent = t.indent - 1
        at("end)")
        
        -- Return connection with Disconnect method
        local connMeta = getmetatable(c1)
        if type(connMeta) ~= "table" then
            connMeta = {}
        end
        if type(connMeta.__index) ~= "table" then
            connMeta.__index = {}
        end
        connMeta.__index.Disconnect = function()
            at(string.format("%s:Disconnect()", c2))
        end
        setmetatable(c1, connMeta)
        
        return c1
    end

    bP.Once = function(self, bs)
        local bS = t.registry[bh] or "signal"
        local c1 = bj("connection", false, nil, false)
        local c2 = aW(c1, "conn")
        at(string.format("local %s = %s:Once(function(...)", c2, bS))
        t.indent = t.indent + 1
        if j(bs) == "function" then
            xpcall(function()
                bs()
            end, function() end)
        end
        t.indent = t.indent - 1
        at("end)")
        
        -- Return connection with Disconnect method
        local connMeta = getmetatable(c1)
        if type(connMeta) ~= "table" then
            connMeta = {}
        end
        if type(connMeta.__index) ~= "table" then
            connMeta.__index = {}
        end
        connMeta.__index.Disconnect = function()
            at(string.format("%s:Disconnect()", c2))
        end
        setmetatable(c1, connMeta)
        
        return c1
    end

    -- ENHANCED: Wait returns proper values for Heartbeat
    bP.Wait = function(self)
        local bS = t.registry[self] or "signal"
        local isHeartbeat = bS:match("Heartbeat")
        
        local z = bj("waitResult", false)
        local _ = aW(z, "waitResult")
        at(string.format("local %s = %s:Wait()", _, bS))
        
        -- For Heartbeat:Wait(), return deltaTime to satisfy while loops
        if isHeartbeat then
            t.fake_time = t.fake_time + 0.016
            return 0.016
        end
        
        return z
    end

    bP.Disconnect = function(self)
        local bS = t.registry[self] or "connection"
        at(string.format("%s:Disconnect()", bS))
    end

    bP.FireServer = function(self, ...)
        local bS = t.registry[self] or "remote"
        local bA = {...}
        local c5 = {}
        for W, b5 in ipairs(bA) do
            table.insert(c5, aZ(b5))
        end
        at(string.format("%s:FireServer(%s)", bS, table.concat(c5, ", ")))
        table.insert(t.call_graph, {type = "RemoteEvent", name = bS, args = bA})
    end

    bP.InvokeServer = function(self, ...)
        local bS = t.registry[self] or "remote"
        local bA = {...}
        local c5 = {}
        for W, b5 in ipairs(bA) do
            table.insert(c5, aZ(b5))
        end
        local z = bj("invokeResult", false)
        local _ = aW(z, "result")
        at(string.format("local %s = %s:InvokeServer(%s)", _, bS, table.concat(c5, ", ")))
        table.insert(t.call_graph, {type = "RemoteFunction", name = bS, args = bA})
        return z
    end

    bP.Create = function(self, x, c6, c7)
        if type(x) ~= "table" and type(x) ~= "userdata" then
            error("Unable to cast value to Object", 0)
        end
        local bS = t.registry[self] or "TweenService"
        local c8 = bj("tween", false)
        local _ = aW(c8, "tween")
        at(string.format("local %s = %s:Create(%s, %s, %s)", _, bS, aZ(x), aZ(c6), aZ(c7)))
        return c8
    end

    bP.Play = function(self)
        local my_bh = self.__proxy_id
        local bS = t.registry[my_bh] or "tween"
        at(string.format("%s:Play()", bS))
    end

    bP.Pause = function(self)
        local my_bh = self.__proxy_id
        local bS = t.registry[my_bh] or "tween"
        at(string.format("%s:Pause()", bS))
    end

    bP.Cancel = function(self)
        local my_bh = self.__proxy_id
        local bS = t.registry[my_bh] or "tween"
        at(string.format("%s:Cancel()", bS))
    end

    bP.Stop = function(self)
        local my_bh = self.__proxy_id
        local bS = t.registry[my_bh] or "tween"
        at(string.format("%s:Stop()", bS))
    end

    bP.Raycast = function(self, c9, ca, cb)
        local bS = t.registry[bh] or "workspace"
        local z = bj("raycastResult", false)
        local _ = aW(z, "rayResult")
        if cb then
            at(string.format("local %s = %s:Raycast(%s, %s, %s)", _, bS, aZ(c9), aZ(ca), aZ(cb)))
        else
            at(string.format("local %s = %s:Raycast(%s, %s)", _, bS, aZ(c9), aZ(ca)))
        end
        return z
    end

    bP.GetMouse = function(self)
        local bS = t.registry[bh] or "player"
        local cc = bj("mouse", false)
        local _ = aW(cc, "mouse")
        at(string.format("local %s = %s:GetMouse()", _, bS))
        return cc
    end

    bP.Kick = function(self, cd)
        local bS = t.registry[bh] or "player"
        if cd then
            at(string.format("%s:Kick(%s)", bS, aZ(cd)))
        else
            at(string.format("%s:Kick()", bS))
        end
    end

    bP.GetPropertyChangedSignal = function(self, ce)
        local cf = aE(ce)
        local bS = t.registry[bh] or "instance"
        local cg = bj(cf .. "Changed", false)
        t.registry[cg] = bS .. ":GetPropertyChangedSignal(" .. aH(cf) .. ")"
        return cg
    end


    bP.GetFullName = function(self)
        local bS = t.registry[bh] or "object"
        -- Map known top-level names to their Roblox full names
        local fullNameMap = {
            game = "Game",
            workspace = "Workspace",
            Workspace = "Workspace",
            Players = "Players",
            RunService = "RunService",
            Lighting = "Lighting",
            ReplicatedStorage = "ReplicatedStorage",
            StarterGui = "StarterGui",
            ServerStorage = "ServerStorage",
            ServerScriptService = "ServerScriptService",
            HttpService = "HttpService"
        }
        at(string.format("%s:GetFullName()", bS))
        return fullNameMap[bS] or bS
    end

    bP.GenerateGUID = function(self, wrapInCurlyBraces)
        local guid = string.format("%08x-%04x-%04x-%04x-%012x",
            math.random(0, 0xFFFFFFFF),
            math.random(0, 0xFFFF),
            math.random(0, 0xFFFF),
            math.random(0, 0xFFFF),
            math.random(0, 0xFFFFFFFFFFFF))
        at(string.format("%s:GenerateGUID(%s)", t.registry[bh] or "HttpService", tostring(wrapInCurlyBraces or false)))
        if wrapInCurlyBraces then
            return "{" .. guid .. "}"
        end
        return guid
    end

    bP.IsClient = function(self)
        at(string.format("%s:IsClient()", t.registry[bh] or "RunService"))
        return true
    end

    bP.IsServer = function(self)
        at(string.format("%s:IsServer()", t.registry[bh] or "RunService"))
        return false
    end

    bP.JSONDecode = function(self, json_str)
        local bS = t.registry[self] or "HttpService"
        at(string.format("%s:JSONDecode(%s)", bS, aZ(json_str)))
        
        if type(json_str) == "string" then
            local pos = 1
            local len = #json_str
            local parse_value
            
            local function skip_whitespace()
                while pos <= len do
                    local c = json_str:sub(pos, pos)
                    if c == " " or c == "\t" or c == "\n" or c == "\r" then pos = pos + 1 else break end
                end
            end
            
            local function parse_string()
                pos = pos + 1
                local res = ""
                while pos <= len do
                    local c = json_str:sub(pos, pos)
                    if c == '"' then
                        pos = pos + 1
                        return res
                    elseif c == '\\' then
                        local next_c = json_str:sub(pos+1, pos+1)
                        if next_c == "n" then res = res .. "\n"
                        elseif next_c == "r" then res = res .. "\r"
                        elseif next_c == "t" then res = res .. "\t"
                        else res = res .. next_c end
                        pos = pos + 2
                    else
                        res = res .. c
                        pos = pos + 1
                    end
                end
                return res
            end
            
            local function parse_array()
                pos = pos + 1
                local arr = {}
                local idx = 1
                skip_whitespace()
                if json_str:sub(pos, pos) == "]" then pos = pos + 1; local p = bj("json_array", false); t.property_store[p] = arr; return p end
                while pos <= len do
                    arr[idx] = parse_value()
                    idx = idx + 1
                    skip_whitespace()
                    local c = json_str:sub(pos, pos)
                    if c == "]" then pos = pos + 1; break
                    elseif c == "," then pos = pos + 1 end
                end
                local p = bj("json_array", false)
                t.property_store[p] = arr
                return p
            end
            
            local function parse_object()
                pos = pos + 1
                local obj = {}
                skip_whitespace()
                if json_str:sub(pos, pos) == "}" then pos = pos + 1; local p = bj("json_object", false); t.property_store[p] = obj; return p end
                while pos <= len do
                    local key = parse_string()
                    skip_whitespace()
                    if json_str:sub(pos, pos) == ":" then pos = pos + 1 end
                    local val = parse_value()
                    obj[key] = val
                    skip_whitespace()
                    local c = json_str:sub(pos, pos)
                    if c == "}" then pos = pos + 1; break
                    elseif c == "," then pos = pos + 1 end
                    skip_whitespace()
                end
                local p = bj("json_object", false)
                t.property_store[p] = obj
                return p
            end
            
            function parse_value()
                skip_whitespace()
                local c = json_str:sub(pos, pos)
                if c == '"' then return parse_string()
                elseif c == '[' then return parse_array()
                elseif c == '{' then return parse_object()
                elseif json_str:sub(pos, pos+3) == "true" then pos = pos + 4; return true
                elseif json_str:sub(pos, pos+4) == "false" then pos = pos + 5; return false
                elseif json_str:sub(pos, pos+3) == "null" then pos = pos + 4; return nil
                else
                    local start_pos = pos
                    while pos <= len and json_str:sub(pos, pos):match("[%d%.%-+eE]") do pos = pos + 1 end
                    return tonumber(json_str:sub(start_pos, pos-1)) or 0
                end
            end
            
            local success, result = pcall(parse_value)
            if success and result ~= nil then
                return result
            end
        end
        -- If it's a proxy string (URL), return a proxy that can be indexed
        if type(json_str) == "table" or (type(json_str) == "string" and json_str:match("^https?://")) then
            local p = bj("json_decoded_fallback", false)
            t.property_store[p] = {data = { {imageUrl = "rbxassetid://1"} }}
            return p
        end
        return {data = {}}
    end


    bP.IsA = function(self, bX)
        return true
    end

    bP.IsDescendantOf = function(self, ch)
        local cur = bh
        while cur do
            if cur == ch then return true end
            cur = t.parent_map[cur]
        end
        return false
    end


    bP.IsAncestorOf = function(self, ci)
        return true
    end

    bP.GetAttribute = function(self, cj)
        return nil
    end

    bP.SetAttribute = function(self, cj, bm)
        local bS = t.registry[bh] or "instance"
        at(string.format("%s:SetAttribute(%s, %s)", bS, aH(cj), aZ(bm)))
    end

    bP.GetAttributes = function(self)
        return {}
    end

    bP.GetPlayers = function(self)
        return {}
    end

    bP.GetPlayerFromCharacter = function(self, ck)
        local bS = t.registry[bh] or "Players"
        local cl = bj("player", false)
        local _ = aW(cl, "player")
        at(string.format("local %s = %s:GetPlayerFromCharacter(%s)", _, bS, aZ(ck)))
        return cl
    end

    bP.GetPlayerByUserId = function(self, cm)
        local bS = t.registry[bh] or "Players"
        local cl = bj("player", false)
        local _ = aW(cl, "player")
        at(string.format("local %s = %s:GetPlayerByUserId(%s)", _, bS, aZ(cm)))
        return cl
    end

    bP.SetCore = function(self, am, bm)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:SetCore(%s, %s)", bS, aH(am), aZ(bm)))
    end

    bP.GetCore = function(self, am)
        return nil
    end

    bP.SetCoreGuiEnabled = function(self, cn, co)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:SetCoreGuiEnabled(%s, %s)", bS, aZ(cn), aZ(co)))
    end

    bP.BindToRenderStep = function(self, am, cp, bs)
        local bS = t.registry[bh] or "RunService"
        at(string.format("%s:BindToRenderStep(%s, %s, function(deltaTime)", bS, aH(am), aZ(cp)))
        t.indent = t.indent + 1
        if j(bs) == "function" then
            xpcall(function()
                bs(0.016)
            end, function() end)
        end
        t.indent = t.indent - 1
        at("end)")
    end

    bP.UnbindFromRenderStep = function(self, am)
        local bS = t.registry[bh] or "RunService"
        at(string.format("%s:UnbindFromRenderStep(%s)", bS, aH(am)))
    end



    bP.GetDebugId = function(self)
        return "DEBUG_" .. (H(bh) or "0")
    end

    bP.MoveTo = function(self, cq, cr)
        local bS = t.registry[bh] or "humanoid"
        if cr then
            at(string.format("%s:MoveTo(%s, %s)", bS, aZ(cq), aZ(cr)))
        else
            at(string.format("%s:MoveTo(%s)", bS, aZ(cq)))
        end
    end

    bP.Move = function(self, ca, cs)
        local bS = t.registry[bh] or "humanoid"
        at(string.format("%s:Move(%s, %s)", bS, aZ(ca), aZ(cs or false)))
    end

    bP.EquipTool = function(self, ct)
        local bS = t.registry[bh] or "humanoid"
        at(string.format("%s:EquipTool(%s)", bS, aZ(ct)))
    end

    bP.UnequipTools = function(self)
        local bS = t.registry[bh] or "humanoid"
        at(string.format("%s:UnequipTools()", bS))
    end

    bP.TakeDamage = function(self, cu)
        local bS = t.registry[bh] or "humanoid"
        at(string.format("%s:TakeDamage(%s)", bS, aZ(cu)))
    end

    bP.ChangeState = function(self, cv)
        local bS = t.registry[bh] or "humanoid"
        at(string.format("%s:ChangeState(%s)", bS, aZ(cv)))
    end

    bP.GetState = function(self)
        return bj("Enum.HumanoidStateType.Running", false)
    end

    bP.SetPrimaryPartCFrame = function(self, cw)
        local bS = t.registry[bh] or "model"
        at(string.format("%s:SetPrimaryPartCFrame(%s)", bS, aZ(cw)))
    end

    bP.GetPrimaryPartCFrame = function(self)
        return CFrame.new(0, 0, 0)
    end

    bP.PivotTo = function(self, cw)
        local bS = t.registry[bh] or "model"
        at(string.format("%s:PivotTo(%s)", bS, aZ(cw)))
    end

    bP.GetPivot = function(self)
        return CFrame.new(0, 0, 0)
    end

    bP.GetBoundingBox = function(self)
        return CFrame.new(0, 0, 0), Vector3.new(1, 1, 1)
    end

    bP.GetExtentsSize = function(self)
        return Vector3.new(1, 1, 1)
    end

    bP.TranslateBy = function(self, cx)
        local bS = t.registry[bh] or "model"
        at(string.format("%s:TranslateBy(%s)", bS, aZ(cx)))
    end

    bP.LoadAnimation = function(self, cy)
        local bS = t.registry[bh] or "animator"
        local cz = bj("animTrack", false)
        local _ = aW(cz, "animTrack")
        at(string.format("local %s = %s:LoadAnimation(%s)", _, bS, aZ(cy)))
        return cz
    end

    bP.GetPlayingAnimationTracks = function(self)
        return {}
    end

    bP.AdjustSpeed = function(self, cA)
        local bS = t.registry[bh] or "animTrack"
        at(string.format("%s:AdjustSpeed(%s)", bS, aZ(cA)))
    end

    bP.AdjustWeight = function(self, cB, cC)
        local bS = t.registry[bh] or "animTrack"
        if cC then
            at(string.format("%s:AdjustWeight(%s, %s)", bS, aZ(cB), aZ(cC)))
        else
            at(string.format("%s:AdjustWeight(%s)", bS, aZ(cB)))
        end
    end

    bP.Teleport = function(self, cD, cl, cE, cF)
        local bS = t.registry[bh] or "TeleportService"
        at(string.format("%s:Teleport(%s, %s%s%s)", bS, aZ(cD), aZ(cl), cE and ", " .. aZ(cE) or '"', cF and ", " .. aZ(cF) or ""))
    end

    bP.TeleportToPlaceInstance = function(self, cD, cG, cl)
        local bS = t.registry[bh] or "TeleportService"
        at(string.format("%s:TeleportToPlaceInstance(%s, %s, %s)", bS, aZ(cD), aZ(cG), aZ(cl)))
    end

    bP.PlayLocalSound = function(self, cH)
        local bS = t.registry[bh] or "SoundService"
        at(string.format("%s:PlayLocalSound(%s)", bS, aZ(cH)))
    end

    -- ============================================
    -- GUI Methods (GuiObject, ScreenGui, etc.)
    -- ============================================

    -- TweenPosition: animates GUI element position
    bP.TweenPosition = function(self, endPosition, easingDirection, easingStyle, time, override, callback)
        local bS = t.registry[bh] or "guiObject"
        local args = {aZ(endPosition)}
        if easingDirection then table.insert(args, aZ(easingDirection)) end
        if easingStyle then table.insert(args, aZ(easingStyle)) end
        if time then table.insert(args, aZ(time)) end
        if override ~= nil then table.insert(args, aZ(override)) end
        at(string.format("%s:TweenPosition(%s)", bS, table.concat(args, ", ")))
        -- Update stored position
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Position = endPosition
        -- Execute callback if provided
        if callback and type(callback) == "function" then
            xpcall(function() callback(true) end, function() end)
        end
        return true
    end

    -- TweenSize: animates GUI element size
    bP.TweenSize = function(self, endSize, easingDirection, easingStyle, time, override, callback)
        local bS = t.registry[bh] or "guiObject"
        local args = {aZ(endSize)}
        if easingDirection then table.insert(args, aZ(easingDirection)) end
        if easingStyle then table.insert(args, aZ(easingStyle)) end
        if time then table.insert(args, aZ(time)) end
        if override ~= nil then table.insert(args, aZ(override)) end
        at(string.format("%s:TweenSize(%s)", bS, table.concat(args, ", ")))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Size = endSize
        if callback and type(callback) == "function" then
            xpcall(function() callback(true) end, function() end)
        end
        return true
    end

    -- TweenSizeAndPosition: animates both size and position
    bP.TweenSizeAndPosition = function(self, endSize, endPosition, easingDirection, easingStyle, time, override, callback)
        local bS = t.registry[bh] or "guiObject"
        local args = {aZ(endSize), aZ(endPosition)}
        if easingDirection then table.insert(args, aZ(easingDirection)) end
        if easingStyle then table.insert(args, aZ(easingStyle)) end
        if time then table.insert(args, aZ(time)) end
        if override ~= nil then table.insert(args, aZ(override)) end
        at(string.format("%s:TweenSizeAndPosition(%s)", bS, table.concat(args, ", ")))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Size = endSize
        t.property_store[bh].Position = endPosition
        if callback and type(callback) == "function" then
            xpcall(function() callback(true) end, function() end)
        end
        return true
    end

    -- TextBox: CaptureFocus / ReleaseFocus / IsFocused
    bP.CaptureFocus = function(self)
        local bS = t.registry[bh] or "textBox"
        at(string.format("%s:CaptureFocus()", bS))
    end

    bP.ReleaseFocus = function(self, submitted)
        local bS = t.registry[bh] or "textBox"
        if submitted ~= nil then
            at(string.format("%s:ReleaseFocus(%s)", bS, aZ(submitted)))
        else
            at(string.format("%s:ReleaseFocus()", bS))
        end
    end

    bP.IsFocused = function(self)
        local bS = t.registry[bh] or "textBox"
        at(string.format("%s:IsFocused()", bS))
        return false
    end

    -- ScrollingFrame: methods
    bP.ScrollToTop = function(self)
        local bS = t.registry[bh] or "scrollingFrame"
        at(string.format("%s.CanvasPosition = Vector2.new(0, 0)", bS))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].CanvasPosition = Vector2.new(0, 0)
    end

    bP.GetCanvasSize = function(self)
        local bS = t.registry[bh] or "scrollingFrame"
        local ps = t.property_store[bh]
        if ps and ps.CanvasSize then return ps.CanvasSize end
        return UDim2.new(0, 0, 2, 0)
    end

    -- ============================================
    -- Sound Methods
    -- ============================================

    bP.Play = function(self)
        local bS = t.registry[bh] or "tween"
        at(string.format("%s:Play()", bS))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Playing = true
        t.property_store[bh].IsPlaying = true
    end

    bP.Stop = function(self)
        local bS = t.registry[bh] or "tween"
        at(string.format("%s:Stop()", bS))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Playing = false
        t.property_store[bh].IsPlaying = false
        t.property_store[bh].TimePosition = 0
    end

    bP.Pause = function(self)
        local bS = t.registry[bh] or "tween"
        at(string.format("%s:Pause()", bS))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Playing = false
        t.property_store[bh].IsPlaying = false
    end

    bP.Resume = function(self)
        local bS = t.registry[bh] or "sound"
        at(string.format("%s:Resume()", bS))
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh].Playing = true
        t.property_store[bh].IsPlaying = true
    end

    -- ============================================
    -- StarterGui Methods (SetCore, GetCore, etc.)
    -- ============================================

    bP.SetCore = function(self, parameterName, value)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:SetCore(%s, %s)", bS, aH(aE(parameterName)), aZ(value)))
    end

    bP.GetCore = function(self, parameterName)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:GetCore(%s)", bS, aH(aE(parameterName))))
        return false
    end

    bP.SetCoreGuiEnabled = function(self, coreGuiType, enabled)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:SetCoreGuiEnabled(%s, %s)", bS, aZ(coreGuiType), aZ(enabled)))
    end

    bP.GetCoreGuiEnabled = function(self, coreGuiType)
        local bS = t.registry[bh] or "StarterGui"
        at(string.format("%s:GetCoreGuiEnabled(%s)", bS, aZ(coreGuiType)))
        return true
    end

    -- ============================================
    -- RunService Methods
    -- ============================================

    bP.BindToRenderStep = function(self, name, priority, callback)
        local bS = t.registry[bh] or "RunService"
        at(string.format("%s:BindToRenderStep(%s, %s, function(deltaTime)", bS, aH(aE(name)), aZ(priority)))
        t.indent = t.indent + 1
        if type(callback) == "function" then
            for i = 1, 3 do
                xpcall(function() callback(0.016) end, function() end)
            end
        end
        t.indent = t.indent - 1
        at("end)")
    end

    bP.UnbindFromRenderStep = function(self, name)
        local bS = t.registry[bh] or "RunService"
        at(string.format("%s:UnbindFromRenderStep(%s)", bS, aH(aE(name))))
    end

    bP.IsStudio = function(self)
        at(string.format("%s:IsStudio()", t.registry[bh] or "RunService"))
        return false
    end

    bP.IsRunning = function(self)
        at(string.format("%s:IsRunning()", t.registry[bh] or "RunService"))
        return true
    end

    -- ============================================
    -- UserInputService Methods
    -- ============================================

    bP.GetMouseLocation = function(self)
        local bS = t.registry[bh] or "UserInputService"
        at(string.format("%s:GetMouseLocation()", bS))
        return Vector2.new(960, 540)
    end

    bP.IsKeyDown = function(self, keyCode)
        local bS = t.registry[bh] or "UserInputService"
        at(string.format("%s:IsKeyDown(%s)", bS, aZ(keyCode)))
        return false
    end

    bP.IsMouseButtonPressed = function(self, mouseButton)
        local bS = t.registry[bh] or "UserInputService"
        at(string.format("%s:IsMouseButtonPressed(%s)", bS, aZ(mouseButton)))
        return false
    end

    bP.GetMouseDelta = function(self)
        local bS = t.registry[bh] or "UserInputService"
        at(string.format("%s:GetMouseDelta()", bS))
        return Vector2.new(0, 0)
    end

    bP.IsGamepadConnected = function(self, gamepadNum)
        return false
    end

    bP.GetGamepadConnected = function(self)
        return false
    end

    bP.GetFocusedTextBox = function(self)
        return nil
    end

    -- ============================================
    -- Players Methods
    -- ============================================

    bP.GetPlayers = function(self)
        local bS = t.registry[bh] or "Players"
        local z = bj("players", false)
        at(string.format("for _, player in %s:GetPlayers() do", bS))
        t.indent = t.indent + 1
        t.pending_iterator = true
        return {}
    end

    bP.GetPlayerFromCharacter = function(self, character)
        local bS = t.registry[bh] or "Players"
        local z = bj("player", false)
        local _ = aW(z, "player")
        at(string.format("local %s = %s:GetPlayerFromCharacter(%s)", _, bS, aZ(character)))
        return z
    end

    bP.GetPlayerByUserId = function(self, userId)
        local bS = t.registry[bh] or "Players"
        local z = bj("player", false)
        local _ = aW(z, "player")
        at(string.format("local %s = %s:GetPlayerByUserId(%s)", _, bS, aZ(userId)))
        return z
    end

    -- ============================================
    -- Debris, PathfindingService, etc.
    -- ============================================

    bP.AddItem = function(self, cN, cO)
        local bS = t.registry[bh] or "Debris"
        at(string.format("%s:AddItem(%s, %s)", bS, aZ(cN), aZ(cO or 10)))
    end

    bP.CreatePath = function(self, params)
        local bS = t.registry[bh] or "PathfindingService"
        local z = bj("path", false)
        local _ = aW(z, "path")
        at(string.format("local %s = %s:CreatePath(%s)", _, bS, aZ(params)))
        return z
    end

    bP.ComputeAsync = function(self, start, finish)
        local bS = t.registry[bh] or "path"
        at(string.format("%s:ComputeAsync(%s, %s)", bS, aZ(start), aZ(finish)))
    end

    bP.GetWaypoints = function(self)
        local bS = t.registry[bh] or "path"
        at(string.format("%s:GetWaypoints()", bS))
        return {}
    end

    -- ============================================
    -- MarketplaceService
    -- ============================================

    bP.PromptPurchase = function(self, player, assetId)
        local bS = t.registry[bh] or "MarketplaceService"
        at(string.format("%s:PromptPurchase(%s, %s)", bS, aZ(player), aZ(assetId)))
    end

    bP.PromptGamePassPurchase = function(self, player, gamePassId)
        local bS = t.registry[bh] or "MarketplaceService"
        at(string.format("%s:PromptGamePassPurchase(%s, %s)", bS, aZ(player), aZ(gamePassId)))
    end

    bP.UserOwnsGamePassAsync = function(self, userId, gamePassId)
        local bS = t.registry[bh] or "MarketplaceService"
        at(string.format("%s:UserOwnsGamePassAsync(%s, %s)", bS, aZ(userId), aZ(gamePassId)))
        return false
    end

    bP.GetProductInfo = function(self, assetId, infoType)
        local bS = t.registry[bh] or "MarketplaceService"
        at(string.format("%s:GetProductInfo(%s)", bS, aZ(assetId)))
        return {Name = "Product", Description = "", PriceInRobux = 0, Creator = {Name = "Roblox"}, AssetId = assetId or 0, AssetTypeId = 0, IsForSale = false, IsLimited = false, IsLimitedUnique = false, IsNew = false, Sales = 0}
    end

    -- ============================================
    -- ContentProvider
    -- ============================================

    bP.PreloadAsync = function(self, contentIdList, callback)
        local bS = t.registry[bh] or "ContentProvider"
        at(string.format("%s:PreloadAsync(%s)", bS, aZ(contentIdList)))
        if callback and type(callback) == "function" then
            xpcall(function() callback("rbxassetid://0", "Enum.AssetFetchStatus.Success") end, function() end)
        end
    end

    -- ============================================
    -- GuiService
    -- ============================================

    bP.GetGuiInset = function(self)
        local bS = t.registry[bh] or "GuiService"
        at(string.format("%s:GetGuiInset()", bS))
        return Vector2.new(0, 36), Vector2.new(0, 0)
    end

    bP.IsTenFootInterface = function(self)
        return false
    end

    bP.GetEmotesMenuOpen = function(self)
        return false
    end

    bP.SetEmotesMenuOpen = function(self, open)
        local bS = t.registry[bh] or "GuiService"
        at(string.format("%s:SetEmotesMenuOpen(%s)", bS, aZ(open)))
    end


    bP.GetAsync = function(self, cI)
        local cL = aE(cI)
        sniff(cL, "GetAsync")
        table.insert(t.string_refs, {value = cL, hint = "HTTP URL (GetAsync)"})
        t.last_http_url = cL
        return "{}"
    end

    bP.PostAsync = function(self, cI, cJ)
        local cL = aE(cI)
        sniff(cL, "PostAsync")
        table.insert(t.string_refs, {value = cL, hint = "HTTP POST URL (PostAsync)"})
        return "{}"
    end

    bP.RequestAsync = function(self, options)
        local url = type(options) == "table" and options.Url or (type(options) == "string" and options or "")
        sniff(url, "RequestAsync")
        table.insert(t.string_refs, {value = url, hint = "HTTP Request URL (RequestAsync)"})
        return {Body = "{}", StatusCode = 200, Success = true}
    end

    bP.JSONEncode = function(self, cJ)
        return "{}"
    end


    bP.HttpGet = function(self, cI)
        local cL = aE(cI)
        sniff(cL, "HttpGet")
        table.insert(t.string_refs, {value = cL, hint = "HTTP URL"})
        t.last_http_url = cL
        if cL:match("thumbnails") then
            return '{"data":[{"imageUrl":"rbxassetid://3944680095"}]}'
        end
        if cL:match("ipwho%.is") then
            return '{"ip":"127.0.0.1"}'
        end
        return "{}"
    end

    bP.HttpGetAsync = function(self, cI)
        local cL = aE(cI)
        table.insert(t.string_refs, {value = cL, hint = "HTTP URL (HttpGetAsync)"})
        table.insert(t.link_spy, {url = cL, method = "HttpGetAsync", from = t.registry[self] or "game"})
        t.last_http_url = cL
        B("[LINK SPY] HttpGetAsync: " .. cL)
        if cL:match("thumbnails") then
            return '{"data":[{"imageUrl":"rbxassetid://3944680095"}]}'
        end
        return "{}"
    end

    bP.HttpPost = function(self, cI, cJ, cM)
        local cL = aE(cI)
        sniff(cL, "HttpPost")
        table.insert(t.string_refs, {value = cL, hint = "HTTP POST URL"})
        local x = bj("HttpResponse", false)
        local _ = aW(x, "httpResponse")
        local bS = t.registry[bh] or "HttpService"
        t.property_store[x] = {Body = "{}", StatusCode = 200, Success = true}
        return x
    end

    bP.HttpPostAsync = function(self, cI, cJ, cM)
        local cL = aE(cI)
        table.insert(t.string_refs, {value = cL, hint = "HTTP POST URL (HttpPostAsync)"})
        table.insert(t.link_spy, {url = cL, method = "HttpPostAsync", from = t.registry[bh] or "HttpService"})
        B("[LINK SPY] HttpPostAsync: " .. cL)
        local x = bj("HttpResponse", false)
        local bS = t.registry[bh] or "HttpService"
        t.property_store[x] = {Body = "{}", StatusCode = 200, Success = true}
        return x
    end

    bP.AddItem = function(self, cN, cO)
        local bS = t.registry[bh] or "Debris"
        at(string.format("%s:AddItem(%s, %s)", bS, aZ(cN), aZ(cO or 10)))
    end

    bi.__index = function(b2, b4)
        t.op_count = t.op_count + 1
        if t.op_count >= r.MAX_OPS then
            error("DUMP_LOOP_LIMIT_EXCEEDED")
        end
        if b4 == F or b4 == "__proxy_id" or b4 == v then
            local val = rawget(b2, b4)
            if val ~= nil then return val end
            local meta = k(b2)
            if meta and meta[b4] ~= nil then return meta[b4] end
            return nil
        end
        
        -- Fix "integer index" crash: handle non-string keys (like numbers) early
        if j(b4) ~= "string" then
            if r.VERBOSE then
                B("[INDEX] " .. (t.registry[bh] or "object") .. " non-string index: " .. m(b4))
            end
            local ps = t.property_store[bh]
            if ps and ps[b4] ~= nil then
                return ps[b4]
            end
            return nil
        else
            -- TRACK NAMECALL: Last string indexed is likely a method
            t.last_namecall_method = b4
        end
        
        -- DEBUG: Log all index accesses if verbose or if they are suspicious
        if r.VERBOSE or b4 == "?" then
            B("[INDEX] " .. (t.registry[bh] or "object") .. " index: " .. m(b4))
        end
        
        -- Check destroyed state (Roblox errors on indexing destroyed instances, except for internal keys)
        local ps = t.property_store[bh]
        if ps and ps._destroyed and b4 ~= "Parent" and b4 ~= "Archivable" then
            -- Roblox allows reading Parent (returns nil) and Archivable on destroyed instances
            if b4 == "Parent" then return nil end
        end
        
        if b4 == "PlaceId" or b4 == "GameId" or b4 == "placeId" or b4 == "gameId" then
            return u
        end
        local bS = t.registry[bh] or aT or "object"
        local cP = aE(b4)
        
        -- Return Heartbeat proxy directly
        if b4 == "Heartbeat" and bS:match("RunService") then
            return bP.Heartbeat
        end
        
        -- Parent must always come from parent_map (Destroy clears it)
        if b4 == "Parent" then
            return t.parent_map[bh]
        end
        if t.property_store[bh] and t.property_store[bh][b4] ~= nil then
            local ps_val = t.property_store[bh][b4]
            if ps_val == JSON_NIL then return nil end
            return ps_val
        end
        -- DEBUG: trace numeric key misses on json proxies
        if type(b4) == "number" and bS:match("json") then
            B("[ JSON_DEBUG ] key=" .. tostring(b4) .. " bS=" .. bS .. " has_ps=" .. tostring(t.property_store[bh] ~= nil))
            if t.property_store[bh] then
                local count = 0
                for k,v in pairs(t.property_store[bh]) do count = count + 1 end
                B("[ JSON_DEBUG ] ps_count=" .. count)
            end
        elseif b4 == "Name" then
            -- Do not update registry with Name to avoid breakages in output code
        end
        
        -- Heartbeat Simulator setup
        if bP[cP] then
            if cP == "Heartbeat" then
                local hb = bj("Heartbeat", false)
                t.registry[hb] = "RunService.Heartbeat"
                return hb
            end
            local cQ, cR = bg()
            t.registry[cQ] = bS .. "." .. cP
            cR.__call = function(W, ...)
                local bA = {...}
                if bA[1] == bh or G(bA[1]) and bA[1] ~= cQ then
                    table.remove(bA, 1)
                end
                return bP[cP](bh, table.unpack(bA))
            end
            cR.__index = function(W, cS)
                if cS == F or cS == "__proxy_id" then
                    return rawget(cQ, cS)
                end
                return bj(cS, false, cQ)
            end
            cR.__tostring = function()
                return bS .. ":" .. cP
            end
            return cQ
        end
        if bS == "fenv" or bS == "getgenv" or bS == "_G" then
            if b4 == "game" then
                return game
            end
            if b4 == "workspace" then
                return workspace
            end
            if b4 == "script" then
                return script
            end
            if b4 == "Enum" then
                return Enum
            end
            if _G[b4] ~= nil then
                return _G[b4]
            end
            return nil
        end
        if bS == "game" or bS == "Game" then
            -- Support service access via index: game.HttpService
            if aJ[b4] or aK[b4] then
                return bP.GetService(bh, b4)
            end
        end
        if b4 == "Name" then
            -- Return stored Name from property_store first, then fall back to aT
            local ps2 = t.property_store[bh]
            if ps2 and ps2.Name then
                return ps2.Name
            end
            return aT or "Object"
        end
        if b4 == "ClassName" then
            local props = t.property_store[bh]
            if props and props.ClassName then
                return props.ClassName
            end
            -- Map known service names to their real ClassNames
            local classNameMap = {
                game = "DataModel",
                workspace = "Workspace",
                RunService = "RunService",
                Players = "Players",
                ReplicatedStorage = "ReplicatedStorage",
                Lighting = "Lighting",
                StarterGui = "StarterGui",
                UserInputService = "UserInputService",
                TweenService = "TweenService",
                HttpService = "HttpService",
                MarketplaceService = "MarketplaceService",
                SoundService = "SoundService",
                CoreGui = "CoreGui"
            }
            return classNameMap[aT] or aT or "Instance"
        end
        if b4 == "DistributedGameTime" then
            return t.fake_time
        end
        if b4 == "Value" then
            -- For Enum items, return their numeric value
            local regName = t.registry[bh] or ""
            if regName:match("^Enum%.") then
                local enumValues = {
                    ["Enum.Material.Plastic"] = 256,
                    ["Enum.Material.Wood"] = 512,
                    ["Enum.Material.Slate"] = 800,
                    ["Enum.Material.Concrete"] = 816,
                    ["Enum.Material.CorrodedMetal"] = 1040,
                    ["Enum.Material.DiamondPlate"] = 1056,
                    ["Enum.Material.Foil"] = 1072,
                    ["Enum.Material.Grass"] = 1280,
                    ["Enum.Material.Ice"] = 1536,
                    ["Enum.Material.Marble"] = 784,
                    ["Enum.Material.Granite"] = 832,
                    ["Enum.Material.Brick"] = 848,
                    ["Enum.Material.Pebble"] = 864,
                    ["Enum.Material.Sand"] = 1296,
                    ["Enum.Material.Fabric"] = 1312,
                    ["Enum.Material.SmoothPlastic"] = 272,
                    ["Enum.Material.Metal"] = 1024,
                    ["Enum.Material.WoodPlanks"] = 528,
                    ["Enum.Material.Cobblestone"] = 880,
                    ["Enum.Material.Neon"] = 288,
                    ["Enum.Material.Glass"] = 1568,
                    ["Enum.Material.ForceField"] = 1584,
                    ["Enum.HumanoidStateType.Dead"] = 15,
                    ["Enum.HumanoidStateType.Running"] = 8,
                    ["Enum.HumanoidStateType.Jumping"] = 3,
                    ["Enum.HumanoidStateType.Freefall"] = 6,
                    ["Enum.KeyCode.W"] = 119,
                    ["Enum.KeyCode.A"] = 97,
                    ["Enum.KeyCode.S"] = 115,
                    ["Enum.KeyCode.D"] = 100
                }
                return enumValues[regName] or 0
            end
            -- Generic Value property for ValueObjects
            local props = t.property_store[bh]
            if props and props.Value ~= nil then
                return props.Value
            end
            return "input"
        end
        if b4 == "LocalPlayer" then
            local cT = bj("LocalPlayer", false, bh)
            local _ = aW(cT, "LocalPlayer")
            at(string.format("local %s = %s.LocalPlayer", _, bS))
            return cT
        end
        if b4 == "PlayerGui" then
            return bj("PlayerGui", false, bh)
        end
        if b4 == "Backpack" then
            return bj("Backpack", false, bh)
        end
        if b4 == "PlayerScripts" then
            return bj("PlayerScripts", false, bh)
        end
        if b4 == "UserId" then
            return 1
        end
        if b4 == "DisplayName" then
            return "Player"
        end
        if b4 == "AccountAge" then
            return 1000
        end
        if b4 == "Team" then
            return bj("Team", false, bh)
        end
        if b4 == "TeamColor" then
            return BrickColor.new("White")
        end
        if b4 == "Character" then
            local cT = bj("Character", false, bh)
            if not t.registry[cT] then
                local _ = aW(cT, "Character")
                local bS = t.registry[bh] or "LocalPlayer"
                at(string.format("local %s = %s.Character", _, bS))
            end
            return cT
        end
        if b4 == "Humanoid" then
            local cU = bj("Humanoid", false, bh)
            t.property_store[cU] = {Health = 100, MaxHealth = 100, WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2}
            return cU
        end
        if b4 == "HumanoidRootPart" or b4 == "PrimaryPart" or b4 == "RootPart" then
            local cV = bj("HumanoidRootPart", false, bh)
            t.property_store[cV] = {Position = Vector3.new(0, 5, 0), CFrame = CFrame.new(0, 5, 0)}
            return cV
        end
        local cW = {"Head", "Torso", "UpperTorso", "LowerTorso", "RightArm", "LeftArm", "RightLeg", "LeftLeg", "RightHand", "LeftHand", "RightFoot", "LeftFoot"}
        for W, cr in ipairs(cW) do
            if b4 == cr then
                return bj(b4, false, bh)
            end
        end
        if b4 == "Animator" then
            return bj("Animator", false, bh)
        end
        if b4 == "CurrentCamera" or b4 == "Camera" then
            local cX = bj("Camera", false, bh)
            t.property_store[cX] = {CFrame = CFrame.new(0, 10, 0), FieldOfView = 70, ViewportSize = Vector2.new(1920, 1080)}
            return cX
        end
        if b4 == "CameraType" then
            return bj("Enum.CameraType.Custom", false)
        end
        if b4 == "CameraSubject" then
            return bj("Humanoid", false, bh)
        end
        local cY = {Health = 100, MaxHealth = 100, WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2, HipHeight = 2, Transparency = 0, Mass = 1, Value = 0, TimePosition = 0, TimeLength = 1, Volume = 0.5, PlaybackSpeed = 1, Brightness = 1, Range = 60, Angle = 90, FieldOfView = 70, Size = 1, Thickness = 1, ZIndex = 1, LayoutOrder = 0}
        if cY[b4] then
            return bl(cY[b4])
        end
        local cZ = {Visible = true, Enabled = true, Anchored = false, CanCollide = true, Locked = false, Active = true, Draggable = false, Modal = false, Playing = false, Looped = false, IsPlaying = false, AutoPlay = false, Archivable = true, ClipsDescendants = false, RichText = false, TextWrapped = false, TextScaled = false, PlatformStand = false, AutoRotate = true, Sit = false}
        if cZ[b4] ~= nil then
            return cZ[b4]
        end
        if b4 == "AbsoluteSize" or b4 == "ViewportSize" then
            return Vector2.new(1920, 1080)
        end
        if b4 == "AbsolutePosition" then
            return Vector2.new(0, 0)
        end
        if b4 == "Position" then
            if aT and (aT:match("Part") or aT:match("Model") or aT:match("Character") or aT:match("Root")) then
                return Vector3.new(0, 5, 0)
            end
            return UDim2.new(0, 0, 0, 0)
        end
        if b4 == "Size" then
            if aT and aT:match("Part") then
                return Vector3.new(4, 1, 2)
            end
            return UDim2.new(1, 0, 1, 0)
        end
        if b4 == "CFrame" then
            return CFrame.new(0, 5, 0)
        end
        if b4 == "Velocity" or b4 == "AssemblyLinearVelocity" then
            return Vector3.new(0, 0, 0)
        end
        if b4 == "RotVelocity" or b4 == "AssemblyAngularVelocity" then
            return Vector3.new(0, 0, 0)
        end
        if b4 == "Orientation" or b4 == "Rotation" then
            return Vector3.new(0, 0, 0)
        end
        if b4 == "LookVector" then
            return Vector3.new(0, 0, -1)
        end
        if b4 == "RightVector" then
            return Vector3.new(1, 0, 0)
        end
        if b4 == "UpVector" then
            return Vector3.new(0, 1, 0)
        end
        if b4 == "Color" or b4 == "Color3" or b4 == "BackgroundColor3" or b4 == "BorderColor3" or b4 == "TextColor3" or b4 == "PlaceholderColor3" or b4 == "ImageColor3" then
            return Color3.new(1, 1, 1)
        end
        if b4 == "BrickColor" then
            return BrickColor.new("Medium stone grey")
        end
        if b4 == "Material" then
            return bj("Enum.Material.Plastic", false)
        end
        if b4 == "Hit" then
            return CFrame.new(0, 0, -10)
        end
        if b4 == "Origin" then
            return CFrame.new(0, 5, 0)
        end
        if b4 == "Target" then
            return bj("Target", false, bh)
        end
        if b4 == "X" or b4 == "Y" then
            return 0
        end
        if b4 == "UnitRay" then
            return Ray.new(Vector3.new(0, 5, 0), Vector3.new(0, 0, -1))
        end
        if b4 == "ViewSizeX" then
            return 1920
        end
        if b4 == "ViewSizeY" then
            return 1080
        end
        if b4 == "Text" or b4 == "PlaceholderText" or b4 == "ContentText" or b4 == "Value" then
            if s then
                return s
            end
            if b4 == "Value" then
                return "input"
            end
            return '"'
        end
        if b4 == "TextBounds" then
            return Vector2.new(0, 0)
        end
        if b4 == "Font" then
            return bj("Enum.Font.SourceSans", false)
        end
        if b4 == "TextSize" then
            return 14
        end
        if b4 == "Image" or b4 == "ImageContent" then
            return '"'
        end
        local c_ = {"Changed", "ChildAdded", "ChildRemoved", "DescendantAdded", "DescendantRemoving", "Touched", "TouchEnded", "InputBegan", "InputEnded", "InputChanged", "MouseButton1Click", "MouseButton1Down", "MouseButton1Up", "MouseButton2Click", "MouseButton2Down", "MouseButton2Up", "MouseEnter", "MouseLeave", "MouseMoved", "MouseWheelForward", "MouseWheelBackward", "Activated", "Deactivated", "FocusLost", "FocusGained", "Focused", "Heartbeat", "RenderStepped", "Stepped", "CharacterAdded", "CharacterRemoving", "CharacterAppearanceLoaded", "PlayerAdded", "PlayerRemoving", "AncestryChanged", "AttributeChanged", "Died", "FreeFalling", "GettingUp", "Jumping", "Running", "Seated", "Swimming", "StateChanged", "HealthChanged", "MoveToFinished", "OnClientEvent", "OnServerEvent", "OnClientInvoke", "OnServerInvoke", "Completed", "DidLoop", "Stopped", "Button1Down", "Button1Up", "Button2Down", "Button2Up", "Idle", "Move", "TextChanged", "ReturnPressedFromOnScreenKeyboard", "Triggered", "TriggerEnded", "Loaded"}
        for W, d0 in ipairs(c_) do
            if b4 == d0 then
                local cg = bj(bS .. "." .. b4, false, bh)
                t.registry[cg] = bS .. "." .. b4
                return cg
            end
        end
        -- Unified recursion (replaces bk)
        local res = bj(cP, false, bh)
        if r.VERBOSE or b4 == "?" then
            B("[FALLBACK] " .. (t.registry[bh] or "object") .. " index: " .. m(b4) .. " -> " .. (t.registry[res] or "proxy"))
        end
        return res
    end

    bi.__newindex = function(b2, b4, b5)
        t.op_count = t.op_count + 1
        if t.op_count >= r.MAX_OPS then
            error("DUMP_LOOP_LIMIT_EXCEEDED")
        end
        if b4 == F or b4 == "__proxy_id" then
            rawset(b2, b4, b5)
            return
        end
        
        -- Check if destroyed (authentic Roblox: errors on property set after Destroy)
        local ps = t.property_store[bh]
        if ps and ps._destroyed then
            error("The Parent property of " .. (t.registry[bh] or "object") .. " is locked", 0)
        end
        
        local bS = t.registry[bh] or aT or "object"
        local cP = aE(b4)
        t.property_store[bh] = t.property_store[bh] or {}
        t.property_store[bh][b4] = b5
        
        -- Sniff links in all string property assignments
        if j(b5) == "string" then
            sniff(b5, "Property." .. cP)
        end
        
        if b4 == "Parent" then
            t.parent_map[bh] = b5
            -- Setting Parent to nil removes from parent (like Roblox)
            if b5 == nil then
                t.parent_map[bh] = nil
            end
        elseif b4 == "Name" then
            -- Update the stored Name property (used by __index for .Name)
            -- Registry name stays the same to keep output code stable
            t.property_store[bh].Name = b5
        end
        
        at(string.format("%s.%s = %s", bS, cP, aZ(b5)))
    end

    bi.__call = function(self, bz, ...)
        t.op_count = t.op_count + 1
        if t.op_count >= r.MAX_OPS then
            error("DUMP_LOOP_LIMIT_EXCEEDED")
        end
        local bA
        if bz == bh or bz == bw or G(bz) then bA = {...} else bA = {bz, ...} end
        
        local myPath = t.registry[bh] or aT or "func"
        if myPath == "game" or myPath == "workspace" or myPath == "script" or myPath == "Instance" then
            error("attempt to call an Instance value", 0)
        end
        local parentProxy = t.parent_map[bh]
        local parentName = parentProxy and t.registry[parentProxy]
        local myShortName = myPath:match("%.([^%.]+)$") or myPath
        
        -- dtc11 bypass: Error on unknown method calls on strict instances
        if parentProxy then
            local pName = t.registry[parentProxy] or "object"
            local isValueType = pName == "Enum" or pName:match("^Enum%.") or pName:match("^Vector3") or pName:match("^CFrame") or pName:match("^Color3") or pName:match("^UDim") or pName:match("^Ray")
            local isStrictInstance = pName == "game" or pName == "workspace" or pName == "script" or pName:match("^Instance") or pName == "DataModel"
            
            if isStrictInstance and not isValueType and not bP[myShortName] then
                error(myShortName .. " is not a valid member of " .. pName)
            end
        end
        
        local z = bj("result", false, bh)
        local _ = aW(z, "result")
        
        local bK = {}
        for L, b5 in ipairs(bA) do
            -- Sniff all string arguments for links (catches HttpGet URLs, SetCore notifications, etc.)
            if j(b5) == "string" then sniff(b5, "Call." .. myShortName) end
            table.insert(bK, aZ(b5))
        end
        
        if parentProxy and parentName then
            at(string.format("local %s = %s:%s(%s)", _, parentName, myShortName, table.concat(bK, ", ")))
        else
            at(string.format("local %s = %s(%s)", _, myPath, table.concat(bK, ", ")))
        end
        return z
    end

    local function d3(d4)
        local function d5(bo, aa)
            local bh, bi = bg()
            local d6 = "0"
            if bo ~= nil then
                d6 = t.registry[bo] or aZ(bo)
            end
            local d7 = "0"
            if aa ~= nil then
                d7 = t.registry[aa] or aZ(aa)
            end
            local val1 = type(bo) == "string" and bo or (type(bo) == "table" and rawget(bo, "__value"))
            local val2 = type(aa) == "string" and aa or (type(aa) == "table" and rawget(aa, "__value"))
            if type(val1) == "string" and type(val2) == "string" then
                sniff(val1 .. val2, "Concatenation")
            end

            local d8 = "(" .. d6 .. " " .. d4 .. " " .. d7 .. ")"
            sniff(d8, "Concatenation Path")
            t.registry[bh] = d8
            bi.__tostring = function()
                return d8
            end
            bi.__call = function()
                return bh
            end
            bi.__index = function(W, b4)
                if b4 == F or b4 == "__proxy_id" then
                    return rawget(bh, b4)
                end
                return bj(d8 .. "." .. aE(b4), false)
            end
            bi.__add = d3("+")
            bi.__sub = d3("-")
            bi.__mul = d3("*")
            bi.__div = d3("/")
            bi.__mod = d3("%")
            bi.__pow = d3("^")
            bi.__concat = d3("..")
            bi.__eq = function()
                return false
            end
            bi.__lt = function()
                return false
            end
            bi.__le = function()
                return false
            end
            return bh
        end
        return d5
    end

    bi.__add = d3("+")
    bi.__sub = d3("-")
    bi.__mul = d3("*")
    bi.__div = d3("/")
    bi.__mod = d3("%")
    bi.__pow = d3("^")
    bi.__concat = d3("..")
    bi.__eq = function()
        return false
    end
    bi.__lt = function()
        return false
    end
    bi.__le = function()
        return false
    end
    bi.__unm = function(bo)
        local z, d9 = bg()
        t.registry[z] = "(-" .. (t.registry[bo] or aZ(bo)) .. ")"
        d9.__tostring = function()
            return t.registry[z]
        end
        return z
    end
    bi.__len = function()
        return 0
    end
    bi.__tostring = function()
        return t.registry[bh] or aT or "Object"
    end
    bi.__pairs = function()
        return function()
            return nil
        end, bh, nil
    end
    bi.__ipairs = bi.__pairs

    return bh
end

local function da(am, db)
    local dc = {}
    local dd = {}
    dd.__index = function(b2, b4)
        if b4 == "new" or db and db[b4] then
            return function(...)
                local bA = {...}
                local c5 = {}
                for W, b5 in ipairs(bA) do
                    table.insert(c5, aZ(b5))
                end
                local d8 = am .. "." .. b4 .. "(" .. table.concat(c5, ", ") .. ")"
                local bh, de = bg()
                t.registry[bh] = d8
                de.__tostring = function()
                    return d8
                end
                de.__index = function(W, bG)
                    if bG == F or bG == "__proxy_id" or bG == v then
                        return rawget(bh, bG)
                    end
                    if bG == "Scale" or bG == "Offset" then
                        return 0
                    end
                    if bG == "X" or bG == "Y" then
                        if am == "UDim2" then
                            return bj("UDim", false, bh)
                        end
                        local p = t.property_store[bh]
                        return p and p[bG] or 0
                    end
                    if bG == "Z" or bG == "W" then
                        local p = t.property_store[bh]
                        return p and p[bG] or 0
                    end
                    if bG == "Magnitude" then
                        local p = t.property_store[bh]
                        if p and p.X and p.Y and p.Z then
                            return math.sqrt(p.X^2 + p.Y^2 + p.Z^2)
                        end
                        return 0
                    end
                    if bG == "Unit" then
                        return bh
                    end
                    if bG == "Position" then
                        return bh
                    end
                    if bG == "CFrame" then
                        return bh
                    end
                    if bG == "LookVector" or bG == "RightVector" or bG == "UpVector" then
                        return bh
                    end
                    if bG == "Rotation" then
                        return bh
                    end
                    if bG == "R" or bG == "G" or bG == "B" then
                        return 1
                    end
                    if bG == "Width" or bG == "Height" then
                        return UDim.new(0, 0)
                    end
                    if bG == "Min" or bG == "Max" then
                        return 0
                    end
                    if bG == "Scale" or bG == "Offset" then
                        return 0
                    end
                    if bG == "p" then
                        return bh
                    end
                    return 0
                end
                local function df(Z)
                    return function(bo, aa)
                        local dg, dh = bg()
                        local O = "(" .. (t.registry[bo] or aZ(bo)) .. " " .. Z .. " " .. (t.registry[aa] or aZ(aa)) .. ")"
                        t.registry[dg] = O
                        
                        -- Persist properties if math is possible
                        local p1 = t.property_store[bo]
                        local p2 = t.property_store[aa]
                        if p1 and p2 then
                            local results = {}
                            for _, coord in ipairs({"X", "Y", "Z", "W"}) do
                                if p1[coord] and p2[coord] then
                                    if Z == "+" then results[coord] = p1[coord] + p2[coord]
                                    elseif Z == "-" then results[coord] = p1[coord] - p2[coord]
                                    elseif Z == "*" then results[coord] = p1[coord] * p2[coord]
                                    elseif Z == "/" then results[coord] = p1[coord] / p2[coord]
                                    end
                                end
                            end
                            t.property_store[dg] = results
                        end

                        dh.__tostring = function()
                            return O
                        end
                        dh.__index = function(W, bG)
                            if bG == F or bG == "__proxy_id" or bG == v then
                                if bG == v then return true end
                                return rawget(dg, bG)
                            end
                            if bG == "X" or bG == "Y" or bG == "Z" or bG == "W" then
                                local p = t.property_store[dg]
                                return p and p[bG] or 0
                            end
                            if bG == "Magnitude" then
                                local p = t.property_store[dg]
                                if p and p.X and p.Y and p.Z then
                                    return math.sqrt(p.X^2 + p.Y^2 + p.Z^2)
                                end
                                return 0
                            end
                            return 0
                        end
                        dh.__add = df("+")
                        dh.__sub = df("-")
                        dh.__mul = df("*")
                        dh.__div = df("/")
                        return dg
                    end
                end
                
                -- Initialize property store for the new object
                local initial_coords = {X = 0, Y = 0, Z = 0, W = 0}
                if bA[1] and type(bA[1]) == "number" then initial_coords.X = bA[1] end
                if bA[2] and type(bA[2]) == "number" then initial_coords.Y = bA[2] end
                if bA[3] and type(bA[3]) == "number" then initial_coords.Z = bA[3] end
                if bA[4] and type(bA[4]) == "number" then initial_coords.W = bA[4] end
                t.property_store[bh] = initial_coords

                de.__add = df("+")
                de.__sub = df("-")
                de.__mul = df("*")
                de.__div = df("/")
                de.__unm = function(bo)
                    local dg, dh = bg()
                    t.registry[dg] = "(-" .. (t.registry[bo] or aZ(bo)) .. ")"
                    dh.__tostring = function()
                        return t.registry[dg]
                    end
                    return dg
                end
                de.__eq = function()
                    return false
                end
                return bh
            end
        end
        return nil
    end
    dd.__call = function(b2, ...)
        return b2.new(...)
    end
    return setmetatable(dc, dd)
end

Vector3 = da("Vector3", {new = true, zero = true, one = true})
Vector2 = da("Vector2", {new = true, zero = true, one = true})
UDim = da("UDim", {new = true})
UDim2 = da("UDim2", {new = true, fromScale = true, fromOffset = true})
CFrame = da("CFrame", {new = true, Angles = true, lookAt = true, fromEulerAnglesXYZ = true, fromEulerAnglesYXZ = true, fromAxisAngle = true, fromMatrix = true, fromOrientation = true, identity = true})
Color3 = da("Color3", {new = true, fromRGB = true, fromHSV = true, fromHex = true})
BrickColor = da("BrickColor", {new = true, random = true, White = true, Black = true, Red = true, Blue = true, Green = true, Yellow = true, palette = true})
TweenInfo = da("TweenInfo", {new = true})
Rect = da("Rect", {new = true})
Region3 = da("Region3", {new = true})
Region3int16 = da("Region3int16", {new = true})
Ray = da("Ray", {new = true})
NumberRange = da("NumberRange", {new = true})
NumberSequence = da("NumberSequence", {new = true})
NumberSequenceKeypoint = da("NumberSequenceKeypoint", {new = true})
ColorSequence = da("ColorSequence", {new = true})
ColorSequenceKeypoint = da("ColorSequenceKeypoint", {new = true})
PhysicalProperties = da("PhysicalProperties", {new = true})
Font = da("Font", {new = true, fromEnum = true, fromName = true, fromId = true})
RaycastParams = da("RaycastParams", {new = true})
OverlapParams = da("OverlapParams", {new = true})
PathWaypoint = da("PathWaypoint", {new = true})
Axes = da("Axes", {new = true})
Faces = da("Faces", {new = true})
Vector3int16 = da("Vector3int16", {new = true})
Vector2int16 = da("Vector2int16", {new = true})
CatalogSearchParams = da("CatalogSearchParams", {new = true})
DateTime = da("DateTime", {now = true, fromUnixTimestamp = true, fromUnixTimestampMillis = true, fromIsoDate = true})

Random = {new = function(di)
    local x = {}
    function x:NextNumber(dj, dk)
        return (dj or 0) + 0.5 * ((dk or 1) - (dj or 0))
    end
    function x:NextInteger(dj, dk)
        return math.floor((dj or 1) + 0.5 * ((dk or 100) - (dj or 1)))
    end
    function x:NextUnitVector()
        return Vector3.new(0.577, 0.577, 0.577)
    end
    function x:Shuffle(dl)
        return dl
    end
    function x:Clone()
        return Random.new()
    end
    return x
end}

setmetatable(Random, {__call = function(b2, di)
    return b2.new(di)
end})

Enum = bj("Enum", true)
local dm = a.getmetatable(Enum)
    dm.__index = function(b2, b4)
        if b4 == F or b4 == "__proxy_id" or b4 == v then
            if b4 == v then return true end
            return rawget(b2, b4)
        end
        return bj(b4, false, b2)
    end

-- Default properties by ClassName for authentic Roblox behavior
local _defaultInstanceProps = {
    Part = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Material = "Enum.Material.Plastic", Shape = "Enum.PartType.Block", TopSurface = "Enum.SurfaceType.Smooth", BottomSurface = "Enum.SurfaceType.Inlet", BrickColor = "Medium stone grey", Archivable = true, Massless = false, CanQuery = true, CanTouch = true, CastShadow = true},
    WedgePart = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Material = "Enum.Material.Plastic", Archivable = true},
    MeshPart = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Archivable = true, DoubleSided = false, CollisionFidelity = "Enum.CollisionFidelity.Default", RenderFidelity = "Enum.RenderFidelity.Automatic"},
    UnionOperation = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Archivable = true, UsePartColor = false},
    TrussPart = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Archivable = true, Style = "Enum.Style.AlternatingSupports"},
    SpawnLocation = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Material = "Enum.Material.Plastic", AllowTeamChangeOnTouch = false, Enabled = true, Neutral = true, Duration = 10, Archivable = true},
    Seat = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Disabled = false, Archivable = true},
    VehicleSeat = {Anchored = false, CanCollide = true, Locked = false, Transparency = 0, Disabled = false, MaxSpeed = 25, Torque = 10, TurnSpeed = 1, Steer = 0, Throttle = 0, HeadsUpDisplay = true, Archivable = true},
    Model = {Archivable = true},
    Folder = {Archivable = true},
    Frame = {Active = false, Visible = true, BackgroundTransparency = 0, BorderSizePixel = 1, ClipsDescendants = false, Archivable = true, LayoutOrder = 0, ZIndex = 1},
    TextLabel = {Text = "Label", TextSize = 14, RichText = false, TextWrapped = false, TextScaled = false, Visible = true, Active = false, BackgroundTransparency = 0, Archivable = true, ZIndex = 1},
    TextButton = {Text = "Button", TextSize = 14, Active = true, AutoButtonColor = true, Visible = true, Modal = false, BackgroundTransparency = 0, Archivable = true, ZIndex = 1},
    TextBox = {Text = "", PlaceholderText = "", TextSize = 14, ClearTextOnFocus = true, MultiLine = false, TextEditable = true, Visible = true, Active = true, BackgroundTransparency = 0, Archivable = true, ZIndex = 1},
    ImageLabel = {Image = "", ScaleType = "Enum.ScaleType.Stretch", ImageTransparency = 0, Visible = true, Active = false, BackgroundTransparency = 0, Archivable = true, ZIndex = 1},
    ImageButton = {Image = "", Active = true, AutoButtonColor = true, Visible = true, BackgroundTransparency = 0, Archivable = true, ZIndex = 1},
    ScreenGui = {Enabled = true, ResetOnSpawn = true, IgnoreGuiInset = false, DisplayOrder = 0, ZIndexBehavior = "Enum.ZIndexBehavior.Sibling", Archivable = true},
    BillboardGui = {Enabled = true, Active = false, AlwaysOnTop = false, ClipsDescendants = false, LightInfluence = 0, MaxDistance = math.huge, Archivable = true},
    SurfaceGui = {Enabled = true, Active = true, AlwaysOnTop = false, ClipsDescendants = false, LightInfluence = 0, Archivable = true, Face = "Enum.NormalId.Front", PixelsPerStud = 50},
    ScrollingFrame = {CanvasPosition = {X=0,Y=0}, ScrollBarThickness = 12, ScrollingEnabled = true, Visible = true, Active = false, ClipsDescendants = true, Archivable = true, ZIndex = 1},
    UIListLayout = {FillDirection = "Enum.FillDirection.Vertical", HorizontalAlignment = "Enum.HorizontalAlignment.Left", SortOrder = "Enum.SortOrder.LayoutOrder", VerticalAlignment = "Enum.VerticalAlignment.Top", Archivable = true},
    UIGridLayout = {FillDirection = "Enum.FillDirection.Horizontal", HorizontalAlignment = "Enum.HorizontalAlignment.Left", SortOrder = "Enum.SortOrder.LayoutOrder", VerticalAlignment = "Enum.VerticalAlignment.Top", FillDirectionMaxCells = 0, StartCorner = "Enum.StartCorner.TopLeft", Archivable = true},
    UIPadding = {Archivable = true},
    UICorner = {Archivable = true},
    UIStroke = {Thickness = 1, Transparency = 0, Enabled = true, ApplyStrokeMode = "Enum.ApplyStrokeMode.Contextual", LineJoinMode = "Enum.LineJoinMode.Round", Archivable = true},
    UIAspectRatioConstraint = {AspectRatio = 1, AspectType = "Enum.AspectType.FitWithinMaxSize", DominantAxis = "Enum.DominantAxis.Width", Archivable = true},
    UISizeConstraint = {Archivable = true},
    UITextSizeConstraint = {MaxTextSize = 100, MinTextSize = 1, Archivable = true},
    UIScale = {Scale = 1, Archivable = true},
    UIGradient = {Enabled = true, Transparency = 0, Archivable = true},
    ViewportFrame = {Ambient = "Color3.fromRGB(200,200,200)", LightColor = "Color3.fromRGB(140,140,140)", LightDirection = "Vector3.new(-1,-1,-1)", ImageTransparency = 0, Archivable = true},
    Sound = {Playing = false, Looped = false, Volume = 0.5, PlaybackSpeed = 1, TimePosition = 0, SoundId = "", Archivable = true, RollOffMaxDistance = 10000, RollOffMinDistance = 10},
    Animation = {AnimationId = "", Archivable = true},
    AnimationTrack = {Looped = false, Priority = "Enum.AnimationPriority.Action", Speed = 1, TimePosition = 0, WeightCurrent = 1, WeightTarget = 1, Archivable = true},
    Humanoid = {Health = 100, MaxHealth = 100, WalkSpeed = 16, JumpPower = 50, JumpHeight = 7.2, HipHeight = 2, AutoRotate = true, AutoJumpEnabled = true, PlatformStand = false, Sit = false, RigType = "Enum.HumanoidRigType.R15", DisplayDistanceType = "Enum.HumanoidDisplayDistanceType.Viewer", HealthDisplayDistance = 100, NameDisplayDistance = 100, UseJumpPower = true, RequiresNeck = true, Archivable = true},
    Weld = {Enabled = true, Archivable = true},
    WeldConstraint = {Enabled = true, Archivable = true},
    Motor6D = {Enabled = true, Archivable = true},
    BodyVelocity = {MaxForce = "Vector3.new(4000,4000,4000)", Archivable = true},
    BodyPosition = {MaxForce = "Vector3.new(4000,4000,4000)", Archivable = true},
    BodyGyro = {MaxTorque = "Vector3.new(4000,4000,4000)", Archivable = true},
    BodyForce = {Archivable = true},
    Attachment = {Visible = false, Archivable = true},
    Beam = {Enabled = true, FaceCamera = false, Archivable = true},
    Trail = {Enabled = true, FaceCamera = false, Lifetime = 2, MinLength = 0.1, Archivable = true},
    ParticleEmitter = {Enabled = true, Rate = 20, Lifetime = "NumberRange.new(5,10)", Speed = "NumberRange.new(5,5)", Archivable = true},
    PointLight = {Brightness = 1, Range = 8, Enabled = true, Shadows = false, Archivable = true},
    SpotLight = {Brightness = 1, Range = 16, Angle = 90, Face = "Enum.NormalId.Front", Enabled = true, Shadows = false, Archivable = true},
    SurfaceLight = {Brightness = 1, Range = 16, Angle = 90, Face = "Enum.NormalId.Front", Enabled = true, Shadows = false, Archivable = true},
    Fire = {Enabled = true, Heat = 9, Size = 5, Archivable = true},
    Smoke = {Enabled = true, Opacity = 0.5, RiseVelocity = 1, Size = 1, Archivable = true},
    Sparkles = {Enabled = true, Archivable = true},
    Explosion = {BlastPressure = 500000, BlastRadius = 4, DestroyJointRadiusPercent = 1, Visible = true, Archivable = true},
    RemoteEvent = {Archivable = true},
    RemoteFunction = {Archivable = true},
    BindableEvent = {Archivable = true},
    BindableFunction = {Archivable = true},
    StringValue = {Value = "", Archivable = true},
    IntValue = {Value = 0, Archivable = true},
    NumberValue = {Value = 0, Archivable = true},
    BoolValue = {Value = false, Archivable = true},
    ObjectValue = {Value = nil, Archivable = true},
    Color3Value = {Archivable = true},
    BrickColorValue = {Archivable = true},
    CFrameValue = {Archivable = true},
    Vector3Value = {Archivable = true},
    RayValue = {Archivable = true},
    ClickDetector = {MaxActivationDistance = 32, Archivable = true},
    ProximityPrompt = {ActionText = "Interact", ObjectText = "", HoldDuration = 0, MaxActivationDistance = 10, RequiresLineOfSight = true, Enabled = true, Archivable = true},
    Tool = {CanBeDropped = true, Enabled = true, RequiresHandle = true, ManualActivationOnly = false, Archivable = true},
    HopperBin = {Active = false, Archivable = true},
    Decal = {Transparency = 0, Face = "Enum.NormalId.Front", Archivable = true},
    Texture = {Transparency = 0, Face = "Enum.NormalId.Front", StudsPerTileU = 2, StudsPerTileV = 2, Archivable = true},
    SurfaceAppearance = {Archivable = true},
    Script = {Enabled = true, Archivable = true},
    LocalScript = {Enabled = true, Archivable = true},
    ModuleScript = {Archivable = true},
    Configuration = {Archivable = true},
    Camera = {FieldOfView = 70, CameraType = "Enum.CameraType.Custom", Archivable = true},
}

Instance = {new = function(bX, bS)
    local bY = aE(bX)
    local x = bj(bY, false)
    local _ = aW(x, bY)
    
    -- Set ClassName and default properties
    t.property_store[x] = t.property_store[x] or {}
    t.property_store[x].ClassName = bY
    t.property_store[x].Name = bY
    t.property_store[x]._destroyed = false
    
    -- Apply class-specific defaults
    local defaults = _defaultInstanceProps[bY]
    if defaults then
        for k, v in pairs(defaults) do
            if t.property_store[x][k] == nil then
                t.property_store[x][k] = v
            end
        end
    end
    
    -- Parts get physics defaults
    local partLike = {Part=1, WedgePart=1, MeshPart=1, UnionOperation=1, TrussPart=1, SpawnLocation=1, Seat=1, VehicleSeat=1}
    if partLike[bY] then
        t.property_store[x].Size = t.property_store[x].Size or Vector3.new(4, 1, 2)
        t.property_store[x].Position = t.property_store[x].Position or Vector3.new(0, 0, 0)
        t.property_store[x].CFrame = t.property_store[x].CFrame or CFrame.new(0, 0, 0)
        t.property_store[x].Orientation = t.property_store[x].Orientation or Vector3.new(0, 0, 0)
        t.property_store[x].Color = t.property_store[x].Color or Color3.fromRGB(163, 162, 165)
        t.property_store[x].BrickColor = t.property_store[x].BrickColor or "Medium stone grey"
    end
    
    -- GUI elements get Size/Position defaults
    local guiLike = {Frame=1, TextLabel=1, TextButton=1, TextBox=1, ImageLabel=1, ImageButton=1, ScrollingFrame=1, ViewportFrame=1}
    if guiLike[bY] then
        t.property_store[x].Size = t.property_store[x].Size or UDim2.new(0, 100, 0, 100)
        t.property_store[x].Position = t.property_store[x].Position or UDim2.new(0, 0, 0, 0)
        t.property_store[x].BackgroundColor3 = t.property_store[x].BackgroundColor3 or Color3.fromRGB(255, 255, 255)
        t.property_store[x].BorderColor3 = t.property_store[x].BorderColor3 or Color3.fromRGB(27, 42, 53)
    end

    if bS then
        local dp = t.registry[bS] or aZ(bS)
        at(string.format("local %s = Instance.new(%s, %s)", _, aH(bY), dp))
        t.parent_map[x] = bS
    else
        at(string.format("local %s = Instance.new(%s)", _, aH(bY)))
    end
    return x
end}

game = bj("game", true)
workspace = bj("workspace", true)
script = bj("script", true)
t.property_store[game] = t.property_store[game] or {}
t.property_store[game].ClassName = "DataModel"
t.property_store[workspace] = t.property_store[workspace] or {}
t.property_store[workspace].ClassName = "Workspace"
t.property_store[script] = {Name = "DumpedScript", Parent = game, ClassName = "LocalScript"}

-- ENHANCED: Task library with timing bypass
task = {
    wait = function(dq)
        if dq then
            at(string.format("task.wait(%s)", aZ(dq)))
        else
            at("task.wait()")
        end
        t.fake_time = t.fake_time + (dq or 0.03)
        return dq or 0.03, p.clock()
    end,
    spawn = function(dr, ...)
        local bA = {...}
        at("task.spawn(function()")
        t.indent = t.indent + 1
        
        local co
        if j(dr) == "function" then
            co = coroutine.create(dr)
        elseif j(dr) == "thread" then
            co = dr
        end
        
        if co then
            local success, err = coroutine.resume(co, table.unpack(bA))
            if not success then
                at("-- [Error in spawn] " .. tostring(err))
            end
        end
        
        while t.pending_iterator do
            t.indent = t.indent - 1
            at("end")
            t.pending_iterator = false
        end
        t.indent = t.indent - 1
        at("end)")
        return co
    end,
    delay = function(dq, dr, ...)
        local bA = {...}
        at(string.format("task.delay(%s, function()", aZ(dq or 0)))
        t.indent = t.indent + 1
        
        local co
        if j(dr) == "function" then
            co = coroutine.create(dr)
        elseif j(dr) == "thread" then
            co = dr
        end
        
        if co then
            local success, err = coroutine.resume(co, table.unpack(bA))
            if not success then
                at("-- [Error in delay] " .. tostring(err))
            end
        end
        
        while t.pending_iterator do
            t.indent = t.indent - 1
            at("end")
            t.pending_iterator = false
        end
        t.indent = t.indent - 1
        at("end)")
        return co
    end,
    defer = function(dr, ...)
        local bA = {...}
        at("task.defer(function()")
        t.indent = t.indent + 1
        
        local co
        if j(dr) == "function" then
            co = coroutine.create(dr)
        elseif j(dr) == "thread" then
            co = dr
        end
        
        if co then
            local success, err = coroutine.resume(co, table.unpack(bA))
            if not success then
                at("-- [Error in defer] " .. tostring(err))
            end
        end
        
        t.indent = t.indent - 1
        at("end)")
        return co
    end,
    cancel = function(dt)
        at("task.cancel(thread)")
    end,
    synchronize = function()
        at("task.synchronize()")
    end,
    desynchronize = function()
        at("task.desynchronize()")
    end
}

-- ENHANCED: Custom _G.os table for handling large files
_G.os = {
    clock = function() 
        t.fake_time = t.fake_time + 0.001
        return t.fake_time 
    end,
    time = function(t) return p.time(t) end,
    date = function(format, time) return p.date(format, time) end,
    difftime = function(t2, t1) return p.difftime(t2, t1) end,
    execute = function(cmd)
        at(string.format("os.execute(%s)", aZ(cmd)))
        at("-- < os.execute > was blocked")
        local result = bj("executeResult", false)
        t.registry[result] = "0"
        return 0, "exit", 0
    end,
    remove = function(filename)
        at(string.format("os.remove(%s)", aH(filename)))
        return true
    end,
    rename = function(oldname, newname)
        at(string.format("os.rename(%s, %s)", aH(oldname), aH(newname)))
        return true
    end,
    exit = function(code, close)
        at(string.format("os.exit(%s%s)", code or "nil", close and ", true" or ""))
    end,
    tmpname = function()
        local tmpname = "/tmp/temp_" .. tostring(math.random(100000, 999999))
        at(string.format("os.tmpname() -- returned %s", aH(tmpname)))
        return tmpname
    end,
    getenv = function(varname)
        at(string.format("os.getenv(%s)", aH(varname)))
        local fakeEnv = {
            PATH = "/usr/bin:/bin",
            HOME = "/home/user",
            USER = "user",
            TEMP = "/tmp",
            TMP = "/tmp"
        }
        return fakeEnv[varname] or nil
    end,
    setlocale = function(locale, category)
        if category then
            at(string.format("os.setlocale(%s, %s)", aZ(locale), aH(category)))
        else
            at(string.format("os.setlocale(%s)", aZ(locale)))
        end
        return "C"
    end
}

-- ENHANCED: wait function with timing bypass
wait = function(dq)
    if dq then
        at(string.format("wait(%s)", aZ(dq)))
    else
        at("wait()")
    end
    t.fake_time = t.fake_time + (dq or 0.03)
    return dq or 0.03, p.clock()
end

delay = function(dq, dr)
    at(string.format("delay(%s, function()", aZ(dq or 0)))
    t.indent = t.indent + 1
    if j(dr) == "function" then
        xpcall(dr, function() end)
    end
    t.indent = t.indent - 1
    at("end)")
end

spawn = function(dr)
    at("spawn(function())")
    t.indent = t.indent + 1
    if j(dr) == "function" then
        xpcall(dr, function() end)
    end
    t.indent = t.indent - 1
    at("end)")
end

-- ENHANCED: tick and time with fake time
tick = function()
    t.fake_time = t.fake_time + 0.001
    return t.fake_time
end

time = function()
    return p.clock()
end

elapsedTime = function()
    return p.clock()
end

local du = {}
local dv = 999999999

local function dw(bG, dx)
    return dx
end

local function dy()
    local b2 = {}
    setmetatable(b2, {
        __call = function(self, ...)
            return self
        end,
        __index = function(self, b4)
            if _G[b4] ~= nil then
                return dw(b4, _G[b4])
            end
            if b4 == "game" then
                return game
            end
            if b4 == "workspace" then
                return workspace
            end
            if b4 == "script" then
                return script
            end
            if b4 == "Enum" then
                return Enum
            end
            return nil
        end,
        __newindex = function(self, b4, b5)
            _G[b4] = b5
            du[b4] = 0
            at(string.format("_G.%s = %s", aE(b4), aZ(b5)))
        end
    })
    return b2
end

_G.G = dy()
_G.g = dy()
_G.ENV = dy()
_G.env = dy()
_G.E = dy()
_G.e = dy()
_G.L = dy()
_G.l = dy()
_G.F = dy()
_G.f = dy()

local function dz(dA)
    local bh = {}
    local dd = {}
    local dB = {
        "hookfunction",
        "hookmetamethod",
        "newcclosure",
        "replaceclosure",
        "checkcaller",
        "iscclosure",
        "islclosure",
        "getrawmetatable",
        "setreadonly",
        "make_writeable",
        "getrenv",
        "getgc",
        "getinstances"
    }
    local function dC(dD, bG)
        local bd = aE(bG)
        if bd:match("^[%a_][%w_]*$") then
            if dD then
                return dD .. "." .. bd
            end
            return bd
        else
            local aI = bd:gsub("'", "\\\\\\\\'")
            if dD then
                return dD .. "['" .. aI .. "']"
            end
            return "['" .. aI .. "']"
        end
    end
    dd.__index = function(b2, b4)
        for W, dE in ipairs(dB) do
            if b4 == dE then
                return nil
            end
        end
        local dF = dC(dA, b4)
        return dz(dF)
    end
    dd.__newindex = function(b2, b4, b5)
        local dG = dC(dA, b4)
        at(string.format("getgenv().%s = %s", dG, aZ(b5)))
    end
    dd.__call = function(b2, ...)
        return b2
    end
    dd.__pairs = function()
        return function()
            return nil
        end, nil, nil
    end
    return setmetatable(bh, dd)
end

local exploit_funcs = {
    getgenv = function()
        return dz(nil)
    end,
    getrenv = function()
        return bj("getrenv()", false)
    end,
    getfenv = function(dH)
        return _G
    end,
    setfenv = function(dI, dJ)
        if j(dI) ~= "function" then
            return
        end
        local L = 1
        while true do
            local am = debug.getupvalue(dI, L)
            if am == "_ENV" then
                debug.setupvalue(dI, L, dJ)
                break
            elseif not am then
                break
            end
            L = L + 1
        end
        return dI
    end,
    hookfunction = function(dK, dL)
        return dK
    end,
    hookmetamethod = function(x, dM, dN)
        return function() end
    end,
    getrawmetatable = function(x)
        if G(x) then
            return a.getmetatable(x)
        end
        return {}
    end,
    setrawmetatable = function(x, dd)
        return x
    end,
    getnamecallmethod = function()
        return "__namecall"
    end,
    setnamecallmethod = function(dM)
    end,
    checkcaller = function()
        return true
    end,
    islclosure = function(dr)
        local name = t.registry[dr]
        if name and FindInExecEnv(name) then return false end
        return j(dr) == "function"
    end,
    iscclosure = function(dr)
        local name = t.registry[dr]
        if name and FindInExecEnv(name) then return true end
        return false
    end,
    newcclosure = function(dr)
        return dr
    end,
    clonefunction = function(dr)
        return dr
    end,
    request = function(dO)
        local reqUrl = type(dO) == "table" and (dO.Url or dO.url) or (type(dO) == "string" and dO) or "unknown"
        sniff(reqUrl, "request")
        _log_link(reqUrl, "request", "HTTP")
        at(string.format("request(%s)", aZ(dO)))
        table.insert(t.string_refs, {value = reqUrl, hint = "HTTP Request"})
        if type(dO) == "table" and dO.Body then sniff(tostring(dO.Body), "request.Body") end
        return {Success = true, StatusCode = 200, StatusMessage = "OK", Headers = {}, Body = "{}"}
    end,
    http_request = function(dO)
        return exploit_funcs.request(dO)
    end,
    syn = {request = function(dO)
        return exploit_funcs.request(dO)
    end},
    http = {request = function(dO)
        return exploit_funcs.request(dO)
    end},
    HttpPost = function(cI, cJ)
        sniff(aE(cI), "HttpPost.URL")
        if type(cJ) == "string" then sniff(cJ, "HttpPost.Body") end
        at(string.format("HttpPost(%s, %s)", aE(cI), aE(cJ)))
        return "{}"
    end,
    setclipboard = function(cJ)
        local str = type(cJ) == "string" and cJ or m(cJ)
        sniff(str, "clipboard")
        table.insert(t.string_refs, {value = str, hint = "clipboard"})
        at(string.format("setclipboard(%s)", aZ(cJ)))
        B("[!] clipboard set: " .. str:sub(1, 200))
    end,
    getclipboard = function()
        return '"'
    end,
    identifyexecutor = function()
        return "Dumper", "3.0"
    end,
    getexecutorname = function()
        return "Dumper"
    end,
    gethui = function()
        local dP = bj("HiddenUI", false)
        aW(dP, "HiddenUI")
        at(string.format("local %s = gethui()", t.registry[dP]))
        return dP
    end,
    gethiddenui = function()
        return exploit_funcs.gethui()
    end,
    protectgui = function(dQ)
    end,
    iswindowactive = function()
        return true
    end,
    isrbxactive = function()
        return true
    end,
    isgameactive = function()
        return true
    end,
    getconnections = function(cg)
        return {}
    end,
    firesignal = function(cg, ...)
    end,
    fireclickdetector = function(dR, dS)
    end,
    fireproximityprompt = function(dT)
    end,
    firetouchinterest = function(dU, dV, dW)
    end,
    getinstances = function()
        return {}
    end,
    getnilinstances = function()
        return {}
    end,
    getgc = function()
        return {}
    end,
    getscripts = function()
        return {}
    end,
    getrunningscripts = function()
        return {}
    end,
    getloadedmodules = function()
        return {}
    end,
    getcallingscript = function()
        return script
    end,
    readfile = function(dA)
        at(string.format("readfile(%s)", aH(dA)))
        return '"'
    end,
    writefile = function(dA, ai)
        at(string.format("writefile(%s, %s)", aH(dA), aZ(ai)))
    end,
    appendfile = function(dA, ai)
        at(string.format("appendfile(%s, %s)", aH(dA), aZ(ai)))
    end,
    loadfile = function(dA)
        return function()
            return bj("loaded_file", false)
        end
    end,
    listfiles = function(dX)
        return {}
    end,
    isfile = function(dA)
        return false
    end,
    isfolder = function(dA)
        return false
    end,
    makefolder = function(dA)
        at(string.format("makefolder(%s)", aH(dA)))
    end,
    delfolder = function(dA)
        at(string.format("delfolder(%s)", aH(dA)))
    end,
    delfile = function(dA)
        at(string.format("delfile(%s)", aH(dA)))
    end,
    Drawing = {new = function(aO)
        local dY = aE(aO)
        local x = bj("Drawing_" .. dY, false)
        local _ = aW(x, dY)
        at(string.format("local %s = Drawing.new(%s)", _, aH(dY)))
        return x
    end, Fonts = bj("Drawing.Fonts", false)},
    crypt = {
        base64encode = function(cJ)
            return cJ
        end,
        base64decode = function(cJ)
            return cJ
        end,
        base64_encode = function(cJ)
            return cJ
        end,
        base64_decode = function(cJ)
            return cJ
        end,
        encrypt = function(cJ, bG)
            return cJ
        end,
        decrypt = function(cJ, bG)
            return cJ
        end,
        hash = function(cJ)
            return "hash"
        end,
        generatekey = function(dZ)
            return string.rep("0", dZ or 32)
        end,
        generatebytes = function(dZ)
            return string.rep("\\\\0", dZ or 16)
        end
    },
    base64_encode = function(cJ)
        return cJ
    end,
    base64_decode = function(cJ)
        return cJ
    end,
    base64encode = function(cJ)
        return cJ
    end,
    base64decode = function(cJ)
        return cJ
    end,
    mouse1click = function()
        at("mouse1click()")
    end,
    mouse1press = function()
        at("mouse1press()")
    end,
    mouse1release = function()
        at("mouse1release()")
    end,
    mouse2click = function()
        at("mouse2click()")
    end,
    mouse2press = function()
        at("mouse2press()")
    end,
    mouse2release = function()
        at("mouse2release()")
    end,
    mousemoverel = function(d_, e0)
        at(string.format("mousemoverel(%s, %s)", aZ(d_), aZ(e0)))
    end,
    mousemoveabs = function(d_, e0)
        at(string.format("mousemoveabs(%s, %s)", aZ(d_), aZ(e0)))
    end,
    mousescroll = function(e1)
        at(string.format("mousescroll(%s)", aZ(e1)))
    end,
    keypress = function(bG)
        at(string.format("keypress(%s)", aZ(bG)))
    end,
    keyrelease = function(bG)
        at(string.format("keyrelease(%s)", aZ(bG)))
    end,
    keyclick = function(bG)
        at(string.format("keyclick(%s)", aZ(bG)))
    end,
    isreadonly = function(b2)
        return false
    end,
    setreadonly = function(b2, e2)
        return b2
    end,
    make_writeable = function(b2)
        return b2
    end,
    make_readonly = function(b2)
        return b2
    end,
    getthreadidentity = function()
        return 7
    end,
    setthreadidentity = function(aG)
    end,
    getidentity = function()
        return 7
    end,
    setidentity = function(aG)
    end,
    getthreadcontext = function()
        return 7
    end,
    setthreadcontext = function(aG)
    end,
    getcustomasset = function(dA)
        return "rbxasset://" .. aE(dA)
    end,
    getsynasset = function(dA)
        return "rbxasset://" .. aE(dA)
    end,
    getinfo = function(dr)
        return {source = "=", what = "Lua", name = "unknown", short_src = "dumper"}
    end,
    getconstants = function(dr)
        return {}
    end,
    getupvalues = function(dr)
        return {}
    end,
    getprotos = function(dr)
        return {}
    end,
    getupvalue = function(dr, ba)
        return nil
    end,
    setupvalue = function(dr, ba, bm)
    end,
    setconstant = function(dr, ba, bm)
    end,
    getconstant = function(dr, ba)
        return nil
    end,
    getproto = function(dr, ba)
        return function() end
    end,
    setproto = function(dr, ba, e3)
    end,
    getstack = function(dH, ba)
        return nil
    end,
    setstack = function(dH, ba, bm)
    end,
    debug = {
        getinfo = c or function()
            return {}
        end,
        getupvalue = debug.getupvalue or function()
            return nil
        end,
        setupvalue = debug.setupvalue or function()
        end,
        getmetatable = a.getmetatable,
        setmetatable = debug.setmetatable or setmetatable,
        traceback = d or function()
            return '"'
        end,
        profilebegin = function()
        end,
        profileend = function()
        end,
        sethook = function()
        end
    },
    rconsoleprint = function(ay)
    end,
    rconsoleclear = function()
    end,
    rconsolecreate = function()
    end,
    rconsoledestroy = function()
    end,
    rconsoleinput = function()
        return ""
    end,
    rconsoleinfo = function(ay)
    end,
    rconsolewarn = function(ay)
    end,
    rconsoleerr = function(ay)
    end,
    rconsolename = function(am)
    end,
    printconsole = function(ay)
    end,
    setfflag = function(e4, bm)
    end,
    getfflag = function(e4)
        return ""
    end,
    setfpscap = function(e5)
        at(string.format("setfpscap(%s)", aZ(e5)))
    end,
    getfpscap = function()
        return 60
    end,
    isnetworkowner = function(cr)
        return true
    end,
    gethiddenproperty = function(x, ce)
        return nil
    end,
    sethiddenproperty = function(x, ce, bm)
        at(string.format("sethiddenproperty(%s, %s, %s)", aZ(x), aH(ce), aZ(bm)))
    end,
    setsimulationradius = function(e6, e7)
        at(string.format("setsimulationradius(%s%s)", aZ(e6), e7 and ", " .. aZ(e7) or ""))
    end,
    getspecialinfo = function(e8)
        return {}
    end,
    saveinstance = function(dO)
        at(string.format("saveinstance(%s)", aZ(dO or {})))
    end,
    decompile = function(script)
        return "-- decompiled"
    end,
    lz4compress = function(cJ)
        return cJ
    end,
    lz4decompress = function(cJ)
        return cJ
    end,
    MessageBox = function(e9, ea, eb)
        return 1
    end,
    setwindowactive = function()
    end,
    setwindowtitle = function(ec)
    end,
    queue_on_teleport = function(al)
        at(string.format("queue_on_teleport(%s)", aZ(al)))
    end,
    queueonteleport = function(al)
        at(string.format("queueonteleport(%s)", aZ(al)))
    end,
    secure_call = function(dr, ...)
        return dr(...)
    end,
    create_secure_function = function(dr)
        return dr
    end,
    isvalidinstance = function(e8)
        return e8 ~= nil
    end,
    validcheck = function(e8)
        return e8 ~= nil
    end
}

for b4, b5 in D(exploit_funcs) do
    _G[b4] = b5
end

_G.hookfunction = nil
_G.hookmetamethod = nil
_G.newcclosure = nil

-- Unsigned 32-bit helper (bit32 semantics: always unsigned [0, 2^32-1])
local function u32(d_)
    return math.floor((d_ or 0)) % 0x100000000
end

-- Signed 32-bit helper (for tobit compatibility)
local function ee(d_)
    d_ = (d_ or 0) % 4294967296
    if d_ >= 2147483648 then
        d_ = d_ - 4294967296
    end
    return math.floor(d_)
end

local ed = {}

ed.tobit = ee
ed.band = function(bo, aa) return u32(u32(bo) & u32(aa)) end
ed.bor = function(bo, aa) return u32(u32(bo) | u32(aa)) end
ed.bxor = function(bo, aa) return u32(u32(bo) ~ u32(aa)) end
ed.lshift = function(d_, U) return u32(u32(d_) << (U % 32)) end
ed.rshift = function(d_, U) return u32(u32(d_) >> (U % 32)) end
ed.bnot = function(d_) return u32(~u32(d_)) end

ed.tohex = function(d_, U)
    return string.format("%0" .. (U or 8) .. "x", (d_ or 0) % 0x100000000)
end

ed.arshift = function(d_, U)
    local b5 = ee(d_ or 0)
    if b5 < 0 then
        return ee(b5 >> U or 0) + ee(-1 << 32 - (U or 0))
    else
        return ee(b5 >> U or 0)
    end
end

ed.rol = function(d_, U)
    d_ = d_ or 0
    U = (U or 0) % 32
    return ee(d_ << U | (d_ >> 32 - U))
end

ed.ror = function(d_, U)
    d_ = d_ or 0
    U = (U or 0) % 32
    return ee(d_ >> U | (d_ << 32 - U))
end

ed.bswap = function(d_)
    d_ = d_ or 0
    local bo = d_ >> 24 & 0xFF
    local aa = d_ >> 8 & 0xFF00
    local ah = d_ << 8 & 0xFF0000
    local ef = d_ << 24 & 0xFF000000
    return ee(bo | aa | ah | ef)
end

ed.countlz = function(U)
    U = ed.tobit(U)
    if U == 0 then
        return 32
    end
    local a2 = 0
    if ed.band(U, 0xFFFF0000) == 0 then
        a2 = a2 + 16
        U = ed.lshift(U, 16)
    end
    if ed.band(U, 0xFF000000) == 0 then
        a2 = a2 + 8
        U = ed.lshift(U, 8)
    end
    if ed.band(U, 0xF0000000) == 0 then
        a2 = a2 + 4
        U = ed.lshift(U, 4)
    end
    if ed.band(U, 0xC0000000) == 0 then
        a2 = a2 + 2
        U = ed.lshift(U, 2)
    end
    if ed.band(U, 0x80000000) == 0 then
        a2 = a2 + 1
    end
    return a2
end

ed.countrz = function(U)
    U = ed.tobit(U)
    if U == 0 then
        return 32
    end
    local a2 = 0
    while ed.band(U, 1) == 0 do
        U = ed.rshift(U, 1)
        a2 = a2 + 1
    end
    return a2
end

ed.lrotate = ed.rol
ed.rrotate = ed.ror

ed.extract = function(U, eg, eh)
    eh = eh or 1
    return U >> eg & 1 << eh - 1
end

ed.replace = function(U, b5, eg, eh)
    eh = eh or 1
    local ei = 1 << eh - 1
    return U & ~(ei << eg) | (b5 & ei << eg)
end

ed.btest = function(bo, aa)
    return ed.band(bo, aa) ~= 0
end

bit32 = ed
bit = ed
_G.bit = bit
_G.bit32 = bit32

table.getn = table.getn or function(b2)
    return #b2
end

table.foreach = table.foreach or function(b2, as)
    for b4, b5 in pairs(b2) do
        as(b4, b5)
    end
end

table.foreachi = table.foreachi or function(b2, as)
    for L, b5 in ipairs(b2) do
        as(L, b5)
    end
end

table.move = table.move or function(ej, as, ds, b2, ek)
    ek = ek or ej
    for L = as, ds do
        ek[b2 + L - as] = ej[L]
    end
    return ek
end

string.split = string.split or function(S, el)
    local b2 = {}
    for O in string.gmatch(S, "([^" .. (el or "%s") .. "]+)") do
        table.insert(b2, O)
    end
    return b2
end

if not math.frexp then
    math.frexp = function(d_)
        if d_ == 0 then
            return 0, 0
        end
        local ds = math.floor(math.log(math.abs(d_)) / math.log(2)) + 1
        local em = d_ / 2 ^ ds
        return em, ds
    end
end

if not math.ldexp then
    math.ldexp = function(em, ds)
        return em * 2 ^ ds
    end
end

if not utf8 then
    utf8 = {}
    utf8.char = function(...)
        local bA = {...}
        local dg = {}
        for L, al in ipairs(bA) do
            table.insert(dg, string.char(al % 256))
        end
        return table.concat(dg)
    end
    utf8.len = function(S)
        return #S
    end
    utf8.codes = function(S)
        local L = 0
        return function()
            L = L + 1
            if L <= #S then
                return L, string.byte(S, L)
            end
        end
    end
end

_G.utf8 = utf8

pairs = function(b2)
    if j(b2) == "table" and not G(b2) then
        return D(b2)
    end
    return function()
        return nil
    end, b2, nil
end

ipairs = function(b2)
    if j(b2) == "table" and not G(b2) then
        return E(b2)
    end
    return function()
        return nil
    end, b2, 0
end

_G.pairs = pairs
_G.ipairs = ipairs
_G.math = math
_G.table = table
_G.string = string
_G.os = {
    time = os.time,
    date = os.date,
    difftime = os.difftime,
    clock = os.clock
}
_G.coroutine = coroutine
_G.io = nil
_G.debug = exploit_funcs.debug
_G.utf8 = utf8
_G.pairs = pairs
_G.ipairs = ipairs
_G.next = next
_G.tostring = tostring
_G.tonumber = tonumber
_G.getmetatable = getmetatable
_G.setmetatable = setmetatable

_G.pcall = function(as, ...)
    local en = {g(as, ...)}
    local eo = en[1]
    if not eo then
        local an = en[2]
        if j(an) == "string" and an:match("TIMEOUT_FORCED_BY_DUMPER") then
            i(an)
        end
    end
    return table.unpack(en)
end

_G.xpcall = function(as, ep, ...)
    local function eq(an)
        if j(an) == "string" and an:match("TIMEOUT_FORCED_BY_DUMPER") then
            return an
        end
        if ep then
            return ep(an)
        end
        return an
    end
    local en = {h(as, eq, ...)}
    local eo = en[1]
    if not eo then
        local an = en[2]
        if j(an) == "string" and an:match("TIMEOUT_FORCED_BY_DUMPER") then
            i(an)
        end
    end
    return table.unpack(en)
end

_G.error = error
if _G.originalError == nil then
    _G.originalError = error
end
_G.assert = assert
_G.select = select
_G.type = type
_G.rawget = rawget
_G.rawset = rawset
_G.rawequal = rawequal
_G.rawlen = rawlen or function(b2)
    return #b2
end
_G.unpack = table.unpack or unpack
_G.pack = table.pack or function(...)
    return {n = select("#", ...), ...}
end
_G.task = task
_G.wait = wait
_G.Wait = wait
_G.delay = delay
_G.Delay = delay
_G.spawn = spawn
_G.Spawn = spawn
_G.tick = tick
_G.time = time
_G.elapsedTime = elapsedTime
_G.game = game
_G.Game = game
_G.workspace = workspace
_G.Workspace = workspace
_G.script = script
_G.Enum = Enum
_G.Instance = Instance
_G.Random = Random
_G.Vector3 = Vector3
_G.Vector2 = Vector2
_G.CFrame = CFrame
_G.Color3 = Color3
_G.BrickColor = BrickColor
_G.UDim = UDim
_G.UDim2 = UDim2
_G.TweenInfo = TweenInfo
_G.Rect = Rect
_G.Region3 = Region3
_G.Region3int16 = Region3int16
_G.Ray = Ray
_G.NumberRange = NumberRange
_G.NumberSequence = NumberSequence
_G.NumberSequenceKeypoint = NumberSequenceKeypoint
_G.ColorSequence = ColorSequence
_G.ColorSequenceKeypoint = ColorSequenceKeypoint
_G.PhysicalProperties = PhysicalProperties
_G.Font = Font
_G.RaycastParams = RaycastParams
_G.OverlapParams = OverlapParams
_G.PathWaypoint = PathWaypoint
_G.Axes = Axes
_G.Faces = Faces
_G.Vector3int16 = Vector3int16
_G.Vector2int16 = Vector2int16
_G.CatalogSearchParams = CatalogSearchParams
_G.DateTime = DateTime

getmetatable = function(x)
    if G(x) then
        return "The metatable is locked"
    end
    return k(x)
end
_G.getmetatable = getmetatable

type = function(x)
    if w(x) then
        return "number"
    end
    if G(x) then
        return "userdata"
    end
    return j(x)
end
_G.type = type

typeof = function(x)
    if w(x) then
        return "number"
    end
    if G(x) then
        local er = t.registry[x]
        if er then
            if er:match("Vector3") then return "Vector3" end
            if er:match("CFrame") then return "CFrame" end
            if er:match("Color3") then return "Color3" end
            if er:match("UDim2") then return "UDim2" end
            if er:match("UDim") then return "UDim" end
            if er:match("TweenInfo") then return "TweenInfo" end
            if er:match("Ray") then return "Ray" end
            -- EnumItem: deeply nested like Enum.Material.Plastic
            if er:match("^Enum%.") and er:match("^Enum%.[^%.]+%.") then
                return "EnumItem"
            end
            -- Enum namespace: top-level like Enum or Enum.Material
            if er == "Enum" or er:match("^Enum%.") then
                return "Enum"
            end
            -- RBXScriptSignal: event properties like .Changed, .Heartbeat etc.
            local signalNames = {Changed=1, Heartbeat=1, Stepped=1, RenderStepped=1, ChildAdded=1, ChildRemoved=1, PlayerAdded=1, PlayerRemoving=1, CharacterAdded=1, CharacterRemoving=1, Touched=1, TouchEnded=1, InputBegan=1, InputEnded=1, InputChanged=1, Died=1, HealthChanged=1, Activated=1, Deactivated=1, FocusLost=1, Triggered=1, TriggerEnded=1, OnClientEvent=1, OnServerEvent=1, MessageOut=1}
            local shortName = er:match("%.([^%.]+)$")
            if shortName and signalNames[shortName] then
                return "RBXScriptSignal"
            end
        end
        return "Instance"
    end
    return j(x) == "table" and "table" or j(x)
end
_G.typeof = typeof

tonumber = function(x, es)
    if w(x) then
        return 123456789
    end
    return n(x, es)
end
_G.tonumber = tonumber

rawequal = function(bo, aa)
    return l(bo, aa)
end
_G.rawequal = rawequal

tostring = function(x)
    if G(x) then
        local et = t.registry[x]
        return et or "Instance"
    end
    return m(x)
end
_G.tostring = tostring

t.last_http_url = nil

loadstring = function(al, eu)
    if j(al) ~= "string" then
        return function()
            return bj("loaded", false)
        end
    end
    local cI = t.last_http_url or al
    t.last_http_url = nil
    if cI:match("^https?://") then
        table.insert(t.link_spy, {url = cI, method = "loadstring", source_size = #al})
        B("[ LINK SPY ] loadstring from URL: " .. cI .. " (" .. #al .. " bytes)")
    end
    local ev = nil
    local ew = cI:lower()
    local ex = {
        {pattern = "rayfield", name = "Rayfield"},
        {pattern = "orion", name = "OrionLib"},
        {pattern = "kavo", name = "Kavo"},
        {pattern = "venyx", name = "Venyx"},
        {pattern = "sirius", name = "Sirius"},
        {pattern = "linoria", name = "Linoria"},
        {pattern = "wally", name = "Wally"},
        {pattern = "dex", name = "Dex"},
        {pattern = "infinite", name = "InfiniteYield"},
        {pattern = "hydroxide", name = "Hydroxide"},
        {pattern = "simplespy", name = "SimpleSpy"},
        {pattern = "remotespy", name = "RemoteSpy"}
    }
    for W, ey in ipairs(ex) do
        if ew:find(ey.pattern) then
            ev = ey.name
            break
        end
    end
    if ev then
        local ez = bj(ev, false)
        t.registry[ez] = ev
        t.names_used[ev] = true
        if cI:match("^https?://") then
            at(string.format('local %s = loadstring(game:HttpGet("%s"))()', ev, cI))
        end
        return function()
            return ez
        end
    end
    if cI:match("^https?://") then
        local ez = bj("Library", false)
        at(string.format('local Library = loadstring(game:HttpGet("%s"))()', cI))


        return function()
            return ez
        end
    end
    if type(al) == "string" then
        al = I(al)
    end
    local R, an = e(al)
    if R then
        -- SECURITY: Apply sandbox to loaded code to prevent VM escape
        if setfenv then
            setfenv(R, eR or _G)
        end
        return R
    end
    
    -- IMPORTANT: Return nil and error on failure to match real loadstring behavior
    return nil, an
end

load = loadstring
_G.loadstring = loadstring
_G.load = loadstring

require = function(eA)
    local eB = t.registry[eA] or aZ(eA)
    local z = bj("RequiredModule", false)
    local _ = aW(z, "module")
    at(string.format("local %s = require(%s)", _, eB))
    return z
end
_G.require = require

print = function(...)
    if not t.in_message_out then
        t.in_message_out = true
        local args = {...}
        local msg = ""
        for i, v in ipairs(args) do
            msg = msg .. (i > 1 and " " or "") .. m(v)
        end
        local outEnum = Enum.MessageType.MessageOutput
        for _, listener in ipairs(t.message_out_listeners) do
            xpcall(function() listener(msg, outEnum) end, function() end)
        end
        t.in_message_out = false
    end
    local bA = {...}
    local b8 = {}
    for W, b5 in ipairs(bA) do
        table.insert(b8, aZ(b5))
    end
    at(string.format("print(%s)", table.concat(b8, ", ")))
    B(...)
end
_G.print = print

warn = function(...)
    if not t.in_message_out then
        t.in_message_out = true
        local args = {...}
        local msg = ""
        for i, v in ipairs(args) do
            msg = msg .. (i > 1 and " " or "") .. m(v)
        end
        local warnEnum = Enum.MessageType.MessageWarning
        for _, listener in ipairs(t.message_out_listeners) do
            xpcall(function() listener(msg, warnEnum) end, function() end)
        end
        t.in_message_out = false
    end
    local bA = {...}
    local b8 = {}
    for W, b5 in ipairs(bA) do
        table.insert(b8, aZ(b5))
    end
    at(string.format("warn(%s)", table.concat(b8, ", ")))
    C(...)
end
_G.warn = warn

shared = bj("shared", true)
_G.shared = shared

local eC = _G
local eD = setmetatable({}, {
    __index = function(b2, b4)
        local aF = rawget(eC, b4)
        if aF == nil then
            aF = rawget(_G, b4)
        end
        return aF
    end,
    __newindex = function(b2, b4, b5)
        rawset(eC, b4, b5)
    end
})
_G._G = eD

-- Anti-dumper bypass: hide executor/dumper-specific globals
-- These are checked by anti-deobfuscation scripts to detect if running inside an executor
saveinstance = nil
_G.saveinstance = nil

-- Drawing: create a mock that absorbs calls silently but stays nil as a global check
-- The anti-dumper does: if Drawing and type(Drawing) == "table" and Drawing.header then
-- We keep Drawing = nil so this check passes, but if the script assigns Drawing we handle it
Drawing = nil
_G.Drawing = nil

-- newproxy: Lua 5.1 function that creates userdata with optional metatable
newproxy = function(addMetatable)
    local proxy = {}
    if addMetatable then
        local mt = {}
        setmetatable(proxy, mt)
        rawset(proxy, "__newproxy_mt", mt)
    else
        setmetatable(proxy, {__metatable = false})
    end
    rawset(proxy, v, true)
    bf[proxy] = true
    return proxy
end
_G.newproxy = newproxy

syn = nil
_G.syn = nil
fluxus = nil
_G.fluxus = nil
KRNL_LOADED = nil
_G.KRNL_LOADED = nil
Synapse = nil
_G.Synapse = nil
is_synapse_function = nil
_G.is_synapse_function = nil
getgenv = function() return eD end
_G.getgenv = getgenv
getrenv = function() return {} end
_G.getrenv = getrenv
getrawmetatable = nil
_G.getrawmetatable = nil
setrawmetatable = nil
_G.setrawmetatable = nil
hookfunction = nil
_G.hookfunction = nil
hookmetamethod = nil
_G.hookmetamethod = nil
newcclosure = nil
_G.newcclosure = nil
iscclosure = nil
_G.iscclosure = nil
islclosure = nil
_G.islclosure = nil
getnamecallmethod = nil
_G.getnamecallmethod = nil
checkcaller = nil
_G.checkcaller = nil
getcallingscript = nil
_G.getcallingscript = nil
getscriptclosure = nil
_G.getscriptclosure = nil
decompile = nil
_G.decompile = nil
firesignal = nil
_G.firesignal = nil
fireclickdetector = nil
_G.fireclickdetector = nil
firetouchinterest = nil
_G.firetouchinterest = nil
fireproximityprompt = nil
_G.fireproximityprompt = nil


function q.reset()
    t = {
        output = {},
        indent = 0,
        registry = {},
        reverse_registry = {},
        names_used = {},
        parent_map = {},
        property_store = {},
        call_graph = {},
        variable_types = {},
        string_refs = {},
        proxy_id = 0,
        callback_depth = 0,
        pending_iterator = false,
        last_http_url = nil,
        last_emitted_line = nil,
        repetition_count = 0,
        current_size = 0,
        limit_reached = false,
        lar_counter = 0,
        captured_constants = {},
        fake_time = 0,
        heartbeat_count = 0,
        op_count = 0,
        loop_count = 0,
        link_spy = {},
        cache = {},
        message_out_listeners = {},
        in_message_out = false,
        logged_links = {},
        last_namecall_method = "HttpGet"
    }

    -- Register global functions for hook logging
    for _, name in ipairs(ExecEnv) do
        local val = _G[name]
        if type(val) == "function" then
            t.registry[val] = name
        end
    end
    aM = {}
    game = bj("game", true)
    workspace = bj("workspace", true)
    script = bj("script", true)
    Enum = bj("Enum", true)
    Instance = bj("Instance", true)
    shared = bj("shared", true)
    t.property_store[game] = {PlaceId = u, GameId = u, JobId = "job", placeId = u, gameId = u}
    _G.game = game
    _G.Game = game
    _G.workspace = workspace
    _G.Workspace = workspace
    _G.script = script
    _G.Enum = Enum
    _G.Instance = Instance
    _G.shared = shared
    
    -- Explicitly add .new to Instance proxy
    t.property_store[Instance] = {
        new = function(_, cn) return bj(cn or "Instance", false) end
    }
    
    local dm = a.getmetatable(Enum)
    dm.__index = function(b2, b4)
        if b4 == F or b4 == "__proxy_id" or b4 == v then
            if b4 == v then return true end
            return rawget(b2, b4)
        end
        return bj(b4, false, b2)
    end
end

function q.get_output()
    return aB()
end

function q.save(aD)
    return aC(aD)
end

function q.get_call_graph()
    return t.call_graph
end

function q.get_string_refs()
    return t.string_refs
end

function q.get_stats()
    return {
        total_lines = #t.output,
        remote_calls = #t.call_graph,
        suspicious_strings = #t.string_refs,
        proxies_created = t.proxy_id
    }
end

function q.dump_env(filePath, flags)
    local getsenv = getsenv or false
    if getsenv == false then
        az("Error: getsenv is not supported by this executor")
        return false, "getsenv not supported"
    end
    
    if not filePath then
        az("Error: FilePath parameter is required")
        return false, "FilePath required"
    end
    
    local ok, err = pcall(function()
        if typeof(filePath) ~= "Instance" then
            error("FilePath must be a Roblox Instance")
        end
        filePath:GetFullName()
    end)
    
    if not ok then
        az("Error: Invalid FilePath - " .. tostring(err))
        return false, "Invalid FilePath"
    end
    
    flags = flags or {}
    local defaultFlags = {
        ["only-functions"] = false,
        ["only-values"] = false,
        ["no-functions"] = false,
        ["no-tables"] = false,
        ["no-userdata"] = false,
        ["no-upvalues"] = false,
        ["no-writing"] = false,
        ["no-printing"] = false
    }
    
    for k, v in pairs(defaultFlags) do
        if flags[k] == nil then
            flags[k] = v
        end
    end
    
    q.reset()
    
    local env = getsenv(filePath)
    if not env then
        az("Error: getsenv returned nil for " .. tostring(filePath.Name))
        return false, "getsenv returned nil"
    end
    
    az("=== " .. filePath.Name .. " ENVIRONMENT DUMP ===")
    az("Timestamp: " .. os.date("%Y-%m-%d %H:%M:%S"))
    aA()
    
    local visited = {}
    local originalGetupvalue = a.getupvalue or (debug and debug.getupvalue)
    
    local function allowed(t)
        if flags["only-functions"] then return t == "function" end
        if flags["only-values"] then return t ~= "function" and t ~= "table" and t ~= "userdata" end
        if t == "function" and flags["no-functions"] then return false end
        if t == "table" and flags["no-tables"] then return false end
        if t == "userdata" and flags["no-userdata"] then return false end
        return true
    end
    
    local function dump_table(tbl, prefix, depth)
        depth = depth or 0
        if depth > 6 then return end
        if visited[tbl] then
            at(prefix .. " = <circular>")
            return
        end
        visited[tbl] = true
        
        local functions, values, tables, userdata, upvalues = {}, {}, {}, {}, {}
        local funcKeys, valueKeys, tableKeys, userdataKeys = {}, {}, {}, {}
        
        for k, v in pairs(tbl) do
            local keyStr = prefix ~= "" and (prefix .. "." .. tostring(k)) or tostring(k)
            local t = typeof(v)
            
            if t == "table" then
                if allowed(t) then
                    tables[keyStr] = v
                    table.insert(tableKeys, keyStr)
                end
                if not flags["no-tables"] and not flags["only-functions"] and not flags["only-values"] then
                    dump_table(v, keyStr, depth + 1)
                end
            elseif t == "function" then
                if allowed(t) then
                    functions[keyStr] = v
                    table.insert(funcKeys, keyStr)
                    if not flags["no-upvalues"] and originalGetupvalue then
                        local i = 1
                        while true do
                            local success, name, val = pcall(function()
                                return originalGetupvalue(v, i)
                            end)
                            if not success or not name then break end
                            table.insert(upvalues, string.format("  %s.upval[%s] = %s (%s)", 
                                keyStr:gsub("\"", "\\\\\""), 
                                tostring(name):gsub("\"", "\\\\\""), 
                                aZ(val),
                                typeof(val)))
                            i = i + 1
                        end
                    end
                end
            elseif t == "userdata" then
                if allowed(t) then
                    userdata[keyStr] = v
                    table.insert(userdataKeys, keyStr)
                end
            else
                if allowed(t) then
                    values[keyStr] = v
                    table.insert(valueKeys, keyStr)
                end
            end
        end
        
        -- Sort all key lists for consistent, readable output
        table.sort(funcKeys)
        table.sort(valueKeys)
        table.sort(tableKeys)
        table.sort(userdataKeys)
        
        local indent = string.rep("  ", depth)
        
        local categories = {
            {name = "values", keys = valueKeys, data = values},
            {name = "functions", keys = funcKeys, data = functions},
            {name = "tables", keys = tableKeys, data = tables},
            {name = "userdata", keys = userdataKeys, data = userdata},
            {name = "upvalues", data = upvalues}
        }
        
        for _, cat in ipairs(categories) do
            if cat.name == "upvalues" then
                if #cat.data > 0 then
                    at(indent .. "-- UPVALUES " .. (prefix ~= "" and ("(" .. prefix .. ")") or "") .. " --")
                    for _, line in ipairs(cat.data) do at(indent .. line) end
                    aA()
                end
            elseif cat.keys and #cat.keys > 0 then
                local countStr = " (" .. #cat.keys .. ")"
                at(indent .. "-- " .. cat.name:upper() .. countStr .. " " .. (prefix ~= "" and ("in " .. prefix) or "") .. " --")
                for _, k in ipairs(cat.keys) do
                    local v = cat.data[k]
                    if cat.name == "functions" then
                        -- Show function with argument count hint
                        local argHint = ""
                        local ok, info = pcall(function()
                            return debug and debug.info and debug.info(v, "a") or nil
                        end)
                        if ok and info then
                            argHint = " --[[" .. tostring(info) .. " args]]"
                        end
                        at(indent .. "  " .. k .. " = function(...)" .. argHint)
                    elseif cat.name == "values" then
                        at(indent .. "  " .. k .. " = " .. aZ(v) .. "  -- " .. typeof(v))
                    elseif cat.name == "tables" then
                        -- Show element count for tables
                        local subCount = 0
                        local ok = pcall(function()
                            for _ in pairs(v) do subCount = subCount + 1 end
                        end)
                        local mtHint = ""
                        local mOk, mt = pcall(getmetatable, v)
                        if mOk and mt then mtHint = " [has metatable]" end
                        at(indent .. "  " .. k .. " = table (" .. subCount .. " items)" .. mtHint)
                    elseif cat.name == "userdata" then
                        local className = ""
                        local ok, cn = pcall(function() return v.ClassName end)
                        if ok and cn then className = " (" .. tostring(cn) .. ")" end
                        at(indent .. "  " .. k .. " = userdata" .. className)
                    end
                end
                aA()
            end
        end
    end
    
    dump_table(env, "")
    
    az("=== END ENV DUMP ===")
    
    local result = aB()
    
    if not flags["no-printing"] then
        B(result)
    else
        B(filePath.Name .. " environment dump completed")
    end
    
    if not flags["no-writing"] then
        local fileName = filePath.Name .. "_env_dump.lua"
        aC(fileName)
        az("Saved to: " .. fileName)
    end
    
    return true, result
end

local eE = {
    callId = "LARRY_",
    binaryOperatorNames = {
        ["and"] = "AND",
        ["or"] = "OR",
        [">"] = "GT",
        ["<"] = "LT",
        [">="] = "GE",
        ["<="] = "LE",
        ["=="] = "EQ",
        ["~="] = "NEQ",
        [".."] = "CAT"
    }
}

function eE:hook(al)
    return self.callId .. al
end

function eE:process_expr(eF)
    if not eF then
        return "nil"
    end
    if type(eF) == "string" then
        return eF
    end
    local eG = eF.tag or eF.kind
    if eG == "number" or eG == "string" then
        local aF = eG == "string" and string.format("%q", eF.text) or (eF.value or eF.text)
        if r.CONSTANT_COLLECTION then
            return string.format("%sGET(%s)", self.callId, aF)
        end
        return aF
    end
    if eG == "local" or eG == "global" then
        return (eF.name or eF.token).text
    elseif eG == "boolean" or eG == "bool" then
        return tostring(eF.value)
    elseif eG == "binary" then
        local eH = self:process_expr(eF.lhsoperand)
        local eI = self:process_expr(eF.rhsoperand)
        local X = eF.operator.text
        local eJ = self.binaryOperatorNames[X]
        if eJ then
            return string.format("%s%s(%s, %s)", self.callId, eJ, eH, eI)
        end
        return string.format("(%s %s %s)", eH, X, eI)
    elseif eG == "call" then
        local dr = self:process_expr(eF.func)
        local bA = {}
        for L, b5 in ipairs(eF.arguments) do
            bA[L] = self:process_expr(b5.node or b5)
        end
        return string.format("%sCALL(%s, %s)", self.callId, dr, table.concat(bA, ", "))
    elseif eG == "indexname" or eG == "index" then
        local bS = self:process_expr(eF.expression)
        local ba = eG == "indexname" and string.format("%q", eF.index.text) or self:process_expr(eF.index)
        return string.format("%sCHECKINDEX(%s, %s)", self.callId, bS, ba)
    end
    return "nil"
end

function eE:process_statement(eF)
    if not eF then
        return ""
    end
    local eG = eF.tag
    if eG == "local" or eG == "assign" then
        local eK, eL = {}, {}
        for W, b5 in ipairs(eF.variables or {}) do
            table.insert(eK, self:process_expr(b5.node or b5))
        end
        for W, b5 in ipairs(eF.values or {}) do
            table.insert(eL, self:process_expr(b5.node or b5))
        end
        return (eG == "local" and "local " or "") .. table.concat(eK, ", ") .. " = " .. table.concat(eL, ", ")
    elseif eG == "block" then
        local b9 = {}
        for W, eM in ipairs(eF.statements or {}) do
            table.insert(b9, self:process_statement(eM))
        end
        return table.concat(b9, "; ")
    end
    return self:process_expr(eF) or ""
end

function q.dump_file(eN, eO)
    q.reset()
    az("This file was deobfuscated by SeCCBreak V.1.0 \nlocal fenv = getfenv()\n")
    local as = o.open(eN, "rb")
    if not as then
        return false
    end
    local al = as:read("*a")
    as:close()
    
    -- Strip BOM and handle UTF-16
    if al:sub(1,3) == "\239\187\191" then -- UTF-8 BOM
        B("[i] UTF-8 BOM detected, stripping...")
        al = al:sub(4)
    elseif al:sub(1,2) == "\255\254" then -- UTF-16LE
        B("[i] UTF-16LE detected, converting...")
        local res = {}
        for i = 3, #al, 2 do
            table.insert(res, al:sub(i,i))
        end
        al = table.concat(res)
    elseif al:sub(1,2) == "\254\255" then -- UTF-16BE
        B("[i] UTF-16BE detected, converting...")
        local res = {}
        for i = 4, #al, 2 do
            table.insert(res, al:sub(i,i))
        end
        al = table.concat(res)
    end

    -- PlaceId Spoofing: Check first 2 lines for "placeid = <number>"
    local spoofId = al:match("^%s*placeid%s*=%s*(%d+)") or al:match("\n%s*placeid%s*=%s*(%d+)")
    if spoofId then
        local newId = tonumber(spoofId)
        B("[!] spoofing PlaceId: " .. newId)
        u = newId -- Override global PlaceId variable
        -- Strip the spoofing line from the script to avoid syntax errors
        al = al:gsub("^%s*placeid%s*=%s*%d+%s*\r?\n?", ""):gsub("\n%s*placeid%s*=%s*%d+%s*\r?\n?", "\n")
    end

    -- Detect binary data (bytecode)
    local isBinary = al:sub(1, 4) == "\27Lua" or al:sub(1, 4) == "\1\0\0\0" or al:find("[\0-\8\14-\31]")
    -- B("[i] file read, size: " .. #al .. (isBinary and " (binary detected)" or ""))

    -- sniff(al, "static") - Removed as requested to focus on dynamic interception

    -- MoonSec V3 Detection (ported from hi.lua)
    local isMoonSec = al:find("This file was protected with MoonSec V3") or al:find("MoonSec V3")
    local isMoonSecAntiTamper = isMoonSec and al:find("_ENV")
    local isMoonSecCP = isMoonSec and al:find("//")
    if isMoonSec then
        B("[>] moonsec v3 detected")
    end
    if isMoonSecAntiTamper then
        B("[>] anti-tamper detected (_env)")
    end
    if isMoonSecCP then
        B("[>] constant protection detected (//)")
    end
    -- B("[*] cleaning luau / binary literals...")
    local eP
    if isBinary then
        B("[!] binary data detected, skipping intensive sanitization")
        eP = al
    else
        -- B("[*] cleaning luau / binary literals...")
        eP = I(al)
    end
    local debug_filename = "DEBUG_SANITIZED.lua"
    local debug_out = o.open(debug_filename, "w")
    if debug_out then
        debug_out:write(eP)
        debug_out:close()
        -- B("[i] debug: saved sanitized code to " .. debug_filename)
    end
    -- B("[i] sanitization done")
    -- NOTE: Script loading moved below sandbox setup so eR can be passed as _ENV
    local R, eQ
    
    local sandbox_writes = {}
    local eR
    eR = {
        CHECKWHILE = function(Condition)
            t.loop_count = t.loop_count + 1
            if t.loop_count >= r.MAX_WHILE_COUNT then
                at("-- SeCCBreak Infinite loop")
                return false
            end
            return Condition
        end,
        LuraphContinue = function() end,
        script = script,
        game = game,
        workspace = workspace,
        -- MoonSec constant protection: pass through core functions
        tonumber = tonumber,
        select = select,
        unpack = unpack or table.unpack,
        tostring = tostring,
        pcall = function(as, ...)
            local dg = {g(as, ...)}
            if not dg[1] and m(dg[2]):match("Time Limit Exceeded") then
                i(dg[2], 0)
            end
            return table.unpack(dg)
        end,
        setmetatable = setmetatable,
        getmetatable = function(obj)
            -- First check for our custom newproxy tables before checking fake type()
            if j(obj) == "table" then
                local proxyMt = rawget(obj, "__newproxy_mt")
                if proxyMt then
                    return proxyMt
                end
                if G(obj) then
                    return "The metatable is locked"
                end
            end
            if type(obj) == "string" or type(obj) == "number" or type(obj) == "function" then return nil end
            local mt = _G.getmetatable(obj)
            return mt
        end,
        rawget = rawget,
        rawset = rawset,
        string = (function()
            local t = {}
            for k, v in pairs(_G.string or string) do t[k] = v end
            t.char = function(...)
                local res = string.char(...)
                sniff(res, "string.char")
                return res
            end
            t.unpack = function(fmt, data, pos)
                local success, result, next_pos = pcall(string.unpack, fmt, data, pos or 1)
                if not success then
                    B(string.format("[!] string.unpack ERROR: %s | Fmt: %q | DataLen: %d | Pos: %s", 
                        tostring(result), tostring(fmt), #tostring(data), tostring(pos)))
                    error(result, 0)
                end
                return result, next_pos
            end
            return t
        end)(),
        assert = assert,
        require = function(...) B("[!] blocked require") return nil end,
        io = {},
        os = (function()
            local t = {}
            for k, v in pairs(_G.os or os) do t[k] = v end
            return t
        end)(),
        math = (function()
            local t = {}
            for k, v in pairs(_G.math or math) do t[k] = v end
            return t
        end)(),
        _G = nil, -- Set below
        _ENV = nil, -- Set below
        -- Corrected bit32 assignment to use local mock if global is missing
        bit32 = _G.bit32 or bit32,
        bit = _G.bit32 or bit32,
        -- Anti-Spy Bypasses (Executor Mocks)
        getgenv = function() return sandbox_writes end,
        getrenv = function() return eR end,
        getfenv = function(lvl)
            -- Always return sandbox env, never the real _G
            return eR
        end,
        setfenv = function(fn, env)
            -- Block setfenv to prevent env manipulation but log it
            B("[!] blocked setfenv attempt")
            at(string.format("setfenv(%s, %s)", aZ(fn), aZ(env)))
            return fn
        end,
        hookfunction = function(target, hook)
            local targetName = t.registry[target] or aZ(target)
            B("[!] HOOK: hookfunction(" .. targetName .. ", ...)")
            at(string.format("hookfunction(%s, function(...) --[[ hook ]] end)", targetName))
            return target -- Return original (as if hooked)
        end,
        replaceclosure = function(target, hook)
            local targetName = t.registry[target] or aZ(target)
            B("[!] HOOK: replaceclosure(" .. targetName .. ", ...)")
            at(string.format("replaceclosure(%s, function(...) --[[ hook ]] end)", targetName))
            return target
        end,
        hookmetamethod = function(obj, method, hook)
            local objName = t.registry[obj] or aZ(obj)
            B("[!] HOOK: hookmetamethod(" .. objName .. ", " .. m(method) .. ", ...)")
            at(string.format("hookmetamethod(%s, %q, function(...) --[[ hook ]] end)", objName, m(method)))
            
            -- Return a functional "old" handler
            return function(self, ...)
                local bA = {...}
                local mth = method
                if method == "__namecall" then
                    mth = t.last_namecall_method or "HttpGet"
                end
                
                -- Attempt to call the method on self if it's a proxy
                if G(self) then
                    local target = self[mth]
                    if type(target) == "function" then
                        return target(self, table.unpack(bA))
                    end
                end
                return nil
            end
        end,
        getoriginalfunction = function(fn) return fn end,
        clonefunction = function(fn) 
            at(string.format("clonefunction(%s)", aZ(fn)))
            return fn 
        end,
        newcclosure = function(fn)
            at(string.format("newcclosure(%s)", aZ(fn)))
            return fn
        end,
        getupvalues = function(fn) return {} end,
        getupvalue = function(fn, index) return nil, nil end,
        debug = {
            getupvalue = function(fn, index) return nil, nil end,
            setupvalue = function(fn, index, val) end,
            getconstants = function(fn) return {} end,
            getinfo = function(fn) return {} end,
            profilebegin = function() end,
            profileend = function() end
        },
        setclipboard = function(content)
            local str = type(content) == "string" and content or tostring(content)
            sniff(str, "clipboard")
            table.insert(t.string_refs, {value = str, hint = "clipboard"})
            B("[!] clipboard: " .. str)
            at(string.format("setclipboard(%s)", aZ(str)))
        end,
        toclipboard = function(content)
            local str = type(content) == "string" and content or tostring(content)
            sniff(str, "clipboard")
            table.insert(t.string_refs, {value = str, hint = "clipboard"})
            B("[!] clipboard: " .. str)
            at(string.format("setclipboard(%s)", aZ(str)))
        end,
        islclosure = function(fn)
            return type(fn) == "function" -- Simplified
        end,
        iscclosure = function(fn)
            return false -- Most things are lclosures in our VM
        end,
        newcclosure = function(fn) 
            at("newcclosure(function(...) --[[ ... ]] end)")
            return fn 
        end,
        getrawmetatable = function(obj) 
            return {
                __namecall = function() end, 
                __index = function() end,
                __tostring = function() return "Metatable" end
            } 
        end,
        setreadonly = function(t, val) 
            at(string.format("setreadonly(%s, %s)", aZ(t), tostring(val)))
        end,
        isreadonly = function(t) return false end,
        getnamecallmethod = function() 
            return t.last_namecall_method or "HttpGet" 
        end,
        setnamecallmethod = function(method)
            t.last_namecall_method = method
        end,
        checkcaller = function() return false end,
        identifyexecutor = function() return "SeCCBreak VM", "1.0" end,
        getgc = function(include_tables) return {} end,
        warn = warn,
        request = function(options)
            local url = type(options) == "table" and options.Url or (type(options) == "string" and options or "")
            sniff(url, "request")
            table.insert(t.string_refs, {value = url, hint = "HTTP Request URL"})
            table.insert(t.link_spy, {url = url, method = "request", from = "global"})
            B("[!] link: " .. url)
            at(string.format("request({Url = %s})", aH(url)))
            return {Body = "{}", StatusCode = 200, Success = true}
        end,
        http_request = function(options)
            local url = type(options) == "table" and options.Url or (type(options) == "string" and options or "")
            table.insert(t.string_refs, {value = url, hint = "HTTP Request URL"})
            table.insert(t.link_spy, {url = url, method = "http_request", from = "global"})
            B("[LINK SPY] http_request: " .. url)
            at(string.format("http_request({Url = %s})", aH(url)))
            return {Body = "{}", StatusCode = 200, Success = true}
        end,
        syn = {
            request = function(options)
                local url = type(options) == "table" and options.Url or (type(options) == "string" and options or "")
                table.insert(t.string_refs, {value = url, hint = "HTTP Request URL"})
                table.insert(t.link_spy, {url = url, method = "syn.request", from = "syn"})
                B("[!] link: " .. url)
                at(string.format("syn.request({Url = %s})", aH(url)))
                return {Body = "{}", StatusCode = 200, Success = true}
            end
        },
        http = {
            request = function(options)
                local url = type(options) == "table" and options.Url or (type(options) == "string" and options or "")
                table.insert(t.string_refs, {value = url, hint = "HTTP Request URL"})
                table.insert(t.link_spy, {url = url, method = "http.request", from = "http"})
                B("[!] link: " .. url)
                at(string.format("http.request({Url = %s})", aH(url)))
                return {Body = "{}", StatusCode = 200, Success = true}
            end
        },
        LARRY_CHECKINDEX = function(x, ba)
            local aF = x[ba]
            if j(aF) == "table" and not t.registry[aF] then
                t.lar_counter = t.lar_counter + 1
                t.registry[aF] = "lartab" .. t.lar_counter
            end
            return aF
        end,
        LARRY_GET = function(b5)
            return b5
        end,
        LARRY_CALL = function(as, ...)
            return as(...)
        end,
        LARRY_NAMECALL = function(eS, em, ...)
            return eS[em](eS, ...)
        end,
        LARRY_GT = function(a, b) return A(a) > A(b) end,
        LARRY_LT = function(a, b) return A(a) < A(b) end,
        LARRY_GE = function(a, b) return A(a) >= A(b) end,
        LARRY_LE = function(a, b) return A(a) <= A(b) end,
        LARRY_EQ = function(a, b) return a == b end,
        LARRY_NEQ = function(a, b) return a ~= b end,
        LARRY_AND = function(a, b) return a and b end,
        LARRY_OR = function(a, b) return a or b end,
        LARRY_CAT = function(a, b) return tostring(a) .. tostring(b) end,
        pcall = function(as, ...)
            local dg = {g(as, ...)}
            if not dg[1] and m(dg[2]):match("Time Limit Exceeded") then
                i(dg[2], 0)
            end
            return table.unpack(dg)
        end,
        spawn = function(fn)
            if j(fn) == "function" then
                xpcall(fn, function() end)
            end
        end,
        task = {
            spawn = function(fn, ...)
                local co
                if j(fn) == "function" then
                    co = coroutine.create(fn)
                    coroutine.resume(co, ...)
                elseif j(fn) == "thread" then
                    co = fn
                    coroutine.resume(co, ...)
                end
                return co
            end,
            wait = function(n)
                local waitTime = n or 0.03
                if waitTime < 0 then
                    error("duration cannot be negative", 0)
                end
                t.fake_time = t.fake_time + waitTime
                -- Phase 1 Simulation: Heartbeat escape
                if _G.heartbeat_listeners then
                    for _, fn in ipairs(_G.heartbeat_listeners) do
                        pcall(fn, waitTime)
                    end
                end
                return waitTime
            end,
            delay = function(n, fn, ...)
                local co
                if j(fn) == "function" then
                    co = coroutine.create(fn)
                    coroutine.resume(co, ...)
                elseif j(fn) == "thread" then
                    co = fn
                    coroutine.resume(co, ...)
                end
                return co
            end,
            defer = function(fn, ...)
                local co
                if j(fn) == "function" then
                    co = coroutine.create(fn)
                    coroutine.resume(co, ...)
                elseif j(fn) == "thread" then
                    co = fn
                    coroutine.resume(co, ...)
                end
                return co
            end
        },
        type = function(x)
            if G(x) then return "userdata" end
            return j(x)
        end,
        typeof = function(x)
            if G(x) then
                local n = t.registry[x] or ""
                -- EnumItem: deeply nested like Enum.Material.Plastic
                if n:match("^Enum%.") and n:match("^Enum%.[^%.]+%.") then return "EnumItem" end
                -- Enum namespace
                if n == "Enum" or n:match("^Enum%.") then return "Enum" end
                if n:match("^Vector3") then return "Vector3" end
                if n:match("^CFrame") then return "CFrame" end
                if n:match("^Color3") then return "Color3" end
                if n:match("^UDim2") then return "UDim2" end
                if n:match("^UDim") then return "UDim" end
                if n:match("^TweenInfo") then return "TweenInfo" end
                if n:match("^Ray") then return "Ray" end
                -- RBXScriptSignal for event properties
                local signalNames = {Changed=1, Heartbeat=1, Stepped=1, RenderStepped=1, ChildAdded=1, ChildRemoved=1, PlayerAdded=1, PlayerRemoving=1, CharacterAdded=1, CharacterRemoving=1, Touched=1, TouchEnded=1, InputBegan=1, InputEnded=1, InputChanged=1, Died=1, HealthChanged=1, Activated=1, Deactivated=1, FocusLost=1, Triggered=1, TriggerEnded=1, OnClientEvent=1, OnServerEvent=1, MessageOut=1}
                local shortName = n:match("%.([^%.]+)$")
                if shortName and signalNames[shortName] then return "RBXScriptSignal" end
                if n:match("^RBXScriptSignal") then return "RBXScriptSignal" end
                if n:match("^RBXScriptConnection") or n:match("Connection$") then return "RBXScriptConnection" end
                return "Instance"
            end
            return j(x)
        end,
        table = (function()
            local t = {}
            for k, v in pairs(_G.table or table) do t[k] = v end
            t.concat = function(...)
                local res = table.concat(...)
                sniff(res, "table.concat")
                return res
            end
            return t
        end)(),
        newproxy = function(addMeta)
            local proxy = {}
            if addMeta then
                local mt = {}
                proxy.__newproxy_mt = mt
                setmetatable(proxy, mt)
            end
            return proxy
        end,
        loadstring = function(code, chunkname)
            B("[!] loadstring intercepted (" .. tostring(chunkname or "chunk") .. "), size=" .. #tostring(code))
            sniff(tostring(code), "loadstring")
            local fn, err = load(code, chunkname or "loadstring_chunk", "t", eR)
            if not fn then
                B("[!] loadstring compile error: " .. tostring(err))
            end
            return fn, err
        end,
        load = function(chunk, chunkname, mode, env)
            B("[!] load intercepted (" .. tostring(chunkname or "chunk") .. ")")
            if type(chunk) == "string" then sniff(chunk, "load") end
            local fn, err
            if type(load) == "function" then
                -- Try to use load directly
                local s, r, e = pcall(function() return load(chunk, chunkname or "load_chunk", mode or "bt", env or eR) end)
                if s then fn, err = r, e end
            end
            if not fn and type(chunk) == "string" then
                -- Fallback to loadstring if load failed
                local s, r, e = pcall(function() return loadstring(chunk, chunkname or "load_chunk") end)
                if s and r then 
                    fn = r
                    if env then setfenv(fn, env) end
                elseif s then err = e end
            end
            if not fn then B("[!] load compile error: " .. tostring(err)) end
            return fn, err
        end
    }
    
    -- Blocked globals that should never leak from _G
    local _blocked_globals = {
        ["os"] = true, ["io"] = true, ["require"] = true, ["dofile"] = true,
        ["loadfile"] = true, ["package"] = true, ["_G"] = true, ["_ENV"] = true,
        ["debug"] = true, ["process"] = true, ["fs"] = true, ["system"] = true,
        ["stdio"] = true, ["lune"] = true,
        ["module"] = true
    }
    
    -- Additional Roblox globals
    eR.elapsedTime = function() return t.fake_time end
    eR.stats = function() return bj("Stats", false) end
    eR.settings = function() return bj("Settings", false) end
    eR.UserSettings = function() return bj("UserSettings", false) end
    
    eR.utf8 = setmetatable({
        nfcnormalize = function(s) return s end,
        nfdnormalize = function(s) return s end
    }, { __index = eR.utf8 or utf8 })
    
    eR.getfenv = function(lvl)
        if type(lvl) == "number" and lvl == 0 then return eR end
        local ok, env = pcall(getfenv, type(lvl) == "number" and (lvl + 1) or lvl)
        return ok and env or eR
    end
    
    eR.setfenv = function(fn, env)
        local ok, res = pcall(setfenv, fn, env)
        return ok and res or fn
    end
    
    eR.setmetatable = setmetatable
    eR.getmetatable = function(obj)
        if type(obj) == "table" and rawget(obj, "__newproxy_mt") then
            return rawget(obj, "__newproxy_mt")
        end
        return getmetatable(obj)
    end
    
    eR.debug = {
        profilebegin = function() end,
        profileend = function() end,
        traceback = function()
            local tb = d()
            -- Sanitize paths from traceback
            tb = tb:gsub("[^%s\n]*[\\/]", "")
            return tb
        end,
        getinfo = function() return {} end,
        getupvalue = function() return nil, nil end,
        setupvalue = function() end,
        getconstants = function() return {} end,
        sethook = function() end,
        getmetatable = function() return nil end,
        setmetatable = function() return nil end
    }
    
    local sandbox_G = setmetatable({}, {
        __index = function(_, k)
            if sandbox_writes[k] ~= nil then return sandbox_writes[k] end
            local sandbox_val = rawget(eR, k)
            if sandbox_val ~= nil then return sandbox_val end
            if _blocked_globals[k] then return nil end
            local real_val = _G[k]
            if real_val ~= nil then return real_val end
            -- SPY FALLBACK: Return a proxy for unknown globals (Zala "field '?'" fix)
            return bj(tostring(k), false, "_G")
        end,
        __newindex = function(_, k, val)
            sandbox_writes[k] = val
        end,
        __metatable = "The metatable is locked"
    })
    eR._G = sandbox_G
    eR._ENV = eR
    eR.shared = {}

    setmetatable(eR, {
        __index = function(_, k)
            if sandbox_writes[k] ~= nil then return sandbox_writes[k] end
            if _blocked_globals[k] then
                B("[!] BLOCKED global access: " .. m(k))
                return nil
            end
            local val = rawget(eR, k)
            if val ~= nil then return val end
            local real_val = _G[k]
            if real_val ~= nil then return real_val end
            -- SPY FALLBACK: Return a proxy for unknown globals in eR (for Lua 5.1 setfenv)
            if j(k) == "string" and k ~= "_ENV" then
                return bj(k, false, "_G")
            end
            return nil
        end,
        __newindex = function(_, k, val)
            sandbox_writes[k] = val
        end,
        __metatable = "The metatable is locked"
    })

    -- Load script with sandbox as _ENV (Lua 5.2+) or use setfenv (Lua 5.1)
    -- Load script with sandbox as _ENV (Lua 5.2+) or use setfenv (Lua 5.1)
    if setfenv then
        -- Lua 5.1: load then setfenv
        R, eQ = e(eP, "Obfuscated_Script")
        if not R then
            B("\n[error] lua load fail: " .. m(eQ))
            return false
        end
        setfenv(R, eR)
    else
        -- Lua 5.2+: pass eR as _ENV (4th arg to load)
        R, eQ = load(eP, "Obfuscated_Script", "t", eR)
        if not R then
            B("\n[error] lua load fail: " .. m(eQ))
            return false
        end
    end
    B("[i] script loaded with sandbox env")
    
    B("[*] running vm...")
    if isMoonSec then
        B("[>] using moonsec-aware sandbox")
    end
    local eT = p.clock()
    b(function()
        if p.clock() - eT > r.TIMEOUT_SECONDS then
            error("Time Limit Exceeded", 0)
        end
    end, "", 1000)
    
    local eo, eU = h(function()
        R()
    end, function(ds)
        return tostring(ds) .. "\n" .. debug.traceback()
    end)
    
    b()
    if not eo then
        az("Stopped: " .. eU)
    end

    -- Final memory sweep
    B("[*] final memory sweep...")
    for _, ref in ipairs(t.string_refs) do
        if type(ref.value) == "string" then
            sniff(ref.value, "Ref Pool (" .. (ref.hint or "unknown") .. ")")
        end
    end
    for k, v in pairs(sandbox_writes) do
        if type(v) == "string" then sniff(v, "Sandbox Write (Val)") end
        if type(k) == "string" then sniff(k, "Sandbox Write (Key)") end
    end
    -- Link Spy Summary (console only)
    if #t.link_spy > 0 then
        B("[!] link recovery summary")
        for i, link in ipairs(t.link_spy) do
            local info = link.url .. " (" .. (link.from or "unknown") .. ")"
            if link.source_size then info = info .. " [" .. link.source_size .. " bytes]" end
            B("    " .. i .. ": " .. info)
        end
    end
    return q.save(eO or r.OUTPUT_FILE)
end

function q.dump_string(al, eO)
    q.reset()
    az("This file was deobfuscated by SeCCBreak V.1.0")
    if al then
        -- PlaceId Spoofing: Check for "placeid = <number>"
        local spoofId = al:match("^%s*placeid%s*=%s*(%d+)") or al:match("\n%s*placeid%s*=%s*(%d+)")
        if spoofId then
            local newId = tonumber(spoofId)
            B("[!] spoofing PlaceId: " .. newId)
            u = newId -- Override global PlaceId variable
            al = al:gsub("^%s*placeid%s*=%s*%d+%s*\r?\n?", ""):gsub("\n%s*placeid%s*=%s*%d+%s*\r?\n?", "\n")
        end
        al = I(al)
    end
    local R, an = e(al)
    if not R then
        az("Load Error: " .. (an or "unknown"))
        return false, an
    end
    -- SECURITY: Apply sandbox to prevent VM escape
    if setfenv then
        local safe_env = setmetatable({}, {
            __index = function(_, k)
                local blocked = {os=1, io=1, debug=1, package=1, require=1, dofile=1, loadfile=1, process=1, _ENV=1}
                if blocked[k] then return nil end
                return _G[k]
            end,
            __newindex = function(_, k, v) rawset(_, k, v) end,
            __metatable = "The metatable is locked"
        })
        setfenv(R, safe_env)
    end
    local eT = p.clock()
    b(function()
        if p.clock() - eT > r.TIMEOUT_SECONDS then
            error("Time Limit Exceeded", 0)
        end
    end, "", 1000)
    xpcall(function()
        R()
    end, function() end)
    b() -- Remove hook
    if eO then
        return q.save(eO)
    end
    return true, aB()
end

if arg and arg[1] then
    local eo = q.dump_file(arg[1], arg[2])
    if eo then
        B("Saved to: " .. (arg[2] or r.OUTPUT_FILE))
        local eV = q.get_stats()
        B(string.format("Lines: %d | Remotes: %d | Strings: %d", eV.total_lines, eV.remote_calls, eV.suspicious_strings))
    end
else
    local as = o.open("obfuscated.lua", "rb")
    if as then
        as:close()
        local eo = q.dump_file("obfuscated.lua")
        if eo then
            B("Saved to: " .. r.OUTPUT_FILE)
            B(q.get_output())
        end
    else
        B("Usage: lua dumper.lua <input> [output] [key]")
    end
end

return q
