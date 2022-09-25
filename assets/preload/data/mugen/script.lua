

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