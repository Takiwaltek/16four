local component = component
local event = event

-- Configuration des panneaux
local panneaux = {
    -- Panneaux de la première section
    {id = "AC110A16473A58F6737C8E826DC83E07", fours = 10, nick = "Panneau 1"},  -- Panneau 1 avec 10 indicateurs
    {id = "A3EF7D074CFAF9AC106E558302CE5837", fours = 6, nick = "Panneau 2"},   -- Panneau 2 avec 6 indicateurs

    -- Panneaux de la deuxième section
    {id = "139627E94499E92143F01A975E1AB9D6", fours = 10, nick = "Panneau 3"},  -- Panneau 3 avec 10 indicateurs
    {id = "B39B73234268EA30677F5F91A8715926", fours = 6, nick = "Panneau 4"},   -- Panneau 4 avec 6 indicateurs
}

-- Afficheurs pour les sections
local afficheurs = {
    {id = "97339B04488B7B3BDE3C118FE716F83F", texte = "Lingots de fer"},  -- Afficheur pour la première section
    {id = "466F61A64D755407725046A9029E0556", texte = "Lingots de cuivre"} -- Afficheur pour la deuxième section
}

-- Structures de données pour les fours
local fours = {}
local previousStates = {}
local fourMetadatas = {}

-- Fonction utilitaire : Splitter une chaîne
local function split(inputstr, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

-- Fonction pour trouver les fours dynamiquement par nom
local function trouverFours()
    for i = 1, 32 do  -- On augmente à 32 fours pour gérer les deux sections
        local fourName = "Four" .. i
        local found = component.findComponent(fourName)
        if #found > 0 then
            local four = component.proxy(found[1])
            if four then
                table.insert(fours, four)
                previousStates[four] = {progress = 0, itemCount = 0}
            end
        end
    end
end

-- Fonction pour assigner les fours aux panneaux
local function configurerPanneauxEtFours()
    for i, four in ipairs(fours) do
        local panel, position

        if i <= 10 then
            -- Panneau 1 pour les 10 premiers fours
            panel = component.proxy(panneaux[1].id)
            position = {x = 0, y = i - 1}
        elseif i <= 16 then
            -- Panneau 2 pour les fours 11 à 16
            panel = component.proxy(panneaux[2].id)
            position = {x = 0, y = i - 11}
        elseif i <= 26 then
            -- Panneau 3 pour les fours 17 à 26
            panel = component.proxy(panneaux[3].id)
            position = {x = 0, y = i - 17}
        elseif i <= 32 then
            -- Panneau 4 pour les fours 27 à 32
            panel = component.proxy(panneaux[4].id)
            position = {x = 0, y = i - 27}
        end

        if panel then
            fourMetadatas[four] = {panel = panel, indicator = position}
        end
    end
end

-- Fonction pour configurer les afficheurs
local function configurerAfficheurs()
    for _, afficheur in ipairs(afficheurs) do
        local display = component.proxy(afficheur.id)
        if display and display.setText then
            pcall(function()
                display:setText(afficheur.texte)
            end)
        else
            print("[Warning] Impossible de configurer l'afficheur : " .. afficheur.id)
        end
    end
end

-- Fonction pour mettre à jour la couleur de l'indicateur sur le panneau
local function mettreAJourIndicateur(panel, position, etat)
    local moduleIndicateur = panel:getModule(position.x, position.y)
    if not moduleIndicateur then return end

    if etat then
        moduleIndicateur:setColor(0, 1, 0, 5)  -- Vert
    else
        moduleIndicateur:setColor(1, 0, 0, 5)  -- Rouge
    end
end

-- Présentation au démarrage (simultanée)
local function presentationDemarrage()
    local function activerPanneaux(startIndex, endIndex)
        for i = startIndex, endIndex do
            for _, four in ipairs(fours) do
                local metadata = fourMetadatas[four]
                if metadata and metadata.panel.id == panneaux[i].id then
                    -- Allumer l'indicateur en vert
                    mettreAJourIndicateur(metadata.panel, metadata.indicator, true)
                    event.pull(0.2)  -- Pause légère pour créer un effet d'animation plus lent
                    -- Éteindre l'indicateur
                    mettreAJourIndicateur(metadata.panel, metadata.indicator, false)
                end
            end
        end
    end

    -- Lancer les animations des deux parties simultanément
    local co1 = coroutine.create(function() activerPanneaux(1, 2) end)  -- Panneaux 1 et 2
    local co2 = coroutine.create(function() activerPanneaux(3, 4) end)  -- Panneaux 3 et 4

    -- Exécuter les deux animations en parallèle
    while coroutine.status(co1) ~= "dead" or coroutine.status(co2) ~= "dead" do
        if coroutine.status(co1) ~= "dead" then coroutine.resume(co1) end
        if coroutine.status(co2) ~= "dead" then coroutine.resume(co2) end
    end
end

-- Fonction pour surveiller les fours et détecter les changements
local function surveillerFours()
    for _, four in ipairs(fours) do
        local metadata = fourMetadatas[four]
        if metadata and metadata.panel and metadata.indicator then
            local currentProgress = four.progress or 0
            local currentItemCount = four:getInventories()[1] and four:getInventories()[1].ItemCount or 0

            local previous = previousStates[four]
            local hasChanged = false

            if currentProgress ~= previous.progress then
                hasChanged = true
                previous.progress = currentProgress
            end

            if currentItemCount ~= previous.itemCount then
                hasChanged = true
                previous.itemCount = currentItemCount
            end

            mettreAJourIndicateur(metadata.panel, metadata.indicator, hasChanged)
        end
    end
end

-- Initialisation des composants et configuration
trouverFours()
configurerPanneauxEtFours()
configurerAfficheurs()

-- Présentation au démarrage
presentationDemarrage()

-- Boucle principale
while true do
    local status, err = pcall(surveillerFours)
    event.pull(0.1)
end
