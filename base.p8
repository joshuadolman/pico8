pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--data--
gamestate="" --startmenu,game,win,lose
debug=""

--end data tab--
-->8
--init--
function _init()
 gamestate="startmenu"
end

--end init tab--
-->8
--update--
function _update60()
 if (gamestate=="startmenu") then
  update_startmenu()
 elseif (gamestate=="game") then
  update_game()
 elseif (gamestate=="win") then
  update_win()
 elseif (gamestate=="lose") then
  update_lose()
 else
  local p
   if (gamestate=="") then
    p="nil"
   else
    p=gamestate
   end
  debug=("gamestate error-\""..p.."\"")
  _draw()
 end
end

--update gamestate functions--
function update_startmenu()
 if btnp(5) then
  gamestate="game"
  --printh("changed gamestate from \"startmenu\" to \"game\".")
 end
end

function update_game()
 if btnp(5) then
  gamestate="win"
  --printh("changed gamestate from \"game\" to \"win\".")
 end
end

function update_win()
 if btnp(5) then
  gamestate="lose"
  --printh("changed gamestate from \"win\" to \"lose\".")
 end
end

function update_lose()
 if btnp(5) then
  gamestate="startmenu"
  --printh("changed gamestate from \"lose\" to \"startmenu\".")
 end
end

--update functions--
function col_check(ax,ay,aw,ah,bx,by,bw,bh)
 if ay>by+bh then
  return false
 end
 if ay+ah<by then
  return false
 end
 if ax>bx+bw then
  return false
 end
 if ax+ah<bx then
  return false
 end
 return true
end

--end update tab--
-->8
--draw--
function _draw()
 if (gamestate=="startmenu") then
  draw_startmenu()
 elseif (gamestate=="game") then
  draw_game()
 elseif (gamestate=="win") then
  draw_win()
 elseif (gamestate=="lose") then
  draw_lose()
 end

 draw_debug()
end

--draw gamestate functions--
function draw_startmenu()
 cls(0)
prnt_cntr("press ❎ to start!",100,7)
end

function draw_game()
 cls(1)
prnt_cntr("press ❎ to win!",100,7)
end

function draw_win()
 cls(11)
 prnt_cntr("press ❎ to lose!",100,7)
end

function draw_lose()
 cls(8)
 prnt_cntr("press ❎ to restart!",100,7)
end

--draw functions--
function prnt_cntr(text, y, c)
 local x=63-(#text*4/2)
 print(text,x,y,c)
end

function draw_debug()
 local top=false
 if (debug!="") then
  local p=("err:"..debug)
  local lines=ceil(#p/31)
  local h=lines*6 

  if top==true then --draw at the top
   rectfill(0,0,127,h,8)
   line(1,1,1,h-1,9)
	for i=1,lines do
    print(sub(p,i*31-30,i*31),3,((i-1)*6)+1,7)
   end
  else -- draw at the bottom
   rectfill(0,127-h,127,127,8)
   line(1,128-h,1,126,9)
	for i=1,lines do
    print(sub(p,i*31-30,i*31),3,((128-h)+(6*(i-1))),7)
   end
  end
 end
end
--end draw tab--
