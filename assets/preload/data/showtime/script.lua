local maDance = false
local dancin = false

local ivDance = false

local stuned = false

local solo = false

function onCreate()
	makeLuaSprite('flash', '', 0, 0)
    makeGraphic('flash',1286,724,'000000')
	setLuaSpriteScrollFactor('flash',0,0)
	setObjectCamera('flash', 'camhud')
	setProperty('flash.visible', false)
	addLuaSprite('flash', true)

	makeAnimatedLuaSprite('redloop', 'show/sky-red', -150, -40)
	addAnimationByPrefix('redloop', 'intro', 'intro', 56, false)
	addAnimationByPrefix('redloop', 'loop', 'loop', 60, true)
	objectPlayAnimation('redloop', 'intro', false)
	addLuaSprite('redloop', false)
	setProperty('redloop.scale.x',2)
	setProperty('redloop.scale.y',2)
	setProperty('redloop.visible', false)
	setObjectOrder('redloop', 1)
	
	makeAnimatedLuaSprite('mari', 'maritzamasterpiece', 260, 100)
	addAnimationByPrefix('mari', 'idle', 'danceleft', 24, false)
    addAnimationByPrefix('mari', '0', 'left', 26, false)
    addAnimationByPrefix('mari', '1', 'down', 26, false)
    addAnimationByPrefix('mari', '2', 'up', 26, false)
    addAnimationByPrefix('mari', '3', 'right', 26, false)
	addAnimationByPrefix('mari', 'showIdle', 'shou', 24, false)
	addAnimationByPrefix('mari', 'showDance', 'show', 24, true)
	objectPlayAnimation('mari', 'idle')
	addLuaSprite('mari', false)
	
	makeAnimatedLuaSprite('iv', 'ivettemasterpiece', -580, 15)
	addAnimationByPrefix('iv', 'idle', 'IvetteIdle', 24, false)
    addAnimationByPrefix('iv', '0', 'Izquierda', 26, false)
    addAnimationByPrefix('iv', '1', 'Abajo', 26, false) 
    addAnimationByPrefix('iv', '2', 'Arriba', 26, false)
    addAnimationByPrefix('iv', '3', 'Derecha', 26, false)
	addAnimationByPrefix('iv', 'showIdle', 'shuo', 24, true)
	objectPlayAnimation('iv', 'idle')
	addLuaSprite('iv', false)
	
	local gfPosition = 5
	
	if getPropertyFromClass(ClientPrefs, lowQuality) == true then
		gfPosition = 3
	end
	
	setObjectOrder('gfGroup', gfPosition)
end

function onBeatHit()
	if solo == false then
		if 	ivDance == false then
			objectPlayAnimation('iv', 'idle', true)
		end
		if 	maDance == false and curBeat % 2 == 0 then
			objectPlayAnimation('mari', 'idle', true)
		end
	else
		if dancin == false then
			if 	maDance == false and curBeat % 2 == 0 then
				objectPlayAnimation('mari', 'showIdle', true)
			end
		end
	end
end

function onStepHit()
	if curStep == 895 then
		setProperty('flash.visible', true)
		setProperty('gf.alpha', 0)
		setProperty('redloop.visible', true)		
		setProperty('redloop.animation.curAnim.curFrame', 0)
		doTweenAlpha('FLASH','flash',0,1,'linear')
       	maDance = true
		solo = true
		ivDance = false
		objectPlayAnimation('mari', 'showIdle',true)
		objectPlayAnimation('iv', 'showIdle',true)
   	 end

	if curStep == 1022 then
		objectPlayAnimation('redloop','intro',true)
    end
	
	if curStep == 1024 then
		dancin = true
		objectPlayAnimation('mari','showDance',true)
		objectPlayAnimation('redloop','loop',true)		
    end
	
	if curStep == 1408 then
		solo = false
		dancin = false
		doTweenAlpha('gbSky','redloop',0, 0.3)	
		doTweenAlpha('hiGF','gf',1, 0.3)		
    end
end

lastNote = {0, ""}

function opponentNoteHit(id,d,t,s)
    lastNote[1] = d
    lastNote[2] = t
	
    if lastNote[2] == "MainAndSecondCharacter" or lastNote[2] == "SecondCharacter" or lastNote[2] == "AllCharacters" or lastNote[2] == "SecondAndThirdCharacter" then
		maDance = true
		cancelTimer('mariNote')
		runTimer('mariNote',0.16)
		objectPlayAnimation('mari', lastNote[1],true)
    end
	if lastNote[2] == "MainAndThirdCharacter " or lastNote[2] == "ThirdCharacter" or lastNote[2] == "AllCharacters" or lastNote[2] == "SecondAndThirdCharacter" then
		ivDance = true
		cancelTimer('ivNote')
		runTimer('ivNote',0.16)
		objectPlayAnimation('iv', lastNote[1],true)
    end
end

function onTimerCompleted(tag)
    if tag == 'mariNote' then
		maDance = false
	end
	if tag == 'ivNote' then
		ivDance = false
	end
	if tag == 'nostuneao' then
        stuned = false;
        setProperty('boyfriend.stunned', false);
    end
end
