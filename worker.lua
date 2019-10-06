local worker = {}
worker.__index = worker
workers = {}

workerSprite = love.graphics.newImage("Sprites/Worker/idle.png")
workerSpriteWalk1 = love.graphics.newImage("Sprites/Worker/walk1.png")

function worker.new(x,y)
  local self = setmetatable({},worker)
  
  self.x = x
  self.y = y
  self.w = 48
  self.h = 48
  self.speed = 70
  
  self.frame = 1
  self.last = 0
  
  self.facing = 1

  self.target = nil
  
  table.insert(workers,self)
  
  return self
end

function worker:findTarget(x,y)
  local d = 100000
  local closest = nil
  
  for _,v in pairs(plantedPumpkin) do
      if not v.beingPicked and v.level == 2 and v.hp > 0 then
        local dis = math.sqrt((x-v.x)^2 + (y-v.y)^2)
        if dis < d then
          closest = v
        end
      end
  end
  
  if closest then
    self.target = closest
    self.target.beingPicked = true
  end
end

function worker:update(dt)
  if not self.target then
    if self.x > 10 then
      self.x = self.x - self.speed*dt
      self.facing = -1
      if self.last < timer then
        self.frame = self.frame + 1
        if self.frame > 2 then
          self.frame = 1
        end
        self.last = timer+.5
      end
    else
      self.frame = 1
    end
    
    self:findTarget(self.x,self.y)
  else
    local dis = math.sqrt(((self.x+self.w/2)-(self.target.x+24))^2 +((self.y+self.h/2)-(self.target.y+24))^2)
    if dis > 40 then
      if self.target.hp <= 0 then
        self.target = nil
        return
      end
      local angle = math.atan2(self.target.y-self.y,self.target.x-self.x)
      local dx = math.cos(angle)*self.speed
      local dy = math.sin(angle)*self.speed
      
      self.x = self.x + dx*dt
      self.y = self.y + dy*dt
      
      if dx > 0 then
        self.facing = 1
      else
        self.facing = -1
      end
      
      if self.last < timer then
        self.frame = self.frame + 1
        if self.frame > 2 then
          self.frame = 1
        end
        self.last = timer+.5
      end
    else
      self.target.hp = 0
      player.inventory[1].amount = player.inventory[1].amount + seedChance[math.random(1,#seedChance)]
      self.target.slot.open = true
      player.pumpkins = player.pumpkins + 1
      self.target = nil
      unplantSound:play()
      
      self.frame = 1
    end
  end
end

function worker:draw()
  local off = 0
  if self.facing == -1 then
    off = 48
  end
  if self.frame == 1 then
    love.graphics.draw(workerSprite,self.x,self.y,0,self.facing,1,off,0)
  elseif self.frame == 2 then
    love.graphics.draw(workerSpriteWalk1,self.x,self.y,0,self.facing,1,off,0)
  end
end

return worker