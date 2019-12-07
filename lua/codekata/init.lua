
function list_directories(dir)
    local result = {}
    local p = io.popen('find "'..dir..'" -type d -depth 1')
    for d in p:lines() do                         --Loop through all files
        table.insert(result, d)
    end
    p:close()
    return result
end

local function set_kata_config(property, value)
    file = io.open ("stats.txt" , "a")
    --let contents = file:read("*a")
    file:write(property .. "=" .. value .. "\n")
    file:close()
end

local function get_kata_config(property)
    for line in io.lines("stats.txt") do
        local i, j = string.find(line, "=", 1, true)
        local p = string.sub(line, 1, i - 1)
        if p == property then
            return string.sub(line, j + 1)
        end
    end
end

local function parse_csv_line(line, sep)
    local res = {}
    local pos = 1
    sep = sep or ','
    while true do
        local c = string.sub(line,pos,pos)
        if (c == "") then break end
        if (c == '"') then
            -- quoted value (ignore separator within)
            local txt = ""
            repeat
                local startp,endp = string.find(line,'^%b""',pos)
                txt = txt..string.sub(line,startp+1,endp-1)
                pos = endp + 1
                c = string.sub(line,pos,pos)
                if (c == '"') then txt = txt..'"' end
                -- check first char AFTER quoted string, if it is another
                -- quoted string without separator, then append it
                -- this is the way to "escape" the quote char in a quote. example:
                --   value1,"blub""blip""boing",value3  will result in blub"blip"boing  for the middle
            until (c ~= '"')
            table.insert(res,txt)
            assert(c == sep or c == "")
            pos = pos + 1
        else
            -- no quotes used, just look for the first separator
            local startp,endp = string.find(line,sep,pos)
            if (startp) then
                table.insert(res,string.sub(line,pos,startp-1))
                pos = endp + 1
            else
                -- no separator found -> use rest of string and terminate
                table.insert(res,string.sub(line,pos))
                break
            end
        end
    end
    return res
end

local function select_kata(config)
    math.randomseed(os.time())
    return config[math.ceil(math.random() * table.maxn(config))]
end

local function basename(path)
  return path:sub(path:find("/[^/]*$") + 1)
end

local function select_language(kata_template_dir)
    local languages = list_directories(kata_template_dir)
    math.randomseed(os.time())
    local selected_language = math.ceil(math.random() * table.maxn(languages))
    return basename(languages[selected_language])
end

local function prepare_kata(kata)
    local kata_dir = os.date("%Y%m%d%H%M-" .. kata.name)
    kata_dir = vim.fn.join({os.getenv("HOME"), "src", "katas", kata_dir}, "/")
    kata_template_dir = vim.fn.join({os.getenv("HOME"), "src", "kata-templates", kata.name}, "/")
    os.execute("mkdir -p " .. kata_dir)
    vim.fn.execute('cd ' .. kata_dir)

    -- I decided to use the template README file so there would be a place for
    -- persistent notes.
    local readme_file = vim.fn.join({kata_template_dir, "README.md"}, "/")
    vim.fn.execute('e ' .. readme_file)
    local language = select_language(kata_template_dir)
    vim.fn.execute('%s#^Language: .*#Language: ' .. language .. "#")
    vim.fn.execute('w')

    local language_template = vim.fn.join({kata_template_dir, language}, "/")
    os.execute("cp -Rf " .. language_template .. "/* " .. kata_dir)
end

local function begin_kata()
    local config_file = vim.fn.join({os.getenv("HOME"), ".code-kata-problems"}, "/")
    local config = loadfile(config_file)()
    local kata = select_kata(config)
    prepare_kata(kata)
    set_kata_config("StartTime", os.date("%Y-%m-%d-%H:%M"))
end

local function end_kata()
    set_kata_config("EndTime", os.date("%Y-%m-%d-%H:%M"))
end

return {
    begin_kata = begin_kata,
    end_kata = end_kata,
}
