function GenerateQuads(atlas, tilewidth, tileheight)
    local sheetWidth = atlas:getWidth() / tilewidth
    local sheetHeight = atlas:getHeight() / tileheight

    local sheetCounter = 1
    local spritesheet = {}

    for y = 0, sheetHeight - 1 do
        for x = 0, sheetWidth - 1 do
            spritesheet[sheetCounter] =
                love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth,
                tileheight, atlas:getDimensions())
            sheetCounter = sheetCounter + 1
        end
    end

    return spritesheet
end


function compileGameStats(self)
    -- compile whole game stats from level stats
    for l, levelStats in pairs(self.gameStats) do 
        for k, gameStat in pairs(levelStats) do
            self.gameStatTotals[k] = self.gameStatTotals[k] + gameStat
        end
    end
end

function renderGameStats(gameStats) 
    love.graphics.setFont(gFonts['small'])
    local keyNum = 1
    for k, item in pairs(gameStats) do 
        love.graphics.printf(tostring(k) .. ':  ' .. tostring(item), 0, VIRTUAL_HEIGHT / 4 + keyNum * 15, VIRTUAL_WIDTH, 'center')
        keyNum = keyNum + 1
    end
end