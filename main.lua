bump = require"bump"
require"player"
require"shop"
pumpkin = require"pumpkin"
weed = require"weeds"
delay = require"delay"
wire = require"barbedwire"
worker = require"worker"

love.graphics.setDefaultFilter("nearest", "nearest")
love.graphics.setLineStyle("rough")

paused = true
tutorial = false

timer = 0

gameover = false

local function reload()
  day = 1
  dayTimer = 60
  dayTime = true

  weedsToSpawn = 1
  weedsSpawned = 0
  
  mainFont = love.graphics.newFont("arial.ttf")
  bigFont = love.graphics.newFont("arial.ttf", 100)
  medFont = love.graphics.newFont("arial.ttf",50)
  timeFont = love.graphics.newFont("arial.ttf",25)
  w,h = love.graphics.getWidth(),love.graphics.getHeight()
  
  overlay = love.graphics.newImage("Sprites/overlay.png")
  nightOverlay = love.graphics.newImage("Sprites/nightOverlay.png")
  
  dirtTexture = love.graphics.newImage("Sprites/dirt.png")
  grassTexture = love.graphics.newImage("Sprites/grass.png")
  tilled_dirtTexture = love.graphics.newImage("Sprites/tilledDirt.png")
  grassTexture:setWrap("repeat", "repeat")
  grass_quad = love.graphics.newQuad(0,0, w,h, grassTexture:getWidth()*3, grassTexture:getHeight()*3)
  world = bump.newWorld()
  
  unplantSound = love.audio.newSource("sounds/unplant.wav", "static")
  
  grid = {}
  
  ox,oy = 24,48*2.5
  sx,sy = 48,48
  
  for x = 1,15 do
    for y = 1,7 do
      local rr = math.random(1,4)
      if rr == 1 then rr = 0 
      elseif rr == 2 then rr = math.pi/2
      elseif rr == 3 then rr = math.pi
      else rr = -math.pi/2 end
      
      local t = true
      if y ~= 1 then
        t = false
      end
      
      local e = {x=ox+x*sx,y=oy+y*sy,open = true,r=rr,p=nil,tilled = t}
      
      table.insert(grid,e)
    end
  end
  
  local p = pumpkin.new(grid[1].x,grid[1].y,grid[1])
  grid[1].open = false
  grid[1].p = p
  
  largePumpkin = {}
  largePumpkin.x = w/2- (21*6)/2
  largePumpkin.y = 10
  largePumpkin.w = 21*6
  largePumpkin.h = 24*6-20
  world:add(largePumpkin,largePumpkin.x,largePumpkin.y,largePumpkin.w,largePumpkin.h)
  largePumpkin.image = love.graphics.newImage("LargePumpkin.png")
  largePumpkin.hp = 2000
  largePumpkin.maxHp = 2000
  
  shop.load()
  player.load()
  
  raining = false
  timeRaining = 0
end

function love.load()
  reload()
end

local lastSpawned = 0

function love.update(dt)
  if not gameover then
    if not paused then
      timer = timer + dt
      dayTimer = dayTimer - dt
      if dayTimer <= 0 then
        dayTimer = 60
        dayTime = not dayTime
        if dayTime then
          day = day + 1
        else
          weedsToSpawn = weedsToSpawn + 1
          weedsSpawned = 0
        end
      end
      
      if raining then
        timeRaining = timeRaining + dt
        if timeRaining >= 5 then
          raining = false
        end
      end
      
      if largePumpkin.hp <= 0 then
        gameover = true
        paused = false
      end
      
      if not dayTime and weedsSpawned < weedsToSpawn then
        if lastSpawned+math.random(1,5) < timer then
          weedsSpawned = weedsSpawned +1
          weed.new(math.random(100,w-100),h)
          lastSpawned = timer
        end
      end
      
      player.update(dt)
      
      for i,v in pairs(plantedPumpkin) do
        local d = v:update(dt)
        if d then
          table.remove(plantedPumpkin,i)
        end
      end
      
      for i,v in pairs(weeds) do
        local d = v:update(dt)
        
        if d then
          table.remove(weeds,i)
        end
      end
      
      for i,v in pairs(workers) do
         v:update(dt)
      end
      
      for i,v in pairs(delays) do
        local d = v:update()
        
        if d then
          table.remove(delays,i)
        end
      end
    end
  end
end

function love.mousepressed(x,y,m)
  if paused and m == 1 and not tutorial then
    if (x >= w/2-100 and x <= w/2+100) and (y >= h/2+10 and y <= h/2+70) then
      paused = false
    elseif (x >= w/2-100 and x <= w/2+100) and (y >= h/2+80 and y <= h/2+140) then
      love.event.quit()
    elseif (x >= w/2-100 and x <= w/2+100) and (y >= h/2+150 and y <= h/2+210) then
      tutorial = true
    end
  elseif tutorial and m == 1 then
    tutorial = false
  elseif shop.shopping and m == 1 then
    shop.clicked(x,y)
  elseif m == 1 and gameover and (x >= w/2-100 and x <= w/2+100) and (y >= h/2+80 and y <= h/2+140) then
    plantedPumpkin = {}
    weeds = {}
    workers = {}
    gameover = false
    reload()
  end
end

tutText = [[
Whacker of the Weeds

In this game you must defend the large pumpkin, it is your PRIZE!
Weeds are attempting to destroy your prize every night.
(Weeds also destroy your small pumpkins)

To combat this you must grow pumpkins, and use them to buy things from the shop.
Shop items:
- Hoe: Allows you to till more land to plant pumpkins.
- Weed Whacker: Allows you too mess up those weeds.
- Barbed Wire: Blocks and damages weeds from progessing
- Worker: They will harvet crops for you.
- Rain: This will instantly grow all crops.

(Click anywhere to close this.)
]]

function love.draw()  
  love.graphics.draw(grassTexture, grass_quad, 0, 0)
  
  for _,v in pairs(grid) do
    if not v.tilled then
      love.graphics.draw(dirtTexture,v.x+sx/2,v.y+sy/2,v.r,sx/16,sy/16,16/2,16/2)
    else
      love.graphics.draw(tilled_dirtTexture,v.x+sx/2,v.y+sy/2,0,sx/16,sy/16,16/2,16/2)
    end
  end
  
  for _,v in pairs(plantedPumpkin) do
    v:draw()
  end
  
  shop.draw()
  
  love.graphics.draw(largePumpkin.image,largePumpkin.x,largePumpkin.y,0,6,6)
  
  for _,v in pairs(weeds) do
    v:draw()
  end
  
  for _,v in pairs(workers) do
    v:draw()
  end
  
  for i,v in pairs(barbedWire) do
    local e = v:draw()
    if e then
      table.remove(barbedWire,i)
    end
  end
  
  player.draw()
  
  if raining then
    love.graphics.draw(rainSpriteRepeated, rain_quad, -timeRaining*10,timeRaining*10 - 1000)
  end
  
  if shop.shopping then
    shop.drawUI()
  end
  
  love.graphics.setColor(1,0,0)
  love.graphics.rectangle("fill",w/2-100,10,200,10)
  love.graphics.setColor(0,1,0)
  love.graphics.rectangle("fill",w/2-100,10,200*(largePumpkin.hp/largePumpkin.maxHp),10)
  love.graphics.setColor(1,1,1)
  
  if paused then
    love.graphics.setFont(bigFont)
    love.graphics.draw(overlay,0,0,0,10,10)
    love.graphics.printf("Paused",0,h/2-100,w,"center")
    
    love.graphics.setFont(medFont)
    love.graphics.setColor(.5,.5,.5)
    love.graphics.rectangle("fill",w/2-100,h/2+10,200,60)
    love.graphics.rectangle("fill",w/2-100,h/2+80,200,60)
    love.graphics.rectangle("fill",w/2-100,h/2+150,200,60)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Resume",w/2-100,h/2+10,200,"center")
    love.graphics.printf("Quit",w/2-100,h/2+80,200,"center")
    
    love.graphics.printf("Tutorial",w/2-100,h/2+150,200,"center")
    if tutorial then
      love.graphics.setColor(.5,.5,.5)
      love.graphics.rectangle("fill",50,50,w-150,h-150)
      love.graphics.setFont(timeFont)
      love.graphics.setColor(1,1,1)
      love.graphics.printf(tutText,60,60,w-160,"left")
    end
  end
  
  if gameover then
    love.graphics.setFont(bigFont)
    love.graphics.draw(overlay,0,0,0,10,10)
    love.graphics.printf("Game Over",0,h/2-100,w,"center")
    love.graphics.setFont(timeFont)
    love.graphics.printf("You let the large pumpkin die!",0,h/2+10,w,"center")
    
    love.graphics.setFont(medFont)
    love.graphics.setColor(.5,.5,.5)
    love.graphics.rectangle("fill",w/2-100,h/2+80,200,60)
    love.graphics.setColor(1,1,1)
    love.graphics.printf("Restart",w/2-100,h/2+80,200,"center")
  end
  
  love.graphics.setFont(mainFont)
end

function math.normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end