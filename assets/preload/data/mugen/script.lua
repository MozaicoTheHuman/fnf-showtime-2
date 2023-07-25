local a = math.random(1,3)

local allowCountdown = false
function onStartCountdown()
	if not allowCountdown then
		runTimer('startText', 0.1);
		runTimer('countdown', 2.25)
		allowCountdown = true;
		--startCountdown()
		return Function_Stop;
	end
	return Function_Continue;
end

function onTimerCompleted(tag, loops, loopsLeft)
	if tag == 'startText' then
		playSound('mugen/ronaldIntro'..tostring(a))
		characterPlayAnim('dad','intro'..tostring(a))
	end
	if tag == 'countdown' then
		startCountdown()
	end
end

function onCreate()

	makeAnimatedLuaSprite('ko', 'koscreen', 300, 180);
	addAnimationByPrefix('ko', 'ko', 'ko', 60, false); 
	objectPlayAnimation('ko', 'ko'); 
	addLuaSprite('ko', false);	
	setLuaSpriteScrollFactor('ko',0,0)	
	setProperty('ko.alpha', 0)	
	setProperty('ko.scale.x',3.4)
	setProperty('ko.scale.y',3.4)
	
end	
function onStepHit()
	
	if curStep == 1552 then
		doTweenAlpha('ko','ko',255, 0.01)	
		objectPlayAnimation('ko','ko',true)	;		
        setProperty('camHUD.visible', false)	
   	 end
end

