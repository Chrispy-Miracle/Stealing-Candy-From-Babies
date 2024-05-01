Player = Class{__includes = Entity}

function Player:init(def)
    Entity.init(self, def)

    -- health (or sugar buzz)
    self.health = def.entity_def.startingHealth
    self.maxHealth = def.entity_def.maxHealth

    -- constantly crashing from sugar buzz!
    if self.type == 'player' then
        Timer.every(1, function () self.health = self.health - 1 end)
    end

    self.balloonsCarried = 0
    self.gravity = 0
    self.isFloating = false
    self.isFalling = false

end

function Player:update(dt)
    Entity.update(self, dt)
end

function Player:render()
    Entity.render(self)
end