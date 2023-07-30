function onCreate()

    makeLuaSprite('darkbg','pondering/darkbg',-130 , -750);
    addLuaSprite('darkbg',true);
	setLuaSpriteScrollFactor('darkbg',0,0)
	setProperty('darkbg.scale.x',999)
	setProperty('darkbg.scale.y',999)
	setProperty('darkbg.alpha', 0)
	setObjectOrder('gfGroup',2)	
	setBlendMode('darkbg', 'multiply')	
	
    makeLuaSprite('blackbg2','pondering/darkbg',-130 , -750);
    addLuaSprite('blackbg2',true);
	setLuaSpriteScrollFactor('blackbg2',0,0)
	setProperty('blackbg2.scale.x',999)
	setProperty('blackbg2.scale.y',999)
	setProperty('blackbg2.alpha', 0)		
	
    makeLuaSprite('dibujanzo','pondering/dibujanzo',0 , 0);
    addLuaSprite('dibujanzo',true);
	setLuaSpriteScrollFactor('dibujanzo',0,0)
	setProperty('dibujanzo.scale.x',2.3)
	setProperty('dibujanzo.scale.y',2.3)
	setProperty('dibujanzo.alpha', 0)

    makeLuaSprite('ponderinglight','pondering/Showtime_mall_night_lights',-300, -985);
    addLuaSprite('ponderinglight',true);
	setProperty('ponderinglight.scale.x',1.4)
	setProperty('ponderinglight.scale.y',1.4)
	setProperty('ponderinglight.alpha', 80)		
	setObjectOrder('gfGroup',5)
	setBlendMode('ponderinglight', 'add')	

    makeLuaSprite('light','pondering/light', 200 , -70);
    addLuaSprite('light',true);
	setProperty('light.scale.x',1.5)
	setProperty('light.scale.y',2.0)
	setProperty('light.alpha', 0)	
	setLuaSpriteScrollFactor('light',1.05,1.05)	
	setObjectOrder('gfGroup',5)
	setBlendMode('light', 'add')	
	
	makeLuaSprite('light2','pondering/light', 1500 , -70);
    addLuaSprite('light2',true);
	setProperty('light2.scale.x',1.5)
	setProperty('light2.scale.y',2.0)
	setProperty('light2.alpha', 0)	
	setLuaSpriteScrollFactor('light2',1.05,1.05)	
	setObjectOrder('gfGroup',5)
	setBlendMode('light2', 'add')

    makeLuaSprite('2light','pondering/lighttransition', 520 , 140);
    addLuaSprite('2light',true);
	setProperty('2light.scale.x',3.0)
	setProperty('2light.scale.y',4.0)
	setProperty('2light.alpha', 0)	
	setLuaSpriteScrollFactor('2light',1.05,1.05)	
	setObjectOrder('gfGroup',5)
	setBlendMode('2light', 'add')	
	
	makeLuaSprite('2light2','pondering/lighttransition', 1760 , 140);
    addLuaSprite('2light2',true);
	setProperty('2light2.scale.x',3.0)
	setProperty('2light2.scale.y',4.0)
	setProperty('2light2.alpha', 0)	
	setLuaSpriteScrollFactor('light2',1.05,1.05)	
	setObjectOrder('gfGroup',5)
	setBlendMode('2light2', 'add')	
	
end

function onStepHit()
	
	if curStep == 1660 then
		doTweenAlpha('appearblackbg','darkbg',0.55, 0.01)		
		doTweenAlpha('when','ponderinglight',0.5, 0.01)			
		doTweenAlpha('luz','light',1, 0.01)		
		doTweenAlpha('luz2','light2',1, 0.01)
		doTweenAlpha('2luz','2light',1, 0.01)		
		doTweenAlpha('2luz2','2light2',1, 0.01)		
   	 end

	if curStep == 1661 then	
		doTweenAlpha('luzxd','light',0.9, 1.1)		
		doTweenAlpha('luz2xd','light2',0.9, 1.1)
		doTweenAlpha('2luzxd','2light',0.1, 1.1)		
		doTweenAlpha('2luz2xd','2light2',0.1, 1.1)		
   	 end		
	
	if curStep == 2048 then
		doTweenAlpha('appearblackbg','darkbg',0.7, 0.02)		
		doTweenAlpha('luz','light',0, 0.01)		
		doTweenAlpha('luz2','light2',0, 0.01)
		doTweenAlpha('2luz','2light',0, 0.3)		
		doTweenAlpha('2luz2','2light2',0, 0.3)		
   	 end
	
	
	if curStep == 2122 then
		doTweenAlpha('fondooscuro','blackbg2',1, 0.01)
		doTweenAlpha('dibujanzo','dibujanzo',1, 5)
		doTweenAlpha('ripluz','light',0, 0.01)	
        setProperty('camHUD.visible', false);  	
    	end

	if curStep == 2122 then
		if getPropertyFromClass('ClientPrefs', 'language')	== 'English' then
			doTweenAlpha('dibujanzo','dibujanzo',1, 6.5)			
			doTweenAlpha('subs-eng','subs-eng',1, 0.3)	
			objectPlayAnimation('subs-eng','subs',true)	
			
		else
			doTweenAlpha('dibujanzo','dibujanzo',1, 6.5)			
			doTweenAlpha('subs-esp','subs-esp',1, 0.3)	
			objectPlayAnimation('subs-esp','subs',true)		
    	end
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
