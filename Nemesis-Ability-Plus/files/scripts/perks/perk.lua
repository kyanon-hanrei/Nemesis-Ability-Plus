dofile_once("data/scripts/lib/utilities.lua")
dofile_once( "data/scripts/perks/perk_list.lua" )
--dofile_once("mods/noita-nemesis/files/store.lua")


local get_perk_flag_name = function( perk_id )
	return "PERK_" .. perk_id
end

function np_perk_reroll_perks( entity_item )

	local perk_spawn_pos = {}
	--local perk_count = 0

	-- remove all perk items (also this one!) ----------------------------
	local all_perks = EntityGetWithTag( "perk" )
	
	local npoints = 0
	local reroll_count = 0
	
	
	if NEMESIS.points ~= nil then
		npoints = NEMESIS.points
	end
	
	if NEMESIS.np_reroll_count ~= nil then
		reroll_count = NEMESIS.np_reroll_count
	end
	
	
	local cost = 25 * math.pow( 2, reroll_count )
	
	local x, y
	if ( npoints >= cost) then
		npoints = npoints - cost
		if ( #all_perks > 0 ) then
			SetRandomSeed( GameGetFrameNum(), GameGetFrameNum() - 523 )
			local target_count = Random(1, #all_perks)
			for i,entity_perk in ipairs(all_perks) do
				if (( entity_perk ~= nil ) and ( i == target_count )) then
					--perk_count = perk_count + 1
					x, y = EntityGetTransform( entity_perk )
					table.insert( perk_spawn_pos, { x, y } )
	
					EntityKill( entity_perk )
				end
			end
		end

		--[[
		local perk_reroll_count = tonumber( GlobalsGetValue( "TEMPLE_PERK_REROLL_COUNT", "0" ) )
		perk_reroll_count = perk_reroll_count + 1
		GlobalsSetValue( "TEMPLE_PERK_REROLL_COUNT", tostring( perk_reroll_count ) )
		]]
	
		reroll_count = reroll_count + 1

		--[[
		local count = perk_count
		local width = 60
		local item_width = width / count
		]]

		local perks = perk_get_spawn_order()

		for i,v in ipairs(perk_spawn_pos) do
			x = v[1]
			y = v[2]

			local next_perk_index = tonumber( GlobalsGetValue( "TEMPLE_REROLL_PERK_INDEX", tostring(#perks) ) )
			local perk_id = perks[next_perk_index]
		
			while( perk_id == nil or perk_id == "" ) do
				-- if we over flow
				perks[next_perk_index] = "LEGGY_FEET"
				next_perk_index = next_perk_index - 1		
				if next_perk_index <= 0 then
					next_perk_index = #perks
				end
				perk_id = perks[next_perk_index]
			end

			next_perk_index = next_perk_index - 1
			if next_perk_index <= 0 then
				next_perk_index = #perks
			end
		
			GlobalsSetValue( "TEMPLE_REROLL_PERK_INDEX", tostring(next_perk_index) )

			GameAddFlagRun( get_perk_flag_name(perk_id) )
			
			perk_spawn( x, y, perk_id )
			EntityLoad( "data/entities/particles/perk_reroll.xml", x, y )
			GamePlaySound ( "data/audio/Desktop/event_cues.bank" ,  "event_cues/shop_item/create" ,  x, y )
		end
	end
	
	if NEMESIS.points ~= nil then
		NEMESIS.points = npoints
	end
	
	if NEMESIS.np_reroll_count ~= nil then
		NEMESIS.np_reroll_count = reroll_count
	end
end