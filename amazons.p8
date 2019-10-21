pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--todo
-->8
--data

gamemode="menu"

board={
	size=10,
	celldim=11,
	grid={},
	--center offset x/y
	cofx=0,
	cofy=0,
	moveables={},
}

gamestate={
	--turn, 8=red, 12=blue
	turn=8,
	phase="move",
	--cursor
	curx=1,
	cury=1,
	sel=false,
	selpiece={},
	prevturn=8
}

menu={
	difficulties={
		"small",
		"medium",
		"large"
	},
	difficulty=2,
}

-->8
--init
function _init()
	palt(0,false)
	palt(14,true)
end

function init_board(boardsize)
	board.size=boardsize
	for x=1,board.size do
		board.grid[x]={}
		for y=1,board.size do
			board.grid[x][y]=0
		end
	end


	board.cofx=flr((128-(board.celldim*board.size))/2)-1
	board.cofy=flr((117-(board.celldim*board.size))/2)+9 
end

function init_pieces(difficulty)
	if difficulty==1 then
		board.grid[3][1]=8
		board.grid[4][6]=8
		board.grid[1][4]=12
		board.grid[6][3]=12
	elseif difficulty==2 then
		board.grid[4][1]=8
		board.grid[8][2]=8
		board.grid[1][3]=8
		board.grid[1][7]=12
		board.grid[8][6]=12
		board.grid[5][8]=12
	elseif difficulty==3 then
		board.grid[4][1]=8
		board.grid[7][1]=8
		board.grid[1][4]=8
		board.grid[10][4]=8
		board.grid[1][7]=12
		board.grid[10][7]=12
		board.grid[4][10]=12
		board.grid[7][10]=12
	end
end
-->8
--update
function _update60()
	if gamemode=="game" then
		update_game()
	elseif gamemode=="menu" then
		update_menu()
	elseif gamemode=="win" then

	end
end

function update_game()
	if gamestate.prevturn~=gamestate.turn then
		check_for_no_moves_left()
		gamestate.prevturn=gamestate.turn
	end
	update_moveables()
	update_input_game()
end

function update_menu()
	if btnp(0) then
		menu.difficulty=max(1,menu.difficulty-1)
	end
	if btnp(1) then
		menu.difficulty=min(#menu.difficulties,menu.difficulty+1)
	end

	if btnp(4) or btnp(5) then
		if menu.difficulty==1 then
			init_board(6)
		elseif menu.difficulty==2 then
			init_board(8)
		elseif menu.difficulty==3 then
			init_board(10)
		end
		init_pieces(menu.difficulty)
		gamemode="game"
	end
end

function update_input_game()
	if btnp(0) then
		update_cursor(-1,0)
	end
	if btnp(1) then
		update_cursor(1,0)
	end
	if btnp(2) then
		update_cursor(0,-1)
	end
	if btnp(3) then
		update_cursor(0,1)
	end
	if btnp(4) then
		--toggle_turn()
	end
	if btnp(5) then
		if gamestate.sel==true and gamestate.phase=="move" then
			if check_if_pos_is_moveable(gamestate.curx,gamestate.cury) then
				board.grid[gamestate.selpiece.x][gamestate.selpiece.y]=0
				board.grid[gamestate.curx][gamestate.cury]=gamestate.turn
				gamestate.selpiece={}
				board.moveables={}
				gamestate.phase="shoot"
				calc_moveable_points(gamestate.curx, gamestate.cury)
			end
		elseif gamestate.sel==true and gamestate.phase=="shoot" then
			if check_if_pos_is_moveable(gamestate.curx,gamestate.cury) then
				board.grid[gamestate.curx][gamestate.cury]=1
				gamestate.sel=false
				empty_moveables()
				gamestate.phase="move"
				toggle_turn()
			end
		else
			if board.grid[gamestate.curx][gamestate.cury]==gamestate.turn then
				empty_moveables()
				calc_moveable_points(gamestate.curx, gamestate.cury)
				if #board.moveables>0 then
					gamestate.sel=true
					gamestate.selpiece.x=gamestate.curx
					gamestate.selpiece.y=gamestate.cury
				end
			end
		end
	end
end

function update_moveables()
	if gamestate.sel==false then
		empty_moveables()
		if board.grid[gamestate.curx][gamestate.cury]==gamestate.turn then
			calc_moveable_points(gamestate.curx, gamestate.cury)
		end
	end
end

function update_cursor(dx,dy)
	gamestate.curx+=dx
	gamestate.cury+=dy
	gamestate.curx=mid(1,gamestate.curx,board.size)
	gamestate.cury=mid(1,gamestate.cury,board.size)
end

function toggle_turn()
	if gamestate.turn==8 then gamestate.turn=12
	elseif gamestate.turn==12 then gamestate.turn=8
	end
end

function empty_moveables()
	board.moveables={}
end

function check_if_pos_is_moveable(x,y)
	for i=1,#board.moveables do
		if x==board.moveables[i].x and y==board.moveables[i].y then
			return true
		end
	end
	return false
end

function no_moves_left(tableofpositions)
	empty_moveables()
	for i=1,#tableofpositions do
		calc_moveable_points(tableofpositions[i].x,tableofpositions[i].y)
	end
	if #board.moveables==0 then return true else return false end
end

function check_for_no_moves_left()
	local tableofpositions_8={}
	local tableofpositions_12={}
	for x=1,board.size do
		for y=1,board.size do
			local pos={}
			if board.grid[x][y]==8 then
				pos.x=x
				pos.y=y
				tableofpositions_8[#tableofpositions_8+1]=pos
			elseif board.grid[x][y]==12 then
				pos.x=x
				pos.y=y
				tableofpositions_12[#tableofpositions_12+1]=pos
			end
		end
	end

	if no_moves_left(tableofpositions_8) then
		gamemode="win"
		gamestate.turn=12
	elseif no_moves_left(tableofpositions_12) then
		gamemode="win"
		gamestate.turn=8
	end
	board.moveables={}
end

function calc_moveable_points(gpx,gpy)
	calc_moveable_points_dir(gpx,gpy,0,1)
	calc_moveable_points_dir(gpx,gpy,0,-1)
	calc_moveable_points_dir(gpx,gpy,1,0)
	calc_moveable_points_dir(gpx,gpy,-1,0)

	for i=1,board.size do
		if gpx+i<=board.size and gpy+i<=board.size then
			if board.grid[gpx+i][gpy+i]==0 then
					local pos={}
					pos.x=gpx+i
					pos.y=gpy+i
					board.moveables[#board.moveables+1]=pos
			else
				break
			end
		end
	end
	for i=1,board.size do
		if gpx-i>0 and gpy-i>0 then
			if board.grid[gpx-i][gpy-i]==0 then
					local pos={}
					pos.x=gpx-i
					pos.y=gpy-i
					board.moveables[#board.moveables+1]=pos
			else
				break
			end
		end
	end
	for i=1,board.size do
		if gpx-i>0 and gpy+i<=board.size then
			if board.grid[gpx-i][gpy+i]==0 then
					local pos={}
					pos.x=gpx-i
					pos.y=gpy+i
					board.moveables[#board.moveables+1]=pos
			else
				break
			end
		end
	end
	for i=1,board.size do
		if gpx+i<=board.size and gpy-i>0 then
			if board.grid[gpx+i][gpy-i]==0 then
					local pos={}
					pos.x=gpx+i
					pos.y=gpy-i
					board.moveables[#board.moveables+1]=pos
			else
				break
			end
		end
	end

	if gamestate.phase=="move" and #board.moveables>0 then
		local pos={}
		pos.x=gpx
		pos.y=gpy
		board.moveables[#board.moveables+1]=pos
	end
end

function calc_moveable_points_dir(gpx,gpy,dirx,diry)
	local loopendx,loopendy
	local loopadderx,loopaddery=dirx,diry
	local brk=false
	if dirx==1 then
		loopendx=board.size
	elseif dirx==-1 then
		loopendx=1
	else
		loopendx=gpx
		loopadderx=1
	end

	if diry==1 then
		loopendy=board.size
	elseif diry==-1 then
		loopendy=1
	else
		loopendy=gpy
		loopaddery=1
	end

	for x=gpx+dirx,loopendx,loopadderx do
		if brk then break end
		for y=gpy+diry,loopendy,loopaddery do
			if board.grid[x][y]==0 then
				local pos={}
				pos.x=x
				pos.y=y
				board.moveables[#board.moveables+1]=pos
			else
				brk=true
				break
			end
		end
	end

end

-->8
--draw
function _draw()
	cls(7)
	if gamemode=="game" then
		draw_boardgrid(board.size,0)
		draw_moveables()
		draw_boardstate()

		draw_ui()

		draw_cursor()
	elseif gamemode=="menu" then
		local y=90
		sspr(54,0,74,18,27,36)
		draw_banner_text("press ❎ to start",31,y-12+((sin(time()/2))*2)+0.5,7,5)
		rectfill(0,y-2,128,y+11,6)
		draw_banner_text(menu.difficulties[menu.difficulty],64-(flr((#menu.difficulties[menu.difficulty]*4)/2)),y+2,7,5)
		draw_banner_text("⬅️",40,y+2+(sin(time()*2))*0.6+0.5,7,5)
		draw_banner_text("➡️",80,y+2+(sin(time()*2+0.5))*0.6+0.5,7,5)
		--print(sin(time()/4)^2)-0.09,1,1,0)
	elseif gamemode=="win" then
		if gamestate.turn==8 then
			print("red win",1,1,0)
		elseif gamestate.turn==12 then
			print("blue win",1,1,0)
		end
	end
end

function draw_ui()
	draw_banner()
	local y,col=2,7
	draw_banner_text("❎",93,y,col,col-2)

	if gamestate.sel==true then
		if gamestate.phase=="move" then
			draw_banner_text("move",107,y,col,col-2)
		elseif gamestate.phase=="shoot" then
			draw_banner_text("shoot",105,y,col,col-2)
		end
	else
		draw_banner_text("select",103,y,col,col-2)
	end
end

function draw_banner_text(text,x,y,c,sc)
	for _x=-1,1 do
		for _y=-1,2 do
			print(text,x+_x,y+_y,0)
		end
	end
	print(text,x,y+1,sc)
	print(text,x,y,c)
end

function draw_banner()
	rectfill(0,0,128,9,6)
	local plyr=0
	local plyrname,txt="",""
	local shadowcol=0
	if gamestate.turn==8 then plyr=48 plyrname="red" shadowcol=2 end
	if gamestate.turn==12 then plyr=32 plyrname="blue" shadowcol=1 end

	spr(plyr,1,1)
	if gamestate.sel==false then
		txt="'s turn"
	else
		if gamestate.phase=="move" then
			txt="'s movement"
		elseif gamestate.phase=="shoot" then
			txt="'s shot"
		end
	end
	draw_banner_text(plyrname..txt,12,2,gamestate.turn,shadowcol)

end

function draw_boardgrid(boardsize,col)
	local xpos,ypos=0,0

	for x=1,boardsize do
		for y=1,boardsize do
			xpos=((x-1)*board.celldim)+board.cofx
			ypos=((y-1)*board.celldim)+board.cofy
			rect(xpos,ypos,xpos+board.celldim,ypos+board.celldim,col)
		end
	end
end

function draw_boardstate()
	local bposstate=0
	for x=1,#board.grid do
		for y=1,#board.grid[x] do
			bposstate=board.grid[x][y]
			if bposstate==8 or 12 then
				draw_piece(bposstate,x,y)
			end
			if board.grid[x][y]==1 then
				--rect(1,1,4,4,5)
				rectfill(board.cofx+(x-1)*board.celldim+1,board.cofy+(y-1)*board.celldim+1,
				board.cofx+(x*board.celldim)-1,board.cofy+(y*board.celldim)-1,5)
			end
		end
	end
end

function draw_piece(player,gpx,gpy)

	local plyrspr=0
	if player==8 then plyrspr=48
	elseif player==12 then plyrspr=32
	else return
	end
	spr(plyrspr,gridpos_to_screenpos(gpx,gpy))
end

function draw_cursor()
	local xpos=((gamestate.curx-1)*board.celldim)+board.cofx-1
	local ypos=((gamestate.cury-1)*board.celldim)+board.cofy-1
	rect(xpos,ypos,xpos+board.celldim+2,ypos+board.celldim+2,0)
	rect(xpos+1,ypos+1,xpos+board.celldim+1,ypos+board.celldim+1,gamestate.turn)
	rect(xpos+2,ypos+2,xpos+board.celldim,ypos+board.celldim,0)
end

function draw_moveables()
	if gamestate.sel~=true then
		fillp(0b0101101001011010.1)
	end

	if board.moveables then
		for i=1,#board.moveables do
			--spr(16, gridpos_to_screenpos(board.moveables[i].x,board.moveables[i].y))
			rectfill(board.cofx+(board.moveables[i].x-1)*board.celldim+1,board.cofy+(board.moveables[i].y-1)*board.celldim+1,
				board.cofx+board.moveables[i].x*board.celldim-1,board.cofy+board.moveables[i].y*board.celldim-1,gamestate.turn)
		end
	end
	fillp()
end

function gridpos_to_screenpos(gpx,gpy)
	local xpos=((gpx-1)*board.celldim)+board.cofx+2
	local ypos=((gpy-1)*board.celldim)+board.cofy+2
	return xpos,ypos
end

-->8
--debug
__gfx__
000000005555555500000000000000000000000000000000000000e000000000e000000000000e00000000000000000000000000000e000000000e000000000e
000000005555555500000000000000000000000000000000000000008888888000888888888800088888880088888888800ccccccc000ccccccc000ccccccc00
00700700555555550000000000000000000000000000000000000008888888880888888888888088888888808888888870ccccccccc0ccccccccc0ccccccccc0
00077000555555550000000000000000000000000000000000000008880008880888088880888088800088800000000770ccc000ccc0ccc000ccc0ccc0000cc0
00077000555555550000000000000000000000000000000000000008800e0088088000880008808800e00880eeee007770cc00e00cc0cc00e00cc0cc00ee0000
0070070055555555000000000000000000000000000000000000000880eee0880880e0880e0880880eee0880eee0077700cc0eee0cc0cc0eee0cc0ccc000000e
00000000555555550000000000000000000000000000000000000008800000880880e0880e08808800000880ee00777000cc0eee0cc0cc0eee0cc0cccccccc00
00000000555555550000000000000000000000000000000000000008888888880880e0880e08808888888880e0077700e0cc0eee0cc0cc0eee0cc00cccccccc0
00000000000000000000000000000000000000000000000000000008888888880880e0880e088088888888800077700ee0cc0eee0cc0cc0eee0cc0000000ccc0
00000000000000000000000000000000000000000000000000000008800000880880e0880e08808800000880077700eee0cc00e00cc0cc0eee0cc0000ee00cc0
0000000000000000000000000000000000000000000000000000000880eee0880880e0880e0880880eee08807770000000ccc000ccc0cc0eee0cc0cc0000ccc0
0000000000000000000000000000000000000000000000000000000880eee0880880e0880e0880880eee088077ccccccc0ccccccccc0cc0eee0cc0ccccccccc0
0000000000000000000000000000000000000000000000000000000880eee0880880e0880e0880880eee08807cccccccc00ccccccc00cc0eee0cc00ccccccc00
0000000000000000000000000000000000000000000000000000000000eee0000000e0000e0000000eee000000000000000000000000000eee0000000000000e
000000000000000000000000000000000000000000000000000000eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0000ee0000000000000000000000000000000000000000000000088888888888888888888888888888888888777cccccccccccccccccccccccccccccccccc0
e01cc10e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01cc7c10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccc7c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0cccccc0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01cccc10000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e01cc10e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e028820e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02887820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888780000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02888820000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e028820e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ee0000ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
