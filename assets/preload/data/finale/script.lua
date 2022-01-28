function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'stun note' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DRAWNOTE_assets');
				setPropertyFromGroup('unspawnNotes', i, 'ignoreNote', true);
		end
	end
end
local stun = false;
function goodNoteHit(id, direction, noteType, isSustainNote)
    if noteType == 'stun note' then
        triggerEvent('Screen Shake','0.2,0.01','')
        playSound('stunsound', 1);
    	characterPlayAnim('bf', 'stun', true);
    	setProperty('boyfriend.stunned', true);
    	stun = true;
    	runTimer('endStun', 1.5);
    end
end

function onTimerCompleted(tag)
    if tag == 'endStun' then
        setProperty('boyfriend.stunned', false);
        stun = false;
    end
end