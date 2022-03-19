local maavoSingin = false

function onCreate()
	makeAnimatedLuaSprite('theHealth', 'healthBarShit/healthBarMUGEN', 260, 585)
	addAnimationByPrefix('theHealth', 'healthBarMUGEN', 'healthBarMUGEN', 0, false)
	scaleObject('theHealth', 0.8, 0.8);	
	addLuaSprite('theHealth', true)
	setObjectCamera('theHealth', 'hud')

end

function onUpdate()
	setProperty('Tulon.cameras', 'camHUD')
	setProperty('theHealth.animation.curAnim.curFrame', getProperty('health')/2*100)
	setProperty('healthBar.alpha', 0)
	setProperty('healthBarBG.alpha', 0)
	setProperty('iconP1.alpha', 0)
	setProperty('iconP2.alpha', 0)
end