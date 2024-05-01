Baby = Class{__includes = Entity}

function Baby:init(def)
    Entity.init(self, def)
end

function Baby:update(dt)
    Entity.update(self, dt)
end

function Baby:render()
    Entity.render(self)
end