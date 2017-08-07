require "Switch"

Light = {}
Light.__index = Light

function Light.create(light, switch)
    local instance = {}
    setmetatable(instance, Light)

    instance.name = "light" .. light
    
    instance.light = light
    gpio.mode(instance.light, gpio.OUTPUT)
    
    instance.switch = switch
    gpio.mode(instance.switch, gpio.INT)
    
    instance.status = false

    instance.last_change_status = 0

    instance.switch_status = instance:read_switch_status()

    print(instance.name .. " created.")

    instance:off()
    
    return instance
end

function Light:toggle()
    print("toggle")
    if (self.status == true) then
        return self:off()
    elseif (self.status == false) then
        return self:on()
    end
end

function Light:can_chage()
    local can_change = (tmr.now() - self.last_change_status) > 50000
    if (can_change == false) then
        print("Can't change " .. self.name)
    end
    self.last_change_status = tmr.now()
    return can_change
end

function Light:on()
    if ((self:can_chage() == false) or (self.status == true)) then
        return self.status
    end

    print(self.name .. " on")
        
    gpio.write(self.light, gpio.LOW)
    self.status = true
end

function Light:off()
    if ((self:can_chage() == false) or (self.status == false)) then
        return self.status
    end

    print(self.name .. " off")
        
    gpio.write(self.light, gpio.HIGH)
    self.status = false
end

function Light:json()

    local buf = "{"
    
    buf = buf .. "\"name\": \""  .. self.name ..  "\","

    buf = buf .. "\"status\":"

    if (self.status == true) then
        buf = buf .. "true"
    elseif (self.status == false) then
        buf = buf .. "false"
    end

    return buf .. "}"
end

function Light:read_switch_status()
    return tonumber(gpio.read(self.switch))
end

function Light:monitor()
    Switch.create(self.switch, function()
        self:toggle()
    end):monitor()
end

function Light:command(cmd)
    if (cmd == "on") then
        self:on()
    elseif (cmd == "off") then
        self:off()
    elseif (cmd == "toggle") then
        self:toggle()
    end
end
