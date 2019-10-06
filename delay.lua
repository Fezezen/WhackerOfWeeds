local delay = {}
delay.__index = delay
delays = {}

function delay.new(time,func)
  local self = setmetatable(delay,{})
  
  self.timeStarted = timer
  self.time = time
  self.func = func
  
  table.insert(delays,self)
  
  return self
end

function delay:update()
  if self.timeStarted+self.time <= timer then
    print(self.timeStarted+self.time,timer)
    self.func()
    return true
  end
end

return delay