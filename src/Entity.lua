Entity = Class{}

function Entity:init(def)
    self.type = def.entity_def.type

    self.animations = self:createAnimations(def.entity_def.animations)

    self.x = def.x
    self.y = def.y

    self.height = def.entity_def.height
    self.width = def.entity_def.width 

    self.walkSpeed = def.entity_def.walkSpeed

end

function Entity:createAnimations(animations)
    local animationsReturned = {}

    for k, animationDef in pairs(animations) do
        animationsReturned[k] = Animation {
            texture = animationDef.texture,
            frames = animationDef.frames,
            interval = animationDef.interval
        }
    end

    return animationsReturned
end

function Entity:changeAnimation(name)
    self.currentAnimation = self.animations[name]
end


function Entity:update(dt)

    if self.currentAnimation then
        self.currentAnimation:update(dt)
    end
end

function Entity:render()
    local anim = self.currentAnimation
    love.graphics.draw(gTextures[anim.texture], 
        gFrames[anim.texture][anim:getCurrentFrame()], self.x, self.y)
end
