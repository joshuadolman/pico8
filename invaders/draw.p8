pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
function _draw()
	cls()
	if game.mode=="game" then draw_game()
	elseif game.mode=="lose" then draw_lose()
	elseif game.mode=="menu" then draw_menu()
	elseif game.mode=="playersdead" then draw_game()
	
	end
	if game.do_transition then screenfade(game.transition) end
end

function draw_game()
	debug_beforedraw=stat(1)
	screenshake=min(0.13,screenshake)
	screen_shake()
	draw_atmosphere(game.level)
	draw_stars()
	
	
	draw_objects()
	draw_powerups()
	
	--draw_collisions()
	--centerprint_outline(levels[game.level].name,20,levels[game.level].atmosphere_color,7)

	
	draw_mothership()

	if game.debug_enabled then
		debug_data="fps:"..tostr(stat(7)).."/"..tostr(stat(8)).." cpu: "..tostr(stat(1)).." syscpu: "..tostr(stat(2)).." mem: "..stat(0).." plyr:"..#players.." bnkr:"..#bunkers.." part:"..#particles.."/".._maximum_particles.." bllt:"..#bullets.." star:"..#stars.." pwr:"..#powerups.." enmy:"..#enemies.." flt:"..#floaters
	--	debug_data="upd: "..((debug_afterupdate-debug_beforeupdate)*100).." drw: "..((debug_afteredraw-debug_beforedraw)*100)
	else
		debug_data=nil
	end
	
	draw_particles()
	pal()
	draw_bullets()
	camera(0,0)
	draw_floaters()
	draw_leveltitle(game.level_title)
	draw_ui()
	--debug_data=((sin(time()/4))+1)/2
	--debug_data=tostr(players[1].acl).."  "..tostr(plyr_data.acl[players[1].acl])
		--debug_data=tostr(game.enemy_movedown_count).."/"..tostr(game.enemy_movedown_amount)
	debug_afteredraw=stat(1)
	draw_dbg()
	-- palt(0,false)
	-- palt(14,true)
	-- spr(67,15,15)
	cpu_last_frame=stat(1)
	_maximum_particles=flr(lerp(30,0,cpu_last_frame))
	if cpu_last_frame!=nil then
		if cpu_last_frame>1 then printh("!!!!") end
	end
end

function draw_menu()
	draw_stars()
	draw_atmosphere(game.level)
	-- centerprint_background("created by",116-0.4+sin(time()),5,0)
	-- centerprint_background("joshuadolman",122-0.4+sin(time()),6,0)
	centerprint_background("created by",116,5,0)
	centerprint_background("joshuadolman",122,6,0)
	palt(0,false)
	palt(14,true)
	
	
	centerprint_background(" 1 player",75,12,0)
	centerprint_background(" 2 player",83,8,0)
	local arrow_y
	if menu.selection==1 then arrow_y=75 else arrow_y=83 end
	sspr(93,19,3,5,44.5+sin(time()/0.5),arrow_y)

	centerprint_background("marathon mode",96,6,0)
	rectfill(35,102,91,108,0)
	if game.numstagesperlevel==8 then
		print("➡️",84,103,7,0)
		print("⬅️",36,103,5,0)
		centerprint("disabled",103,8,0)
	else
		print("➡️",84,103,5,0)
		print("⬅️",36,103,7,0)
		centerprint("enabled",103,11,0)
	end
	--⬅️
	palt(7,true)
	if menu.logo_final_y-menu.logo_y<8 then
		sspr(90,0,38,20,63-36,menu.logo_y+0.5+sin(time()+2.3)*2,76,40)
	else
		sspr(90,0,38,20,63-36,menu.logo_y,76,40)
	end
	
	pal()
end


function draw_lose()
	
	draw_stars()
	draw_atmosphere(game.level)
	--centerprint("you lose",62,8)
	for i=#colors.trail,1,-1 do
		palt(14,true)
		pal(2,colors.trail[i])
		pal(8,colors.trail[i])
		sspr(97,32,31,7,19,22+(sin((time()-i/10)/1.4)*4),93,21)
		pal()
	end

	palt(14,true)
	ypos=22+(sin(time()/1.4)*4)
	sspr(97,32,31,7,19,ypos,93,21)	

	centerprint_background("try again?",75+(sin(time()/0.4)*1),8+flr(time()*10)%2,0)
	
end

function draw_objects()
	for i=1,#players do
		if players[i].dead==false then
			if players[i].hp==2 then
			draw_object_outline(players[i],7)
			else
			draw_object_outline(players[i],0)
			end
			
			draw_object(players[i])
		end
	end
	for i=1,#bunkers do
		draw_object_outline(bunkers[i],0)
		draw_object(bunkers[i])
	end
	local e
	for i=1,#enemies do
		e=enemies[i]
		
		if e.y>124-(levels[game.level].atmosphere_height) or e.y>80 then
			draw_object_outline(e,0) 
		elseif e.y>116-(levels[game.level].atmosphere_height) then
		--	rectfill(e.x-e.ofx-1,e.y-e.ofy-1,e.x-e.ofx+8,e.y-e.ofy+8,0)
		end
		-- if e.y>140-(levels[game.level].atmosphere_height) or e.y>86 then
		-- 	draw_object_outline(e,0) 
		-- else
		-- 	rectfill(e.x-e.ofx,e.y-e.ofy,e.x-e.ofx+e.w,e.y-e.ofy+e.h+1,0)
		-- end
		-- draw_object_outline(enemies[i],0)
		draw_object(e)
	end
end

function draw_particles()
	local p
	for i=1,#particles do
		p=particles[i]
		perc=p.life/p.maxlife
		ind=flr((1-perc)*#colors.particles)+1
		col=colors.particles[ind]
		--debug_data="ind "..ind.."  col "..col
		circfill(p.x,p.y,p.size,col)
	end
end

function draw_powerups()
	palt(0,false)
	palt(14,true)
	for i=1,#powerups do
		spr(pwr_data.spr[powerups[i].t],powerups[i].x,powerups[i].y)
	end
	palt()
end

function draw_floaters()
	local color,x=7,0
	--if flr(timer.frames/2)%9==0 then color=8 end
	if flr(timer.frames/3)%5==0 then color=9 end
	if flr(timer.frames/3)%4==0 then color=10 end
	local f
	for i=1,#floaters do
		f=floaters[i]
		if flr(timer.frames/3)%5~=0 and flr(timer.frames/3)%4~=0 then
			color=f.color
		end
		if f.x+(#f.text*4)/2>127 then x=129-(#f.text*4) else x=f.x-(#f.text*4)/2 end
		print_background(f.text,max(1,flr(x)),flr(f.y),color,0)
	end
end

function draw_mothership()
	if mothership.dead==false then
	
	
		if mothership.hit then
			pal(2,7)
			pal(5,7)
			pal(6,7)
			pal(8,7)
			pal(9,7)
			pal(10,7)
		end
		palt(14,true)
		palt(0,false)
			
		sspr(109,20,19,12,mothership.x-mothership.ofx,mothership.y-mothership.ofy)
		pal()
	end
	
end

function draw_leveltitle(lt)
	if lt.hangtimer==lt.hangtimerstart then
		if lt.y<lt.endy then 
			lt.y+=lt.spd
		elseif lt.y==lt.endy then
			lt.hangtimer-=1
		else lt.y=lt.endy end
	elseif lt.hangtimer==0 then
		if lt.y>lt.starty then 
			lt.y-=lt.spd
		else lt.y=lt.starty end
	else
		lt.hangtimer-=1
	end

	centerprint_background(levels[game.level].name.." : stage "..game.stage,lt.y,levels[game.level].atmosphere_color,0)
end

function draw_ui()
	if timer.frames==0 and timer.seconds%4==0 then game.ui_stat_display+=1 end
	if game.ui_stat_display>7 then game.ui_stat_display=1 end

	local text,col=pwr_data.statname[game.ui_stat_display],7
	if #players==1 then
		rectfill(-2,-2,129,6,12)
		if players[1].dead then col=0 else col=7 end
		print(text..": lv "..players[1][pwr_data.stat[game.ui_stat_display]].."/"..#plyr_data[pwr_data.stat[game.ui_stat_display]],1,1,col)
		print(players[1].lives,121-#tostr(players[1].lives)*4,1,col)
		print("♥",121,1,col)
	elseif #players==2 then
		if text=="shot inertia" then text="inertia"
		elseif text=="acceleration" then text="accel"
		elseif text=="fire rate" then text="rate"
		elseif text=="firepower" then text="power"
		elseif text=="bullet velocity" then text="shotspd"
		elseif text=="max speed" then text="speed"
		elseif text=="accuracy" then text="accuracy"
		end
		rectfill(-2,-2,63,6,12)
		rectfill(64,-2,129,6,8)
		if players[1].dead then col=0 else col=7 end
		print(players[1][pwr_data.stat[game.ui_stat_display]].."/"..#plyr_data[pwr_data.stat[game.ui_stat_display]].." "..text,1,1,col)
		print(players[1].lives,57-#tostr(players[1].lives)*4,1,col)
		print("♥",57,1,col)
		
		if players[2].dead then col=0 else col=7 end
		print(players[2].lives,72,1,col)
		print("♥",64,1,col)
		text=text.." "..players[2][pwr_data.stat[game.ui_stat_display]].."/"..#plyr_data[pwr_data.stat[game.ui_stat_display]]
		print(text,128-#text*4,1,col)
	else
	end
end

function draw_collisions()
	for i=1,#players do
		draw_collision(players[i])
	end
	for i=1,#bunkers do
		draw_collision(bunkers[i])
	end
	for i=1,#bullets do
		pset(bullets[i].x,bullets[i].y,14)
	end
	for i=1,#enemies do
		draw_collision(enemies[i])
	end
	for i=1,#powerups do
		draw_collision(powerups[i])
	end
	draw_collision(mothership)
end

function draw_collision(obj)
	local color=14
	if obj.colliding then color=15 end
	local ax0,ax1,ay0,ay1 = get_collision_points(obj)	
	rect(ax0,ay0,ax1,ay1,color)
end

function draw_bullets()
	for i=1,#bullets do
		circfill(bullets[i].x,bullets[i].y,2,0)
		circfill(bullets[i].x,bullets[i].y,1,bullets[i].color)
	end
end

function draw_object(obj)
	palt(0,false)
	palt(14,true)
	if obj.hit==true then
		if timer.frames%5==0 then
			pal(6,8)
			pal(7,8)
		else
			pal(6,7)
			pal(7,7)
		end
	else
		pal(6,colors[obj.color_index][2])
		pal(7,colors[obj.color_index][1])
	end
	spr(obj.spr,obj.x-obj.ofx,obj.y-obj.ofy)
	pal()
end

function draw_object_outline(obj,outline_color)
	palt(0,false)
	palt(14,true)
	pal(6,outline_color)
	pal(7,outline_color)

	spr(obj.spr,obj.x-obj.ofx-1,obj.y-obj.ofy  )
	spr(obj.spr,obj.x-obj.ofx+1,obj.y-obj.ofy  )
	spr(obj.spr,obj.x-obj.ofx  ,obj.y-obj.ofy-1)
	spr(obj.spr,obj.x-obj.ofx  ,obj.y-obj.ofy+1)
	spr(obj.spr,obj.x-obj.ofx-1,obj.y-obj.ofy-1)
	spr(obj.spr,obj.x-obj.ofx+1,obj.y-obj.ofy+1)
	spr(obj.spr,obj.x-obj.ofx-1,obj.y-obj.ofy+1)
	spr(obj.spr,obj.x-obj.ofx+1,obj.y-obj.ofy-1)

end

function draw_atmosphere(level_index)
	local atmosphere_height,atmosphere_color=levels[level_index].atmosphere_height,levels[level_index].atmosphere_color
	local atmostphere_chunk=atmosphere_height/20
	
	rectfill(0,127-atmostphere_chunk,127,127,atmosphere_color)
	fillp(0b0000101000000101)
	rectfill(0,127-atmostphere_chunk*5,127,127-atmostphere_chunk,atmosphere_color)
	fillp(0b0101101001011010)
	rectfill(0,127-atmostphere_chunk*11,127,127-atmostphere_chunk*5,atmosphere_color)
	fillp(0b1111101011110101)
	rectfill(0,127-atmosphere_height,127,127-atmostphere_chunk*11,atmosphere_color)
	fillp()
end

function draw_stars()
	for i=1,#stars do
		pset(stars[i].x,stars[i].y,stars[i].c)
	end
end
-->8
--util

function centerprint(text,y,color)
	print(text,64-(#text*4)/2,y,color)
end

function centerprint_background(text,y,text_color,background_color)
	local x=64-(#text*4)/2
	rectfill(x-1,y-1,x+#text*4-1,y+5,background_color)

	print(text,x,y,text_color)
end

function print_background(text,x,y,text_color,background_color)
	rectfill(x-1,y-1,x+#text*4-2,y+6,background_color)
	print(text,x,y,text_color)
end

function centerprint_outline(text,y,color,outline_color)
	local x=64-(#text*4)/2

	print_outline(text,x,y,color,outline_color)
end

function print_outline(text,_x,y,color,outline_color)
	print(text,_x-1,y  ,outline_color)
	print(text,_x+1,y  ,outline_color)
	print(text,_x  ,y-1,outline_color)
	print(text,_x  ,y+1,outline_color)
	print(text,_x-1,y-1,outline_color)
	print(text,_x+1,y+1,outline_color)
	print(text,_x-1,y+1,outline_color)
	print(text,_x+1,y-1,outline_color)
	
	print(text,_x/2,y,color)
end
