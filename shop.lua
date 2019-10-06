shop = {}

function shop.load()
  shop_sprite = love.graphics.newImage("Sprites/shop.png")
  rainSprite = love.graphics.newImage("Sprites/rain.png")
  
  shopSound = love.audio.newSource("sounds/shop.wav", "static")
  
  rainSpriteRepeated = rainSprite
  rainSpriteRepeated:setWrap("repeat", "repeat")
  rain_quad = love.graphics.newQuad(-w, -h*3, w*5, h*5, rainSpriteRepeated:getWidth()*3, rainSpriteRepeated:getHeight()*3) 
  
  shop.x = (w/2)-(48*6)
  shop.y = 10
  shop.w = 48*3
  shop.h = 48*2
  
  shop.shopping = false
  
  quitButton = {}
  quitButton.x = w-200
  quitButton.y = h-100
  quitButton.w = 150
  quitButton.h = 50
  
  hoeButton = {}
  hoeButton.x = 60
  hoeButton.y = 130
  hoeButton.w = 200
  hoeButton.h = 50
  
  wackerButton = {}
  wackerButton.x = 60
  wackerButton.y = 200
  wackerButton.w = 200
  wackerButton.h = 50
  
  wireButton = {}
  wireButton.x = 60
  wireButton.y = 270
  wireButton.w = 200
  wireButton.h = 50
  
  workerButton = {}
  workerButton.x = 60
  workerButton.y = 340
  workerButton.w = 200
  workerButton.h = 50
  
  rainButton = {}
  rainButton.x = 60
  rainButton.y = 410
  rainButton.w = 200
  rainButton.h = 50
  
  world:add(shop,shop.x,shop.y,shop.w,shop.h)
end

function shop.check()
  if (player.x+player.w/2 >= shop.x and player.x+player.w/2 <= shop.x+shop.w)  then
    return true
  end
  return false
end

function shop.draw()
  love.graphics.draw(shop_sprite,shop.x,0,0,3,3)
end

local function checkQuitButton(x,y)
  if (x >= quitButton.x and x <= quitButton.x+quitButton.w) and (y >= quitButton.y and y <= quitButton.y+quitButton.h) then
    return true
  end
end

local function checkHoeButton(x,y)
  if (x >= hoeButton.x and x <= hoeButton.x+hoeButton.w) and (y >= hoeButton.y and y <= hoeButton.y+hoeButton.h) then
    return true
  end
end

local function checkWackerButton(x,y)
  if (x >= wackerButton.x and x <= wackerButton.x+wackerButton.w) and (y >= wackerButton.y and y <= wackerButton.y+wackerButton.h) then
    return true
  end
end

local function checkWireButton(x,y)
  if (x >= wireButton.x and x <= wireButton.x+wireButton.w) and (y >= wireButton.y and y <= wireButton.y+wireButton.h) then
    return true
  end
end

local function checkWorkerButton(x,y)
  if (x >= workerButton.x and x <= workerButton.x+workerButton.w) and (y >= workerButton.y and y <= workerButton.y+workerButton.h) then
    return true
  end
end

local function checkRainButton(x,y)
  if (x >= rainButton.x and x <= rainButton.x+rainButton.w) and (y >= rainButton.y and y <= rainButton.y+rainButton.h) then
    return true
  end
end

function shop.clicked(x,y)
  local qb = checkQuitButton(x,y)
  
  if qb then
    shop.shopping = false
    return
  end
  
  local h = checkHoeButton(x,y)
  
  if h then
    if player.pumpkins >= 20 then
      player.pumpkins = player.pumpkins - 20
      player.inventory[2].amount = player.inventory[2].amount + 3
      shopSound:play()
    end
    return
  end
  
  local w = checkWackerButton(x,y)
  
  if w then
    if player.pumpkins >= 2 then
      player.pumpkins = player.pumpkins - 2
      player.inventory[3].amount = player.inventory[3].amount + 5
      shopSound:play()
    end
    return
  end
  
  local ww = checkWireButton(x,y)
  
  if ww then
    if player.pumpkins >= 10 then
      player.pumpkins = player.pumpkins - 10
      player.inventory[4].amount = player.inventory[4].amount + 3
      shopSound:play()
    end
    return
  end
  
  local s = checkWorkerButton(x,y)
  
  if s then
    if player.pumpkins >= 25 then
      player.pumpkins = player.pumpkins - 25
      worker.new(50,300)
      shopSound:play()
    end
    return
  end
  
  local r = checkRainButton(x,y)
  
  if r then
    if player.pumpkins >= 100 then
      player.pumpkins = player.pumpkins - 100
      for _,v in pairs(plantedPumpkin) do
        v.level = 2
      end
      timeRaining = 0
      raining = true
      shopSound:play()
    end
    return
  end
end

function shop.drawUI()
  love.graphics.push()
  love.graphics.setColor(.3,.3,.3)
  love.graphics.rectangle("fill",50,50,w-100,h-100)
  love.graphics.setColor(0,0,0)
  love.graphics.rectangle("line",50,50,w-100,h-100)
  
  love.graphics.setColor(1,1,0)
  love.graphics.setFont(medFont)
  love.graphics.printf("Shop",60,60,120)
  
  -- quit button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",quitButton.x,quitButton.y,quitButton.w,quitButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Leave",quitButton.x+10,quitButton.y,quitButton.w)
  
  -- hoe button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",hoeButton.x,hoeButton.y,hoeButton.w,hoeButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Hoe",hoeButton.x,hoeButton.y,hoeButton.w,"center")
  love.graphics.draw(hoe,hoeButton.x+1,hoeButton.y+1,0,3,3)
  love.graphics.setFont(mainFont)
  love.graphics.draw(pm,hoeButton.x+hoeButton.w-45,hoeButton.y+30,0,3,3,0,3)
  love.graphics.print("20",hoeButton.x+hoeButton.w-30,hoeButton.y+25)
  
  -- weedwacker button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",wackerButton.x,wackerButton.y,wackerButton.w,wackerButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Weed whacker",wackerButton.x,wackerButton.y+20,wackerButton.w,"center")
  love.graphics.draw(weedwacker,wackerButton.x+1,wackerButton.y+1,0,3,3)
  love.graphics.setFont(mainFont)
  love.graphics.draw(pm,wackerButton.x+wackerButton.w-45,wackerButton.y+30,0,3,3,0,3)
  love.graphics.print("2",wackerButton.x+wackerButton.w-30,wackerButton.y+25)
  
  -- wire button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",wireButton.x,wireButton.y,wireButton.w,wireButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Barbwire",wireButton.x,wireButton.y+20,wireButton.w,"center")
  love.graphics.draw(barbedWireImage,wireButton.x+1,wireButton.y+1,0,3,3)
  love.graphics.setFont(mainFont)
  love.graphics.draw(pm,wireButton.x+wireButton.w-45,wireButton.y+30,0,3,3,0,3)
  love.graphics.print("10",wireButton.x+wireButton.w-30,wireButton.y+25)
  
  -- worker button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",workerButton.x,workerButton.y,workerButton.w,workerButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Worker",workerButton.x,workerButton.y+20,workerButton.w,"center")
  love.graphics.draw(workerSprite,workerButton.x+1,workerButton.y+1,0,1,1)
  love.graphics.setFont(mainFont)
  love.graphics.draw(pm,workerButton.x+workerButton.w-45,workerButton.y+30,0,3,3,0,3)
  love.graphics.print("25",workerButton.x+workerButton.w-30,workerButton.y+25)
  
  -- worker button
  love.graphics.setColor(.4,.4,.4)
  love.graphics.rectangle("fill",rainButton.x,rainButton.y,rainButton.w,rainButton.h)
  love.graphics.setColor(1,1,1)
  love.graphics.printf("Rain",rainButton.x,rainButton.y+20,rainButton.w,"center")
  love.graphics.draw(rainSprite,rainButton.x+1,rainButton.y+1,0,3,3)
  love.graphics.setFont(mainFont)
  love.graphics.draw(pm,rainButton.x+rainButton.w-45,rainButton.y+30,0,3,3,0,3)
  love.graphics.print("100",rainButton.x+rainButton.w-30,rainButton.y+25)
  
  -- pumpkin display
    love.graphics.setFont(mainFont)
    love.graphics.draw(pm,200,60,0,10,10)
    love.graphics.printf(" x "..player.pumpkins,230,90,100)
  
  love.graphics.pop()
end
