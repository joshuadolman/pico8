pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
dbg_colbg,dbg_coltx,dbg_spd,dbg_height,dbg_txtrowcount,debug_data=8,7,2,0,0,nil

function draw_dbg()
	if debug_data then
		dbg_txtrowcount,dbg_height=ceil(#tostr(debug_data)/31),(6*dbg_txtrowcount)
		rectfill(0,0,127,dbg_height,dbg_colbg)
		local substrloc=nil
		for i=0,dbg_txtrowcount-1 do
			substrloc=i*31+1
			print(sub(tostr(debug_data),substrloc,substrloc+30),3,i*6+1,dbg_coltx)
		end
		line(1,1,1,dbg_height-1,9)
	end
end