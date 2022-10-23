Webhooks = {
    ["ticket"] = "",
    ["message"] = "",
    ["command"] = ""

}

local types = {
    ["ticket"] = function(params)
        return {
            webhook = GetWebhook("ticket"),
            text = ("#%s - %s: %s"):format(params.id, params.name, params.text),
        }
    end,
    ["message"] = function(params)
        return {
            webhook = GetWebhook("message"),
            text = ("%s"):format(params.text),
        }
    end,
    ["command"] = function(params)
        return {
            webhook = GetWebhook("command"),
            text = ("%s"):format(params.text),
        }
    end,
}

function GetWebhook(key)
    return Webhooks[key]
end

dclog = function(src, logType, params, target)
    local ts = os.time()
    local time = os.date('%Y-%m-%d %H:%M:%S', ts)
    if not types[logType] then return print(logType, "not found in types!") end
    local logData = types[logType](params)
    local embed = {
        ['username'] = 'GFX LOGS',
        ["title"] = logType,
        ['avatar_url'] = "https://cdn.discordapp.com/attachments/610776060744957953/1029899309665243187/3131.png",
        ['embeds'] = {
            {
                ["color"] = logData.color ~= nil and logData.color or 15548997,
                ["fields"] = {
                    {
                        ["name"] = '',
                        ["value"] = '',
                        ["inline"] = true
                    },
                },
                ["footer"] = {
                    ["text"] = 'GFX LOGS | '..time,
                },
            }
        }
    }

    local srcStr = ''
    local playerData = {}
    if src then
        if type(src) == "number" then
            playerData = getId(src)
    
            for k,v in pairs(playerData) do
                srcStr = srcStr .. "\n **"..k..":**"..v
            end
        else
            playerData = src
            for k,v in pairs(playerData) do
                if k ~= "nickname" then
                    srcStr = srcStr .. "\n **"..k..":**"..v
                end
            end
        end
    end
    embed["embeds"][1]["fields"][1].name = '**Source Info** ~ ' ..(playerData["nickname"] ~=nil and playerData["nickname"] or '')
    embed["embeds"][1]["fields"][1].value = srcStr

    local tStr = ''
    if target then
        if type(target) == "number" then
            local targetData = getId(target)
            for k,v in pairs(targetData) do
                if k ~= "nickname" then
                    tStr = tStr .. "\n **"..k..":**"..v
                end
            end
            table.insert(embed["embeds"][1]["fields"], {
                ["name"] = '**Target Info** ~ ' ..targetData["nickname"],
                ["value"] = tStr,
                ["inline"] = true
            })
        else
            for k,v in pairs(target) do
                if k ~= "nickname" then
                    tStr = tStr .. "\n **"..k..":**"..v
                end
            end
            table.insert(embed["embeds"][1]["fields"], {
                ["name"] = '**Target Info** ~ ' ..target["nickname"],
                ["value"] = tStr,
                ["inline"] = true
            })
        end
    end
    if logData.text then
        table.insert(embed["embeds"][1]["fields"], {
            ["name"] = '**Log Data**',
            ["value"] = logData.text,
            ["inline"] = true
        })
    end
    PerformHttpRequest(logData.webhook, function(err, text, headers) end, 'POST', json.encode(embed), { ['Content-Type'] = 'application/json' })
end

exports("dclog", dclog)

function getId(source)
    local identifier = {}
    local identifiers = {}
	identifiers = GetPlayerIdentifiers(source)
    for i = 1, #identifiers do
        if string.match(identifiers[i], "discord:") then
            identifier["discord"] = string.sub(identifiers[i], 9)
            identifier["discord"] = "<@"..identifier["discord"]..">"
        end
        if string.match(identifiers[i], "steam:") then
            identifier["steam"] = identifiers[i]
		end
        if string.match(identifiers[i], "license:") then
            identifier["license"] = identifiers[i]
		end
        if string.match(identifiers[i], "fivem:") then
            identifier["fivem"] = identifiers[i]
		end
        if string.match(identifiers[i], "ip:") then
            identifier["ip"] = identifiers[i]
		end
    end
    if identifier["discord"] == nil then
        identifier["discord"] = "Bilinmiyor"
    end
    identifier["name"] = GetPlayerName(source)
    return identifier
end
