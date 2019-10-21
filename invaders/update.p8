pico-8 cartridge // http://www.pico-8.com
version 18
__lua__

function _update60()
		
	update_timer()

	if game.mode=="game" then
		update_game()
	elseif game.mode=="menu" then
		update_menu()
	elseif game.mode=="playersdead" then
		update_playersdead()
	elseif game.mode=="lose" then
		update_lose()
	end
end

function update_game()
	if cpu_last_frame!=nil then
		if cpu_last_frame<0.75 then
			update_stars()
		end
	end
	if check_stage_loss() then music(-1) sfx(56) reset_stage() end

	if game.enemy_movedown_count>=game.enemy_movedown_amount then
		update_enemies()
		for i=1,#players do
			if players[i].dead==false then
				movement_bob(players[i])
				update_plyr_movement(players[i],i-1)
				update_plyr_shooting(players[i],i-1)
				update_hitflash(players[i])
			end
		end
	else
		for i=1,#players do
			if players[i].dead==false then
				update_plyr_movement(players[i],i-1)
				movement_bob(players[i])
			end
		end
		for i=1,#enemies do
			movement_bob(enemies[i])
			animate_enemy(enemies[i])
		end
		movedown_enemies()
	end
	debug_beforeupdate=stat(1)
	update_bullets()
	debug_afterupdate=stat(1)
	update_bunkers()
	update_powerups()
	update_floaters()
	update_particles()

	
	
	if #enemies==0 and mothership.dead==false then
		update_mothership()
	end
	if mothership.dead==true and #powerups==0 then
		init_bullets()
		next_stage()
	end
	if btnp(4,0) or btnp(4,1) then game.ui_stat_display+=1 game.level_title.hangtimer=game.level_title.hangtimerstart end
	if game.do_transition then
		game.transition+=0.015
		if game.transition>=1.2 then
			next_level()
		end
	end

	if btnp(2,1) then next_level() end
	if btnp(3,1) then next_stage() end
end

function update_menu()
	if menu.logo_y<menu.logo_final_y then menu.logo_y+=ceil(menu.logo_spd*sqrt((menu.logo_y-menu.logo_final_y)^2)) end
	update_stars()
	if game.do_transition==false then
	if btnp(0) then sfx(58) game.numstagesperlevel=8 end
	if btnp(1) then sfx(58) game.numstagesperlevel=16 end
	if btnp(2) or btnp(3) then
		sfx(57)
		if menu.selection==1 then menu.selection=2 else menu.selection=1 end
	end
	end
	if game.do_transition==false then
		if btnp(4) or btnp(5) then sfx(50) music(-1) game.do_transition=true end
	end
	if game.do_transition then
		game.transition+=0.015
		if game.transition>=1.2 then
			game.do_transition=false
			game.transition=0
			start_game(menu.selection)
		end
	end
end

function update_playersdead()
	update_particles()

	if game.do_transition then
		game.transition+=0.015
		if game.transition>=1.2 then
			reload_level()
		end
	end
end

function update_lose()
	if game.transition<0 then game.do_transition=false end
	if btnp(4) or btnp(5) or btnp(4,1) or btnp(5,1) then
		game.mode="menu"
		for i=#players,1,-1 do
			del(players,players[i])
		end
		init_bullets()
		game.level=1
		game.stage=1
		game.enemy_movedown_count=0
		init_leveltitle(game.level_title)
		init_enemies()
	end
	if game.do_transition then
		game.transition-=0.015
	end
end


function update_plyr_movement(plyr,plyrid)
	plyr.spr=1
	if btn(0,plyrid) then
		plyr.spd=plyr.spd-plyr_data.acl[plyr.acl]
		plyr.spr=2
	end
	if btn(1,plyrid) then
		plyr.spd=plyr.spd+plyr_data.acl[plyr.acl]
		plyr.spr=3
	end
	if btn(0,plyrid)==false and btn(1,plyrid)==false then
		if plyr.spd>0 then plyr.spd=max(plyr.spd-(plyr_data.acl[plyr.acl]/2),0) end
		if plyr.spd<0 then plyr.spd=min(plyr.spd+(plyr_data.acl[plyr.acl]/2),0) end
		plyr.spr=1
	elseif btn(0,plyrid) and btn(1,plyrid) then
		plyr.spr=1
	end
	local maxspd_r,maxspd_l=plyr_data.maxspd[plyr.maxspd],plyr_data.maxspd[plyr.maxspd]
	if plyr.x<=63 then
		maxspd_l*=fofx(plyr.x)
		plyr.spd=mid(-maxspd_l,plyr.spd,plyr_data.maxspd[plyr.maxspd])
	end
	if plyr.x>=64 then
		maxspd_r*=fofx(plyr.x)
		plyr.spd=mid(-plyr_data.maxspd[plyr.maxspd],plyr.spd,maxspd_r)
	end
	
	plyr.x=mid(0,plyr.x+plyr.spd,128)
end

function update_plyr_shooting(plyr,plyrid)
	if btn(5,plyrid) and plyr.shot_curcd<=0 then
		sfx(63)
		spawn_bullet(plyr.x,plyr.y,rnd(plyr_data.acc[plyr.acc])-plyr_data.acc[plyr.acc]/2+(plyr.spd*plyr_data.shot_velocityinheritance[plyr.shot_velocityinheritance]),-1,plyr_data.shot_power[plyr.shot_power],plyr_data.shot_spd[plyr.shot_spd],colors["p"..plyrid+1][1],"player")
		plyr.shot_curcd=plyr_data.shot_cd[plyr.shot_cd]
	end
	if plyr.shot_curcd>0 then plyr.shot_curcd-=1 end

end

function update_bullets()
	local blt
	for i=#bullets,1,-1 do
		blt=bullets[i]
		--if flr(rnd(20)/blt.spd)==0 then spawn_particle(blt.x,blt.y,rnd(1*blt.spd*0.1)-1*blt.spd*0.5*0.1,blt.spd/10,0,50) end
		if blt.y<=5 or blt.y>=130 or blt.dead then del(bullets,blt)
		else
			blt.x+=blt.dx*blt.spd
			if blt.x<=1 or blt.x>=126 then blt.dx=-blt.dx end
			blt.y+=blt.dy*blt.spd
			for j=#bunkers,1,-1 do
				if point_collide(blt.x,blt.y, bunkers[j]) then
					do_damage(blt.power,bunkers[j],true)
					blt.dead=true
				end
			end

			if blt.shooter=="player" or blt.shooter=="both" then
				--check against enemies
				for j=#enemies,1,-1 do
					if point_collide(blt.x,blt.y, enemies[j]) then
						do_damage(blt.power,enemies[j])
						blt.dead=true
					end
				end
				if point_collide(blt.x,blt.y,mothership) then
					damage_mothership(blt.power)
					blt.dead=true
				end
			elseif blt.shooter=="enemy" or blt.shooter=="both" then
				for j=#players,1,-1 do
					if point_collide(blt.x,blt.y, players[j]) then
						do_damage(blt.power,players[j])
						blt.dead=true
					end
				end
			end
			--end
		end	
		if blt.dead then del(bullets,blt) end
	end
end

function update_bunkers()
	local bnkr
	for i=#bunkers,1,-1 do
	bnkr=bunkers[i]
		update_hitflash(bnkr)
		movement_bob(bnkr)
		if bnkr.dead then
			del(bunkers,bnkr)
		end
	end
end

function update_enemies()
	local e
	for i=#enemies,1,-1 do
		e=enemies[i]
		animate_enemy(e)
		movement_bob(e)
		if enmy_data.shot[e.index] then
			if e.shot_curcd==0 then
				sfx(62)
				if e.index==5 then
					spawn_bullet(e.x,e.y+8,-enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
					spawn_bullet(e.x,e.y+8,0,enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")

					spawn_bullet(e.x,e.y+8,enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
					e.shot_curcd=enmy_data.shot_cd[e.index]
				elseif e.index==15 then
					spawn_bullet(e.x,e.y+8,-enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")

					spawn_bullet(e.x,e.y+8,enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
					e.shot_curcd=enmy_data.shot_cd[e.index]
				elseif e.index==9 then
					if e.shotinvertdirx then
						spawn_bullet(e.x,e.y+8,-enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
						e.shot_curcd=enmy_data.shot_cd[e.index]
						e.shotinvertdirx=false
					else
						spawn_bullet(e.x,e.y+8,enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
						e.shot_curcd=enmy_data.shot_cd[e.index]
						e.shotinvertdirx=true
					end
				else
					spawn_bullet(e.x,e.y+8,enmy_data.shot_dx[e.index],enmy_data.shot_dy[e.index],1,enmy_data.shot_spd[e.index],11,"enemy")
					e.shot_curcd=enmy_data.shot_cd[e.index]
				end
			else 
				e.shot_curcd=e.shot_curcd-1
			end
		end
		remaining_enemies_perc=1-((#enemies/game.enemy_count)^0.8)
		numplayersmult=1
		if #players==2 then numplayersmult=1.1 end
		e.x+=e.dx*enmy_data.spd[e.index]*(1+(game.stage/game.numstagesperlevel)/6)*levels[game.level].spd*numplayersmult*lerp(0.5,2.2,remaining_enemies_perc)--*(0.8+(e.y/127)*0.25)
		if e.x<=1 or e.x>=127 then
			toggle_enemy_direction()
		end
		update_hitflash(e)
		if e.y>75 then
			for j=#bunkers,1,-1 do
				if collide(e,bunkers[j]) then
					kill(bunkers[j])
					kill(e)
				end
			end
		end
		if e.y>100 then
			for j=#players,1,-1 do
				if players[j].dead==false then
					if collide(e,players[j]) then
						do_damage(1,players[j])
						kill(e)
					end
				end
			end
		end
		if e.y>124 then game.stage_loss=true end

		if e.dead then
			numplayersmult=1
			if #players==2 then numplayersmult=1.4 end
			if rnd(100)>(95-(10-game.level*2)*numplayersmult) then spawn_powerup(e.x,e.y) end
			
			if e.index==3 then
				spawn_bullet(e.x,e.y,0,1,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,0,-1,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,1,0,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,-1,0,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,0.7,0.7,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,-0.7,0.7,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,0.7,-0.7,1,0.8,11,"both")
				spawn_bullet(e.x,e.y,-0.7,-0.7,1,0.8,11,"both")
			end
			del(enemies,e)
		end
	end
end

function update_floaters()
	local f
	for i=#floaters,1,-1 do
	f=floaters[i]
	if f.y>f.endy then f.y=f.y+((f.endy-f.y)*0.25) else f.y=f.endy end

	if f.y==f.endy then f.hangtimer-=1 end

	if f.hangtimer<=0 then f.dead=true end

	if f.dead then del(floaters,f) end
	end
end

function update_particles()
	local p
	if #particles>_maximum_particles then
		local count=#particles-_maximum_particles
		for i=1,10 do
			del(particles,particles[1])
		end
	end

	for i=#particles,1,-1 do
		p=particles[i]
		p.x+=p.dx
		p.y+=p.dy

		p.dy+=0.13
		p.dx*=0.95
		p.size=max((p.life/p.maxlife)*p.startsize,0)
		p.life-=1
		if p.life<=0 then del(particles,p) end
	end
end

function update_powerups()
	local p
	for i=#powerups,1,-1 do
		p=powerups[i]
		p.y+=p.dy
		p.x=mid(3,p.x+p.dx,124)
		p.dy+=0.007
		p.dx*=0.97
		for j=#players,1,-1 do
			if players[j].dead==false then
				if collide(p,players[j]) then
					--sfx(58)
					upgrade_player(p,players[j])
					p.dead=true
				end
			end
		end

		if p.y>=130 then p.dead=true end

		if p.dead then del(powerups,powerups[i]) end
	end
end

function update_mothership()
	update_hitflash(mothership)
	if game.stage%2==0 then mothership.dead=true return end
	if flr(time()*10)%20==0 then sfx(45) end
	movement_bob(mothership)
	mothership.x+=mothership.spd
	if mothership.spd>0 then
		if mothership.x>190 then mothership.dead=true end
	else
		if mothership.x<-80 then mothership.dead=true end
	end
end

function movedown_enemies()
	local perc_move=((game.enemy_movedown_amount-game.enemy_movedown_count)*0.03)+0.3
	for i=1,#enemies do
	--	printh("moving enemy "..i.." from "..enemies[i].cury.." to "..enemies[i].cury+perc_move)
		enemies[i].cury+=perc_move
		movement_bob(enemies[i])
		--printh("count "..game.enemy_movedown_count.." amount "..game.enemy_movedown_amount)
	end
	game.enemy_movedown_count+=perc_move
end

function upgrade_player(pwr,plyr)
	sfx(50)
	local stat,color,_x,_y=pwr_data.stat[pwr.t],colors[plyr.color_index][1],plyr.x,plyr.y
	if stat=="lives" then
		plyr.lives+=1
		spawn_floater(_x,_y,"+1 life!",color)
		
		return
	elseif stat=="shield" then
		if plyr.hp==1 then
			plyr.hp=2
			spawn_floater(_x,_y,"gained shield!",color)
		else
			spawn_floater(_x,_y,"shield already powered!",color)
		end
		return
	end
	if plyr[stat]>=#plyr_data[stat] then
		spawn_floater(_x,_y,pwr_data.statname[pwr.t].." already maxed!",color)
	else
		plyr[stat]+=1
		spawn_floater(_x,_y,pwr_data.statname[pwr.t].." increased!",color)
	end
end

function players_out_of_lives()
	for i=1,#players do
		if players[i].lives>0 then return false end
	end

	return true
end

function damage_mothership(dmg)
	local _x,_y=mothership.x,mothership.y
	mothership.hp-=1
	if mothership.hp<=0 then
		spawn_particle_deathexplosion(_x,_y,4)
		spawn_particle_deathexplosion(_x,_y,4)
		spawn_particle_deathexplosion(_x,_y,4)
		spawn_powerup(_x,_y)

		mothership.dead=true
		mothership.x=-100
		sfx(52)
		sfx(53)
	else
		mothership.flashtimer=30
		mothership.hit=true
		sfx(51)
		sfx(53)
		spawn_particle_hit(_x,_y,3)
	end
end

function do_damage(dmg,obj,bunker)
	if obj.hit==false then
		if obj.hp==nil then
			sfx(52)
			sfx(53)
			if #particles<_maximum_particles then
				spawn_particle_deathexplosion(obj.x,obj.y,1+dmg)
			end
			obj.dead=true
		else
			if bunker then
				obj.cury-=4
				obj.hp-=1
				if obj.hp<=3 then obj.spr+=1 end
			else
				obj.hp-=dmg
			end
			if obj.hp<=0 then
				sfx(52)
				sfx(53)
				if #particles<_maximum_particles then
					spawn_particle_deathexplosion(obj.x,obj.y,1+dmg)
				end
				obj.dead=true
			else
				sfx(51)
				sfx(53)
				if #particles<_maximum_particles then
					spawn_particle_hit(obj.x,obj.y,dmg*1.2)
				end
			end
		end
		
		obj.x-=(rnd(2)-1)
		obj.hit=true
		obj.flashtimer=24
	end
end


function collide(obj_a,obj_b)
	local ax0,ax1,ay0,ay1 = get_collision_points(obj_a)
	local bx0,bx1,by0,by1 = get_collision_points(obj_b)
	if     ax0>bx1 then return false
	elseif ax1<bx0 then return false
	elseif ay0>by1 then return false
	elseif ay1<by0 then return false
	end

	return true
end

function point_collide(x,y,obj)
	if obj.dead then return false end
	local ox0,ox1,oy0,oy1 = get_collision_points(obj)
	if     x>ox0 and x<ox1 and y>oy0 and y<oy1 then return true else return false end
end

function get_collision_points(obj)
	local x,ofx,w,colofx=obj.x,obj.ofx,obj.w,obj.col_ofx
	local y,ofy,h,colofy=obj.y,obj.ofy,obj.h,obj.col_ofy
	local x0,x1,y0,y1 = x-ofx+colofx, x-ofx+w+colofx, y-ofy+colofy, y-ofy+h+colofy
	return x0,x1,y0,y1
end

function update_hitflash(obj)
	if obj.hit==true then obj.flashtimer-=1 end
	if obj.flashtimer<=0 then obj.hit=false end
end

function fofx(x)
	x=x/64-1
	return 1-(x^30)
end

function animate_enemy(e)
	if flr((t()+e.anim_offset)*enmy_data.anim_speed[e.index])%2==0 then
		e.spr=enmy_data.spr[e.index]+1
	else
		e.spr=enmy_data.spr[e.index]
	end
end

function lerp(a,b,t)
	t=mid(0,t,1)
	return a+((b-a)*t)
end

function kill(obj)
	obj.dead=true
	if #particles<_maximum_particles then
		spawn_particle_deathexplosion(obj.x,obj.y,3)
	end
	sfx(52)
	sfx(53)
end

function toggle_enemy_direction()
	for i=#enemies,1,-1 do
		enemies[i].dx = -enemies[i].dx
		enemies[i].cury+=levels[game.level].jump
	end
end

function update_stars()
	for i=1,flr(#stars*(rnd(0.1)+0.025)) do
		stars[flr(rnd(#stars))+1].c=flr(rnd(2)+6)
	end
end

function movement_bob(obj)
	obj.bob=sin((time()+obj.bob_offset)/obj.bob_speed)*obj.bob_amount
	obj.y=obj.cury+obj.bob+0.5
end

function reload_level()
	game.mode="game"
	if players_out_of_lives() then
		game.mode="lose"
		game.do_transition=true
		start_music(0)
	else
		for i=1,#players do
			if players[i].lives>0 then
				players[i].lives-=1
			end
			players[i].hp=1
			players[i].dead=false
		end
	end
	if game.mode=="game" then
		init_bunkers(levels[game.level].bunker_count)
		init_leveltitle(game.level_title)
		init_floaters()
		init_powerups()
		init_bullets()
		-- init_enemies(game.level)
		load_enemies(game.level,game.stage)
		game.do_transition=false
		game.transition=0
		game.enemy_movedown_count=0
		game.stage_loss=false
		start_music(levels[game.level].msc)
	end
end

function next_level()
	game.level=mid(1,game.level+1,#levels)
	game.stage=1
	init_stars(levels[game.level].atmosphere_height)
	init_bunkers(levels[game.level].bunker_count)
	init_leveltitle(game.level_title)
	init_floaters()
	init_powerups()
	init_bullets()
	-- init_enemies(game.level)
	load_enemies(game.level,game.stage)
	start_music(levels[game.level].msc)
	game.do_transition=false
	game.transition=0
	game.enemy_movedown_count=0
	game.stage_loss=false
	for i=1,#players do
		if players[i].dead then
			if players[i].lives>0 then players[i].lives-=1 end
			players[i].hp=1
			players[i].dead=false
		end
	end

end

function check_stage_loss()
	local p1,p2=true,true
	if game.stage_loss==true then return true end
	for i=1,#players do
		if i==1 then p1=players[i].dead end
		if i==2 then p2=players[i].dead end
	end
	
	for i=1,#enemies do
		if enemies[i].cury>=124 then return true end
	end

	if p1 and p2 then return true end
	return false
end

function reset_stage()

	game.do_transition=true
	game.mode="playersdead"
end

function next_stage()
	game.enemy_movedown_count=0
	if game.stage==game.numstagesperlevel then
		game.do_transition=true
	else
		for i=1,#players do
			if players[i].dead then
				if players[i].lives>0 then players[i].lives-=1 end
				players[i].hp=1
				players[i].dead=false
			end
		end
		game.stage+=1
		load_enemies(game.level,game.stage)
		game.level_title.hangtimer=game.level_title.hangtimerstart
	end
end
