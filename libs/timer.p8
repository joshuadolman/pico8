pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
timer={
	frames=0,
	seconds=0,
	minutes=0,
	hours=0
}

function update_timer()
	timer.frames+=1
	if timer.frames==60 then
		timer.seconds+=1
		timer.frames=0
		if timer.seconds==60 then
			timer.minutes+=1
			timer.seconds=0
			if timer.minutes==60 then
				timer.hours+=1
				timer.minutes=0
			end
		end
	end
end