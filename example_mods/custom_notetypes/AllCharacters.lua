function onCreate()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if getPropertyFromGroup('unspawnNotes', i, 'noteType') == 'AllCharacters' then
			setPropertyFromGroup('unspawnNotes', i, 'texture', 'NOTE_assets');
			if getPropertyFromGroup('unspawnNotes', i, 'mustPress') then 
			end
		end
	end
end