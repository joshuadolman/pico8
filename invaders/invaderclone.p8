pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--todo

-->8
--data

#include ../libs/debug.p8
#include ../libs/screenshake.p8

player={
	x=63,
	y=115,
	spd=0,
	acl=4,
	maxspd=4,
	maxspd_def=1,
	spr=1,

	shot_power=3,
	shot_spd=3,
	shot_cd=1,
	shot_curcd=0,
	shot_cd_def=1, --frames
}

players={}

plyr_data={
	shot_power={1,2,3,4,5,6,7,8},
	shot_cd={30,25,20,15,12,10,8},
	shot_spd={0.5,1,2,3,4},
	acl={0.02,0.03,0.05,0.08,0.10,0.12,0.15,0.20},
	maxspd={0.8,1.0,1.2,1.5,1.8,2.0,2.2,2.5},
}

time={
	frames=0,
	seconds=0,
	minutes=0,
	hours=0
}

stars_count=80
stars={}

bullets={}

bunkers={}

particles={}
particle_colors={7,7,7,10,10,9,8,2,5,5,5,5,5,5,5}

offset=0
-->8
--init

function _init()
	init_stars()
	init_bunkers(4)
end

function init_stars()
	for i=1,stars_count do
		stars[i]={}
		stars[i].x=flr(rnd(129))
		stars[i].y=flr(rnd(100))
		stars[i].c=flr(rnd(3)+5)
	end
end

function init_bunkers(count)
	for i=1,count do
		local bunker={}
	bunker.hp=3
			bunker.x=(128/count)*i-(128/count)/2
		bunker.y=106
		bunker.spr=48
		add(bunkers,bunker)
	end
end


function spawn_bullet(plyr)
	local bullet={}
	bullet.x=plyr.x+0.5
	bullet.y=plyr.y-3
	bullet.p=plyr_data.shot_power[plyr.shot_power]
	bullet.spd=plyr_data.shot_spd[plyr.shot_spd]
	bullets[#bullets+1]=bullet
end

function spawn_particle(size,x,y,dx,dy,life,type)
	local particle={}
	particle.type=type
	particle.size=size
	particle.startsize=size
	particle.x=x
	particle.y=y
	particle.dx=dx
	particle.dy=dy
	particle.life=life
	particle.maxlife=life
	add(particles,particle)
end

function spawn_deathexplosion(x,y,size)
	for i=1,size*3 do
		spawn_particle(flr(rnd(size))+3,x+flr(rnd(4))-2,y+flr(rnd(4))-2,flr((rnd(6)-2)*(size/4)),-flr(rnd(4)*(size/4)),rnd(size*8)+size*3,particle_explosion)
	end
	screenshake+=size/30
	--sfx(62)
	--sfx(59)
	sfx(60)
end
-->8
--update

function _update60()
	update_time(time)
	update_stars()
	update_plyr(player)
	update_bullets()
	update_particles()
end

function update_particles()
	for i=#particles,1,-1 do
		particles[i].type(particles[i])
		if particles[i].life<=0 then del(particles,particles[i]) end
	end

end

function particle_trail(p)
	printh("particle_trail function called\n")
end

function particle_explosion(p)
	p.x+=p.dx
	p.y+=p.dy

	p.dy+=0.15
	p.dx*=0.9
	p.size=(p.life/p.maxlife)*p.startsize
	p.life-=1
end

function particle_bullettrail(p)
	p.x+=p.dx
	p.y+=p.dy

	p.dy+=0.01
	p.dx*=0.7
	p.size=(p.life/p.maxlife)*p.startsize
	p.life-=1
end

function update_bullets()
	for i=#bullets,1,-1 do
		bullets[i].y-=bullets[i].spd
		if time.frames%flr(60/bullets[i].p/8)==0 then
			spawn_particle(ceil(bullets[i].p/2),bullets[i].x+flr(rnd(2))-1,bullets[i].y+flr(rnd(2))-1,rnd(1)-0.5,0,(rnd(20)+3)*bullets[i].p,particle_bullettrail)
		end
		if bullets[i].y<-20 then del(bullets,bullets[i]) end
	end
end

function update_time(t)
	t.frames+=1
	if t.frames==60 then
		t.seconds+=1
		t.frames=0
		if t.seconds==60 then
			t.minutes+=1
			t.seconds=0
			if t.minutes==60 then
				t.hours+=1
				t.minutes=0
			end
		end
	end

	--debug_data="time: "..t.hours..":"..t.minutes..":"..t.seconds..":"..t.frames
end

function update_stars()
	for i=1,flr(stars_count*(rnd(0.1)+0.025)) do
		stars[flr(rnd(stars_count))+1].c=flr(rnd(2)+6)
	end
end

function update_plyr(plyr)
	--player movement
	

	plyr.spr=1
	if btn(0) then
		plyr.spd=plyr.spd-plyr_data.acl[plyr.acl]
		plyr.spr=2
	end
	if btn(1) then
		plyr.spd=plyr.spd+plyr_data.acl[plyr.acl]
		plyr.spr=3
	end
	if btn(0)==false and btn(1)==false then
		if plyr.spd>0 then plyr.spd=max(plyr.spd-(plyr_data.acl[plyr.acl]/2),0) end
		if plyr.spd<0 then plyr.spd=min(plyr.spd+(plyr_data.acl[plyr.acl]/2),0) end
		plyr.spr=1
	elseif btn(0) and btn(1) then
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
	--plyr.x+=plyr.spd
	--debug_data="l "..maxspd_l.."    s ".. plyr.spd.."    r "..maxspd_r

	--player shooting
	if btnp(4) then
		if plyr.shot_curcd==0 then
		--	spawn_bullet(plyr)
		--	plyr.shot_curcd=plyr_data.shot_cd[plyr.shot_cd]
		end
		spawn_deathexplosion(40,40,3)
	end
	if plyr.shot_curcd>0 then plyr.shot_curcd-=1 end

	if btnp(5) then
		--upgrade_plyr(player)
		--upgrade_plyr(player)
		--spawn_deathexplosion(40,40,5)
		spawn_deathexplosion(bunkers[1].x,bunkers[1].y,2)

	end
end

function upgrade_plyr(plyr)
	--plyr.shot_cd+=1
	plyr.shot_power+=1
	plyr.maxspd+=1
	--plyr.shot_spd+=1
	plyr.acl+=1
end

function fofx(x)
	x=x/64-1
	return 1-(x^30)
end
-->8
--draw

function _draw()
	screen_shake()
	draw_bg()


	draw_plyr(player)
	draw_bullets()
	draw_bunkers()
	pal()

	draw_particles()

	dbg_draw()
--	centerprint3d_8outline("welcome to earth",8,7,80)
end

function draw_particles()
	for i=1,#particles do

		perc=particles[i].life/particles[i].maxlife
				ind=flr((1-perc)*#particle_colors)+1
		col=particle_colors[ind]
		--debug_data="ind "..ind.."  col "..col
		circfill(particles[i].x,particles[i].y,particles[i].size,col)
	end
end

function draw_bunkers()
	if bunkers then
		for i=1,#bunkers do
			--spr(48,bunkers[i].x,bunkers[i].y)
			--circfill(bunkers[i].x,bunkers[i].y,4,12)
			draw_plyr(bunkers[i])
		end
	end
end

function draw_bullets()
	for i=1,#bullets do
		circfill(bullets[i].x,bullets[i].y,bullets[i].p/2,9)
		circfill(bullets[i].x,bullets[i].y+1-bullets[i].p/2,bullets[i].p/2,9)
	end
end

function draw_bg()
	cls()
	rectfill(0,124,127,127,1)
	fillp(0b0000101000000101)
	rectfill(0,119,127,123,1)
	fillp(0b0101101001011010)
	rectfill(0,110,127,119,1)
	fillp(0b1111101011110101)
	rectfill(0,94,127,109,1)
	fillp()

	for i=1,#stars do
		pset(stars[i].x,stars[i].y,stars[i].c)
	end

end

function draw_plyr(obj)
	palt(0,false)
	palt(14,true)
	pal(7,0)
	pal(6,0)
	spr(obj.spr,obj.x-3.5-1,obj.y  )
	spr(obj.spr,obj.x-3.5+1,obj.y  )
	spr(obj.spr,obj.x-3.5  ,obj.y-1)
	spr(obj.spr,obj.x-3.5  ,obj.y+1)
	spr(obj.spr,obj.x-3.5-1,obj.y+1)
	spr(obj.spr,obj.x-3.5+1,obj.y-1)
	spr(obj.spr,obj.x-3.5-1,obj.y-1)
	spr(obj.spr,obj.x-3.5+1,obj.y+1)
	pal()
	palt(0,false)
	palt(14,true)
	pal(7,11)
	pal(6,3)
	spr(obj.spr,obj.x-3.5,obj.y)
	pal()
end

-->8
--util

function centerprint3d_8outline(text,textcol,linecol,y)
	local x=63-(#text*4)/2
	print(text,x-1,y  ,linecol)
	print(text,x+1,y  ,linecol)
	print(text,x  ,y-1,linecol)
	print(text,x  ,y+1,linecol)
	print(text,x-1,y-1,linecol)
	print(text,x+1,y+1,linecol)
	print(text,x-1,y+1,linecol)
	print(text,x+1,y-1,linecol)

	print(text,x  ,y+2,linecol)
	print(text,x-1,y+2,linecol)
	print(text,x+1,y+2,linecol)

	print(text,x,y,textcol)
end

__gfx__
00000000eeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eee77eeeee77eeeeeeee77ee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700ee6776eee6776eeeeee6776e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000ee7777eee67777eeee77776e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000677777766777777ee7777776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700777777777777ee6776ee7777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000076eeee6776eeeeeeeeeeee67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000eeeeeeeeeeeeeeeeeeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
e777777e000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
67766776000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
77777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
76eeee67000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
eeeeeeee000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000200000b6640c6540e6441063412624196251f6151b215000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000400000032301323023230232303323053230532305323033230332301323013230132301323003130131301313013130061300613006130161301613016130161301613016130161301613026130261305613
000200000b6600c6500e6401063012620196301f61024610000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000100000265001650026400464006640096300b6300e6301063013630166301863019630196401964019640196401764016640156401363012630106300f6300e6300c6200b6200a62009610076100761006610
00020000095500d550135601d5702d300233000d30000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 01424344

