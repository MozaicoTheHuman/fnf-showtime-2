local ivetteSingin = false
local maritzaSingin = false
local stun = false;

function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'stun note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DRAWNOTE_assets');
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
		end
	end

--3 monos--
--Mari
	makeAnimatedLuaSprite('mari', 'maritzamasterpiece', 160, 140)
	addAnimationByPrefix('mari', 'idle', 'danceleft', 24, false)
	addAnimationByPrefix('mari', 'left', 'left', 24, false)
	addAnimationByPrefix('mari', 'down', 'down', 24, false)
	addAnimationByPrefix('mari', 'up', 'up', 24, false)
	addAnimationByPrefix('mari', 'right', 'right', 24, false)
	scaleObject('mari', 1, 1);	
	addLuaSprite('mari', true)
--Ivette
	makeAnimatedLuaSprite('ibet', 'ivettemasterpiece', -650, 100)
	addAnimationByPrefix('ibet', 'idle', 'idle', 24, false)
	addAnimationByPrefix('ibet', 'left', 'left', 24, false)
	addAnimationByPrefix('ibet', 'down', 'down', 24, false)
	addAnimationByPrefix('ibet', 'up', 'up', 24, false)
	addAnimationByPrefix('ibet', 'right', 'right', 24, false)
	scaleObject('ibet', 1, 1);	
	addLuaSprite('ibet', false)
end

function goodNoteHit(id, direction, noteType, isSustainNote)
	--Nota stun
    if noteType == 'stun note' then
        triggerEvent('Screen Shake','0.2,0.01','')
        playSound('stunsound', 1);
        triggerEvent('Play Animation','stun','1')
    	setProperty('boyfriend.stunned', true);
    	stun = true;
    	runTimer('endStun', 1.4);
    end
end


function opponentNoteHit(id,data,type,sus)
	--Maritza and Maavo or Maritza Alone Characters Sing
	if (type == 'MainAndSecondCharacter' or type == 'SecondCharacter') then
		if data == 0 then
			objectPlayAnimation('mari', 'left', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);
		end
		if data == 1 then
			objectPlayAnimation('mari', 'down', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);
		end
		if data == 2 then
			objectPlayAnimation('mari', 'up', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);
		end
		if data == 3 then
			objectPlayAnimation('mari', 'right', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);
		end
	end
	--Ivette and Maavo or Ivette Alone Characters Sing
	if (type == 'MainAndThirdCharacter' or type == 'ThirdCharacter') then
		if data == 0 then
			objectPlayAnimation('ibet', 'left', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 1 then
			objectPlayAnimation('ibet', 'down', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 2 then
			objectPlayAnimation('ibet', 'up', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 3 then
			objectPlayAnimation('ibet', 'right', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
	end
	--All Characters Sing
	if (type == 'AllCharacters' or type == 'SecondAndThirdCharacter') then
		if data == 0 then
			objectPlayAnimation('mari', 'left', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);

			objectPlayAnimation('ibet', 'left', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 1 then
			objectPlayAnimation('mari', 'down', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);

			objectPlayAnimation('ibet', 'down', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 2 then
			objectPlayAnimation('mari', 'up', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);

			objectPlayAnimation('ibet', 'up', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
		if data == 3 then
			objectPlayAnimation('mari', 'right', true)
			maritzaSingin = true
			cancelTimer('endMari')
			runTimer('endMari', 0.7);

			objectPlayAnimation('ibet', 'right', true)
			ivetteSingin = true
			cancelTimer('endIbet')
			runTimer('endIbet', 0.7);
		end
	end	
end

function onBeatHit()
	if  ivetteSingin == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('ibet', 'idle', true)
		end
	end
	if 	maritzaSingin == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('mari', 'idle', true)
		end
	end
end

function onTimerCompleted(tag)
	--Nota stun
    if tag == 'endStun' then
        setProperty('boyfriend.stunned', false);
        stun = false;
    end
	--timer Mari
	if tag == 'endMari' then
		maritzaSingin = false
	end
	--timer Ivette
	if tag == 'endIbet' then
		ivetteSingin = false
	end
end