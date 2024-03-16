-- Black Jack, slightly modified from the tutorial at
-- https://simplegametutorials.github.io/love/blackjack/


function love.load()
  love.graphics.setBackgroundColor(.9, .9, .9)

  images = {}
  for nameIndex,  name in ipairs {
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13,
    'pip_heart', 'pip_diamond', 'pip_club', 'pip_spade',
    'mini_heart', 'mini_diamond', 'mini_club', 'mini_spade',
    'card', 'card_face_down',
    'face_jack', 'face_queen', 'face_king'
  } do
    images[name] = love.graphics.newImage('images/' .. name .. '.png')
  end

  function takeCard(hand)
    table.insert(hand, table.remove(deck, love.math.random(#deck)))
  end

  function getTotal(hand)
    local total = 0
    local hasAce = false
    for cardIndex, card in ipairs(hand) do
      if card.rank > 10 then -- face card: counts 10
        total = total + 10
      else
        total = total + card.rank
      end
      if card.rank == 1 then
        hasAce = true
      end
    end
    -- ace counts 11 unless value of hand would go over 21:
    if hasAce and total <= 11 then
      total = total + 10
    end
    return total
  end

  local buttonY = 230
  local buttonHeight = 25
  local textOffsetY = 6

  buttonHit = {
    text = 'Hit!',
    x = 10, y = buttonY,
    width = 53,
    height = buttonHeight,
    textOffsetX = 16,
    textOffsetY = textOffsetY
  }

  buttonStand = {
    text = 'Stand',
    x = 70, y = buttonY,
    width = 53,
    height = buttonHeight,
    textOffsetX = 8,
    textOffsetY = textOffsetY
  }

  buttonPlayAgain = {
    text = 'Play again',
    x = 10, y = buttonY,
    width = 113,
    height = buttonHeight,
    textOffsetX = 24,
    textOffsetY = textOffsetY
  }

  function isMouseInButton(button)
    local mx, my = love.mouse.getPosition()
    return mx >= button.x and mx < button.x + button.width and
           my >= button.y and my < button.y + button.height
  end

  function reset()
    deck = {}
    for suitIndex, suit in ipairs {'club', 'diamond', 'heart', 'spade'} do
      for rank = 1, 13 do
        table.insert(deck, {suit = suit, rank = rank})
      end
    end

    playerHand = {}
    takeCard(playerHand)
    takeCard(playerHand)

    dealerHand = {}
    takeCard(dealerHand)
    takeCard(dealerHand)

    roundOver = false
  end

  reset()
end


function love.draw()

  local cardSpacing = 60
  local marginX = 10

  local function hasHandWon(thisHand, otherHand)
    local thisTotal = getTotal(thisHand)
    local otherTotal = getTotal(otherHand)
    return thisTotal <= 21 and (otherTotal > 21 or thisTotal > otherTotal)
  end

  local function drawWinner(message)
    local x = buttonPlayAgain.x + buttonPlayAgain.width + 10
    local y = buttonPlayAgain.y + buttonPlayAgain.textOffsetY
    love.graphics.setColor(0, 0, 0)
    love.graphics.print(message, x, y)
  end

  local function drawCard(card, x, y)
    local cardWidth, cardHeight = 53, 73
    local numberOffsetX, numberOffsetY = 3, 4
    local suitOffsetX, suitOffsetY = 3, 14
    local suitImage = images['mini_' .. card.suit]

    love.graphics.setColor(1, 1, 1) -- white
    love.graphics.draw(images.card, x, y)

    if card.suit == 'heart' or card.suit == 'diamond' then
      love.graphics.setColor(.89, .06, .39) -- reddish
    else
      love.graphics.setColor(.2, .2, .2) -- dark gray
    end

    local function drawCorner(image, offsetX, offsetY)
      love.graphics.draw(image,
        x + offsetX,
        y + offsetY)
      love.graphics.draw(image,
        x + cardWidth - offsetX,
        y + cardHeight - offsetY,
        0, -1) -- rotation, sx (sy defaults to sx)
    end

    drawCorner(images[card.rank], 3, 4)
    drawCorner(images['mini_' .. card.suit], 3, 14)

    if card.rank > 10 then
      local faceImage
      if card.rank == 11 then
        faceImage = images.face_jack
      elseif card.rank == 12 then
        faceImage = images.face_queen
      elseif card.rank == 13 then
        faceImage = images.face_king
      end

      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(faceImage, x + 12, y + 11)
    else
      local function drawPip(offsetX, offsetY, mirrorX, mirrorY)
        local pipImage = images['pip_' .. card.suit]
        local pipWidth = 11
        love.graphics.draw(pipImage, x + offsetX, y + offsetY)
        if mirrorX then
          love.graphics.draw(pipImage,
            x + cardWidth - offsetX - pipWidth,
            y + offsetY)
        end
        if mirrorY then
          love.graphics.draw(pipImage,
            x + offsetX + pipWidth,
            y + cardHeight - offsetY,
            0, -1)
        end
        if mirrorX and mirrorY then
          love.graphics.draw(pipImage,
            x + cardWidth - offsetX,
            y + cardHeight - offsetY,
            0, -1)
        end
      end
      local xLeft, xMid = 11, 21
      local yTop, yThird, yQtr, yMid = 7, 19, 23, 31

      if card.rank == 1 then -- ace
        drawPip(xMid, yMid)
      elseif card.rank == 2 then
        drawPip(xMid, yTop, false, true)
      elseif card.rank == 3 then
        drawPip(xMid, yTop, false, true)
        drawPip(xMid, yMid)
      elseif card.rank == 4 then
        drawPip(xLeft, yTop, true, true)
      elseif card.rank == 5 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xMid, yMid)
      elseif card.rank == 6 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xLeft, yMid, true)
      elseif card.rank == 7 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xLeft, yMid, true)
        drawPip(xMid, yThird)
      elseif card.rank == 8 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xLeft, yMid, true)
        drawPip(xMid, yThird)
      elseif card.rank == 9 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xLeft, yQtr, true, true)
        drawPip(xMid, yMid)
      elseif card.rank == 10 then
        drawPip(xLeft, yTop, true, true)
        drawPip(xLeft, yQtr, true, true)
        drawPip(xMid, 16, false, true)
      end
    end
  end

  local function drawButton(button)
    if isMouseInButton(button) then
      love.graphics.setColor(1, .8, .3)
    else
      love.graphics.setColor(1, .5, .2)
    end
    love.graphics.rectangle('fill', button.x, button.y, button.width, button.height)
    love.graphics.setColor(1, 1, 1)
    love.graphics.print(button.text, button.x + button.textOffsetX, button.y + button.textOffsetY)
  end

  -- Dealer's hand:
  for cardIndex, card in ipairs(dealerHand) do
    local dealerMarginY = 30
    if cardIndex == 1 and not roundOver then
      love.graphics.setColor(1, 1, 1)
      love.graphics.draw(images.card_face_down, marginX, dealerMarginY)
    else
      drawCard(card, (cardIndex - 1) * cardSpacing + marginX, dealerMarginY)
    end
  end

  -- Player's hand:
  for cardIndex, card in ipairs(playerHand) do
    drawCard(card, (cardIndex - 1) * cardSpacing + marginX, 140)
  end

  -- Annotation:
  love.graphics.setColor(0, 0, 0)
  if roundOver then
    love.graphics.print('Total: ' .. getTotal(dealerHand), marginX, 10)
  else
    love.graphics.print('Total: ?', marginX, 10)
  end
  love.graphics.print('Total: ' .. getTotal(playerHand), marginX, 120)

  if roundOver then
    if hasHandWon(playerHand, dealerHand) then
      drawWinner('Player wins')
    elseif hasHandWon(dealerHand, playerHand) then
      drawWinner('Dealer wins')
    else
      drawWinner('Draw')
    end
  end

  -- Controls (buttons):
  if not roundOver then
    drawButton(buttonHit)
    drawButton(buttonStand)
  else
    drawButton(buttonPlayAgain)
  end
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end

  if not roundOver then
    if key == 'h' then -- player hits
      takeCard(playerHand)
      if getTotal(playerHand) >= 21 then
        roundOver = true
      end
    elseif key == 's' then -- player stands
      roundOver = true
    end

    -- If player has stood, gone bust, or 21: the dealer
    -- now takes cards while their total is less than 17:
    if roundOver then
      while getTotal(dealerHand) < 17 do
        takeCard(dealerHand)
      end
    end
  else
    reset()
  end
end


function love.mousereleased()
  if not roundOver then
    if isMouseInButton(buttonHit) then
      takeCard(playerHand)
      if getTotal(playerHand) >= 21 then
        roundOver = true
      end
    elseif isMouseInButton(buttonStand) then
      roundOver = true
    end

    if roundOver then
      while getTotal(dealerHand) < 17 do
        takeCard(dealerHand)
      end
    end
  elseif isMouseInButton(buttonPlayAgain) then
    reset()
  end
end
