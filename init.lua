require "Light"

-- Light
light = Light.create(0, 1)
light:monitor()

light2 = Light.create(2, 3)
light2:monitor()

-- Wifi
wifi.setmode(wifi.STATION)
wifi.sta.config("USER", "PASS")
wifi.sta.connect()
wifi.sta.autoconnect(1)

-- Server
srv = net.createServer(net.TCP)
srv:listen(8081, function(conn)

    print("new connection")

    function json(_GET)
        
        light:command(_GET.light0)
        
        light2:command(_GET.light2)
    
        local buf = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"lights\": ["
        buf = buf .. light:json() .. ","
        buf = buf .. light2:json()
        return buf .. "]}"
    end
    
    conn:on("receive", function(client,request)
        
        local _, _, method, path, vars = string.find(request, "([A-Z]+) (.+)?(.+) HTTP");
        
        if (method == nil) then
            _, _, method, path = string.find(request, "([A-Z]+) (.+) HTTP");
        end
        
        local _GET = {}

        local response
        
        if (vars ~= nil) then
            for k, v in string.gmatch(vars, "(%w+)=(%w+)&*") do
                _GET[k] = v
            end
        end

        response = json(_GET)

        client:send(response)
        client:close();
        collectgarbage();
    end)
end)
