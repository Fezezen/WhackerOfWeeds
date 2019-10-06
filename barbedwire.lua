local wire = {}
barbedWire = {}

wire.__index = wire

function wire.new(x,y)
  local self = setmetatable({},wire)
  
  self.x = x
  self.y = y
  
  self.w = 48
  self.h = 48
  self.hp = 200
  
  table.insert(barbedWire,self)
  
  return self
end

function wire:draw()
  love.graphics.draw(barbedWireImage,self.x,self.y,0,3,3)
  
  if self.hp <= 0 then
    return true
  end
end

return wire