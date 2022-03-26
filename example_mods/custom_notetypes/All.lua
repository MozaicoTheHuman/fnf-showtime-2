function onCreate()
	--Iterate over all notes
	for i = 0, getProperty('unspawnNotes.length')-1 do
		--Check if the note is an PicoSign
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'All' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'DOUNOTE_assets'); --Change texture

			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then --Doesn't let Dad/Opponent notes get ignored
			end
		end
	end
	--debugPrint('Script started!')
end