ASSETS_PATH = 'assets/'

local screenWidth = 900
local screenHeight = 720

local cards = {}
local cardWidth = 150
local cardHeight = 150
local columns = 5
local rows = 4
local xStart = 35
local yStart = 40
local xOffset = 20
local yOffset = 20
local numberOfCards = columns*rows

local background = nil
local colors = {
    black = { 0, 0, 0 },
    red = { 1, 0, 0 },
    green = { 0, 1, 0 },
    blue = { 0, 0, 1 },
    cyan = { 0, 1, 1 },
    magenta = { 1, 0, 1 },
    yellow = { 1, 1, 0 },
    pink = { 1, 0.75, 0.8 },
    saladgreen = { 0.13, 0.46, 0.33 },
    maroon = { 0.5, 0, 0 }
}
local parrots = { n = 11 }
local cats = { n = 10 }
local frogs = { n = 10 }

local cardBackColor = { 0.7, 0.7, 0.7 }
local cardBack = nil
local cardBackQuad = nil
-- local cardColor = { 0.7, 0, 0.4 }
-- local quad = nil

local score = 0
local clicks = 0
local firstShownCard = nil
local secondShownCard = nil
local clickToContinue = false

local mode = false
local buttons = {}
local buttonWidth = 200
local buttonHeight = 100
local buttonX = screenWidth / 2 - buttonWidth / 2
local buttonY = 200

local buttonsKeywords = {
    parrots = 'parrots',
    cats = 'cats',
    frogs = 'frogs'
}


local isWin = false
local winButtonWidth = 600
local winButtonHeight = 180
local winButtonX = screenWidth / 2 - winButtonWidth / 2
local winButtonY = 300
local winMessage = 'You\'re the best!\nClick to continue'

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function table.copy(original)
    local newTable = {}
    for k,v in pairs(original) do
        -- newTable[k] = v
        table.insert(newTable, v)
    end
    return newTable
end

local function generateCardsPairTable(totalNumberOfCards, picturesTable)
    local pairsOfCards = {}
    -- local colorsTmp = table.copy(colors)
    local tempTable = table.copy(picturesTable)
    for i = 1, totalNumberOfCards/2 do
        -- local color = table.remove(colorsTmp, math.random(#colorsTmp))
        local color = table.remove(tempTable, math.random(#tempTable))
        print(color)
        table.insert(pairsOfCards, color)
        table.insert(pairsOfCards, color)

        -- if #colorsTmp == 0 and i < totalNumberOfCards/2 then
        if #tempTable == 0 and i < totalNumberOfCards/2 then
            print('not enough pictures!')
            return pairsOfCards
        end
    end
    
    print('number of colors in pairsOfCards = ' .. #pairsOfCards)
    return pairsOfCards
end

local function generateModeChooseButtons()
    local y = buttonY
    for k, v in pairs(buttonsKeywords) do
        local button = {
            y = y,
            keyword = v
        }
        buttons[k] = button
        y = y + buttonHeight + 20
    end
end

local function loadPictures(keyword, n)
    local newTable = {}
    for i = 1, n do
        local img = love.graphics.newImage(ASSETS_PATH..keyword..'_'..i..'.jpg')
        table.insert(newTable, img)
    end
    return newTable
end

local function startGame(gamemode)
    if #cards > 0 then
        for k, v in ipairs(cards) do
            table.remove(cards, k)
        end
    end
    local pairs
    if gamemode == 'parrots' then
        pairs = generateCardsPairTable(numberOfCards, parrots)
    elseif gamemode == 'cats' then
        pairs = generateCardsPairTable(numberOfCards, cats)
    elseif gamemode == 'frogs' then
        pairs = generateCardsPairTable(numberOfCards, frogs)
    end

    local y = yStart
    for i = 1, rows do
        local x = xStart
        for j = 1, columns do
            -- local color = table.remove(pairs, math.random(#pairs))
            local image = table.remove(pairs, math.random(#pairs))
            local quad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
            local card = {
                x = x,
                y = y,
                width = cardWidth,
                height = cardHeight,
                shown = false,
                image = image,
                quad = quad
            }
            table.insert(cards, card)

            x = x + cardWidth + xOffset
        end
        y = y + cardHeight + yOffset
    end
end

function love.load()
    math.randomseed( os.time() )
    math.random(); math.random(); math.random()

    love.window.setMode(900, 720)
    love.window.setTitle('Love Parrots')
    love.graphics.setBackgroundColor(1, 1, 1)

    background = love.graphics.newImage(ASSETS_PATH..'background.jpg')
    cardBack = love.graphics.newImage(ASSETS_PATH..'cardback.jpg')
    cardBackQuad = love.graphics.newQuad(0, 0, cardWidth, cardHeight, cardWidth, cardHeight)
    parrots = loadPictures('parrot', parrots.n)
    cats = loadPictures('cat', cats.n)
    frogs = loadPictures('frog', frogs.n)
    generateModeChooseButtons()
end

local function drawRectangle(x, y, width, height, color, alpha)
    love.graphics.setColor(color[1], color[2], color[3], alpha or 0.6)
    love.graphics.rectangle('fill', x, y, width, height, 20, 20)
    love.graphics.setColor(color)
    love.graphics.rectangle('line', x, y, width, height, 20, 20)
end

local function drawCard(x, y, image, quad)
    love.graphics.draw(image, quad, x, y)
end

local function isPointInside(x1, y1, x2, y2, width, height)
    return (x1 >= x2)
       and (y1 >= y2)
       and (x1 <= x2 + width)
       and (y1 <= y2 + height)
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(background, 0, 0, 0, 1.5)
    
    local mx, my = love.mouse.getPosition()
    if not mode then
        for k, v in pairs(buttons) do
            if isPointInside(mx, my, buttonX, v.y, buttonWidth, buttonHeight) then
                drawRectangle(buttonX, v.y, buttonWidth, buttonHeight, colors.pink, 1)
            else
                drawRectangle(buttonX, v.y, buttonWidth, buttonHeight, colors.pink, 0.6)
            end

            love.graphics.setColor(colors.black)
            love.graphics.print(v.keyword, buttonX+15, v.y+15, 0, 3, 3)
        end

    else
        love.graphics.setColor(0, 0, 0)
        love.graphics.print('Score:\t'..score..'\tClicks:\t'..clicks, 0, 0, 0, 2, 2)
        for k, v in ipairs(cards) do
            love.graphics.setColor(1, 1, 1)
            if not v.shown then
                drawCard(v.x, v.y, cardBack, cardBackQuad)
                if isPointInside(mx, my, v.x, v.y, cardWidth, cardHeight) then
                    love.graphics.setColor(colors.pink)
                    love.graphics.rectangle('line', v.x, v.y, cardWidth, cardHeight)
                end
            else
                drawCard(v.x, v.y, v.image, v.quad)
            end
        end
        if isWin then
            drawRectangle(winButtonX, winButtonY, winButtonWidth, winButtonHeight, colors.pink, 0.75)
            love.graphics.setColor(colors.black)
            love.graphics.print(winMessage, winButtonX+15, winButtonY+15, 0, 3, 3)
        end
    end
end

local function hideCurrentShownCards()
    cards[firstShownCard].shown = false
    cards[secondShownCard].shown = false
    firstShownCard = nil
    secondShownCard = nil
end

local function checkForWin()
    local win = true
    for k, v in ipairs(cards) do
        if not v.shown then win = false end
    end
    return win
end

local function processCardReveal(cardNumber)
    local card = cards[cardNumber]
    local currentShownCard = cards[firstShownCard]
    if card.shown then
        return
    end
    if currentShownCard == nil then
        card.shown = true
        firstShownCard = cardNumber
    else
        card.shown = true
        secondShownCard = cardNumber
        -- if card.color == currentShownCard.color then
        if card.image == currentShownCard.image then
            score = score + 1
            firstShownCard = nil
            secondShownCard = nil

            if checkForWin() then
                isWin = true
            end
        else
            clickToContinue = true
        end
    end
    clicks = clicks + 1
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if not mode then
            for k, v in pairs(buttons) do
                if isPointInside(x, y, buttonX, v.y, buttonWidth, buttonHeight) then
                    mode = true
                    startGame(v.keyword)
                end
            end
        elseif isWin then
            mode = false
            isWin = false
        else
            if clickToContinue then
                clickToContinue = false
                hideCurrentShownCards()
            else
                for k, v in ipairs(cards) do
                    if isPointInside(x, y, v.x, v.y, cardWidth, cardHeight) then
                        processCardReveal(k)
                    end
                end
            end
        end
    end
end