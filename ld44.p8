pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
--todo
--Your Life Is Currency

-->8
--data
gamemode="game"

plyr={
	hp=5,
	x=7,y=7,
	w=8,h=8,
}

-->8
--init
function _init()
end

-->8
--update
function _update60()
	if gamemode=="game" then
		update_game()
	else
	end
end

function update_game()
end

-->8
--draw
function _draw()
	cls(14)
	if gamemode=="game" then
		draw_game()
	end
end

function draw_game()
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000