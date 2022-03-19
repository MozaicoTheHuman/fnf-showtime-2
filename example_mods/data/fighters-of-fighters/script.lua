local maavoSingin = false

function onCreate()
	makeAnimatedLuaSprite('theHealth', 'healthBarShit/healthBarMUGEN', 260, 585)
	addAnimationByPrefix('theHealth', 'healthBarMUGEN', 'healthBarMUGEN', 0, false)
	scaleObject('theHealth', 0.8, 0.8);	
	addLuaSprite('theHealth', true)
	setObjectCamera('theHealth', 'hud')


	makeAnimatedLuaSprite('Tulon', 'Maavo', 900, 75)
	addAnimationByPrefix('Tulon', 'idle', 'idle', 24, false)
	addAnimationByPrefix('Tulon', 'left', 'right', 24, false)
	addAnimationByPrefix('Tulon', 'down', 'down', 24, false)
	addAnimationByPrefix('Tulon', 'up', 'up', 24, false)
	addAnimationByPrefix('Tulon', 'right', 'left', 24, false)
	scaleObject('Tulon', -1, 1);	
	addLuaSprite('Tulon', true)

	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'Both' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_mugen');
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then
			end
		end
	end
end

function onBeatHit()
	if curBeat % 2 == 0 then

	end
	if 	maavoSingin == false then
	    if curBeat % 2 == 0 then
		    objectPlayAnimation('Tulon', 'idle', true)
		end
	end
end

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
	if tag == 'tulonTimer' then
		maavoSingin = false
		objectPlayAnimation('Tulon', 'idle', true)
	end
end

function onUpdate()
	setProperty('Tulon.cameras', 'camHUD')
	setProperty('theHealth.animation.curAnim.curFrame', getProperty('health')/2*100)
	setProperty('healthBar.alpha', 0)
	setProperty('healthBarBG.alpha', 0)
	setProperty('iconP1.alpha', 0)
	setProperty('iconP2.alpha', 0)
end