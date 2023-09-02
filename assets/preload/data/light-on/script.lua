local focasing = false

function onCreate()

	makeAnimatedLuaSprite('foca', 'foca ql', -290, 305); 
	addAnimationByPrefix('foca', 'idle', 'benjastand', 24, false); 
    	addAnimationByPrefix('foca', '0', 'left', 24, false); 
    	addAnimationByPrefix('foca', '1', 'down', 24, false); 
    	addAnimationByPrefix('foca', '2', 'up', 24, false); 
    	addAnimationByPrefix('foca', '3', 'right', 24, false); 
	objectPlayAnimation('foca', 'idle'); 
	addLuaSprite('foca', false); 
	
end

function onBeatHit()
	
	if focasing == false then
		objectPlayAnimation('foca', 'idle', true)
	end
	
end

lastNote2 = {0, ""}
function opponentNoteHit(id,d,t,s)
	lastNote2[1] = d
    lastNote2[2] = t
    if lastNote2[2] == "SecondCharacter" or lastNote2[2] == "MainAndSecondCharacter" then
	    focasing = true
		cancelTimer('bailaafoca')
		runTimer('bailaafoca',0.1)
		objectPlayAnimation('foca', lastNote2[1], true);
    end
end

function onTimerCompleted(tag)
  
	if tag == 'bailaafoca' then
		focasing = false
	end
end