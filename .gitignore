-- Gestion des composants
local component = component
local event = event

-- Configuration des panneaux
local panneaux = {
    {id = "AC110A16473A58F6737C8E826DC83E07", fours = 10},  -- Panneau 1 avec 10 indicateurs
    {id = "A3EF7D074CFAF9AC106E558302CE5837", fours = 6},   -- Panneau 2 avec 6 indicateurs
}

-- Table de tous les fours (16 fours)
local fours = {
    -- Panneau 1 (10 fours)
    {id = "4B6F4CFC4C8D44CEAB265B82612C3CFB", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 0}},
    {id = "D0543E814B8D6ED179E4458E745A6B67", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 1}},
    {id = "F8E729D94E7901535FC9CFAF82F49D3A", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 2}},
    {id = "653A6D554FDF8010D9477BA8B9980C54", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 3}},
    {id = "0AFD534145CF6FECD352B283211073DC", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 4}},
    {id = "4138DCD94339300FDEC7AC8360C05412", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 5}},
    {id = "F1E9535F45346E56FF046B84DACC5420", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 6}},
    {id = "3181F6BB486C31D33C6B3AA163A19785", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 7}},
    {id = "B0E4046646B5AF627B2C0BA900E60BF2", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 8}},
    {id = "C55BFA04443C026CA327C1B23684860D", panel_id = "AC110A16473A58F6737C8E826DC83E07", indicateur = {x = 0, y = 9}},

    -- Panneau 2 (6 fours)
    {id = "904AFE2241A4F1C228E3CC80C7B3ED9F", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 0}},
    {id = "3E5887E44FA8D9189F6A2389150ED496", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 1}},
    {id = "7C324B7C4A2AF2FA74E624BB6916101A", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 2}},
    {id = "28EB7E914202DCE2BC59CFBB33A92E45", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 3}},
    {id = "2FE9B85D4266C66D4C3A39927DBA972E", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 4}},
    {id = "AC579648418A3AB40B8E528C458B66E5", panel_id = "A3EF7D074CFAF9AC106E558302CE5837", indicateur = {x = 0, y = 5}},
}

-- Derniers progrès enregistrés et compteurs de stabilité
local derniersProgres = {}
local tempsStables = {}
local delaiInactivite = 0.5  -- Temps (en secondes) pour considérer le four comme inactif

-- Initialisation des compteurs pour chaque four
for i, four in ipairs(fours) do
    derniersProgres[i] = -1
    tempsStables[i] = 0
end

-- Fonction pour obtenir le progrès d'un four
local function obtenirProgres(four_id)
    local fourComponent = component.proxy(four_id)
    if not fourComponent then
        print("Erreur : Impossible de trouver le four avec l'ID " .. four_id)
        return -1
    end
    return fourComponent.progress or 0
end

-- Fonction pour mettre à jour la couleur de l'indicateur
local function mettreAJourIndicateur(panel_id, indicateur, etat)
    local panneau = component.proxy(panel_id)
    if not panneau then
        print("Erreur : Panneau introuvable (ID: " .. panel_id .. ").")
        return
    end

    local moduleIndicateur = panneau:getModule(indicateur.x, indicateur.y)  -- `y = 0` explicitement défini
    if not moduleIndicateur then
        print("Erreur : Module indicateur introuvable à x=" .. indicateur.x .. ", y=" .. indicateur.y)
        return
    end

    if etat then
        moduleIndicateur:setColor(0, 1, 0, 5)  -- Vert (actif)
    else
        moduleIndicateur:setColor(1, 0, 0, 5)  -- Rouge (inactif)
    end
end

-- Boucle principale
while true do
    for i, four in ipairs(fours) do
        local currentProgress = obtenirProgres(four.id)

        if currentProgress == derniersProgres[i] then
            -- Si le progrès ne change pas, augmenter le compteur de stabilité
            tempsStables[i] = tempsStables[i] + 0.1
            if tempsStables[i] >= delaiInactivite then
                -- Si le progrès est stable pendant le délai, considérer le four comme inactif
                mettreAJourIndicateur(four.panel_id, four.indicateur, false)
            end
        else
            -- Si le progrès change, réinitialiser le compteur de stabilité
            tempsStables[i] = 0
            mettreAJourIndicateur(four.panel_id, four.indicateur, true)
        end

        -- Mettre à jour le dernier progrès enregistré
        derniersProgres[i] = currentProgress
    end

    -- Pause non bloquante
    local ok, err = pcall(event.pull, 0.1)  -- Attend 0.1 seconde
    if not ok then
        print("Erreur lors de l'attente : " .. tostring(err))
    end
end
