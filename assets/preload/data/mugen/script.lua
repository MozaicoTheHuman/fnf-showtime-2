math.randomseed(os.time()) -- random initialize
math.random(); math.random(); math.random() 
local a = math.random(1,3)

function onCreate()
	makeLuaSprite('icon1', 'mugenHud/maavoMUGEN', 900, 560)
	scaleObject('icon1', 0.8, 0.8);	
	setObjectCamera('icon1', 'hud')
	addLuaSprite('icon1',true)
	setProperty('icon1.flipX', true)
	
	makeLuaSprite('icon2', 'mugenHud/clown', 268, 560)
	scaleObject('icon2', 0.8, 0.8);	
	setObjectCamera('icon2', 'hud')
	addLuaSprite('icon2',true)
	
	makeAnimatedLuaSprite('bggfx', 'kfm/gfx',-600, -200); 
	addAnimationByPrefix('bggfx', 'idle', 'bg', 24, true); 
	scaleObject('bggfx', 4, 4);	
	objectPlayAnimation('bggfx', 'idle')

	
	makeAnimatedLuaSprite('gfx', 'kfm/gfx', 700, 115); 
	addAnimationByPrefix('gfx', 'idle', 'SSBUportrait', 24, false); 
	objectPlayAnimation('gfx', 'idle')
	
	makeAnimatedLuaSprite('spark', 'kfm/gfx', 505, 300); 
	addAnimationByPrefix('spark', 'idle', 'hyperspark', 24, true); 
	objectPlayAnimation('spark', 'idle')
	scaleObject('spark', 1.2, 1.2);

	
end

local allowCountdown = false
function onStartCountdown()
	if not allowCountdown then
		setProperty('inCutscene', true);
		runTimer('startText', 0.1);
		runTimer('countdown', 2)
		allowCountdown = true;
		--startCountdown()
		return Function_Stop;
	end
	return Function_Continue;
end

function onUpdate()
	abajo = getPropertyFromClass('ClientPrefs', 'downScroll')
	setProperty('iconP1.alpha', 0)
	setProperty('iconP2.alpha', 0)
	if abajo == false then
		setProperty('healthBarBG.x', 334)
		setProperty('healthBarBG.scale.x', 0.9)	
		setProperty('healthBarBG.scale.y', 1.5)	
		setProperty('healthBar.scale.x', 0.9)	
		setProperty('healthBar.scale.y', 1.5)	
		setProperty('healthBarBG.y', 630)
		setProperty('healthBar.y', 636)
		
	else
		setProperty('icon1.y',-10)
		setProperty('icon2.y',-10)
		setProperty('healthBarBG.x', 334)
		setProperty('healthBarBG.scale.x', 0.9)	
		setProperty('healthBarBG.scale.y', 1.5)	
		setProperty('healthBar.scale.x', 0.9)	
		setProperty('healthBar.scale.y', 1.5)	
		setProperty('healthBarBG.y', 60)
		setProperty('healthBar.y', 66)
	end
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startText' then
		if a == 1 then
			playSound('payaso1')
			characterPlayAnim('dad','intro1')
		end
		if a == 2 then
			playSound('payaso2')
			characterPlayAnim('dad','intro2')
		end
		if a == 3 then
			playSound('payaso3')
			characterPlayAnim('dad','intro3')
		end
	end
	if tag == 'countdown' then
		setProperty('inCutscene', false);
		startCountdown()
	end
end
