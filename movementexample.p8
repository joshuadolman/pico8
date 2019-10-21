pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--globals
px,py=64,64
dx,dy=64,64
 
--check if button was pressed previously
function btn_prev(i)
  return (btn(i) and 2^i==band(2^i,btn_))
end
 
function _update60()
  --check if player is still moving in the same direction as last frame
  if not btn(direction) then
    direction=-1
  end
 
  --check if there is a new button pressed
  for i=0,3 do
    if btn(i) and (not btn_prev(i) or direction==-1) then
      direction=i
    end
  end
 
  --move player
  if btnp(direction) then
    if direction<=1 then
      dx+=(direction-0.5)*16
    else
      dy+=(direction-2.5)*16
    end
  end
 
  --store current buttons
  btn_ = btn()
	if dx!=px then
		if dx>px then
			px+=1
		else
			px-=1
		end
	end
	if dy!=py then
		if dy>py then
			py+=1
		else
			py-=1
		end
	end
end
 
function _draw()
    cls()
    print("direction "..direction)
    print("x "..px..", y "..py)
    pset(px,py)
end
