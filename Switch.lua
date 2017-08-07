
Switch = {}
Switch.__index = Switch

function Switch.create(port, onchange)
    local instance = {}
    setmetatable(instance, Switch)
    gpio.mode(port, gpio.INT)
    instance.port = port
    instance.interval = 120
    instance.checking = false
    instance.onchange = onchange
    instance.current = gpio.read(port)
    return instance
end

function Switch:double_check()
    if (self.checking) then
        return
    end
    self.checking = true
    tmr.alarm(self.port, self.interval, function()
        local after = gpio.read(self.port)
        if (self.current ~= after) then
            self.onchange(after)
            self.current = after
        end
        self.checking = false
    end)
end

function Switch:monitor()
    gpio.trig(self.port, "both", function()
        self:double_check()
    end)
end
