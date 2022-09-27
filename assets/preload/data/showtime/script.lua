local marising = false
local ivdance = false
local stuneao = false
local baila = false
local manten = false
function onCreate()

	makeLuaSprite('flash', '', -400, 0);
    makeGraphic('flash',2800,1800,'000000')
	addLuaSprite('flash', true);
	setLuaSpriteScrollFactor('flash',0,0)
	setProperty('flash.scale.x',2)
	setProperty('flash.scale.y',2)
	setProperty('flash.alpha',0)

    makeLuaSprite('redSky','mabosolo/sky',-1300 , -750);
    addLuaSprite('redSky',false);
	setProperty('redSky.alpha', 0)
	
    makeLuaSprite('suelodarks','mabosolo/bg',-1300 , -750);
    addLuaSprite('suelodarks',false);
	setProperty('suelodarks.alpha', 0)

	makeAnimatedLuaSprite('mari', 'maritzamasterpiece',160, 140); 
	addAnimationByPrefix('mari', 'idle', 'danceleft', 24, false); 
	addAnimationByPrefix('mari', 'show', 'show', 24, true)
    addAnimationByPrefix('mari', '0', 'left', 26, false); 
    addAnimationByPrefix('mari', '1', 'down', 26, false); 
    addAnimationByPrefix('mari', '2', 'up', 26, false); 
    addAnimationByPrefix('mari', '3', 'right', 26, false); 
	objectPlayAnimation('mari', 'idle'); 
	addLuaSprite('mari', false); 
	
	makeAnimatedLuaSprite('iv', 'ivettemasterpiece', -650, 65); 
	addAnimationByPrefix('iv', 'idle', 'IvetteIdle', 24, false); 
	addAnimationByPrefix('iv', 'shuo', 'shuo', 24, true)
    addAnimationByPrefix('iv', '0', 'Izquierda', 26, false); 
    addAnimationByPrefix('iv', '1', 'Abajo', 26, false); 
    addAnimationByPrefix('iv', '2', 'Arriba', 26, false); 
    addAnimationByPrefix('iv', '3', 'Derecha', 26, false); 
	objectPlayAnimation('iv', 'idle'); 
	addLuaSprite('iv', false); 
	
	
	makeLuaSprite('black1','black-strip',-460 , -900);
	addLuaSprite('black1',true);
	setLuaSpriteScrollFactor('black1',0, 0);
	scaleObject('black1', 4, 2);	

	makeLuaSprite('black2','black-strip',-460 , 1200);
	addLuaSprite('black2',true);
	setLuaSpriteScrollFactor('black2',0, 0);
	scaleObject('black2', 4, 2);	
	
	setObjectOrder('gfGroup',5)
	setObjectOrder('mari',10)
end

function onUpdate()

	if manten == true then
		if getProperty('black1.y') < -974 then
				setProperty('black1.y', getProperty('black1.y')+40)
		end
		if 720 < getProperty('black2.y') then
			setProperty('black2.y', getProperty('black2.y')-40)
		end
	end
end

function onBeatHit()
	if manten == false then

		if 	ivdance == false then
			if curBeat % 2 == 0 then
				objectPlayAnimation('iv', 'idle', true)
			end
		end
	end
	if baila == false then
		if 	marising == false then
			if curBeat % 2 == 0 then
				objectPlayAnimation('mari', 'idle', true)
			end
		end
	end
end

function onStepHit()
	if curStep == 895 then
		setProperty('flash.alpha',1)
		doTweenAlpha('flTw','flash',0,1.3,'linear')
        marising = true
		manten = true
		ivdance = true
		objectPlayAnimation('iv', 'shuo',true);
		doTweenColor('mariColorTween', 'mari', '000000', 0.01, 'linear')
		doTweenAlpha('appearredsky','redSky',1, 0.4)
		doTweenAlpha('suelo','suelodarks',1, 0.4)
		doTweenY('cutscenemoment', 'black1',-393, 0.4,'expoIn')
		doTweenY('cutscenemoment2', 'black2',859, 0.4,'expoIn')
		
    end
	
	if curStep == 1024 then
		baila = true
		objectPlayAnimation('mari','show',true)
	
    end
	
	if curStep == 1408 then
		manten = false
		baila = false
		doTweenAlpha('dissapearsky','redSky',0, 0.4)
		doTweenAlpha('chaosuelo','suelodarks',0, 0.4)
		doTweenY('cutscenemoment', 'black1',-900, 0.4,'expoOut')
		doTweenY('cutscenemoment2', 'black2',1200, 0.4,'expoOut')
		doTweenColor('2ndmariColorTween', 'mari', 'ffffff', 0.01, 'linear')
    end
end

function goodNoteHit(id,d,t,s)
    if t == 'stun note' then
        triggerEvent('Screen Shake','0.2,0.01','')
        playSound('stunsound', 1);
        triggerEvent('Play Animation','stun','1')
    	setProperty('boyfriend.stunned', true);
    	stuneao = true;
    	runTimer('nostuneao', 1.4);
    end
end


lastNote = {0, ""}

function opponentNoteHit(id,d,t,s)

    lastNote[1] = d
    lastNote[2] = t
	
    if lastNote[2] == "MainAndSecondCharacter" or lastNote[2] == "SecondCharacter" or lastNote[2] == "AllCharacters" or lastNote[2] == "SecondAndThirdCharacter" or lastNote[2] == "All" then
		marising = true
		cancelTimer('cantaadenuevo')
		runTimer('cantaadenuevo',0.16)
		objectPlayAnimation('mari', lastNote[1],true)
    end
	
	if lastNote[2] == "MainAndThirdCharacter " or lastNote[2] == "ThirdCharacter" or lastNote[2] == "AllCharacters" or lastNote[2] == "SecondAndThirdCharacter" or lastNote[2] == "All" then
		ivdance = true
		cancelTimer('ivdancin')
		runTimer('ivdancin',0.16)
		objectPlayAnimation('iv', lastNote[1],true)
    end
end

function onTimerCompleted(tag)
	
    if tag == 'cantaadenuevo' then
		marising = false
	end
	if tag == 'ivdancin' then
		ivdance = false
	end
	if tag == 'nostuneao' then
        setProperty('boyfriend.stunned', false);
        stuneao = false;
    end
end
