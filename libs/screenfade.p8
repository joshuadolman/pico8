pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function screenfade(_perc)
  -- this function sets the
  -- color palette so everything
  -- you draw afterwards will
  -- appear darker
  -- it accepts a number from
  -- 0 means normal
  -- 1 is completely black
  -- this function has been
  -- adapted from the jelpi.p8
  -- demo
  
  -- first we take our argument
  -- and turn it into a 
  -- percentage number (0-100)
  -- also making sure its not
  -- out of bounds  
  local p=flr(mid(0,_perc,1)*100)
  
  -- these are helper variables
  local kmax,col,dpal,j,k
  
  -- this is a table to do the
  -- palette shifiting. it tells
  -- what number changes into
  -- what when it gets darker
  -- so number 
  -- 15 becomes 14
  -- 14 becomes 13
  -- 13 becomes 1
  -- 12 becomes 3
  -- etc...
  dpal={0,1,1, 2,1,13,6,
           4,4,9,3, 13,1,13,14}
  
  -- now we go trough all colors
  for j=1,15 do
   --grab the current color
   col = j
   
   --now calculate how many
   --times we want to fade the
   --color.
   --this is a messy formula
   --and not exact science.
   --but basically when kmax
   --reaches 5 every color gets 
   --turns black.
   kmax=(p+(j*1.46))/22
   
   --now we send the color 
   --through our table kmax
   --times to derive the final
   --color
   for k=1,kmax do
    col=dpal[col]
   end
   
   --finally, we change the
   --palette
   pal(j,col,1)
  end
 end