pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--grid settings
gs={
	--dimensions
	d=13,
	--square size
	s=7,
	--border
	brdr=3,
	--offsets x & y
	ofx=10,
	ofy=10,

}

test={
	x=5,
	y=5,
}

--gamestate
game={
	move=1,
	curplyr="black",
	--board
	b={},
	csb=0,
	csw=7.5,
}
-->8
function _init()
	palt(0,false)
	palt(14,true)

	init_board()
end

function init_board()
	for x=0,gs.d-1 do
		game.b[x]={}
		for y=0,gs.d-1 do
			game.b[x][y]=nil
		end
	end 
end
-->8
function _update60()

	if game.move%2==0 then
		game.curplyr="white"
	else
		game.curplyr="black"
	end
	
 if btn(4) then
 	--board pos
	local bpos=game.b[test.x][test.y]
 	if btnp(5) then
 		if bpos==nil then
 			game.b[test.x][test.y]=0
 		elseif bpos==0 then
 			game.b[test.x][test.y]=1
 		elseif bpos==1 then
 			game.b[test.x][test.y]=nil
 		end
 	end
 	if btnp(0) then
 		game.csw-=1
 	end
 	if btnp(1) then
 	game.csw+=1
 	end
 	if btnp(2) then
 		game.csb+=1
 	end
 	if btnp(3) then
 		game.csb-=1
 	end	
 else
 	if btnp(0) then
 		test.x-=1
 	end
 	if btnp(1) then
 		test.x+=1
 	end
 	if btnp(2) then
 		test.y-=1
 	end
 	if btnp(3) then
 	test.y+=1
 	end
 	
 	if btnp(5) then
 		if game.b[test.x][test.y]==nil then
 			game.move+=1
 			game.b[test.x][test.y]=(game.move+1)%2
 		end
 	end
 	
 end
 	
	if test.x>=gs.d then test.x=0 end
	if test.y>=gs.d then test.y=0 end
	if test.x<0 then test.x=gs.d-1 end
	if test.y<0 then test.y=gs.d-1 end
end
-->8
function _draw()
	cls(0)

	local tx,ty
	rectfill(gs.ofx-gs.brdr,
			gs.ofy-gs.brdr,	
			(gs.d-1)*gs.s+gs.ofx+gs.brdr,
			(gs.d-1)*gs.s+gs.ofy+gs.brdr,
			15)
	for _y=0,gs.d-2 do
		for _x=0,gs.d-2 do
			tx=_x*gs.s +gs.ofx
			ty=_y*gs.s +gs.ofy
			rect(tx,ty,tx+gs.s,ty+gs.s,4)
			--[[if _y==4 and _x==4 then
				rect(tx-1,ty-1,tx+1,ty+1)
			end]]
			if _y==3 or _y==9 or _y==15 then
				if _x==3 or _x==9 or _x==15 then
						rect(tx-1,ty-1,tx+1,ty+1)
				end
			end
		end
	end

--ui	
	rectfill(0,0,127,6,5)
	print(game.csb,1,1,0)
	local _str=""..game.csw
	print(game.csw,128-(#_str*4),1,7)
	rectfill(0,121,127,127,5)
	local c
	if game.move%2==0 then c=7 else c=0 end
	for _y=0,gs.d-1 do
		for _x=0,gs.d-1 do
		
			tx=_x*gs.s +gs.ofx-flr((gs.s)/2)+1
			ty=_y*gs.s +gs.ofy-flr((gs.s)/2)+1
			if game.b[_x][_y]!=nil then
				--sspr(8+(game.b[_x][_y]*3),0,3,3,tx,ty)
				if game.b[_x][_y]==0 then
					c=7 else c=0
				end
				rectfill(tx,ty,tx+gs.s-3,ty+gs.s-3,c)
			end
		end
	end
	
	pal(11,c)
	sspr(15,1,5,5,test.x*gs.s+(gs.ofx-2),test.y*gs.s+(gs.ofx-2))

	
	print(game.curplyr.."'s turn to play...",1,122,c)
	--print("x "..test.x,1,122,4)
	--print("y "..test.y,21,122,4)
	posstr=test.x..","..test.y
	print(posstr,
			128-(#posstr*4),122,c)
			

end
__gfx__
00000000777000eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777000ebbbbbe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777000ebeeebe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000eeeeeeebeeebe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000ebeeebe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000ebbbbbe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000eeeeeee00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
