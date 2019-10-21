pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--data--
gamestate=""
debug=""

paddle={
 w  =30,
 h  =4,
 x  =(128/2)-(30/2),
 y  =122,
 dx =0,
 dy =0,
 col=5
}



--end data tab--
-->8
--init--
function _init()
 initstartmenu()
end

function initstartmenu()
 cls(1)
 gamestate="startmenu"
end

--end init tab--
-->8
--update--
function _update60()
 if (gamestate=="startmenu") then
  updatestartmenu()
 elseif (gamestate=="game") then
  updategame()
 end
end
--update gamestate functions--
function updatestartmenu()
 movepaddle()
 if btn(5) then
  gamestate="game"
 end
end

function updategame()
movepaddle()
end

--update gameplay functions--
function movepaddle()
 if btn(0) then
  paddle.dx=-1
 elseif btn(1) then
  paddle.dx=1
 elseif not btn(0) and not btn(1) then
  paddle.dx=paddle.dx/1.1
 end
 paddle.x=mid(0,(paddle.x+paddle.dx),127-paddle.w)
end

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
  drawstartmenu()
 elseif (gamestate=="game") then
  drawgame()
 end

 draw_debug()

end

--gamestate functions--
function drawstartmenu()
 cls(1)
 --rectfill(0,40,127,12,0)
 paddle_draw()
 print("press ❎ to start!",29,100,7)
end

function drawgame()
 cls(0)
 --rectfill(0,40,127,12,0)
 paddle_draw()
end

--drawing routines--
function paddle_draw()
 rectfill(paddle.x,paddle.y,paddle.x+paddle.w,paddle.y+paddle.h,paddle.col)
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
