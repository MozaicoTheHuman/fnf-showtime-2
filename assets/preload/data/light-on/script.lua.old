local maavoSingin = false
local focaSingin = false

function onCreate()

	makeAnimatedLuaSprite('Tulon', 'Maritza', 700, 115)
	addAnimationByPrefix('Tulon', 'idle', 'danceleft', 24, false)
	addAnimationByPrefix('Tulon', 'left', 'right', 24, false)
	addAnimationByPrefix('Tulon', 'down', 'down', 24, false)
	addAnimationByPrefix('Tulon', 'up', 'up', 24, false)
	addAnimationByPrefix('Tulon', 'right', 'left', 24, false)
	scaleObject('Tulon', -1, 1);	
	addLuaSprite('Tulon', false)

    makeAnimatedLuaSprite('Foca culia', 'foca ql', -290, 305)
	addAnimationByPrefix('Foca culia', 'idle', 'benjastand', 24, false)
	addAnimationByPrefix('Foca culia', 'left', 'left', 24, false)
	addAnimationByPrefix('Foca culia', 'down', 'down', 24, false)
	addAnimationByPrefix('Foca culia', 'up', 'up', 24, false)
	addAnimationByPrefix('Foca culia', 'right', 'right', 24, false)
	scaleObject('Foca culia', 1, 1);	
	addLuaSprite('Foca culia', false)
end

function onBeatHit()
	if 	maavoSingin == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('Tulon', 'idle', true)
		end
	end
	if 	focaSingin == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('Foca culia', 'idle', true)
		end
	end
end

--Foca culia cantando brigido
function opponentNoteHit(id,data,type,sus)
	if (type == 'SecondCharacter'  or type == 'ThirdCharacter' or type == 'AllCharacters' or type == 'SecondAndThirdCharacter' or type ==  'MainAndThirdCharacter' or type =='MainAndSecondCharacter') then
		if data == 0 then
		    objectPlayAnimation('Foca culia', 'left', true)
			focaSingin = true
			cancelTimer('endShit')
			runTimer('endShit', 0.7);
	    end
	    if data == 1 then
		    objectPlayAnimation('Foca culia', 'down', true)
			focaSingin = true
			cancelTimer('endShit')
			runTimer('endShit', 0.7);
	    end
	    if data == 2 then
		    objectPlayAnimation('Foca culia', 'up', true)
			focaSingin = true
			cancelTimer('endShit')
			runTimer('endShit', 0.7);
	    end
	    if data == 3 then
		    objectPlayAnimation('Foca culia', 'right', true)
			focaSingin = true
			cancelTimer('endShit')
			runTimer('endShit', 0.7);
		end
	end
end

--La wea para que maritza cante
function goodNoteHit(id,data,type,sus)
	if (type == 'SecondCharacter'  or type == 'ThirdCharacter' or type == 'AllCharacters' or type == 'SecondAndThirdCharacter' or type ==  'MainAndThirdCharacter' or type =='MainAndSecondCharacter') then
		if data == 0 then
		    objectPlayAnimation('Tulon', 'left', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if data == 1 then
		    objectPlayAnimation('Tulon', 'down', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if data == 2 then
		    objectPlayAnimation('Tulon', 'up', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if data == 3 then
		    objectPlayAnimation('Tulon', 'right', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
		end
	end
end

function onTimerCompleted(tag)
    if tag == 'endShit' then
		focaSingin = false
		objectPlayAnimation('Foca culia', 'idle', true)
	end
	if tag == 'tulonTimer' then
		maavoSingin = false
		objectPlayAnimation('Tulon', 'idle', true)
	end
end

