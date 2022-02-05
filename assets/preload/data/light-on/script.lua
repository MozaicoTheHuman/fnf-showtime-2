function onCreate()
	makeAnimatedLuaSprite('Tulon', 'Maavo', 900, 100)
	addAnimationByPrefix('Tulon', 'idle', 'idle', 24, false)
	addAnimationByPrefix('Tulon', 'left', 'left', 24, false)
	addAnimationByPrefix('Tulon', 'down', 'down', 24, false)
	addAnimationByPrefix('Tulon', 'up', 'up', 24, false)
	addAnimationByPrefix('Tulon', 'right', 'right', 24, false)
	scaleObject('Tulon', -1, 1);	
	addLuaSprite('Tulon', true)

    makeAnimatedLuaSprite('Foca culia', 'foca ql', -600, 300)
	addAnimationByPrefix('Foca culia', 'idle', 'idle', 24, false)
	addAnimationByPrefix('Foca culia', 'left', 'left', 24, false)
	addAnimationByPrefix('Foca culia', 'down', 'down', 24, false)
	addAnimationByPrefix('Foca culia', 'up', 'up', 24, false)
	addAnimationByPrefix('Foca culia', 'right', 'right', 24, false)
	scaleObject('Foca culia', 1, 1);	
	addLuaSprite('Foca culia', true)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Both' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DOUNOTE_assets');
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			end
		end
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then
		objectPlayAnimation('Tulon', 'idle')
        objectPlayAnimation('Foca culia', 'idle')
	end
end

function goodNoteHit(id, noteData, noteType, isSustainNote)
	if noteType == 'No Animation' then
		if noteData == 0 then
		    objectPlayAnimation('Tulon', 'left', true)
	    end
	    if noteData == 1 then
		    objectPlayAnimation('Tulon', 'down', true)
	    end
	    if noteData == 2 then
		    objectPlayAnimation('Tulon', 'up', true)
	    end
	    if noteData == 3 then
		    objectPlayAnimation('Tulon', 'right', true)
		end
	end	
    if noteType == 'Both' then
		if noteData == 0 then
             objectPlayAnimation('Tulon', 'left', true)
		end
		if noteData == 1 then
            objectPlayAnimation('Tulon', 'down', true)
		end
		if noteData == 2 then
            objectPlayAnimation('Tulon', 'up', true)
		end
		if noteData == 3 then
            objectPlayAnimation('Tulon', 'right', true)
        end
    end
end

function opponentNoteHit(id,data,type,sus)
	if type == 'No Animation' then
		if data == 0 then
		    objectPlayAnimation('Foca culia', 'left', true)
	    end
	    if data == 1 then
		    objectPlayAnimation('Foca culia', 'down', true)
	    end
	    if data == 2 then
		    objectPlayAnimation('Foca culia', 'up', true)
	    end
	    if data == 3 then
		    objectPlayAnimation('Foca culia', 'right', true)
		end
	end	
    if type == 'Both' then
		if data == 0 then
             objectPlayAnimation('Foca culia', 'left', true)
		end
		if data == 1 then
            objectPlayAnimation('Foca culia', 'down', true)
		end
		if data == 2 then
            objectPlayAnimation('Foca culia', 'up', true)
		end
		if data == 3 then
            objectPlayAnimation('Foca culia', 'right', true)
        end
    end
end