pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
gun={
	rarity=nil,
	slot=6,
	something="y",
	eladd="70.2",
}

rarities={
	"white",
	"green",
	"blue",
	"purple",
	"orange",
}

slots={
	primary,
	seconday,
	tertiary
}
-->8
function _init()
	gun_gen()
end

function gun_gen()
	gun.rarity=rarities[randint(#rarities)]
	gun.slot=slots[randint(#slots)]
end

function randint(a)
	a=1+flr(rnd(a))
	return a
end
-->8
function _update60()
end
-->8
function _draw()
	cls(0)
	pal(15,colormap[gun.rarity])
	x,y=1,1
	for k,v in pairs(gun) do
		print(v)
	end
	--print(gun.rarity,1,1,15)
	--print(gun[0],x,10,15)
	--print(rarities[1])
end

colormap={
	white=6,
 green=3,
 blue=12,
 purple=2,
	orange=9
}

