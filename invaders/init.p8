pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--todo

--clean up particles bullets etc
--use collision checks
--losing
-- --if all players die with lives left then stage is reset
-- --if
--speed of powerup dy reduced towards bottom of screen
-->8
--includes

-->8
--data
debug_afterupdate,debug_beforeupdate,debug_afteredraw,debug_beforedraw=0,0,0,0

game={
	mode="menu",
	level=1,
	stage=1,
	enemy_count=1,
	do_transition=false,
	transition=0,
	level_title={
		y=-1,
		starty=-1,
		endy=8,
		spd=1,
		hangtimer=240,
		hangtimerstart=120,
	},
	enemy_movedown_count=0,
	enemy_movedown_amount=120,
	debug_enabled=false,
	cpu_last_frame=0,
	stage_loss=false,
	numstagesperlevel=8,
	ui_stat_display=1,
	music_enabled=true,
}

menu={
	selection=1,
	logo_y=-20,
	logo_final_y=15,
	logo_spd=0.1
}

players={}
bunkers={}
stars={}
bullets={}
particles={}
enemies={}
powerups={}
floaters={}

mothership={
	x=20,
	y=12,
	cury=12,
	ofx=0,
	ofy=0,

	hp=1,

	spd=0.2,

	w=20,
	h=13,
	col_ofx=-1,
	col_ofy=-1,

	bob=0,
	bob_amount=2,
	bob_speed=2.5,
	bob_offset=0,

	hit=false,
	flashtimer=0,

	dead=false
}

_maximum_particles=12

plyr_data={
	shot_power={1,2,3},
	shot_cd={80,60,50,45,40,35,30,25,20,15,12,10,8},
	shot_spd={0.5,0.75,1,1.25,1.5,2,2.5,3,3.5,4},
	shot_velocityinheritance={0.5,0.4,0.3,0.2,0.1,0.05,0},

	acl={0.02,0.03,0.05,0.08,0.10,0.12,0.15,0.20,0.25,0.3,0.35,0.4},
	maxspd={0.5,0.6,0.8,1.0,1.2,1.5,1.8,2.0,2.2,2.5},

	acc={0.18,0.12,0.06,0},

}

pwr_data={
	spawnrate={1,1,1,1,2,2,3,3,3,4,5,5,5,9,6,6,6,7,8,8,8},
	stat={"acl","shot_velocityinheritance","shot_cd","shot_power","shot_spd","maxspd","acc","shield","lives",""},
	spr= {51,34,49,48,35,33,50,64,32,24},
	statname={"acceleration","shot inertia","fire rate","firepower","bullet velocity","max speed","accuracy","shield","lives",""},
}

enmy_data={--  1     2     3     4 12B 5     6 4K  7     8     9 6M  10 7G 11 D1 12    13    14    15
	hp=         {2    ,3    ,1    ,3    ,1    ,1    ,1    ,6    ,1    ,1    ,1    ,1    ,6    ,1    ,1    },
	shot=       {false,false,false,false,true ,true ,false,true ,true ,false,false,false,false,true,true},
	shot_spd=   {0    ,0    ,0    ,0    ,0.5  ,0.6  ,0    ,1    ,0.5  ,0    ,1    ,0    ,0    ,1.5  ,0.4   },
	shot_dx=    {0    ,0    ,0    ,0    ,1.33 ,0    ,0    ,0    ,1    ,0    ,0    ,0    ,0    ,0    ,1.1    },
	shot_dy=    {0    ,0    ,0    ,0    ,0.67 ,1    ,0    ,1    ,0.5  ,0    ,-1   ,0    ,0    ,1    ,0.6   },
	shot_cd=    {150  ,80   ,0    ,0    ,200  ,180  ,0    ,120  ,140  ,0    ,150  ,0    ,0    ,60   ,240  },
	spr=        {54   ,52   ,8    ,20   ,22   ,24   ,36   ,38   ,40   ,06   ,66   ,54   ,72   ,68   ,4    },
	color_index={"e9" ,"e8" ,"e11","p1" ,"e1" ,"e7" ,"e5" ,"e2" ,"e10" ,"e3","bn" ,"e12","e4" ,"p2" ,"e6" },
	spd=        {0.05 ,0.67 ,0.5  ,0.5  ,0.5  ,0.5  ,0.5  ,0.5  ,0.5  ,1    ,0.5  ,0.5 ,0.25  ,0.5  ,0.5  },
	bob_speed=  {3    ,1.2  ,1.4  ,1.4  ,1.4  ,3    ,1.4  ,1.0  ,1.4  ,0.25 ,1.4  ,4    ,4   ,1.4  ,1.4  },
	anim_speed= {0.33 ,3    ,4    ,4    ,4    ,1.5  ,4    ,0.9  ,4    ,12   ,1.5  ,0.5  ,0.5   ,1    ,4    },
}

colors={
	particles={7,7,7,10,10,9,8,2,5,5,5,5,5,5,5},
	p1={12,1 },
	p2={8 ,2 },
	bn={11,3 },
	e1={9 ,4 },
	e2={5 ,1 },
	e3={10,9 },
	e4={13,5 },
	e5={6 ,13},
	e6={4 ,2 },
	e7={15,9 },
	e8={7 ,6 },
	e9={13,1 },
 e10={9 ,8 },
 e11={15,4 },
 e12={9 ,2 },
 trail={8,9,10,7},
 --floaters={7,10,9,8,2,1,12,13,11,3,4,15}
}

levels={
	[1]={
		name="pluto",
		atmosphere_height=8,
		atmosphere_color=5,
		bunker_count=2,
		spd=0.8,
		jump=8,
		msc=9,
	},
	[2]={
		name="neptune",
		atmosphere_height=22,
		atmosphere_color=12,
		bunker_count=2,
		spd=0.9,
		jump=3.5,
		msc=18,
	},
	[3]={
		name="uranus",
		atmosphere_height=42,
		atmosphere_color=13,
		bunker_count=6,
		spd=1,
		jump=3,
		msc=25,
	},
	[4]={
		name="saturn",
		atmosphere_height=52,
		atmosphere_color=15,
		bunker_count=5,
		spd=1,
		jump=4,
		msc=30,
	},
	[5]={
		name="jupiter",
		atmosphere_height=75,
		atmosphere_color=4,
		bunker_count=4,
		spd=1,
		jump=3.5,
		msc=2,
	},
	[6]={
		name="mars",
		atmosphere_height=25,
		atmosphere_color=8,
		bunker_count=3,
		spd=1,
		jump=4,
		msc=30,
	},
	[7]={
		name="venus",
		atmosphere_height=20,
		atmosphere_color=9,
		bunker_count=3,
		spd=1,
		jump=4,
		msc=30,
	},
	[8]={
		name="earth",
		atmosphere_height=30,
		atmosphere_color=1,
		bunker_count=3,
		spd=1,
		jump=4,
		msc=30,
	},
	[9]={
		name="mercury",
		atmosphere_height=14,
		atmosphere_color=10,
		bunker_count=3,
		spd=1,
		jump=4,
		msc=30,
	},
	[10]={
		name="zorbar",
		atmosphere_height=50,
		atmosphere_color=2,
		bunker_count=3,
		spd=1,
		jump=4,
		msc=30,
	},
}
-->8
--init

function _init()
	init_stars(0)
	init_leveltitle(game.level_title)
	menuitem(1,"disable music",toggle_music)
	music(8,800)
end

function toggle_music()
	if game.music_enabled then
		game.music_enabled=false
		music(-1)
		menuitem(1,"enable music",toggle_music)
	else
		game.music_enabled=true
		menuitem(1,"disable music",toggle_music)
		if game.mode=="game" then start_music(levels[game.level].msc) end
	end
end

function init_leveltitle(lt)
	lt.y=lt.starty
	lt.hangtimer=lt.hangtimerstart
end

function init_enemies()
	for i=#enemies,1,-1 do
		del(enemies,enemies[i])
	end
end

function init_bullets()
	for i=#bullets,1,-1 do
		del(bullets,bullets[i])
	end
end

function spawn_mothership()
	mothership.dead=false
	mothership.hp=flr(game.level*0.4)+1
	mothership.spd=(rnd(0.3+(game.level/10)*0.8+(game.stage/game.numstagesperlevel)*0.3)-(0.15+(game.level/10)*0.2+(game.stage/game.numstagesperlevel)*0.15))
	if mothership.spd<0.3 and mothership.spd>=0 then mothership.spd+=0.3 end
	if mothership.spd>-0.3 and mothership.spd<=0 then mothership.spd-=0.3 end
	if mothership.spd>0 then mothership.x=-80 else mothership.x=200 end
	mothership.cury=flr(rnd(10))+10
end

function load_enemies(level,stage)
	init_enemies()
	local offy,enemy_index=48,0
	level-=1
	stage-=1
	for y=0,7 do
		for x=0,7 do
			xp=stage*8+x
			yp=level*8+y+offy
			enemy_index=sget(xp,yp)
			--printh("Enemy_Index at "..xp..","..yp.." is "..enemy_index)
			if enemy_index!=0 then spawn_enemy(enemy_index,x*9+32,8+y*8-game.enemy_movedown_amount) end
		end
	end
	game.enemy_count=#enemies
	spawn_mothership()
end

function init_floaters()
	for i=#floaters,1,-1 do
		del(floaters,floaters[i])
	end
end

function init_powerups()
	for i=#powerups,1,-1 do
		del(powerups,powerups[i])
	end
end

function spawn_floater(x,y,text,color)
	local f={}
	f.x=x
	f.y=y
	f.endy=y-flr(rnd(40)+5)
	f.text=text
	f.hangtimer=flr(rnd(50)+15)
	f.dead=false
	f.color=color
	add(floaters,f)
end

function spawn_powerup(x,y)
	local p={}
	p.x=x
	p.y=y
	p.ofx=4
	p.ofy=0

	p.w=13
	p.h=7
	p.col_ofx=1
	p.col_ofy=0


	local plyravgspd,plyrtotalspd,plyrcount=0,0,0
	local plyravgacl,plyrtotalacl=0,0
	for i=1,#players do
		plyrtotalspd+=plyr_data.maxspd[players[i].maxspd]
		plyrtotalacl+=plyr_data.acl[players[i].acl]
		plyrcount+=1
	end
	plyravgspd=plyrtotalspd/plyrcount
	plyravgacl=plyrtotalacl/plyrcount
	p.dy=(rnd(0.3)+0.1+plyravgspd/5+plyravgacl*2)*(1-(y/140)^0.5)
	p.dx=rnd(1)-0.5

	p.t=pwr_data.spawnrate[flr(rnd(#pwr_data.spawnrate))+1]
	
	if pwr_data.stat[p.t]~="lives" then 
		if pwr_data.stat[p.t]~="shield" then
			if all_players_have_max_upgrade_for_stat(p.t) then p.t=pwr_data.spawnrate[flr(rnd(#pwr_data.spawnrate))+1] end
		end
	end

	p.dead=false
	add(powerups,p)
end

function all_players_have_max_upgrade_for_stat(pwr)
	for i=1,#players do
		if players[i][pwr_data.stat[pwr]]<#plyr_data[pwr_data.stat[pwr]] then return false end
	end
	return true
end

function spawn_enemy(enemy_index,x,y)
	local e={}
	e.index=enemy_index

	e.x=x
	e.y=y
	e.cury=y
	e.dx=-1
	e.ofx=4
	e.ofy=0

	e.bob=0
	e.bob_amount=0.7
	e.bob_speed=enmy_data.bob_speed[enemy_index]+(rnd(0.3)-0.15)
	e.bob_offset=rnd(10)

	e.col_ofx=-1
	e.col_ofy=0
	e.w=9
	e.h=8

	if enemy_index==9 then e.invertshotdirx=false end
	
	e.anim_offset=rnd(100)
	local random_animspd_mult,anim_speed=0.5,enmy_data.anim_speed[enemy_index]
	e.anim_speed=anim_speed+(rnd((anim_speed*0.9)*2)-anim_speed*0.9)

	e.hp=enmy_data.hp[enemy_index]
	e.dead=false
	e.hit=false
	e.flashtimer=0

	e.shot_curcd=enmy_data.shot_cd[enemy_index]
	e.color_index=enmy_data.color_index[enemy_index]
	e.spr=enmy_data.spr[enemy_index]

	add(enemies,e)
end

function start_game(playercount)
	for i=1,playercount do
		spawn_player()
	end
	if playercount==2 then players[1].lives=2 players[2].lives=2 end
	init_bunkers(levels[game.level].bunker_count)
	init_powerups()
	-- init_enemies(game.level)
	load_enemies(game.level,game.stage)
	game.mode="game"
	start_music(levels[game.level].msc)
end

function init_bunkers(bunker_count)
		for i=#bunkers,1,-1 do
		del(bunkers,bunkers[i])
	end
	for i=1,bunker_count do
		spawn_bunker((i-1)*(127/bunker_count)+(127/bunker_count)/2)
	end
end

function spawn_bunker(x)
	local bnkr={}
	bnkr.x=x
	bnkr.y=111
	bnkr.cury=111
	bnkr.ofx=0
	bnkr.ofy=0

	bnkr.col_ofx=0
	bnkr.col_ofy=0
	bnkr.w=7
	bnkr.h=4

	bnkr.hp=6

	bnkr.hit=false
	bnkr.flashtimer=0

	bnkr.bob=0
	bnkr.bob_amount=0.7
	bnkr.bob_speed=1.4+(rnd(0.3)-0.15)
	bnkr.bob_offset=rnd(10)

	bnkr.color_index="bn"
	bnkr.spr=16

	add(bunkers,bnkr)
end

--[[ old version that includes box collision info
function spawn_bullet(x,y,dx,dy,power,spd,color,shooter)
	local bullet={}
	bullet.x=x
	bullet.y=y
	bullet.dx=dx
	bullet.dy=dy
	bullet.power=power
	
	bullet.w=power+1
	bullet.h=power+1
	bullet.ofx=0.5
	bullet.ofy=0.5
	bullet.col_ofx=-power/2
	bullet.col_ofy=-power/2

	bullet.spd=spd
	bullet.color=color
	bullet.dead=false

	bullet.shooter=shooter
	add(bullets,bullet)
end
]]


function spawn_bullet(x,y,dx,dy,power,spd,color,shooter)
	local bullet={}
	bullet.x=x
	bullet.y=y
	bullet.dx=dx
	bullet.dy=dy
	bullet.power=power
	
	bullet.spd=spd
	bullet.color=color
	bullet.dead=false

	bullet.shooter=shooter
	add(bullets,bullet)
end

function spawn_player()
	local plyr={}
	plyr.x=rnd(127)
	plyr.y=119
	plyr.cury=119
	plyr.ofx=4
	plyr.ofy=0

	plyr.col_ofx=1
	plyr.col_ofy=2
	plyr.w=5
	plyr.h=4

	plyr.color_index="p"..#players+1
	plyr.spr=1
	
	plyr.hp=1

	plyr.spd=0
	
	plyr.maxspd=1
	plyr.acl=1
	
	plyr.acc=1
	
	plyr.shot_curcd=0

	plyr.shot_spd=1--#plyr_data.shot_spd
	plyr.shot_power=1--#plyr_data.shot_power
	plyr.shot_cd=1--#plyr_data.shot_cd
	plyr.shot_velocityinheritance=1--#plyr_data.shot_velocityinheritance


	plyr.lives=3
	

	plyr.colliding=false

	plyr.dead=false

	plyr.hit=false
	plyr.flashtimer=0

	plyr.bob=0
	plyr.bob_amount=0.6
	plyr.bob_speed=0.8+(rnd(0.2)-0.1)
	plyr.bob_offset=rnd(10)

	plyr.score=0

	add(players, plyr)
end

function spawn_particle(x,y,dx,dy,size,life)
	if #particles>_maximum_particles then return end
	local p={}
	p.size=size
	p.startsize=size
	p.x=x
	p.y=y
	p.dx=dx
	p.dy=dy
	p.life=life
	p.maxlife=life
	add(particles,p)
end

function spawn_particle_deathexplosion(x,y,size)
	for i=1,min(size*3,7) do
		spawn_particle(x+flr(rnd(4))-2,y+flr(rnd(4))-2,flr((rnd(6)-2)*(size/4)),-flr(rnd(4)*(size/4)),flr(rnd(size))+3,rnd(size*8)+size*2.5)
	end
	screenshake+=size/20
end

function start_music(id)
	if game.music_enabled then
		music(id,0,0b0011)
	end
end

function spawn_particle_hit(x,y,size)
	for i=1,min(size*2,6) do
		spawn_particle(x+flr(rnd(4))-2,y+flr(rnd(4))-2,flr((rnd(6)-2)*(size/3)),-flr(rnd(4)*(size/3)),flr(rnd(size))+3,rnd(size*6)+size*1.8)
	end
	screenshake+=size/35
end


function init_stars(atmosphere_height)
  atmosphere_height*=0.7
	for i=#stars,1,-1 do
		del(stars,stars[i])
	end
	local stars_amount=150
	stars_amount=flr((1-(atmosphere_height/127))*stars_amount)

	for i=1,stars_amount do
		stars[i]={}
		stars[i].x=flr(rnd(128))
		stars[i].y=flr(rnd(127-atmosphere_height-8)+8)
		stars[i].c=flr(rnd(2)+6)
	end
end

