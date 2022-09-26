local marising = false
local focasing = false


function onCreate()

	makeAnimatedLuaSprite('mari', 'Maritza', 700, 115); 
	setProperty('mari.flipX', true)
	addAnimationByPrefix('mari', 'idle', 'danceleft', 24, false); 
    addAnimationByPrefix('mari', '0', 'right', 24, false); 
    addAnimationByPrefix('mari', '1', 'down', 24, false); 
    addAnimationByPrefix('mari', '2', 'up', 24, false); 
    addAnimationByPrefix('mari', '3', 'left', 24, false); 
	objectPlayAnimation('mari', 'idle'); 
	addLuaSprite('mari', false); 
	
	
	
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
	
	if 	marising == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('mari', 'idle', true)
		end
	end
	if 	focasing == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('foca', 'idle', true)
		end
	end
	
end

lastNote = {0, ""}

function goodNoteHit(id,d,t,s)

    lastNote[1] = d
    lastNote[2] = t
	
    if lastNote[2] == "SecondCharacter" or lastNote[2] == "MainAndSecondCharacter" then
		marising = true
		cancelTimer('cantaadenuevo')
		runTimer('cantaadenuevo',0.16)
		objectPlayAnimation('mari', lastNote[1], true);
    end
end
function noteMiss(id,d,t,s)
	
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
    if tag == 'cantaadenuevo' then
		marising = false
	end
	if tag == 'bailaafoca' then
		focasing = false
	end
end
