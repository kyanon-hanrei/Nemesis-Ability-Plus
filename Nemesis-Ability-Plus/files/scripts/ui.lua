if initialized == nil then initialized = false; end

if not initialized then
    initialized = true
    dofile_once( "data/scripts/lib/utilities.lua" )
    local gui = gui or GuiCreate();
    local gui_id = 6969
    GuiStartFrame( gui );
    local screen_width, screen_height = GuiGetScreenDimensions(gui)

    local function reset_id()
        gui_id = 6969
    end
    
    local function next_id()
        local id = gui_id
        gui_id = gui_id + 1
        return id
    end

    local function previous_data( gui )
        local left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height = GuiGetPreviousWidgetInfo( gui );
        if left_click == 1 then left_click = true; elseif left_click == 0 then left_click = false; end
        if right_click == 1 then right_click = true; elseif right_click == 0 then right_click = false; end
        if hover == 1 then hover = true; elseif hover == 0 then hover = false; end
        return left_click,right_click,hover,x,y,width,height,draw_x,draw_y,draw_width,draw_height;
    end


    function draw_gui()
        reset_id()
        GuiStartFrame(gui)
        GuiIdPushString( gui, "nemesis")
        local players = get_players()
        local player_id = players[1]
        local pos_x, pos_y = EntityGetTransform(player_id)

        if (NEMESIS ~= nil) then
            local NP = NEMESIS.points or 0
            local costNP = np_cost(pos_y)
            local show_np_cost = ModSettingGet("Nemesis-Ability-Plus.NAP_SHOW_NP_COST")
            if show_np_cost == true then
                GuiText( gui, 22, 69/1.69, "NP: " .. tostring(NP) .. " / " .. tostring(costNP))
            else
                GuiText( gui, 22, 69/1.69, "NP: " .. tostring(NP) )
            end
        end
        GuiIdPop(gui)
    end
end

function np_cost(pos_y)
    local cost_point = 0
    local ngcount = SessionNumbersGetValue("NEW_GAME_PLUS_COUNT")
    local m_y = 0
    pos_y = pos_y - 175
    if pos_y < 1330 then
        m_y = 1330
    elseif pos_y < 2870 then
        m_y = 2870
    elseif pos_y < 4910 and ngcount == "0" then
        m_y = 4910
    elseif pos_y < 6450 then
        m_y = 6450
    elseif pos_y < 8500 and ngcount == "0" then
        m_y = 8500
    elseif pos_y < 10550 then
        m_y = 10550
    else
        m_y = 13110
    end
    local level = math.floor(m_y/512)
    if ngcount ~= "0" then
		level = 25 + math.floor(m_y/512)
	end
    cost_point = 10*math.floor(math.pow(level, 1.5)) + 15
    return cost_point
end

draw_gui()