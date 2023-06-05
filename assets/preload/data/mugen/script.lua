local a = math.random(1,3)

local allowCountdown = false
function onStartCountdown()
	if not allowCountdown then
		runTimer('startText', 0.1);
		runTimer('countdown', 2.25)
		allowCountdown = true;
		--startCountdown()
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startText' then
		playSound('mugen/ronaldIntro'..tostring(a))
		characterPlayAnim('dad','intro'..tostring(a))
	end
	if tag == 'countdown' then
		startCountdown()
	end
end