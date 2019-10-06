local pumpkin = {}
plantedPumpkin = {}
pumpkin.__index = pumpkin

local pumpkinLevelSprites = {
  love.graphics.newImage("Sprites/pumpkin/pumpkin-0.png"),
  love.graphics.newImage("Sprites/pumpkin/pumpkin-1.png"),
  love.graphics.newImage("Sprites/pumpkin/pumpkin-2.png")
}

function pumpkin.new(x,y,slot)
  local self = setmetatable({},pumpkin)
  
  self.x = x
  self.y = y
  self.level = 0
  self.tick = 0
  
  self.hp = 100
  
  self.beingPicked = false
  
  self.slot = slot
  
  table.insert(plantedPumpkin,self)
  
  return self
end

function pumpkin:update(dt)
  if self.hp <= 0 then
    return"d"
  end
  
  if self.level ~= 2 then
    self.tick = self.tick+dt
    if self.tick >= 5 then
      local r = math.random(1,10)
      if r <= 5 then
        self.level = self.level + 1
      end
      self.tick = 0
    end
  end
end

function pumpkin:draw()
  local p = pumpkinLevelSprites[self.level+1] or pumpkinLevelSprites[3]
  love.graphics.draw(p,self.x,self.y,0)
end

return pumpkin