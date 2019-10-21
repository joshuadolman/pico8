pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
--todo list
--=============
--need urgently
--=============
--split grid into
-- --full solution
-- --hints
-- --player editable grid

--generate puzzles?
-- --or just create a selection?
-- -- --make random permutations? (randomise which numbers are in which slots, rotate, flip, slide sections etc)
-- -- --store as images? (save tokens) easily 42, probably maybe more
--[[
flip horizontal,vertical,diagonal bl->tr,diagonal tl->br
shuffle numbers
shuffle sets of 3 columns, row
shuffle within set of 3 columns, rows 
]]

--win screen?
-- --show difficulty and timer

--==============
--nearly done
--==============
--main menu, difficulty selector

--=================
--almost neccessary
--=================
--cleanup code!!!!

--============
--nice to have
--============
--experiment with notes ui,show all at once?


--======================
--we fucking did it bois
--======================
--solver into coroutine


--solver broken on medium
--solver on premade mid sometimes reloads snapshots more than once?? eg iteration70 is that us going back up the callstack? can we print that to check?


-->8
--data
gamemode="intro"
--intro,menu,game

settings={
	helpers_enabled=true
}

logo={
	desired_y=30,
	y= -26,
	drawposy= -26,

	grid_desired_y=18,
	grid_y=130,

	moving=true
}

ribbon={
	h=0,
	desired_h=13,
	
	y=93,
	
	sel=1,

	visible=false,
	moving=false,
	closing=false,
	menu="intro",
		--intro,main,difficulty,info,help
	direction=nil,

	menus={
		intro={},
		main={
			"play",
			"help",
			"info"
		},
		difficulty={
			[1]="easy",
			[2]="medium",
			[3]="hard",
			[4]="insane"
		}
	},

}
--not "settings:togglehelpers" becase the menuitem() callback doesnt work for some reason"
function settings_togglehelpers()
	if settings.helpers_enabled then settings.helpers_enabled=false else settings.helpers_enabled=true end
end

temp={
	coverposy=110,
}

function temp:draw()
	self.coverposy-=1
	rectfill(0,0,127,self.coverposy,7)
end

plyr={
	pos={x=1,y=1},
	cur_note="cell",
	note_i=1
 }
 

function plyr:move()
	if btnp(0) or btnp(1) or btnp(2) or btnp(3) then
		sfx(63)
	end
	
	if btnp(0) then
		if self.pos.x==1 then
			self.pos.x=9
		else
			self.pos.x-=1
		end
	end

	if btnp(1) then
		if self.pos.x==9 then
			self.pos.x=1
		else
			self.pos.x+=1
		end
	end

	if btnp(2) then
		if self.pos.y==1 then
			self.pos.y=9
		else
			self.pos.y-=1
		end
	end

	if btnp(3) then
		if self.pos.y==9 then
			self.pos.y=1
		else
			self.pos.y+=1
		end
	end
end

function plyr:edit()
	--if btnp(4) then solver:solve() end
	if btnp(4) then
		if sudoku.hints[self.pos.x][self.pos.y]==0 then
			if sudoku.board[self.pos.x][self.pos.y]==0 then
				sudoku.board[self.pos.x][self.pos.y]=9
			else
				sudoku.board[self.pos.x][self.pos.y]-=1
			end
		end
	end

	if btnp(5) then
		if sudoku.hints[self.pos.x][self.pos.y]==0 then
			if sudoku.board[self.pos.x][self.pos.y]==9 then
				sudoku.board[self.pos.x][self.pos.y]=0
			else
				sudoku.board[self.pos.x][self.pos.y]+=1
			end
		end
	end
end

function plyr:notesinput()
	if btnp(0,1) then
		if self.note_i==notes.max then
			self.note_i=1
		else
			self.note_i+=1
		end 
	end

	if btnp(1,1) then
		if self.note_i==1 then
			self.note_i=notes.max
		else
			self.note_i-=1
		end 
	end
	
	if btnp(2,1) then
		if self.cur_note=="row" then
			self.cur_note="cell"
		elseif self.cur_note=="col" then
			self.cur_note="row"
		elseif self.cur_note=="box" then
			self.cur_note="col"
		elseif self.cur_note=="cell" then
			self.cur_note="box"
		end
	end

	if btnp(3,1) then
		if self.cur_note=="row" then
			self.cur_note="col"
		elseif self.cur_note=="col" then
			self.cur_note="box"
		elseif self.cur_note=="box" then
			self.cur_note="cell"
		elseif self.cur_note=="cell" then
			self.cur_note="row"
		end
	end

	if btnp(4,1) then
		if plyr.cur_note=="cell" then
			if notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]==0 then
				notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]=9
			else
				notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]-=1
			end
		elseif plyr.cur_note=="row" then
			if 	notes[plyr.cur_note][plyr.pos.y][plyr.note_i]==0 then
				notes[plyr.cur_note][plyr.pos.y][plyr.note_i]=9
			else
				notes[plyr.cur_note][plyr.pos.y][plyr.note_i]-=1
			end
		elseif plyr.cur_note=="col" then
			if notes[plyr.cur_note][plyr.pos.x][plyr.note_i]==0 then
				notes[plyr.cur_note][plyr.pos.x][plyr.note_i]=9
			else
				notes[plyr.cur_note][plyr.pos.x][plyr.note_i]-=1
			end
		elseif plyr.cur_note=="box" then
			if notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]==0 then
				notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]=9
			else
				notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]-=1
			end
		end
	end

	if btnp(5,1) then
		if plyr.cur_note=="cell" then
			if notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]==9 then
				notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]=0
			else
				notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]+=1
			end
		elseif plyr.cur_note=="row" then
			if notes[plyr.cur_note][plyr.pos.y][plyr.note_i]==9 then
				notes[plyr.cur_note][plyr.pos.y][plyr.note_i]=0
			else
				notes[plyr.cur_note][plyr.pos.y][plyr.note_i]+=1
			end
		elseif plyr.cur_note=="col" then
			if notes[plyr.cur_note][plyr.pos.x][plyr.note_i]==9 then
				notes[plyr.cur_note][plyr.pos.x][plyr.note_i]=0
			else
				notes[plyr.cur_note][plyr.pos.x][plyr.note_i]+=1
			end
		elseif plyr.cur_note=="box" then
			if notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]==9 then
				notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]=0
			else
				notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]+=1
			end
		end
	end
end

timer={
	frames=0,
	seconds=0,
	minutes=0
}

function timer:timer()
	self.frames+=1
	if self.frames%60==0 and self.frames>0 then
		self.frames=0
		self.seconds+=1
	end

	if self.seconds%60==0 and self.seconds>0 then
		self.seconds=0
		self.minutes+=1
	end
end

function timer:draw()
	local _m,_s=tostr(self.minutes),tostr(self.seconds)
	if #_m<2 then _m="0".._m end
	if #_s<2 then _s="0".._s end
	_wid=((#_m+#_s+1)*4)
	-- rectfill(126-_wid,1,126,7,5)
	print(_m..":".._s,127-_wid,ui.topbar.y-6,5)
end

function timer:init()
	self.frames=0
	self.seconds=0
	self.minutes=0
end

notes={
	max=5,
	row={},
	col={},
	box={},
	cell={}
}

function notes:init()
	for _y=1,sudoku.dim do
		self.row[_y]={}
		for _i=1,self.max do
			self.row[_y][_i]=0
		end
	end

	for _x=1,sudoku.dim do
		self.col[_x]={}
		for _i=1,self.max do
			self.col[_x][_i]=0
		end
	end

	for _b=1,sudoku.dim do
		self.box[_b]={}
		for _i=1,self.max do
			self.box[_b][_i]=0
		end
	end

	for _x=1,sudoku.dim do
		self.cell[_x]={}
		for _y=1,sudoku.dim do
			self.cell[_x][_y]={}
			for _i=1,self.max do
				self.cell[_x][_y][_i]=0
			end
		end
	end
end

table={
	[0]=nil,
	[1]=24,
	[3]="text",
	[4]=nil,
	[5]=nil
}

-->8
--sudoku
sudoku={
	posx=0,
	posy=25,
	dim=9,
	mutate={}, --contains mutator functions
	board={--in columns
--[[ 	{0,0,5,0,0,6,0,5,0},
	{2,0,7,0,8,0,0,0,0},
	{0,0,4,0,0,0,0,0,0},
	{0,6,0,0,0,5,0,0,0},
	{0,0,8,0,4,0,1,0,0},
	{0,0,0,3,0,0,0,9,0},
	{0,0,0,0,0,0,7,0,0},
	{0,0,0,0,1,0,8,0,4},
	{0,3,0,2,0,0,0,0,0}, ]]
--[[ 	
	{2,8,0,0,5,0,0,6,0},
	{0,0,1,0,0,3,2,0,0},
	{0,4,3,0,7,2,0,1,0},
	{3,0,8,0,0,0,0,2,0},
	{0,6,0,2,0,0,0,5,0},
	{0,2,0,0,0,6,9,0,1},
	{0,0,2,3,6,0,1,8,0},
	{0,0,0,9,2,0,4,0,0},
	{0,3,0,0,1,0,0,9,2}, ]]
--[[ 
		{0,6,1,8,0,0,0,0,7},
		{0,8,9,2,0,5,0,4,0},
		{0,0,0,0,4,0,9,0,3},
		{2,0,0,1,6,0,3,0,0},
		{6,7,0,0,0,0,0,5,1},
		{0,0,4,0,2,3,0,0,8},
		{7,0,5,0,9,0,0,0,0},
		{0,9,0,4,0,2,7,3,0},
		{1,0,0,0,0,8,4,6,0}, ]]
	},
	hints={},
}

valid={
	row="incomplete",
	col="incomplete",
	box="incomplete",
	sol="incomplete"
}

function sudoku:generate()
	for _x=1,self.dim do
		self.board[_x]={}
		for _y=1,self.dim do
			self.board[_x][_y]=ceil(rnd(self.dim))
		end
	end
end

function sudoku:test()
	for _i=1,self.dim do
		self.board[_i][1]=_i
		self.board[9][_i]=10-_i
	end
	self.board[4][2]=1
	self.board[5][2]=2
	self.board[6][2]=3
	self.board[4][3]=7
	self.board[5][3]=8
	self.board[6][3]=9
end

function sudoku:draw()
	for _x=1,self.dim do
		for _y=1,self.dim do
			print_cellvalue(_y,_x,false)
		end
	end
end

function sudoku:load(_d)
	local _puzzleindex=0--flr(rnd(5))-1
	
	for _y=1,self.dim do
		for _x=1,self.dim do
			-- self.board[_x][_y]=sget(((_i-1)*9)+_x-1,7+_y)
			self.hints[_x][_y]=sget((_puzzleindex*10)+-1+_x,7+_y+((_d-1)*10))
			self.board[_x][_y]=sget((_puzzleindex*10)+-1+_x,7+_y+((_d-1)*10))  --sget(((_i-1)*9)+_x-1,7+_y)
		end
	end
end

function sudoku:init()
	for _x=1,sudoku.dim do
		self.hints[_x]={}
		self.board[_x]={}
		for _y=1,sudoku.dim do
			self.hints[_x][_y]=0
			self.board[_x][_y]=0
		end
	end
end

function chk_row(_row)
	local _v="valid"
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if _i!=_j then
				if sudoku.board[_i][_row]==0 or sudoku.board[_j][_row]==0 then
					_v="incomplete"
				else
					if sudoku.board[_i][_row]==sudoku.board[_j][_row] then
						return "invalid"
					end
				end
			end
		end
	end
	return _v
end

function chk_col(_col)
	local _v="valid"
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if _i!=_j then
				if sudoku.board[_col][_i]==0 or sudoku.board[_col][_j]==0 then
					_v="incomplete"
				else
					if sudoku.board[_col][_i]==sudoku.board[_col][_j] then
						return "invalid"
					end
				end
			end
		end
	end
	return _v
end

box_lut={
	[1]={
		x={1,2,3,1,2,3,1,2,3},
		y={1,1,1,2,2,2,3,3,3}
	},
	[2]={
		x={4,5,6,4,5,6,4,5,6},
		y={1,1,1,2,2,2,3,3,3}
	},
	[3]={
		x={7,8,9,7,8,9,7,8,9},
		y={1,1,1,2,2,2,3,3,3}
	},
	[4]={
		x={1,2,3,1,2,3,1,2,3},
		y={4,4,4,5,5,5,6,6,6}
	},
	[5]={
		x={4,5,6,4,5,6,4,5,6},
		y={4,4,4,5,5,5,6,6,6}
	},
	[6]={
		x={7,8,9,7,8,9,7,8,9},
		y={4,4,4,5,5,5,6,6,6}
	},
	[7]={
		x={1,2,3,1,2,3,1,2,3},
		y={7,7,7,8,8,8,9,9,9}
	},
	[8]={
		x={4,5,6,4,5,6,4,5,6},
		y={7,7,7,8,8,8,9,9,9}
	},
	[9]={
		x={7,8,9,7,8,9,7,8,9},
		y={7,7,7,8,8,8,9,9,9}
	},
}


function chk_box(_box)
	local _v="valid"
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if _i!=_j then
				if sudoku.board[box_lut[_box].x[_i]][box_lut[_box].y[_i]]==0 or sudoku.board[box_lut[_box].x[_j]][box_lut[_box].y[_j]]==0 then
				_v="incomplete"
				else
					if sudoku.board[box_lut[_box].x[_i]][box_lut[_box].y[_i]]==sudoku.board[box_lut[_box].x[_j]][box_lut[_box].y[_j]] then
						return "invalid"

					end
				end
			end
		end
	end
	
	return _v
end

function chk_sol()
	local _v="valid"
	
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if sudoku.board[_i][_j]==0 then _v="incomplete" end
		end
	end

	for _i=1,sudoku.dim do
		_r=chk_row(_i)
		_c=chk_col(_i)
		_b=chk_box(_i)
		if _r=="invalid" or _c=="invalid" or _b=="invalid" then _v="invalid" end
	end

	return _v

end

function calc_box(_x,_y)
	local _box
	if _y<=3 then
		if _x<=3 then
			_box=1
		elseif _x>3 and _x<=6 then
			_box=2
		elseif _x>6 and _x<=9 then
			_box=3
		end
	elseif _y>3 and _y<=6 then
		if _x<=3 then
			_box=4
		elseif _x>3 and _x<=6 then
			_box=5
		elseif _x>6 and _x<=9 then
			_box=6
		end
	elseif _y>6 and _y<=9 then
		if _x<=3 then
			_box=7
		elseif _x>3 and _x<=6 then
			_box=8
		elseif _x>6 and _x<=9 then
			_box=9
		end
	end
	return _box
end

-->8
--init

function _init()

	--music(0,1000)
	--sudoku:generate()
	--sudoku:test()
	--sudoku:load(1)
	--solver:solve()
	--solver:solve()
--[[ 	p=solver:get_possibles(2,1)
	if #p>0 then
		for i=1,#p do
			printh(p[i])
		end
	end ]]
end

function init_game(_difficulty)
	gamemode="game"
	menuitem(1,"toggle helpers",settings_togglehelpers)
	menuitem(2,"solve",solvepuzzle)
	notes:init()
	timer:init()
	sudoku:init()
	sudoku:load(_difficulty)
end

-->8
--update

function _update60()
	if gamemode=="intro" then
		update_intro()
	elseif gamemode=="menu" then
	elseif gamemode=="game" then
		update_game()
	end

end

function update_intro()
	if ribbon.moving==false and ribbon.closing==false and ribbon.visible==true then
		ribbon:input()
	end
	ribbon:update()

	if logo.moving then
		if logo.desired_y!=logo.y then logo.y+=1 else ribbon.visible=true ribbon.moving=true logo.moving=false end
		if logo.grid_desired_y!=logo.grid_y then logo.grid_y-=2	end
		logo.drawposy=logo.y
	else
		logo.drawposy=(logo.y+0.5)+sin(time()*0.8)
	end
end

function ribbon:input()
	if ribbon.menu!="intro" then
		if btnp(2) then
			if ribbon.menu=="difficulty" or ribbon.menu=="main" then
				ribbon.sel-=1
			end
			if ribbon.sel<1 then
				if ribbon.menu=="main" then
					ribbon.sel=3
				elseif ribbon.menu=="difficulty" then
					ribbon.sel=4
				end
			end
		end

		if btnp(3) then
			if ribbon.menu=="main" and ribbon.sel==3 then
				ribbon.sel=1
			elseif ribbon.menu=="difficulty" and ribbon.sel==4 then
				ribbon.sel=1
			elseif ribbon.menu=="difficulty" or ribbon.menu=="main" then
				ribbon.sel+=1
			end
		end
	end
	
	if btnp(4) then
		-- 	ribbon.desired_h=40
		-- 	ribbon.moving=true
			if ribbon.menu!="main" and ribbon.menu!="intro" then
				ribbon.direction="backward"
				ribbon.closing=true
			end
		end
		if btnp(5) then
			--init_game()
			--gamemode="game"
			if ribbon.menu!="difficulty" then
				ribbon.direction="forward"
				ribbon.closing=true
			else
				init_game(ribbon.sel)
			end
		end
end

function update_menu()
end

function update_game()

	if solver.coroutine and costatus(solver.coroutine)!='dead' then
	else
		if temp.coverposy<10 then
			timer:timer()
			plyr:move()
			plyr:edit()
			plyr:notesinput()
		end
	end
	valid.row=chk_row(plyr.pos.y)
	valid.col=chk_col(plyr.pos.x)
	valid.box=chk_box(calc_box(plyr.pos.x,plyr.pos.y))
	valid.sol=chk_sol()
	if solver.coroutine and costatus(solver.coroutine)!='dead' then
		-- if timer.seconds%10==0 then
			coresume(solver.coroutine)
		-- end
	else
		-- solver.coroutine=nil
	end
end

function ribbon:update()
	if  ribbon.h!=ribbon.desired_h then
		if ribbon.moving==true then
			if ribbon.h>ribbon.desired_h then
					ribbon.h-=1
			elseif ribbon.h<ribbon.desired_h then
				ribbon.h+=1
			end
		end
	else
		ribbon.moving=false
	end

	if ribbon.closing==true then
		if ribbon.h==-5 then
			if ribbon.direction=="forward" then
				if ribbon.menu=="intro" then
					ribbon.menu="main"
					ribbon.desired_h=29
				elseif ribbon.menu=="main" then
					if ribbon.sel==1 then
						ribbon.menu="difficulty"
						ribbon.desired_h=36
					elseif ribbon.sel==2 then
						ribbon.menu="help"
						ribbon.desired_h=54
					elseif ribbon.sel==3 then
						ribbon.menu="info"
						ribbon.desired_h=34
					end
				elseif ribbon.menu=="info" or ribbon.menu=="help" then
					ribbon.menu="main"
					ribbon.desired_h=29
				end
			elseif ribbon.direction=="backward" then
				if ribbon.menu=="main" then
					ribbon.menu="intro"
					ribbon.desired_h=13
				elseif ribbon.menu=="difficulty" or ribbon.menu=="info" or ribbon.menu=="help" then
					ribbon.menu="main"
					ribbon.desired_h=29
				end
			end
			ribbon.closing=false
			ribbon.moving=true
		else
			ribbon.h-=1
		end
	end
end

-->8
--draw

function _draw()
	if gamemode=="intro" then
		draw_intro()
	elseif gamemode=="menu" then
	elseif gamemode=="game" then
		draw_game()
	end
end


function draw_intro()
	cls(7)

	draw_grid(3,6,logo.grid_y)
	logo:draw(logo.drawposy)
	if ribbon.visible==true then ribbon:draw() end

	-- print(ribbon.menu,1,1,0)
	-- print(ribbon.sel,1,7,0)
end

function ribbon:draw()
	clip(0,self.y-(self.h/2),128,self.h+1)
	rectfill(0,self.y-(self.h/2),127,self.y+(self.h/2),6)
	-- cprint_rs("press ❎ to start",94.5+sin(time()*0.67),7,5,-2)
	if self.menu=="intro" then
		cprint_rs("press ❎ to start",90,7,5,-2)
	elseif self.menu=="main" then
		print("play",109,83,0)
		print("help",109,91,0)
		print("info",109,99,0)
		
		rectfill(0,82+((self.sel-1)*8),127,81+((self.sel)*8)-1,8)
		print(self.menus.main[self.sel],109,83+((self.sel-1)*8),7)
	elseif self.menu=="difficulty" then
		print("easy",4,79,0)
		print("medium",4,87,0)
		print("hard",4,95,0)
		print("insane",4,103,0)

		rectfill(0,78+((self.sel-1)*8),127,77+((self.sel)*8)-1,8)
		print(self.menus.difficulty[self.sel],4,79+((self.sel-1)*8),7)
	elseif self.menu=="info" then
		cprint_rs("made by joshuadolman",80,7,5)
		cprint_rs("with support from opieop clan",87,7,5)
		cprint_rs("special thanks to #nerd-talk",94,7,5)
		cprint_rs("extra special thanks to smt",101,7,5)
	elseif self.menu=="help" then
		print("main controls (p1):",1,67,5)
		print("decrease cell number",34,73,7)
		print("🅾️",1,73,8)
		print("increase cell number",34,79,7)
		print("❎",1,79,8)		
		print("change current cell",34,85,7)
		print("⬆️➡️⬇️⬅️",1,85,8)

		print("note controls (p2):",1,91,5)
		print("decrease note number",34,97,7)
		print("🅾️",1,97,8)
		print("increase note number",34,103,7)
		print("❎",1,103,8)		
		print("change note zone",34,109,7)
		print("⬆️⬇️",1,109,8)
		print("change current note",34,115,7)
		print("⬅️➡️",1,115,8)
		--print("
	end
	clip()
	if self.menu!="intro" then
		print("continue❎",88,122,6)
		if self.menu!="main" then
			print("🅾️back",1,122,6)
		end
	end
end

function logo:draw(_y)
	local _x=38
	palt(0,false)
	palt(11,true)
	sspr(0,56,60,1,_x-4,_y-2)
	sspr(0,56,60,1,_x-4,_y+9)
	sspr(0,48,52,8,_x,_y)
end

function draw_game()
	cls(7)
	
	rect(sudoku.posx+26,sudoku.posy+1,103+sudoku.posx,77+sudoku.posy,6)
	draw_grid(8,0,sudoku.posy)
	
	plyr:drawlines()
	sudoku:draw()

	plyr:draw()
	if temp.coverposy>5 then
		temp:draw()
	end

	if solver.coroutine and costatus(solver.coroutine)!='dead' then
		if solver.message.y<solver.message.desired_y then solver.message.y+=2 end
		print("solving",51,solver.message.y+1,6)
		print("solving",50,solver.message.y,5)
	end
	if solver.coroutine then
		if costatus(solver.coroutine)=='dead' then
			if solver.completion==nil then	
			elseif solver.completion==true then
			elseif solver.completion==false then
				cprint_rs("could not find solution",solver.message.desired_y,5,6)
			end
		end
	end
	if temp.coverposy<10 then
		draw_ui()
	end
end

function draw_grid(_gridsize,_color,_posy)
	local _offx,_offy=0,0
	local _dim=_gridsize*9+4

	rectfill(64-(_dim/2)+sudoku.posx,_posy,64-(_dim/2)+_dim+sudoku.posx,_dim+_posy,7)
	rect(64-(_dim/2)+sudoku.posx,_posy,64-(_dim/2)+_dim+sudoku.posx,_dim+_posy,_color)
	for _x=1,sudoku.dim do
		for _y=1,sudoku.dim do
			_offx=flr((_x-1)/3)+1
			_offy=flr((_y-1)/3)+1
			rect(((_x-1)*_gridsize)+sudoku.posx+_offx+64-(_dim/2),((_y-1)*_gridsize)+_posy+_offy,(_x*_gridsize)+sudoku.posx+_offx+64-(_dim/2),(_y*_gridsize)+_posy+_offy,_color)
		end
	end
end
ui={
	topbar={
		desired_y=8,
		y=-1
	},
	botbar={
		desired_y=119,
		y=128
	}
}
function draw_ui()
	--topbar
	if ui.topbar.y!=ui.topbar.desired_y then
		ui.topbar.y+=1
	end
	rectfill(0,-1,127,ui.topbar.y,6)
	draw_positions(1,ui.topbar.y-7)
	timer:draw()
	-- line(0,9,127,9,5)
	--botbar
	if ui.botbar.y!=ui.botbar.desired_y then
		ui.botbar.y-=1
	end
	-- line(0,118,127,118,5)
	rectfill(0,ui.botbar.y,127,128,6)
	draw_helpers(1,ui.botbar.y+1)
	notes:draw(121,ui.botbar.y+1)


	--print("row:",60,121,5)
end

function notes:draw(_x,_y)
	for _g=self.max,1,-1 do
		rectfill(_x-((8*(_g-1))+1),_y,(5+_x)-(8*(_g-1)),_y+6,5)
	end
	local _str="notes ("..plyr.cur_note.."):"
	--local _str="x:"
	print(_str,_x-(8*(self.max-1))-(#_str*4)-1,_y+1,5)
	for _i=1,self.max do
		if plyr.cur_note=="cell" then
			if notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][_i]!=0 then print(notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][_i],_x+1-(8*(_i-1)),_y+1,6) end
		elseif plyr.cur_note=="row" then
			if notes[plyr.cur_note][plyr.pos.y][_i]!=0 then print(notes[plyr.cur_note][plyr.pos.y][_i],_x+1-(8*(_i-1)),_y+1,6) end
		elseif plyr.cur_note=="col" then
			if notes[plyr.cur_note][plyr.pos.x][_i]!=0 then print(notes[plyr.cur_note][plyr.pos.x][_i],_x+1-(8*(_i-1)),_y+1,6) end
		elseif plyr.cur_note=="box" then
			if notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][_i]!=0 then print(notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][_i],_x+1-(8*(_i-1)),_y+1,6) end
		end
	end
	
	rectfill(_x-((8*(plyr.note_i-1))+1),_y,(5+_x)-(8*(plyr.note_i-1)),_y+6,8)

	if plyr.cur_note=="cell" then
		if notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i]!=0 then print(notes[plyr.cur_note][plyr.pos.x][plyr.pos.y][plyr.note_i],_x+1-(8*(plyr.note_i-1)),_y+1,7) end
	elseif plyr.cur_note=="row" then
		if notes[plyr.cur_note][plyr.pos.y][plyr.note_i]!=0 then print(notes[plyr.cur_note][plyr.pos.y][plyr.note_i],_x+1-(8*(plyr.note_i-1)),_y+1,7) end
	elseif plyr.cur_note=="col" then
		if notes[plyr.cur_note][plyr.pos.x][plyr.note_i]!=0 then print(notes[plyr.cur_note][plyr.pos.x][plyr.note_i],_x+1-(8*(plyr.note_i-1)),_y+1,7) end
	elseif plyr.cur_note=="box" then
		if notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i]!=0 then print(notes[plyr.cur_note][calc_box(plyr.pos.x,plyr.pos.y)][plyr.note_i],_x+1-(8*(plyr.note_i-1)),_y+1,7) end
	end
end

function draw_positions(_x,_y)
	_str="x:"..plyr.pos.x.." y:"..plyr.pos.y.." b:"..calc_box(plyr.pos.x,plyr.pos.y)
	-- rectfill(_x,_y,(#_str*4)+2,_y+6,5)
	print(_str,_x+1,_y+1,5)
end


function draw_helpers(_x,_y)
	if settings.helpers_enabled==false then return end
	local _c,_grey,_red,_green=7,7,8,11
	if valid.row=="valid" then
		_c=_green
	elseif valid.row=="incomplete" then
		_c=_grey
	elseif valid.row=="invalid" then
		_c=_red
	end
	pal(6,_c)
	spr(1,_x,_y)
	pal()

	if valid.col=="valid" then
		_c=_green
	elseif valid.col=="incomplete" then
		_c=_grey
	elseif valid.col=="invalid" then
		_c=_red
	end
	pal(6,_c)
	spr(2,_x+8,_y)
	pal()

	if valid.box=="valid" then
		_c=_green
	elseif valid.box=="incomplete" then
		_c=_grey
	elseif valid.box=="invalid" then
		_c=_red
	end
	pal(6,_c)
	spr(3,_x+16,_y)
	pal()

	if valid.sol=="valid" then
		_c=_green
	elseif valid.sol=="incomplete" then
		_c=_grey
	elseif valid.sol=="invalid" then
		_c=_red
	end
	pal(6,_c)
	spr(4,_x+24,_y)
	pal()

end

function plyr:draw()
	local _offx,_offy
	_offx=flr((self.pos.x-1)/3)
	_offy=flr((self.pos.y-1)/3)
--[[	for _lx=1,sudoku.dim do
		rectfill(((_lx-1)*8)+sudoku.posx+flr((_lx-1)/3)+2,((self.pos.y-1)*8)+sudoku.posy+_offy+2,(_lx*8)+sudoku.posx+flr((_lx-1)/3),(self.pos.y*8)+sudoku.posy+_offy,6)
	end]]
	rectfill(((self.pos.x-1)*8)+sudoku.posx+_offx+28,((self.pos.y-1)*8)+sudoku.posy+_offy+2,(self.pos.x*8)+sudoku.posx+_offx+26,(self.pos.y*8)+sudoku.posy+_offy,8)
	--print(sudoku.board[self.pos.x][self.pos.y],((self.pos.x-1)*8)+sudoku.posx+_offx+4,((self.pos.y-1)*8)+sudoku.posy+_offy+3,7)
	print_cellvalue(self.pos.x,self.pos.y,true)
end

function plyr:drawlines()
	local _c=6
	for _lx=1,sudoku.dim do
		rectfill(((_lx-1)*8)+sudoku.posx+flr((_lx-1)/3)+28,((self.pos.y-1)*8)+sudoku.posy+flr((self.pos.y-1)/3)+2,(_lx*8)+sudoku.posx+flr((_lx-1)/3)+26,(self.pos.y*8)+sudoku.posy+flr((self.pos.y-1)/3),_c)
	end

	for _ly=1,sudoku.dim do
		rectfill(((self.pos.x-1)*8)+sudoku.posx+flr((self.pos.x-1)/3)+28,((_ly-1)*8)+sudoku.posy+flr((_ly-1)/3)+2,(self.pos.x*8)+sudoku.posx+flr((self.pos.x-1)/3)+26,(_ly*8)+sudoku.posy+flr((_ly-1)/3),_c)
	end
end



-->8
--draw_helpers

function cprint_rs(text,_y,_tc,_sc,_offx)
	_offx=_offx or 0
	print(text,65-((#text*4)/2)+_offx,_y,_sc)
	print(text,65-((#text*4)/2)+_offx,_y+1,_sc)
	print(text,64-((#text*4)/2)+_offx,_y+1,_sc)
	print(text,64-((#text*4)/2)+_offx,_y,_tc)
end

function print_cellvalue(_x,_y,_h)
	local _offx,_offy,_c=0,0,0

	_offx=flr((_x-1)/3)
	_offy=flr((_y-1)/3)
	if sudoku.hints[_x][_y]!=0 then
		-- if _h then _c=5 else _c=0 end
		print(sudoku.hints[_x][_y],((_x-1)*8)+sudoku.posx+_offx+30,((_y-1)*8)+sudoku.posy+_offy+3,_c)
	elseif sudoku.board[_x][_y]!=0 and sudoku.hints[_x][_y]==0 then
		if _h then _c=7 else _c=5 end
		print(sudoku.board[_x][_y],((_x-1)*8)+sudoku.posx+_offx+30,((_y-1)*8)+sudoku.posy+_offy+3,_c)
	end
end

-->8
--solver

solver={
	message={
		y=4,
		desired_y=18
	},
	coroutine=nil,
	iterations=0,
	completion=nil
}

function solvepuzzle()
	solver.coroutine=cocreate(solver.solve)
	-- solver.solve()
end

--debug function : solver
function solver:checkfornil()
	local s=""
	for _i=1,sudoku.dim do
		s=s.."\n"
		for _j=1,sudoku.dim do
			s=s.." "..tostr(sudoku.board[_i][_j])
		end
	end
	
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if sudoku.board[_i][_j]==nil then
				printh("cell at (".._i..",".._j..") is nil!")
				printh(s)
			end
		end
	end
end

function solver:solve()
	solver.iterations+=1
	-- debug output : solver
	printh("================================")
	printh("solve iterations: "..solver.iterations)
	printh("================================")
	solver:checkfornil()

	_obvresult=solver:fillobvious()
	if _obvresult==false then return false end
	if solver:iscomplete() then return true end
	if solver.iterations>3000 then solver.completion=false return false end
	yield()
	
	local _x,_y
	for _i=1,sudoku.dim do
		for _j=1,sudoku.dim do
			if sudoku.board[_i][_j]==0 then
				_x,_y=_i,_j
				plyr.pos.x=_x
				plyr.pos.y=_y
				break
			end
		end
	end

	local _poss=solver:get_possibles(_x,_y)
	if #_poss>0 then
		for _n=1,#_poss do
			local _snapshot=solver:snapgrid()
			--debug output : solver
			printh("attempting "..tostr(_poss[_n]).." in cell (".._x..",".._y..")")
			sudoku.board[_x][_y]=_poss[_n]
			_result=solver:solve()
			if _result then
				solver.completion=true
				return true
			else
				solver:snapreload(_snapshot)
			end
		end
	end
	solver.completion=false
	return false
end

function solver:snapreload(_snapshot)
	--debug output : solver
	printh("reloading snapshot!")
	local ss,sg,sp="snap","board","board post reload"
	for _x=1,sudoku.dim do
		ss=ss.."\n"
		sg=sg.."\n"
		for _y=1,sudoku.dim do
		ss=ss.." "..tostr(_snapshot[_x][_y])
		sg=sg.." "..tostr(sudoku.board[_x][_y])
		end
	end
	printh(ss)
	printh(sg)


	for _x=1,sudoku.dim do
		for _y=1,sudoku.dim do
			sudoku.board[_x][_y]=_snapshot[_x][_y]
		end
	end

	--debug output : solver
	for _x=1,sudoku.dim do
		sp=sp.."\n"
		for _y=1,sudoku.dim do
		sp=sp.." "..tostr(sudoku.board[_x][_y])
		end
	end
	printh(sp)
	printh("snapshot reloaded!")
end

function solver:snapgrid()
	local _snapshot={}
	for _x=1,sudoku.dim do
		_snapshot[_x]={}
		for _y=1,sudoku.dim do
			_snapshot[_x][_y]=sudoku.board[_x][_y]
		end
	end

	return _snapshot
end

function solver:fillobvious()
	--debug output : solver
	printh("attempting to fill obvious...")
	while true do
		_changemade=false
		for _i=1,sudoku.dim do
			for _j=1,sudoku.dim do
				if sudoku.board[_i][_j]==0 then
					_poss=solver:get_possibles(_i,_j)
					plyr.pos.x=_i
					plyr.pos.y=_j
					if #_poss==0 then
						solver.completion=false
						return false
					else
						if #_poss==1 then
							sudoku.board[_i][_j]=_poss[1]
							_changemade=true
						end
					end
				end
			end
		end
		if _changemade==false then return true end
	end
end

function solver:get_possibles(_i,_j)
	local _possibles={1,2,3,4,5,6,7,8,9}
	-- printh("getting possibles for: (".._i..",".._j..")")
	for _x=1,sudoku.dim do
		del(_possibles,sudoku.board[_x][_j])
	end

	for _y=1,9 do
		del(_possibles,sudoku.board[_i][_y])
	end

	_istart=flr((_i-1)/3) * 3
	_jstart=flr((_j-1)/3) * 3

	for _x=1,3 do
		for _y=1,3 do
			--printh(_istart.._x.." ".._jstart.._y)
		 del(_possibles,sudoku.board[_istart+_x][_jstart+_y])
		end
	end
	--debug output : solver
	local s=""
	for n=1,#_possibles do
		s=s.." ".._possibles[n]
	end
	printh("possibles for (".._i..",".._j.."):"..s)
	
	return _possibles
end

function solver:iscomplete()
	for _x=1,sudoku.dim do
		for _y=1,sudoku.dim do
			if sudoku.board[_x][_y]==0 then
				return false
			end
		end
	end
--	debug output : solver
	-- printh("== == == == == == == == ==  ==")
	printh("==  puzzle is complete in "..self.iterations.." iterations ==")
	-- printh("== == == == == == == == ==")
	return true
end


__gfx__
00000000555555505555555055555550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505556555055555550565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700555555505556555055666550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000566666505556555055666550565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000555555505556555055666550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700555555505556555055555550565656500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000555555505555555055555550555555500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f000000000000000000
000260701feeeeeeeeef070090002f008030000feeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee00000000f000000000f000000000000000000
680070090feeeeeeeeef004806030f596200008feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeee00000000f000000000f000000000000000000
190004500feeeeeeeeef500200009f010007450feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
820100040feeeeeeeeef092000068f000900710feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
004602900feeeeeeeeef100000004f010000080feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
050003028feeeeeeeeef340000290f029005000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
009300074feeeeeeeeef400008005f052400030feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
040050036feeeeeeeeef050104700f100008945feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
703018000feeeeeeeeef600070020f000050200feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefe00000000f000000000f000000000f00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
002700508feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
000950613feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
000108000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
260000070feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
003000400feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
040000021feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
000305000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
139024000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
605009200feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeeeeeeeeeeeeeeeeeeeeeefeeeeeeeeef00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000
008009410f810009000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef000000000f000000000f00000000000000000000000000000feeeeeeeeef00000000
200001003f274080009feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef000000000f000000000f00000000000000000000000000000feeeeeeeeef00000000
001080906f950007030feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef000000000f000000000f00000000000000000000000000000feeeeeeeeef00000000
005720000f000001000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000f00000000000000000000000000000feeeeeeeeef00000000
080000020f405090102feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
000094100f000200000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
309050700f060800073feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
500900004f100070658feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
016300200f000400091feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000feeeeeeeeef00000000
001060750feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
200000000feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
005170204feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
600040005feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
048000920feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
900020001feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
106083500feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
000000008feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
024050600feeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeefeeeeeeeeef0000000000000000000000000000000000000000000000000feeeeeeeeef00000000
fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00000000000000000000fffffffffffffffffffffffffffffffff
0000000000000000000000000bb000000000000000b00000b000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0888880888880888880888880bb066660066666060006060b060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0822280228220822220822280bb065556065556060065060b060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0888880008000800000800080bb060006060006066650060b060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0822220008000800000800080bb0600060600060655600600060bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
0800000888880888880888880bb0666650666660600560666660bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
020bbb0222220222220222220bb0555500555550500050555550bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000bbb0000000000000000000bb000000000000000b000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
655000000000000000000000000000000000000000000000000000000556bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
__sfx__
011000200705007050070500705007050070500705007051090510905009050090510c0510c0500c0500c0500c0500c0500c0500c0500c0500c0500c0500c0510505105050050500505005050050500505005051
0110000009040090500905009051070510705007050070510c0510c0500c0500c0510505105050050500505107051070500705007050070500705007050070510505105050050500505109051090500905009051
0110000021150000000000000000211501f15021150211501815018150181501815000000000001d1501d1501f1501f1501f1501f150211501f1501d1501d150241502415024150241500000000000000001d150
011000001575615756157561573613756137561375613736187561875618756187361175611756117561173613756137561375613756137561375613756137361175611756117561173615756157561575615736
011000000c654000000000000000156061560617654176061565400000000000000024550295502b5502d5502b5502d550295500000000000295502d5502b5502455000000000000000000000185501d5501f550
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001835000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011000001d45000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010c00001f35000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
010800002155000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200001e66000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000300002f67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100003a67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000205001100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41024344
01 00024344
00 01024344
02 00030204

