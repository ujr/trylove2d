-- Game of Fifteen, slightly modified from tutorial at
-- https://simplegametutorials.github.io/love/fifteen/


function love.load()
  love.graphics.setNewFont(30)

  gridXCount = 4
  gridYCount = 4

  function getInitialValue(x, y)
    return (y - 1) * gridXCount + x
  end

  function move(direction)
    local emptyX
    local emptyY

    for y = 1, gridYCount do
      for x = 1, gridXCount do
        if grid[y][x] == gridXCount * gridYCount then
          emptyX = x
          emptyY = y
        end
      end
    end

    local newEmptyX = emptyX
    local newEmptyY = emptyY

    if direction == 'down' then
      newEmptyY = emptyY - 1
    elseif direction == 'up' then
      newEmptyY = emptyY + 1
    elseif direction == 'right' then
      newEmptyX = emptyX - 1
    elseif direction == 'left' then
      newEmptyX = emptyX + 1
    end

    if grid[newEmptyY] and grid[newEmptyY][newEmptyX] then
      grid[newEmptyY][newEmptyX], grid[emptyY][emptyX] =
      grid[emptyY][emptyX], grid[newEmptyY][newEmptyX]
    end
  end

  function isComplete()
    for y = 1, gridYCount do
      for x = 1, gridXCount do
        if grid[y][x] ~= getInitialValue(x, y) then
          return false
        end
      end
    end
    return true
  end

  function reset()
    grid = {}

    for y = 1, gridYCount do
      grid[y] = {}
      for x = 1, gridXCount do
        grid[y][x] = getInitialValue(x, y)
      end
    end

    repeat
      -- Shuffle (issue random moves; just placing numbers
      -- at random might give an unsovable configuration):
      for moveNumber = 1, 1000 do
        local roll = love.math.random(4) -- result in 1..4
        if roll == 1 then move('down')
        elseif roll == 2 then move('up')
        elseif roll == 3 then move('right')
        elseif roll == 4 then move('left')
        end
      end
  
      -- Make sure the empty tile is at bottom right:
      for moveNumber = 1, gridXCount - 1 do
        move('left')
      end
      for moveNumber = 1, gridYCount - 1 do
        move('up')
      end
    until not isComplete()
  end

  reset()
end


function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'down' then
    move('down')
  elseif key == 'up' then
    move('up')
  elseif key == 'right' then
    move('right')
  elseif key == 'left' then
    move('left')
  end

  if isComplete() then
    reset()  -- start again
  end
end


function love.draw()
  local ww, wh = love.graphics.getDimensions()
  local margin = 50

  assert(gridXCount == gridYCount, "need square grid")
  local gridSize = math.max(gridXCount, gridYCount)
  local boardSize = math.min(ww, wh) - margin - margin

  local pieceSize = boardSize/gridSize
  local xOrg = 0.5 * (ww - boardSize)
  local yOrg = 0.5 * (wh - boardSize)

  for y = 1, 4 do
    for x = 1, 4 do
      -- there are are N=gridX*gridY pieces on the board;
      -- draw pieces 1..N-1, but piece N is the empty tile:
      if grid[y][x] ~= gridXCount * gridYCount then
        love.graphics.setColor(.4, .1, .6)
        love.graphics.rectangle('fill',
          xOrg + (x - 1) * pieceSize + 1,
          yOrg + (y - 1) * pieceSize + 1,
          pieceSize - 2, pieceSize - 2)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(grid[y][x],
          xOrg + (x - 1) * pieceSize + 0.1*pieceSize,
          yOrg + (y - 1) * pieceSize + 0.1*pieceSize)
      end
    end
  end
end
