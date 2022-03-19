local maavoSingin = false
local focaSingin = false

function onUpdate()
	setProperty('iconP1.y', 565)
	setProperty('iconP1.x', 875)
	setProperty('iconP2.x', 270)
	setProperty('iconP2.y', 550)
end

function onCreate()

	makeAnimatedLuaSprite('Tulon', 'Maritza', 600, 225)
	addAnimationByPrefix('Tulon', 'idle', 'maritza_danceright', 24, false)
	addAnimationByPrefix('Tulon', 'left', 'maritza_right', 24, false)
	addAnimationByPrefix('Tulon', 'down', 'maritza_down', 24, false)
	addAnimationByPrefix('Tulon', 'up', 'maritza_up', 24, false)
	addAnimationByPrefix('Tulon', 'right', 'maritza_left', 24, false)
	scaleObject('Tulon', 1, 1);	
	addLuaSprite('Tulon', false)

	makeLuaSprite('theHealth','lifebars/BenjaminMartin', 172, 527);
	addLuaSprite('theHealth',false);
	scaleObject('theHealth', 0.93, 0.93);
	setObjectCamera('theHealth', 'hud')
	setObjectOrder('theHealth', getObjectOrder('healthBar'))

    makeAnimatedLuaSprite('Foca culia', 'foca ql', -350, 265)
	addAnimationByPrefix('Foca culia', 'idle', 'benjastand', 24, false)
	addAnimationByPrefix('Foca culia', 'left', 'left', 24, false)
	addAnimationByPrefix('Foca culia', 'down', 'down', 24, false)
	addAnimationByPrefix('Foca culia', 'up', 'up', 24, false)
	addAnimationByPrefix('Foca culia', 'right', 'right', 24, false)
	scaleObject('Foca culia', 1, 1);	
	addLuaSprite('Foca culia', false)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Both' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DOUNOTE_assets');
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			end
		end
	end
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

--La wea para que maavo cante
function opponentNoteHit(id,data,type,sus)
	if type == 'No Animation' then
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
    if type == 'Both' then
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

--La wea para que gf cante
function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'No Animation' then
		if noteData == 0 then
		    objectPlayAnimation('Tulon', 'left', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if noteData == 1 then
		    objectPlayAnimation('Tulon', 'down', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if noteData == 2 then
		    objectPlayAnimation('Tulon', 'up', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
	    end
	    if noteData == 3 then
		    objectPlayAnimation('Tulon', 'right', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
		end
	end	
    if noteType == 'Both' then
		if noteData == 0 then
             objectPlayAnimation('Tulon', 'left', true)
			 maavoSingin = true
			 cancelTimer('tulonTimer')
			 runTimer('tulonTimer', 0.7);
		end
		if noteData == 1 then
            objectPlayAnimation('Tulon', 'down', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
		end
		if noteData == 2 then
            objectPlayAnimation('Tulon', 'up', true)
			maavoSingin = true
			cancelTimer('tulonTimer')
			runTimer('tulonTimer', 0.7);
		end
		if noteData == 3 then
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

