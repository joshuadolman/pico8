pico-8 cartridge // http://www.pico-8.com
version 16
__lua__



function del_tble(tble)
	if #tble>0 then
		for k,v in pairs(tble) do
  	  tble[k] = nil
		end
	end
end
-->8
--init
grid_w=10
grid_h=20
grid_ofx=0
grid_ofy=0
grid_cellsize=5
grid={}


droptime=0
dropmult=1
dropspeedup=1

framecounter=0


cur_tet={
	blckpos={1,1,1,2,1,3,1,4},
	typ=1
}

function _init()
	printh("starting tetris")
	init_grid()
end

function init_grid()
	for _x=1,grid_w do
		grid[_x]={}
		for _y=1,grid_h do
			grid[_x][_y]=0
		end
	end
	grid_ofx=63-((grid_w/2)*grid_cellsize)
	grid_ofy=63-((grid_h/2)*grid_cellsize)
end

function spawn_tet()
	del_tble(cur_tet.blckpos)
	cur_tet.typ=flr(rnd(6))+1
	if cur_tet.typ==1 then
		temp_create_tet_line()
	elseif cur_tet.typ==2 then
		temp_create_tet_box()
	elseif cur_tet.typ==3 then
		temp_create_tet_ess()
	elseif cur_tet.typ==4 then
		temp_create_tet_revess()
	elseif cur_tet.typ==5 then
		temp_create_tet_ell()
	elseif cur_tet.typ==6 then
		temp_create_tet_revell()
	end
end

function temp_create_tet_box()
	cur_tet.blckpos[1]=3
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=4
	cur_tet.blckpos[4]=1
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=2
	cur_tet.blckpos[7]=4
	cur_tet.blckpos[8]=2
end

function temp_create_tet_line()
	cur_tet.blckpos[1]=3
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=3
	cur_tet.blckpos[4]=2
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=3
	cur_tet.blckpos[7]=3
	cur_tet.blckpos[8]=4
end

function temp_create_tet_ess()
	cur_tet.blckpos[1]=4
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=3
	cur_tet.blckpos[4]=1
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=2
	cur_tet.blckpos[7]=2
	cur_tet.blckpos[8]=2
end

function temp_create_tet_revess()
	cur_tet.blckpos[1]=2
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=3
	cur_tet.blckpos[4]=1
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=2
	cur_tet.blckpos[7]=4
	cur_tet.blckpos[8]=2
end

function temp_create_tet_ell()
	cur_tet.blckpos[1]=3
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=3
	cur_tet.blckpos[4]=2
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=3
	cur_tet.blckpos[7]=4
	cur_tet.blckpos[8]=3
end

function temp_create_tet_revell()
	cur_tet.blckpos[1]=3
	cur_tet.blckpos[2]=1
	cur_tet.blckpos[3]=3
	cur_tet.blckpos[4]=2
	cur_tet.blckpos[5]=3
	cur_tet.blckpos[6]=3
	cur_tet.blckpos[7]=2
	cur_tet.blckpos[8]=3
end

-->8
--update

function _update60()
	if btnp(3) then
		cur_tet_move(0,1)
		if btn(3) then
			dropmult=2
		end
	elseif btn(3)==false then
		dropmult=1
	end

	if btnp(4) then
		cur_tet_rotate()
	end

	if btnp(0) then
		cur_tet_move(-1,0)
	elseif btnp(1) then
		cur_tet_move(1,0)
	end

	framecounter+=1
	dropspeedup+=0.0001
	droptime=flr(max(5,60/dropspeedup)/dropmult)
	if framecounter%droptime==0 then
		framecounter=0
		cur_tet_move(0,1)
	end
end

function cur_tet_move(_dx,_dy)
	if cur_tet_isdirectionfree(_dx,_dy) then
		for i=1,4 do
			cur_tet.blckpos[(i*2)-1]+=_dx
			cur_tet.blckpos[i*2]+=_dy
		end
	elseif _dy==1 then
		cur_tet_lockin()
		spawn_tet()
	end
end

function cur_tet_isdirectionfree(_dx,_dy)
	--printh("called \"cur_tet_isdirectionfree\"")
	_chkx,chky=0,0
	for i=1,4 do
		_chkx=cur_tet.blckpos[(i*2)-1]+_dx
		_chky=cur_tet.blckpos[i*2]+_dy
		if _chkx<1 or _chkx>grid_w or _chky<1 or _chky>grid_h then
			--printh("returning false from \"cur_tet_isdirectionfree\" because edge boundries")
			return false
		end
		if grid[_chkx][_chky]!=0 then
			--printh("returning false from \"cur_tet_isdirectionfree\" because grid spot below any falling block is full")
			return false
		end
	end
	--printh("returning true from \"cur_tet_isdirectionfree\"")
	return true
end

function cur_tet_lockin()
	printh("locking in!")
	for _i=1,4 do 
		grid[cur_tet.blckpos[(_i*2)-1]][cur_tet.blckpos[_i*2]]=cur_tet.typ
	end
	checkrows()
end

function checkrows()
	printh("called \"checkrows\"")
	local hasspace=false
	for _y=1,grid_h do
	hasspace=false
		for _x=1,grid_w do
		printh("called checking grid: ".._x..", ".._y)
			if grid[_x][_y]==0 then
				hasspace=true
			end
		end
		if hasspace==false then
			add(rowstokill,_y)
			printh("found row with no spaces: ".._y)
		end
	end
	if #rowstokill>0 then
		killrows()
	end
end

rowstokill={}

function killrows()
	printh("called \"killrows\"")
	for _r in all(rowstokill) do
		for _x=1,grid_w do
			grid[_x][_r]=0
		end
	end
	del_tble(rowstokill)
end

function cur_tet_rotate()

end
-->8
--draw

function _draw()
	cls(5)
	draw_grid()
	draw_cur_tet()
	--debug_print_grid()
	debug_print_rowstokill()
end

function draw_grid()
	for _x=1,grid_w do
		for _y=1,grid_h do
			_x1=((_x-1)*grid_cellsize)+grid_ofx
			_y1=((_y-1)*grid_cellsize)+grid_ofy
			rect(_x1,_y1,_x1+grid_cellsize,_y1+grid_cellsize,0)
			if grid[_x][_y]!=0 then
				spr(grid[_x][_y]+16,((_x-1)*grid_cellsize)+grid_ofx+1,((_y-1)*grid_cellsize)+grid_ofy+1)
				--rectfill(_x1+1,_y1+1,_x1+grid_cellsize-2,_y1+grid_cellsize-2)
			end
		end
	end
end

function debug_print_grid()
	for _x=1,grid_w do
		for _y=1,grid_h do
			print(grid[_x][_y],1+(_x-1)*4,1+(_y-1)*6,14)
		end
	end
end

function debug_print_rowstokill()
	--printh("rows to kill: "..#rowstokill)
	for _k,_v in pairs(rowstokill) do
		printh("killrows: ".._v)
	end
end

function draw_cur_tet()
	local _px,_py
	if #cur_tet.blckpos>=2 then
		for _i=1,4 do
			_px=((cur_tet.blckpos[(_i*2)-1]-1)*grid_cellsize)+grid_ofx+1
			_py=((cur_tet.blckpos[_i*2]-1)*grid_cellsize)+grid_ofy+1
			spr(cur_tet.typ,_px,_py)
		end
	end
end


__gfx__
00000000777c0000777a0000777b00009998000066650000aaa90000000000000000000000000000000000000000000000000000000000000000000000000000
000000007cc100007aa900007bb300009882000065510000a9940000000000000000000000000000000000000000000000000000000000000000000000000000
007007007cc100007aa900007bb300009882000065510000a9940000000000000000000000000000000000000000000000000000000000000000000000000000
00077000c1110000a9990000b3330000822200005111000094440000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccc0000aaaa0000bbbb0000888800001111000099990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccc0000aaaa0000bbbb0000888800001111000099990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccc0000aaaa0000bbbb0000888800001111000099990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000cccc0000aaaa0000bbbb0000888800001111000099990000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77760000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76650000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
65550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
