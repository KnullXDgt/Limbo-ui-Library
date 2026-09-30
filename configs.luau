local ConfigSystem = {
    CurrentConfig = nil,
    Configs = {},
    
    Save = function(self, name, data)
        self.Configs[name] = {
            Name = name,
            Theme = data.Theme or "Default",
            Elements = data.Elements or {}
        }
        self.CurrentConfig = name
        return true
    end,
    
    Load = function(self, name)
        return self.Configs[name]
    end,
    
    Delete = function(self, name)
        self.Configs[name] = nil
        if self.CurrentConfig == name then
            self.CurrentConfig = nil
        end
        return true
    end,
    
    List = function(self)
        local list = {}
        for name, _ in pairs(self.Configs) do
            table.insert(list, name)
        end
        return list
    end
}

return ConfigSystem
