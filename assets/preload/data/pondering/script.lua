function onCreate()

    makeLuaSprite('darkbg','pondering/darkbg',-130 , -750);
    addLuaSprite('darkbg',false);
	setLuaSpriteScrollFactor('darkbg',0,0)
	setProperty('darkbg.scale.x',999)
	setProperty('darkbg.scale.y',999)
	setProperty('darkbg.alpha', 0)	

    makeLuaSprite('light','pondering/light',0 , 0);
    addLuaSprite('light',true);
	setProperty('light.scale.x',1.8)
	setProperty('light.scale.y',1.5)
	setProperty('light.alpha', 0)	
	setLuaSpriteScrollFactor('light',1.15,1.15)	
	setObjectOrder('gfGroup',5)
	setBlendMode('light', 'add')	
	
    makeLuaSprite('blackbg2','pondering/darkbg',-130 , -750);
    addLuaSprite('blackbg2',true);
	setLuaSpriteScrollFactor('blackbg2',0,0)
	setProperty('blackbg2.scale.x',999)
	setProperty('blackbg2.scale.y',999)
	setProperty('blackbg2.alpha', 0)		
	
    makeLuaSprite('dibujanzo','pondering/dibujanzo',0 , 0);
    addLuaSprite('dibujanzo',true);
	setLuaSpriteScrollFactor('dibujanzo',0,0)
	setProperty('dibujanzo.scale.x',1.5)
	setProperty('dibujanzo.scale.y',1.5)
	setProperty('dibujanzo.alpha', 0)
	setObjectOrder('gfGroup',5)	
	
end

function onStepHit()
	
	if curStep == 1660 then
		doTweenAlpha('appearblackbg','darkbg',0.6, 0.01)
		doTweenAlpha('luz','light',0.6, 0.01)		
   	 end
	
	if curStep == 2122 then
		doTweenAlpha('fondooscuro','blackbg2',1, 0.01)
		doTweenAlpha('dibujanzo','dibujanzo',1, 5)
		doTweenAlpha('ripluz','light',0, 0.01)	
        setPropertyFromGroup('opponentStrums', 0, 'alpha', 0)
        setPropertyFromGroup('opponentStrums', 1, 'alpha', 0)
        setPropertyFromGroup('opponentStrums', 2, 'alpha', 0)
        setPropertyFromGroup('opponentStrums', 3, 'alpha', 0)
        setPropertyFromGroup('playerStrums', 0, 'alpha', 0)
        setPropertyFromGroup('playerStrums', 1, 'alpha', 0)
        setPropertyFromGroup('playerStrums', 2, 'alpha', 0)
        setPropertyFromGroup('playerStrums', 3, 'alpha', 0)		
    	end

	if curStep == 2132 then
		doTweenAlpha('dibujanzo','dibujanzo',1, 6.5)	
    	end

	if curStep == 2290 then
		doTweenAlpha('dibujanzo','dibujanzo',0, 0.01)		
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
