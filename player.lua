player = {}

function player.load()  
  slotImage = love.graphics.newImage("/Sprites/slot.png")
  pm = love.graphics.newImage("/Sprites/inventory/pm.png")
  hoe = love.graphics.newImage("/Sprites/inventory/hoe.png")
  weedwacker = love.graphics.newImage("/Sprites/inventory/weedwacker.png")
  barbedWireImage = love.graphics.newImage("/Sprites/inventory/barbedwire.png")
  
  plantSound = love.audio.newSource("/sounds/plant.wav", "static")
  useWhacker = love.audio.newSource("/sounds/useWacker.wav", "static")
  barbSound = love.audio.newSource("/sounds/barb.wav", "static")
  hoeSound = love.audio.newSource("/sounds/hoe.wav", "static")
  
  player.frames = {
    love.graphics.newImage("/Sprites/Player/idle.png"),
    love.graphics.newImage("/Sprites/Player/walk1.png")
  }
  player.frame = 1
  player.lastFrame = 1
  
  seedsImage = love.graphics.newImage("/Sprites/inventory/seeds.png")
  
  player.x = w/2
  player.y = h/2
  player.w = 32
  player.h = 32
  
  player.gx = player.x
  player.gy = player.y
  
  player.speed = 200
  player.facing = {x=0,y=1}
  player.lastFacing = 1
  
  player.pumpkins = 0
  
  player.selectedSquare =nil
  player.selectedSlot = 1
  
  player.inventory = {
    {name = "seeds",image = seedsImage,amount = 0},
    {name = "hoes",image = hoe,amount = 0},
    {name = "weedwackers",image = weedwacker,amount = 0},
    {name = "barbedwire",image = barbedWireImage,amount = 0}
  }
  
  world:add(player,player.x,player.y,player.w,player.h)
end

local function checkGrid()
  player.selectedSquare = nil
  for _,v in pairs(grid) do
    if (player.x+player.w/2 >= v.x and player.x+player.w/2  <= v.x+sx)  then
      if (player.y+player.h/2 >= v.y and player.y+player.h/2 <= v.y+sy)  then
        player.selectedSquare = v
        return
      end
    end
  end
end

local function movement(dt)
  if not shop.shopping then
    if love.keyboard.isDown("d") then
      player.facing.x = 1
      player.lastFacing = 1
    elseif love.keyboard.isDown("a") then
      player.facing.x = -1
      player.lastFacing = -1
    else
      player.facing.x = 0
    end
    
    if love.keyboard.isDown("s") then
      player.facing.y = 1
    elseif love.keyboard.isDown("w") then
      player.facing.y = -1
    else
      player.facing.y = 0
    end
    
    if player.facing.x ~= 0 or player.facing.y ~= 0 then
      if player.lastFrame < timer then
        player.frame = player.frame +1
        if player.frame == 3 then
          player.frame = 1
        end
        player.lastFrame = timer+.3
      end
    else
      player.frame = 1
    end
  else
    player.facing = {x=0,y=0}
  end
  
  local nx,ny = math.normalize(player.facing.x,player.facing.y)
  player.gx,player.gy = player.x+(nx*player.speed*dt),player.y+(ny*player.speed*dt)
  
  local ax,ay,cols,len = world:move(player,player.gx,player.gy)
  
  player.x = ax
  player.y = ay
  
  if player.x <= -20 then
    player.x = -20
  elseif player.x >= w-20 then
    player.x = w-20
  end
  
  if player.y <= 0 then
    player.y = 0
  elseif player.y >= h-20 then
    player.y = h-20
  end
end

function player.update(dt)
  movement(dt)
  checkGrid()
end

seedChance = {1,2,2,2,2,2}

local function dropSeed()
  local s = seedChance[math.random(1,#seedChance)]
  return s
end

local function checkWeed()
  for _,v in pairs(weeds) do
    local d = math.sqrt(((player.x+player.w/2)-(v.x+v.w/2))^2+((player.y+player.h/2)-(v.y+v.h/2))^2)
    
    if d <= 50 then
      return v
    end
  end
end

function love.keypressed(key)
  if key == "e" then
    local c = checkWeed()
    if player.selectedSlot == 3 and player.inventory[3].amount ~= 0 and c then
      c.hp = c.hp - 50
      player.inventory[3].amount = player.inventory[3].amount -1
      useWhacker:play()
    elseif player.selectedSlot == 4 and player.inventory[4].amount ~= 0 then
      wire.new(player.x,player.y)
      player.inventory[4].amount = player.inventory[4].amount -1
      barbSound:play()
    elseif player.selectedSquare then
      if player.selectedSquare.open then
        if player.selectedSlot == 1 then
          if player.selectedSquare.tilled and player.inventory[1].amount ~= 0 then
            player.selectedSquare.p = pumpkin.new(player.selectedSquare.x,player.selectedSquare.y,player.selectedSquare)
            player.selectedSquare.open = false
            player.inventory[1].amount = player.inventory[1].amount - 1
            plantSound:play()
          end
        elseif player.selectedSlot == 2 then
          if not player.selectedSquare.tilled and player.inventory[2].amount ~= 0 then
            player.selectedSquare.tilled = true
            player.inventory[2].amount = player.inventory[2].amount - 1
            hoeSound:play()
          end
        end
      elseif player.selectedSquare.p and player.selectedSquare.p.level == 2 then
        player.pumpkins = player.pumpkins +1
        player.inventory[1].amount = player.inventory[1].amount + dropSeed()
        player.selectedSquare.p.hp = 0
        player.selectedSquare.open = true
        player.selectedSquare.p = nil
        unplantSound:play()
      end
    else
      local inrange = shop.check()
      
      if inrange then
        shop.shopping = true
      end
    end
  elseif key == "escape" and not gameover then
    paused = not paused
    if not paused and tutorial then tutorial = false end
  elseif key == "1" or key == "2" or key == "3" or key == "4" or key == "5" then
    local k = tonumber(key)
    player.selectedSlot = k
  end
end


local function renderInventory()
  love.graphics.setColor(0.3,.3,.3)
  love.graphics.rectangle("fill",w-48,0,50,h)
  love.graphics.setColor(1,1,1)
  for i = 1,5 do
    love.graphics.draw(slotImage,w-48,(48*i-1),0,3,3)
    if player.inventory[i] and player.inventory[i].amount > 0 then
      love.graphics.draw(player.inventory[i].image,w-48,(48*i-1),0,3,3)
      if player.inventory[i].amount > 1 then
        love.graphics.print(player.inventory[i].amount,w-48,(48*i-1))
      end
    end
  end
  
  love.graphics.rectangle("line",w-48,(48*player.selectedSlot-1),48,48)
  
  love.graphics.draw(pm,w-45,350,0,3,3)
  love.graphics.printf("x "..player.pumpkins,w-35,355,50)
end

function player.draw()
  if player.selectedSquare then
    love.graphics.rectangle("line",player.selectedSquare.x,player.selectedSquare.y,sx,sy)
  end
  
  --love.graphics.rectangle("fill",player.x,player.y,player.w,player.h)
  local off = 0
  if player.lastFacing == -1 then
    off = 48
  end
  
  love.graphics.draw(player.frames[player.frame],player.x,player.y,0,player.lastFacing,1,off)

  if dayTime then
    love.graphics.setFont(timeFont)
    love.graphics.print("Day time left: "..math.ceil(dayTimer),w-250)
  else
    love.graphics.setFont(timeFont)
    love.graphics.print("Night time left: "..math.ceil(dayTimer),w-250)
    love.graphics.setColor(0,0,0)
    love.graphics.draw(nightOverlay,0,0,0,10,10)
    love.graphics.setColor(1,1,1)
  end
  love.graphics.print("Day: "..day,w-250,25)
  love.graphics.setFont(mainFont)

  renderInventory()
end