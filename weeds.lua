local weed = {}
weeds = {}
weed.__index = weed

weedSprite = love.graphics.newImage("Sprites/weed.png")

local dieSounds = {
  love.audio.newSource("sounds/weedDie1.wav", "static"),
  love.audio.newSource("sounds/weedDie2.wav", "static")
}

function weed.new(x,y)
  local self = setmetatable({},weed)
  
  self.x = x
  self.y = y
  self.w = 48
  self.h = 48
  
  self.lastAttack = 5
  
  self.speed = 50
  
  self.hp = 100
  
  table.insert(weeds,self)
  return self
end

function weed:checkPlant()
  for _,v in pairs(plantedPumpkin) do
    local d = math.sqrt(((self.x+self.w/2)-(v.x+24))^2 +((self.y+self.h/2)-(v.y+24))^2)
    if d <= 40 then
      return v
    end
  end
end

function weed:checkBarbedWire()
  for _,v in pairs(barbedWire) do
    local d = math.sqrt(((self.x+self.w/2)-(v.x+24))^2 +((self.y+self.h/2)-(v.y+24))^2)
    if d <= 40 then
      return v
    end
  end
end

function weed:update(dt)
  local w = self:checkBarbedWire()
  local p = self:checkPlant()
  if w then
    if self.lastAttack < timer then
      w.hp = w.hp - 25
      self.hp = self.hp - 10
      self.lastAttack = timer+5
    end
  elseif p then
    if self.lastAttack < timer then
      p.hp = p.hp - 25
      self.lastAttack = timer+5
    end
  elseif self.y > 130 then
    self.y = self.y - self.speed*dt
  elseif self.x < largePumpkin.x+2 then
    self.x = self.x + self.speed*dt
  elseif self.x > largePumpkin.x+largePumpkin.w-2 then
    self.x = self.x - self.speed*dt
  elseif self.lastAttack < timer then
    largePumpkin.hp = largePumpkin.hp - 2
    self.lastAttack = timer+5
  end
  
  if self.hp <= 0 then
    dieSounds[math.random(1,#dieSounds)]:play()
    return true
  end
end

function weed:draw()
  love.graphics.draw(weedSprite,self.x,self.y,0,1,1)
end

return weed