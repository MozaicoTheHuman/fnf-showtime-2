local ivetteSingin = false
local maritzaSingin = false
local stun = false;
local striptween = false

function onUpdate()
	if striptween == false then
		setProperty('theStrip1.alpha', 0)
		setProperty('theStrip2.alpha', 0)
	end
	if striptween == true then
		setProperty('theStrip1.alpha', 1)
		setProperty('theStrip2.alpha', 1)
		if getProperty('theStrip1.y') < -974 then
			setProperty('theStrip1.y', getProperty('theStrip1.y')+40)
		end
		if 720 < getProperty('theStrip2.y') then
			setProperty('theStrip2.y', getProperty('theStrip2.y')-40)
		end
	end
end

function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'stun note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DRAWNOTE_assets');
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
		end
	end


    --SKY TRANSITION
    makeLuaSprite('theSkyT','mabosolo/sky-trans',-1300 , -750);
	addLuaSprite('theSkyT',false);
    setProperty('theSkyT.alpha', 0)
    --GROUND TRANSITION
    makeLuaSprite('theGroundT','mabosolo/bg-trans',-1300 , -750);
	addLuaSprite('theGroundT',false);
    setProperty('theGroundT.alpha', 0)
    --SKY SOLO
    makeLuaSprite('theSkyS','mabosolo/sky',-1300 , -750);
    addLuaSprite('theSkyS',false);
    setProperty('theSkyS.alpha', 0)
    --GROUND SOLO
    makeLuaSprite('theGroundS','mabosolo/bg',-1300 , -750);
    addLuaSprite('theGroundS',false);
    setProperty('theGroundS.alpha', 0)
	--Mari Solo
	makeAnimatedLuaSprite('mari2', 'maritzamasterpiece', 160, 140)
    addAnimationByPrefix('mari2', 'show', 'show', 24, true)
	scaleObject('mari2', 1, 1);	
	addLuaSprite('mari2', true)	
    setProperty('mari2.alpha',0)
    --Ibet Solo 1
    makeAnimatedLuaSprite('ibet2', 'ivettemasterpiece', -650, 100)
	addAnimationByPrefix('ibet2', 'shuo', 'shuo', 24, true)
	scaleObject('ibet2', 1, 1);	
	addLuaSprite('ibet2', false)
    setProperty('ibet2.alpha',0)  
	
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

	makeLuaSprite('theBlack','mabosolo/black-thing',-1300 , -750);
	addLuaSprite('theBlack',true);
	setProperty('theBlack.alpha',0) 

	--Strip 1
	makeLuaSprite('theStrip1','black-strip',-460 , -393);
	addLuaSprite('theStrip1',true);
	setLuaSpriteScrollFactor('theStrip1',0, 0);
	scaleObject('theStrip1', 4, 2);	

	--Strip 2
	makeLuaSprite('theStrip2','black-strip',-460 , 859);
	addLuaSprite('theStrip2',true);
	setLuaSpriteScrollFactor('theStrip2',0, 0);
	scaleObject('theStrip2', 4, 2);	
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

function onStepHit()
	if curStep == 1024 then
		setProperty('mari2.alpha',1)
        setProperty('mari.alpha',0)	
    end

    if curStep == 895 then
        runTimer('transStart', 0.06);
    end

	if curStep == 1408 then
        setProperty('mari.alpha', 1)
		setProperty('ibet.alpha', 1)
		setProperty('theSkyT.alpha', 0)
        setProperty('theGroundT.alpha', 0)
        setProperty('theSkyS.alpha', 0)
        setProperty('theGroundS.alpha', 0)
		striptween = false
		setProperty('ibet2.alpha',0) 
		setProperty('mari2.alpha',0) 
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
    if tag == 'transStart' then
		striptween = true
		setProperty('theBlack.alpha',1) 
		runTimer('transMid', 0.06);
		setProperty('gf.alpha',0)
    end
    if tag == 'transMid' then
        setProperty('theBlack.alpha',0) 
        setProperty('theSkyT.alpha', 1)
        setProperty('theGroundT.alpha', 1)
        runTimer('transEnd', 0.06);
        solo = true
		doTweenColor('bfColorTween', 'mari', '000000', 0.01, 'linear')
        setProperty('ibet2.alpha',1) 
        setProperty('ibet.alpha',0)
    end
    if tag == 'transEnd' then
        setProperty('theSkyT.alpha', 0)
        setProperty('theGroundT.alpha', 0)
        setProperty('theSkyS.alpha', 1)
        setProperty('theGroundS.alpha', 1)
    end
end