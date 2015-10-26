-- Buffs cannot be cast on targets that are a level less than the level that
-- the rank of the buff was learned at minus 10 and only seems to apply to
-- spells which are instant cast (most buffs).
-- e.g. target is level 13; can cast Power Word: Shield (Rank 3) because it was
-- learned at level 18 (13 is less than 18 minus 10 or 8) but cannot cast Power
-- Word: Fortitude (Rank 3) because it was learned at level 24 (13 is not less
-- than 24 minus 10 or 14)

-- Print to chat frame
local function print(msg)
    DEFAULT_CHAT_FRAME:AddMessage("|cffff0000sjMacro|r "..msg)
end

-- Reversed ipairs
local function ripairs(t)
    local function ripairs_it(t,i)
        i=i-1
        local v=t[i]
        if v==nil then return v end
        return i,v
    end
    return ripairs_it, t, getn(t)+1
end

-- Addon table
sjMacro = sjMacro or {
    best_buff_enabled = false
}

local _, class = UnitClass("player")

-- Druid
-- Balance
local T,   T_T   = "Thorns", "Interface\\Icons\\Spell_Nature_Thorns"
-- Restoration
--local MOW, MOW_T = "Mark of the Wild", "Interface\\Icons\\Spell_Nature_Regeneration"
--local GOW, GOW_T = "Gift of the Wild", "Interface\\Icons\\Spell_Nature_Regeneration"
local RG,  RG_T  = "Regrowth", "Interface\\Icons\\Spell_Nature_Rejuvenation"
local RJ,  RJ_T  = "Rejuvenation", "Interface\\Icons\\Spell_Nature_ResistNature"

-- Mage
-- Arcane
local AM, AM_T = "Amplify Magic", "Interface\\Icons\\Spell_Holy_FlashHeal"
local AI, AI_T = "Arcane Intellect", "Interface\\Icons\\Spell_Holy_MagicalSentry"
local DM, DM_T = "Dampen Magic", "Interface\\Icons\\Spell_Nature_AbolishMagic"

-- Paladin
-- Holy
--local BOW,  BOW_T  = "Blessing of Wisdom", "Interface\\Icons\\Spell_Holy_SealOfWisdom"
--local GBOW, GBOW_T = "Greater Blessing of Wisdom", "Interface\\Icons\\Spell_Holy_GreaterBlessingOfWisdom"
-- Protection
--local BOP,  BOP_T  = "Blessing of Protection", "Interface\\Icons\\Spell_"
--local BOSC, BOSC_T = "Blessing of Sacrifice", "Interface\\Icons\\Spell_"
--local BOSN, BOSN_T = "Blessing of Sanctuary", "Interface\\Icons\\Spell_"
-- Retribution
--local BOM  = "Blessing of Might", "Interface\\Icons\\Spell_"
--local GBOM = "Greater Blessing of Might", "Interface\\Icons\\Spell_"

-- Priest
-- Discipline
local DS, DS_T   = "Divine Spirit", "Interface\\Icons\\Spell_Holy_DivineSpirit"
local PWF, PWF_T = "Power Word: Fortitude", "Interface\\Icons\\Spell_Holy_WordFortitude"
local PWS, PWS_T = "Power Word: Shield", "Interface\\Icons\\Spell_Holy_PowerWordShield"
-- Holy
local RN, RN_T   = "Renew", "Interface\\Icons\\Spell_Holy_Renew"
-- Shadow Protection
local SP, SP_T   = "Shadow Protection", "Interface\\Icons\\Spell_Shadow_AntiShadow"

-- ----------------------------------------------------------------------------
-- Functions
-- ----------------------------------------------------------------------------

-- Initialize the best buff features for classes with buffs
function sjMacro.BestBuffInit()
    local _, class = UnitClass("player")
    if not (class == "MAGE" or class == "PRIEST") then
        return
    end

    sjMacro.best_buff_enabled = true
    sjMacro.spells_best_rank = {}

    if class == "DRUID" then
        sjMacro.spell_textures = {
            -- Balance
            [2] = { [T_T] = T },
            -- Restoration
            [4] = {
                --[MOW_T] = MOW,
                --[GOW_T] = GOW,
                [RG_T] = RG,
                [RJ_T] = RJ
            }
        }
        sjMacro.spells_level_learned = {
            --[MOW] = {  1, 10, 20, 30, 40, 50, 60 },
            --[GOW] = { 50, 60 },
            [RG] = { 12, 18, 24, 30, 36, 42, 48, 54, 60 },
            [RJ] = {  4, 10, 16, 22, 28, 34, 40, 46, 52, 58 },
            [T]  = {  6, 14, 24, 34, 44, 54 }
        }
    elseif class == "MAGE" then
        sjMacro.spell_textures = {
            -- Arcane
            [2] = {
                [AM_T] = AM,
                [AI_T] = AI,
                [DM_T] = DM
            }
        }
        sjMacro.spells_level_learned = {
            [AM] = { 18, 30, 42, 54 },
            [AI] = {  1, 14, 28, 42, 56 },
            [DM] = { 12, 24, 36, 48, 60 }
        }
    --[[
       [elseif class == "PALADIN" then
       [    sjMacro.spell_textures = {
       [        -- Holy
       [        [2] = {
       [            [BOW_T]  = BOW,
       [            [GBOW_T] = GBOW_T
       [        },
       [        -- Protection
       [        [3] = {
       [            [BOP_T]  = BOP,
       [            [BOF_T]  = BOF,
       [            [BOK_T]  = BOK,
       [            [BOSC_T] = BOSC,
       [            [BOSN_T] = BOSR
       [        -- Retribution
       [        [4] = { [MW_T] = MW, [RG_T] = RG, [RJ_T] = RJ }
       [    }
       [    sjMacro.spells_level_learned = {
       [        [BOL]  = { 40, 50, 60 },
       [        [BOM]  = {  4, 12, 22, 32, 42, 52 },
       [        [BOP]  = { 10, 24, 38 },
       [        [BOSC] = { 46, 54 },
       [        [BOSN] = { 30, 40, 50, 60 },
       [        [BOW]  = { 14, 24, 34, 44, 54, 60 }
       [    }
       ]]
    elseif class == "PRIEST" then
        sjMacro.spell_textures = {
            -- Discipline
            [2] = { [DS_T] = DS, [PWF_T] = PWF, [PWS_T] = PWS },
            -- Holy
            [3] = { [RN_T] = RN },
            -- Shadow
            [4] = { [SP_T] = SP }
        }
        sjMacro.spells_level_learned = {
            [DS]  = { 40, 42, 56 },
            [PWF] = {  1, 12, 24, 36, 48, 60 },
            [PWS] = {  6, 12, 18, 24, 30, 36, 42, 48, 54, 60 },
            [R]   = {  1, 14, 20, 26, 32, 38, 44, 50, 56 },
            [SP]  = { 30, 42, 56 }
        }
    end

    -- Initial update run
    sjMacro.UpdateBestBuffRanks()
end

-- Update list of best buff ranks
function sjMacro.UpdateBestBuffRanks()
    if not sjMacro.best_buff_enabled then
        return
    end

    local ranks = {}
    local texture
    for i,tab in pairs(sjMacro.spell_textures) do
        local _, _, offset, num_spells = GetSpellTabInfo(i)
        for j=0, num_spells do
            texture = GetSpellTexture(offset + j, "spell")
            if tab[texture] then
                local spell = tab[texture]
                if not ranks[spell] then
                    ranks[spell] = 0
                end
                ranks[spell] = ranks[spell] + 1
            end
        end
    end

    for k,v in pairs(ranks) do
        sjMacro.spells_best_rank[k] = v
    end
end

-- Get the buff best rank for unitID
function sjMacro.GetSmartBuffRank(spell, unitID)
    assert(sjMacro.spells_level_learned[spell])
    assert(UnitExists(unitID))
    local target_level = UnitLevel(unitID)
    local use_rank = false
    for rank, level in ripairs(sjMacro.spells_level_learned[spell]) do
        if target_level >= level - 10 then
            use_rank = rank
            break
        end
    end
    return use_rank
end

-- Returns the unitID of what to cast on and whether the player already has
-- a target (in order to target last target correctly).
-- reaction: Minimum reaction required for target
-- TODO: Implement customizable priority
local function SmartTargetHelper(reaction)
    reaction = reaction or 0
    local have_target = UnitExists("target")
    local target = "player"
    local f = GetMouseFocus()
    if f.unit and UnitReaction(f.unit, "player") > reaction then
        target = f.unit
    elseif UnitExists("mouseover") and UnitReaction("player", "mouseover") > reaction then
        target = "mouseover"
    elseif UnitExists("target") and UnitReaction("player", "target") > reaction then
        target = "target"
    end
    return target, have_target
end

-- Casts a spell on the specified unitID and targets last target if have_target
-- is true.
-- spell: Spell to cast
-- target: unitID to cast on
-- have_target: If currently have a target (for target last target)
local function SmartCastHelper(spell, target, have_target)
    if UnitIsUnit(target, "target") then
        CastSpellByName(spell)
    else
        TargetUnit(target)
        CastSpellByName(spell)
        if have_target then
            TargetLastTarget()
        else
            ClearTarget()
        end
    end
end

-- Smart cast spell
-- spell: Spell to cast
-- reaction: Minimum reaction required for target
function sjMacro.SmartCast(spell, reaction)
    local target, have_target = SmartTargetHelper(reaction)
    SmartCastHelper(spell, target, have_target)
    --print(format("spell : %q", spell))
    --print(format("target : %q (have_target : %q)", target, tostring(have_target)))
    return target
end

-- Smart cast buff
function sjMacro.SmartBuff(spell)
    if not sjMacro.best_buff_enabled then
        return
    end
    if spell == "Mark of the Wild" or spell == "Gift of the Wild" then
        print("Mark of the Wild and Gift of the Wild unavailable for now")
        return
    end

    local target, have_target = SmartTargetHelper(4)
    local rank = sjMacro.GetSmartBuffRank(spell, target)
    if rank then
        if rank > sjMacro.spells_best_rank[spell] then
            rank = sjMacro.spells_best_rank[spell]
        end
        local full_spell = format("%s(Rank %s)", spell, rank)
        SmartCastHelper(full_spell, target, have_target)
        --print(format("spell : %q", spell))
        --print(format("full_spell : %q", full_spell))
        --print(format(" target : %q (have_target: %q)", target, tostring(have_target)))
    end
end

-- Global function aliases
SmartBuff = sjMacro.SmartBuff
SmartCast = sjMacro.SmartCast

sjMacro.BestBuffInit()

