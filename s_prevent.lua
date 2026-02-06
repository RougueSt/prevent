local control = {
    wall = {},
    spec = {},
    play = {},
    dim = {},
    int = {}
}

groupsAllowed = {
    "Admin",
    "Console"
}

function getPlayerFromPartialName(name)
    local name = name and name:gsub("#%x%x%x%x%x%x", ""):lower() or nil
    if name then
        for _, player in ipairs(getElementsByType("player")) do
            local name_ = getPlayerName(player):gsub("#%x%x%x%x%x%x", ""):lower()
            if name_:find(name, 1, true) then
                return player
            end
        end
    end
end

function permCheck(player)
    local conta = getAccountName(getPlayerAccount(player))
    for i, group in pairs(groupsAllowed) do
        if isObjectInACLGroup ("user."..conta, aclGetGroup (group)) then
            return true
        end
    end
    return false
end

addEventHandler('onResourceStart', getResourceRootElement(getThisResource()), function()
    local lista = getElementsByType('player')
        for i,Player in ipairs(lista) do 
            if permCheck(Player) then        
                outputChatBox('Utilize os comandos:', Player, 230,30,30, true)
                outputChatBox('Script desenvolvido por #29e014Rougue#8075', Player, 230,30,30, true)
                outputChatBox('--------------------------------------------', Player, 230,30,30)
                        
                outputChatBox('/wall --> Comando usado para ligar o wall hack', Player, 230,230,230)
                outputChatBox('/spec [jogador]--> para telar outro jogar e ainda funcionar o wallhack, se telar usando o spec do painel não funciona!!', Player, 230,230,230)
                outputChatBox('/spec --> para sair do spec', Player, 230,230,230)
                outputChatBox('/name --> Copia o nick do jogador no ctrl + v se o nick do cara for muito complicado ', Player, 230,230,230)
                outputChatBox('/spechelp --> Mostra esses comandos ', Player, 230,230,230)
                outputChatBox('--------------------------------------------\n', Player, 230,30,30)
            end
        end
end)

addEventHandler('onPlayerQuit', root, function() -- prevent eventual memory leak
    for i, j in pairs(control) do
        for a, b in pairs(j) do
            if a == source then
                control[i][a] = nil
            end
        end
    end
end)

local function AtivaWall(Player, comando)
    if permCheck(Player)  then
        if not control.wall[Player] then
            control.wall[Player] = true
            triggerClientEvent(Player, 'nametags:prevent', Player, true)
            outputServerLog(getPlayerName(Player).. ' ativou o wall')
        else
            control.wall[Player] = nil
            outputServerLog(getPlayerName(Player) .. ' desativou o wall')
            triggerClientEvent(Player, 'nametags:prevent', Player, false)
            return
        end
    end
end

addCommandHandler('wall', AtivaWall, false, false)
--spec player
function spec (staff, comando, player)
    if permCheck(staff) then
        if player == nil then
            if isElementFrozen(staff) then
                setElementFrozen(staff, false)
                if isPedInVehicle(staff) then
                    local vehicle = getPedOccupiedVehicle(staff)
                    setElementFrozen(vehicle, false)
                    setElementAlpha(vehicle, 255)
                end
            end
            if (getCameraTarget(staff) == staff) then
                outputChatBox('Você não está telando ninguém', staff, 230, 30, 30)
                return
            end
            local spectado = getCameraTarget(staff)
            triggerClientEvent(spectado, 'camera:cords', staff, false)
            control.spec[staff] = nil
            setElementAlpha(staff, 255)
            setCameraTarget(staff, staff)
            setElementFrozen(staff, false)
            if getElementDimension(staff) ~= control.dim[staff] or getElementInterior(staff) ~= control.int[staff] then
                setElementDimension(staff, control.dim[staff] or 0)
                setElementInterior(staff, control.int[staff] or 0)
                control.dim[staff] = nil
                control.int[staff] = nil
            end
            if isPedInVehicle(staff) then
                local vehicle = getPedOccupiedVehicle(staff)
                setElementFrozen(vehicle, false)
            end
            return
        else
            spectado = getPlayerFromPartialName(player)
            if getCameraTarget(staff) == spectado then 
                return
            else
                if spectado == staff then
                    outputChatBox('você não pode telar você mesmo', staff)
                    return
                end
                triggerClientEvent(getCameraTarget(staff), 'camera:cords', staff, false)
            end
        end 
        if not isElement(spectado) then
            outputChatBox('Digite o nick parcial de um jogador ou /spec para parar de telar', staff, 230, 30, 30)
            return
        end
        if isPedInVehicle(staff) then
            local vehicle = getPedOccupiedVehicle(staff)
            setElementFrozen(vehicle, true)
            setElementAlpha(vehicle, 0)
        end
        if getElementDimension(staff) ~= getElementDimension(spectado) or getElementInterior(staff) ~= getElementInterior(spectado) then
            control.dim[staff] = getElementDimension(staff)
            control.int[staff] = getElementInterior(staff)
            setElementDimension(staff, getElementDimension(spectado))
            setElementInterior(staff, getElementInterior(spectado))
        end
        setElementFrozen(staff, true)
        setCameraTarget(staff, spectado)
        triggerClientEvent(spectado, 'camera:cords', staff, true)
        control.spec[staff] = true
        control.play[staff] = spectado
        setElementAlpha(staff, 0)
        outputChatBox('Digite /spec para parar de telar jogador: '.. getPlayerName(spectado), staff, 30, 230, 30)
    end
end

local function staffCam(data, staff)
    if client ~= control.play[staff] then 
        banPlayer(staff, true, false, true, 'Server', 'Banido por tentar burlar o sistema de espectate.', 0)
        return
    end
    
    if permCheck(staff) and data and isElement(staff) then
        triggerClientEvent(staff, 'camera:setTarget', resourceRoot, data)
    end
end

addEvent('camera:cords:server', true)
addEventHandler('camera:cords:server', root, staffCam)

addCommandHandler('spec', spec, false, false)

addCommandHandler('name', function(staff)
    if not permCheck(staff) then return end
    
    if getCameraTarget(staff) == staff or getPedOccupiedVehicle(staff) == getCameraTarget(staff) then
        outputChatBox('Você não está telando ninguem', staff, 230, 30, 30)
        return 
    end
    
    triggerClientEvent(staff, 'copiar:nome', staff, getPlayerName(getCameraTarget(staff)))
end, false, false)