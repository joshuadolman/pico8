pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
screenshake=0

function screen_shake()
  local fade = 0.95
  local offset_x=16-rnd(32)
  local offset_y=16-rnd(32)
  offset_x*=screenshake
  offset_y*=screenshake
  
  camera(offset_x,offset_y)
  screenshake*=fade
  if screenshake<0.05 then
    screenshake=0
  end
end

