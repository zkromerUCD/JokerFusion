-- TODO: Modify Off the Grid (perma mult) to use built in instead of custom perma mult
-- ###################### ATLASES ######################
SMODS.Atlas {
	key = "JokerFusion",
	path = "BenchPlayer.png",
	px = 168,
	py = 235
}

SMODS.Atlas {
	key = "Silver",
	path = "Silver.png",
	px = 1109,
	py = 1477
}

SMODS.Atlas {
	key = "Gino",
	path = "Gino.png",
	px = 500,
	py = 500
}

-- TODO CONVERT TO ENHANCED ATLAS
--[[
SMODS.Atlas {
	key = 'Enhancement_Fire',
	path = 'Enhancement_Fire.png',
	px = 71,
	py = 95
}
 ]]
SMODS.Atlas {
	key = 'Enhancements',
	path = 'Enhancements.png',
	px = 71,
	py = 95
}
SMODS.Atlas {
	key = 'Enhancement_Fire_Mask',
	path = 'Enhancement_Fire_Mask.png',
	px = 71,
	py = 95
}
-- ###################### CARD ENHANCEMENTS ######################
-- You have no idea how long coding the mask for this enhancement, such that the right side of the card does not display
SMODS.Enhancement {
	key = 'Fire',
	name = 'Fire Card',
	loc_txt = {
		name = 'Fire Card',
		text = {
			'{C:green}#1# in #2#{} chance to level',
			'up played hand.',
			'{C:green}#1# in #2#{} chance this',
			'card is destroyed'
		}
	},
	pos = { x = 1, y = 0 },
	unlocked = true,
	discovered = true,
	atlas = 'Enhancements',
	config = { chance = 4.0 },
	loc_vars = function(self, info_queue)
		return {
			vars = {
				(G.GAME.probabilities.normal or 1),
				self.config.chance
			},
		}
	end,
	calculate = function(self, card, context)
		if context.cardarea and context.cardarea == G.play and not context.before and not context.after and not context.repetition then
			-- Level up hand
			if pseudorandom('fus_fire') < G.GAME.probabilities.normal/self.config.chance then
				level_up_hand(card, G.GAME.last_hand_played)
			end
		end
		-- Destroying card is now handled in lovely.toml
	end
}
-- ###################### SHADERS ######################
-- fire_mask_path = love.filesystem.getWorkingDirectory()..'/Mods/JokerFusion/assets/shaders/fire_mask.png'
SMODS.Shader({ 
	key = 'fire_mask', 
	path = 'fire_mask.fs',
	send_vars = function(sprite, card)
		--img_mask = love.graphics.newImage(fire_mask_path)
		return {
			img_mask = G.ASSET_ATLAS['fus_Enhancements'][1][0].image
		}
	end
})

-- TEMP

SMODS.Sound({
	key = "gino_die",
	path = "gino_die.ogg"
})

-- ###################### JOKERS ######################
--[[
SMODS.Joker {
	key = 'benchplayer',
	blueprint_compat = false,
	loc_txt = {
		name = 'Bench Player',
		text = {
			"Common jokers each give {X:mult,C:white}X#1# {} Mult"
		}
	},
	config = { extra = { xmult = 1.25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}
]]

SMODS.Joker {
	key = 'handbelisk',
	blueprint_compat = true,
	loc_txt = {
		name = 'Handbelisk',
		text = {
			"Gains {X:mult,C:white}X#1# {} mult each time",
			"you play a hand of",
			"different size. Resets when",
			"you play two hands of the",
			"same size",
			"{C:inactive}(Currently {X:mult,C:white}X#2#{C:inactive} mult)"
		}
	},
	config = { extra = {xmult_increment = 1.0, xmult = 1.0, base_xmult = 1.0 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult_increment, card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if G.GAME.handbelisk_lengths_played == nil then
			G.GAME.handbelisk_lengths_played = {false, false, false, false, false}
		end
		
		-- Used when scoring a new hand length
		local old_xmult = card.ability.extra.xmult
		
		if context.joker_main then
			local l = #context.scoring_hand
			if G.GAME.handbelisk_lengths_played[l] == true and not context.blueprint then
				-- Reset xmult if same handlength Played and reset array
				card.ability.extra.xmult = card.ability.extra.base_xmult
				G.GAME.handbelisk_lengths_played = {false, false, false, false, false}
				return {
					message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
					Xmult_mod = card.ability.extra.xmult
				}
			else
				G.GAME.handbelisk_lengths_played[l] = true
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_increment
				
				return {
					message = localize{type='variable', key='a_xmult', vars={old_xmult}},
					Xmult_mod = old_xmult
				}
			end
		end
	end,	
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'flubonacci',
	blueprint_compat = false,
	loc_txt = {
		name = 'Flubonacci',
		text = {
			"Each scored card randomly",
			"changes its rank."
		}
	},
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.after and not context.blueprint then
			for i, c in ipairs(context.scoring_hand) do
				-- TODO: Add case for rankless and suitless cards (i.e. stone cards)
				local rank = pseudorandom_element({'2','3','4','5','6','7','8','9','T','J','Q','K','A'}, pseudoseed('flubonacci'))
				local suit_prefix = string.sub(c.base.suit, 1, 1)..'_'
				c:set_base(G.P_CARDS[suit_prefix..rank])
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

-- Check if jens is enabled, if so, do not create wet mime
local w_mime_exists = false
if not SMODS.Mods.jen then
	wet_mime_exists = true
else
	if not SMODS.Mods.jen.can_load then
		wet_mime_exists = true
	end
end
if wet_mime_exists then
	SMODS.Joker {
		key = 'wet_mime',
		blueprint_compat = false,
		loc_txt = {
			name = 'Wet Mime',
			text = {
				"Cards held in hand count in scoring.",
				"",
				"",
				"",
				"This joker has the exact",
				"same effects as Crimbo",
				"from Jen's",
				"This joker will not",
				"appear when Jen's is enabled."
			}
		},
		config = { extra = { xmult = 1.25 } }, 
		loc_vars = function(self, info_queue, card)
			return { vars = { card.ability.extra.xmult } }
		end,
		rarity = 4,
		atlas = 'Gino',
		pos = { x = 0, y = 0 },
		cost = 20,
		set_badges = function(self, card, badges)
			badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
		end,
	}
end

SMODS.Joker {
	key = 'regicide',
	blueprint_compat = true,
	loc_txt = {
		name = 'Regicide',
		text = {
			"When a {C:attention}face{} card scores,",
			"it is destroyed and this",
			"joker gains {X:mult,C:white}X#2# {} Mult.",
			"{C:inactive}(Currently {X:mult,C:white}X#1#{C:inactive} Mult)"
		}
	},
	config = { extra = { xmult = 1.0, xmult_increment = 0.25} }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.xmult_increment } }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.joker_main then
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				Xmult_mod = card.ability.extra.xmult
			}
		end
		if context.destroying_card and context.destroying_card:is_face() and not context.blueprint and not context.destroying_card.ability.eternal then
			card_eval_status_text(card, "extra", nil, nil, nil, { message = "Executed", colour = G.C.FILTER })
			card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_increment
			return nil, true
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'bench_player',
	blueprint_compat = true,
	loc_txt = {
		name = 'Bench Player',
		text = {
			"Common jokers each give {X:mult,C:white}X#1# {} Mult"
		}
	},
	config = { extra = { xmult = 1.25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 2,
	atlas = 'JokerFusion',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.other_joker and context.other_joker.config.center.rarity == 1 and card ~= context.other_joker then
			G.E_MANAGER:add_event(Event({
				func = function()
					context.other_joker:juice_up(0.5, 0.5)
					return true
				end
			}))
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				Xmult_mod = card.ability.extra.xmult
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

function table_to_string(tbl)
    local i = 0
	local result = "{"
    for k, v in pairs(tbl) do
        -- Check the key type (ignore any numerical keys - assume its an array)
        if type(k) == "string" then
            result = result.."[\""..k.."\"]".."="
        else
			result = result.."[\""..tostring(k).."\"]".."="
		end
		i = i + 1
		if i == 15 then
			i = 0
			result = result.."\n"
		end
    end
    -- Remove leading commas from the result
    if result ~= "" then
        result = result:sub(1, result:len()-1)
    end
    return result.."}"
end

-- Missingno
SMODS.Joker {
	key = 'missingno',
	blueprint_compat = false, -- ??? See if this is actually true
	loc_txt = {
		name = 'Missingno',
		text = {
			"Copies the ability of a {C:green}random{} {C:attention}joker{}.",
			"Joker changes {C:attention}every hand{}.",
			"{C:inactive}(Currently {C:attention}#1#{C:inactive}.)"
		}
	},
	config = { extra = { joker = G.P_CENTER_POOLS.Joker[1] } }, 
	loc_vars = function(self, info_queue, card)
		local var1 = nil
		if card.ability.extra.joker.key then
			var1 = G.localization["descriptions"]["Joker"][card.ability.extra.joker.key].name
		else
			var1 = card.ability.extra.joker.ability.name
			-- var1 = G.localization["descriptions"]["Joker"][card.ability.extra.joker.center.key]
		end
		-- return { vars = { table_to_string(G.P_CENTERS[card.ability.extra.joker.key])}}
		return { vars = { var1 or "Joker" } }
	end,
	rarity = 1,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	get_joker = function(self)
		-- TODO: Mark all cards in this mod as either compatible or non-compatible with blueprint;
		-- and only choose cards that are compatible with blueprint via a 1000 iteration for loop,
		-- Make sure random joker is also not missingno
		-- if all loops provide incompatible cards, default to standard Joker (G.P_CENTER_POOLS.Joker[1])
		for i=1,1000 do
			local j = pseudorandom_element(G.P_CENTER_POOLS.Joker, pseudoseed('missingno'))
			if j.blueprint_compat and j.unlocked then 
				return Card(0, 0, 0, 0, nil, j, nil)
			end
		end
		return Card(0, 0, 0, 0, nil, G.P_CENTER_POOLS.Joker[1], nil)

	end,
	calculate = function(self, card, context)
		-- If a hand is getting played, determine next joker
		new_joker = nil
		if context.after and not context.retrigger_joker and not context.blueprint then
			new_joker = self:get_joker()
			new_joker.missingno = true
		end
		
		if not context.blueprint then
			context.blueprint = (context.blueprint and (context.blueprint + 1)) or 1
			context.blueprint_card = context.blueprint_card or card
			if context.blueprint > #G.jokers.cards + 1 then return end
			--card.ability.extra.joker.debuff = true
			local other_joker_ret = card.ability.extra.joker:calculate_joker(context)
			--card.ability.extra.joker.debuff = true
		end
		
		-- Switch to next joker if a new joker has been specified
		if new_joker then
			card.ability.extra.joker:remove()
			card.ability.extra.joker = new_joker
		end
		
		if other_joker_ret then 
			other_joker_ret.card = context.blueprint_card or self
			other_joker_ret.colour = G.C.BLUE
			return other_joker_ret
		end
	end,
	add_to_deck = function(self, card, from_debuff)
		card.ability.extra.joker = self:get_joker()
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'smearedpainting',
	blueprint_compat = false,
	loc_txt = {
		name = 'Smeared Painting',
		text = {
			"All scored cards",
			"become the suit of", 
			"the first scored card."
		}
	},
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.after and context.scoring_hand and not context.blueprint then
			local suit_prefix = string.sub(context.scoring_hand[1].base.suit, 1, 1)..'_'
			local high_ranks = {[10] = 'T', [11] = 'J', [12] = 'Q', [13] = 'K', [14] = 'A'}
			for i, c in ipairs(context.scoring_hand) do
				local rank = c:get_id()
				if rank >= 10 then
					rank = high_ranks[rank]
				end
				c:set_base(G.P_CARDS[suit_prefix..rank])
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'metermaid',
	blueprint_compat = true,
	loc_txt = {
		name = 'Meter Maid',
		text = {
			"Each {C:attention}face{} card held",
			"in has a #2# in #3# chance",
			"to give this joker {C:mult}+#4#{} Mult",
			"{C:inactive}(Currently {C:mult}#1#{C:inactive} Mult.)"
		}
	},
	config = { extra = { mult = 0, mult_increment = 1, chance = 2 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { 
			card.ability.extra.mult,
			(G.GAME.probabilities.normal or 1),
			card.ability.extra.chance,
			card.ability.extra.mult_increment
		} }
	end,
	rarity = 1,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.hand and not context.blueprint then
			if context.other_card:is_face() then
				if context.other_card.debuff then
					return
					--[[return {
						message = localize('k_debuffed'),
						colour = G.C.RED,
						card = context.other_card,
					}]]
				else
					if pseudorandom("fus_metermaid") < G.GAME.probabilities.normal/card.ability.extra.chance then
						card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_increment
						my_card = card
						return {
							message = "Joker upgraded!",
							colour = G.C.MULT,
							card = my_card
						}
					end
				end
			end
		elseif context.joker_main then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'polaroid',
	blueprint_compat = true,
	loc_txt = {
		name = 'Polaroid',
		text = {
			"First played {C:attention}face {} card",
			"gains {C:chips}+#1# {}chips when scored."
		}
	},
	config = { extra = { chip_mod = 10 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chip_mod } }
	end,
	rarity = 1,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 4,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play then
			local first_face = nil
			for i = 1, #context.scoring_hand do
				if context.scoring_hand[i]:is_face() then first_face = context.scoring_hand[i]; break end
			end
			if context.other_card == first_face then
				context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus or 0
				context.other_card.ability.perma_bonus = context.other_card.ability.perma_bonus + card.ability.extra.chip_mod
				return {
					extra = {message = localize('k_upgrade_ex'), colour = G.C.CHIPS},
					colour = G.C.CHIPS,
					card = card
				}
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'periodictablet',
	blueprint_compat = true,
	loc_txt = {
		name = 'Periodic Tablet',
		text = {
			"#1# in #2# chance to create",
			"a tarot card when hand played",
			"is not your most played hand."
		}
	},
	config = { extra = { chance = 4 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { 
			(G.GAME.probabilities.normal or 1),
			card.ability.extra.chance, 
		} }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.joker_main then
			-- Check if hand is not most played
			local spawn_tarot = false
			local times_played = (G.GAME.hands[context.scoring_name].played or 0)
			for k, v in pairs(G.GAME.hands) do
				if k ~= context.scoring_name and v.played >= times_played and v.visible then
					spawn_tarot = true
					break
				end
			end
			if spawn_tarot then
				if pseudorandom("fus_periodictablet") < G.GAME.probabilities.normal/card.ability.extra.chance and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
					G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
					G.E_MANAGER:add_event(Event({
						func = (function()
							G.E_MANAGER:add_event(Event({
								func = function() 
									local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'fus_periodictablet')
									card:add_to_deck()
									G.consumeables:emplace(card)
									G.GAME.consumeable_buffer = 0
									return true
								end}))   
								card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})                       
							return true
						end
					)}))
				end
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'offthegrid',
	blueprint_compat = false,
	loc_txt = {
		name = 'Off the Grid',
		text = {
			"If the first discard of",
			"the round is a single",
			"enhanced card, that card",
			"is destroyed, and all cards",
			"in your deck with that",
			"enhancement gain {C:chips}+#1#{} chips", 
			"and {C:mult}+#2#{} mult"
			
		}
	},
	config = { extra = { chip_mod = 10, mult_mod = 5 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.chip_mod, card.ability.extra.mult_mod } }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.discard and G.GAME.current_round.discards_used <= 0 and #context.full_hand == 1 and not context.blueprint then
			if not context.other_card.debuff and context.other_card.ability and context.other_card.ability.effect then
				local enhancement = context.other_card.ability.effect
				for i, c in ipairs(G.playing_cards) do
					if c.ability and c.ability.effect == enhancement then
						c.ability.perma_bonus = c.ability.perma_bonus or 0
						c.ability.perma_bonus = c.ability.perma_bonus + card.ability.extra.chip_mod
						c.ability.perma_mult = c.ability.perma_mult or 0
						c.ability.perma_mult = c.ability.perma_mult + card.ability.extra.mult_mod
					end
				end
			end
			return {
				message = "Upgraded!",
				colour = G.C.MULT,
				delay = 0.45, 
				remove = true,
				card = self
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'bottomout',
	blueprint_compat = true,
	loc_txt = {
		name = 'Bottom Out',
		text = {
			"Halves all listed probabilities.", 
			"(ex. 2 in 6 -> 1 in 6)"
		}
	},
	config = { extra = {} }, 
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 1,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 4,
	add_to_deck = function(self, card, from_debuff)
		for k, v in pairs(G.GAME.probabilities) do 
			G.GAME.probabilities[k] = v/2
		end
	end,
	remove_from_deck = function(self, card, from_debuff)
		for k, v in pairs(G.GAME.probabilities) do 
			G.GAME.probabilities[k] = v*2
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'gatekeeper',
	blueprint_compat = true,
	loc_txt = {
		name = 'Gatekeeper',
		text = {
			"Whenever you add a card",
			"to your deck, if it has",
			"an enhancement, remove the",
			"enhancement and give this",
			"joker {C:mult}+#1#{} Mult",
			"{C:inactive}(Currently {C:mult}+#2#{C:inactive} Mult)"
		}
	},
	config = { extra = { mult_increment = 15, mult = 0 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_increment, card.ability.extra.mult } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.playing_card_added and not context.blueprint then
			local enhanced = {}
			local c = context.cards[1]
			if c.config.center ~= G.P_CENTERS.c_base and not c.debuff and not c.vampired then 
				enhanced[#enhanced+1] = c
				c.vampired = true
				c:set_ability(G.P_CENTERS.c_base, nil, true)
				G.E_MANAGER:add_event(Event({
					func = function()
						c:juice_up()
						c.vampired = nil
						return true
					end
				})) 
			end
			if #enhanced > 0 then 
				card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_increment*#enhanced
				return {
					message = localize{type='variable',key='a_mult',vars={card.ability.mult}},
					colour = G.C.MULT,
					card = card
				}
			end
		elseif context.joker_main then
			return {
				mult_mod = card.ability.extra.mult,
				message = localize { type = 'variable', key = 'a_mult', vars = { card.ability.extra.mult } }
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'voiceofthepeople',
	blueprint_compat = true,
	loc_txt = {
		name = 'Voice of the People',
		text = {
			"Retrigger all {C:attention}non-face{} cards."
		}
	},
	config = { extra = {repetitions = 1} }, 
	loc_vars = function(self, info_queue, card)
		return { vars = {} }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.cardarea == G.play and context.repetition and not context.repetition_only then
			-- context.other_card is something that's used when either context.individual or context.repetition is true
			-- It is each card 1 by 1, but in other cases, you'd need to iterate over the scoring hand to check which cards are there.
			if not context.other_card:is_face() then
				return {
					message = 'Again!',
					repetitions = card.ability.extra.repetitions,
					-- The card the repetitions are applying to is context.other_card
					card = context.other_card
				}
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'grimaldi',
	blueprint_compat = false, --??? maybe idk
	loc_txt = {
		name = 'Great Grimaldi',
		text = {
			"{C:mult}#1#{} discards per round,",
			"{C:attention}-#2#{} hand size, and",
			"{C:chips}+#3#{} hands per round.",
			" ",
			"{C:inactive,E:1}\"Shall I?\""
		}
	},
	config = { extra = { discards = 0, hand_size_mod = 1, hands_mod = 6, prev_discards = 0 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.discards, card.ability.extra.hand_size_mod, card.ability.extra.hands_mod } }
	end,
	rarity = 4,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 20,
	add_to_deck = function(self, card, from_debuff)
		card.ability.extra.prev_discards = G.GAME.round_resets.discards
		G.GAME.round_resets.discards = card.ability.extra.discards
		G.GAME.round_resets.hands = G.GAME.round_resets.hands + card.ability.extra.hands_mod
		G.hand:change_size(-card.ability.extra.hand_size_mod)
	end,
	remove_from_deck = function(self, card, from_debuff)
		local diff = G.GAME.round_resets.discards - card.ability.extra.discards
		G.GAME.round_resets.discards = diff + card.ability.extra.prev_discards
		G.GAME.round_resets.hands = G.GAME.round_resets.hands - card.ability.extra.hands_mod
		G.hand:change_size(card.ability.extra.hand_size_mod)
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
		badges[#badges+1] = create_badge("Circus of the Other", G.C.RED, G.C.BLACK, 1.2 )
		badges[#badges+1] = create_badge("Actual historical dude", G.C.PURPLE, G.C.WHITE, 1.2 )

 	end,
}

SMODS.Joker {
	key = 'stickercollector',
	blueprint_compat = true,
	loc_txt = {
		name = 'Sticker Collector',
		text = {
			-- This is not the effect listed on discord, but Aaron told me to do this instead
			"Removes seals from scored cards",
			"and gives this joker {X:mult,C:white}X#1#{} Mult",
			"{C:deactivated}(Currently {X:mult,C:white}X#2#{C:deactivated} Mult{}"
		}
	},
	config = { extra = { xmult_increment = 0.25, xmult = 1 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult_increment, card.ability.extra.xmult } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
			if context.other_card.seal then
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_increment
				context.other_card:set_seal(nil)
				card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_upgrade_ex'), colour = G.C.MULT })
			end
		elseif context.joker_main then
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				Xmult_mod = card.ability.extra.xmult
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'luckysevens',
	blueprint_compat = true,
	loc_txt = {
		name = 'Lucky Sevens',
		text = {
			"Whenever you score a {C:attention}7{}",
			"that {C:green}sucessfully{} triggers a {C:attention}Lucky{}", 
			"card effect, {X:mult,C:white}X#1#{} mult"
		}
	},
	config = { extra = { xmult = 2 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.individual and context.other_card.lucky_trigger then
			if context.other_card:get_id() == 7 then
				card_eval_status_text(card, "extra", nil, nil, nil, { message = "Lucky!!!", colour = G.C.FILTER })
				return {
					message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
					x_mult = card.ability.extra.xmult
				}
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'stalepopcorn',
	blueprint_compat = true,
	loc_txt = {
		name = 'Stale Popcorn',
		text = {
			"{X:mult,C:white}X#1#{} Mult, looses {X:mult,C:white}X#2#{}",
			"whenever you play a {V:1}#3#{} card,",
			"suit changes every round"
		}
	},
	config = { extra = { xmult = 2, xmult_penalty = 0.25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { 
			card.ability.extra.xmult,
			card.ability.extra.xmult_penalty,
			localize(G.GAME.current_round.stalepopcorn_card.suit, 'suits_singular'),
			colours = {G.C.SUITS[G.GAME.current_round.stalepopcorn_card.suit]}
		} }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
			if not context.other_card.debuff and context.other_card:is_suit(G.GAME.current_round.stalepopcorn_card.suit) then
				if card.ability.extra.xmult - card.ability.extra.xmult_penalty <= 1 then
					card.ability.extra.xmult = 1
					card_eval_status_text(card, "extra", nil, nil, nil, { message = localize('k_eaten_ex'), colour = G.C.FILTER })
					G.E_MANAGER:add_event(Event({
                        func = function()
                            play_sound('tarot1')
                            card.T.r = -0.2
                            card:juice_up(0.3, 0.4)
                            card.states.drag.is = true
                            card.children.center.pinch.x = true
                            G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                func = function()
                                        G.jokers:remove_card(card)
                                        card:remove()
                                        card = nil
                                    return true; end})) 
                            return true
                        end
                    }))
				else
					card.ability.extra.xmult = card.ability.extra.xmult - card.ability.extra.xmult_penalty
					card_eval_status_text(card, "extra", nil, nil, nil, { message = localize{type='variable',key='a_xmult_minus',vars={card.ability.extra.xmult_penalty}}, colour = G.C.RED })
				end
			end
		end
		if context.joker_main and card.ability.extra.xmult > 1 then
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				Xmult_mod = card.ability.extra.xmult
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'gymbro',
	blueprint_compat = false,
	loc_txt = {
		name = 'Gym Bro',
		text = {
			"Played cards give {X:mult,C:white}X#1#{}",
			"Mult if you have played a",
			"card of the same {C:attention}rank{} this round."
		}
	},
	config = { extra = { xmult = 1.25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 8,
	calculate = function(self, card, context)
		if context.individual and context.cardarea == G.play and not context.blueprint then
			local bonus = 1
			if G.GAME.current_round.gymbro_card.ranks[context.other_card:get_id()] then
				bonus = card.ability.extra.xmult
			end
			G.GAME.current_round.gymbro_card.ranks[context.other_card:get_id()] = true
			return {
				message = localize{type='variable', key='a_xmult', vars={bonus}},
				x_mult = bonus
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

-- TODO (I think it is finished; check at some point)
SMODS.Joker {
	key = 'graverobber',
	blueprint_compat = true,
	loc_txt = {
		name = 'Grave Robber',
		text = {
			"When Small or Big Blind is selected",
			"destroy the leftmost joker.",
			"This joker gains {C:mult}+#1#{} mult for each",
			"joker destroyed this run",
			"{C:deactivated}(Currently {C:mult}+#2#{C:deactivated} mult)"
		}
	},
	config = { extra = { mult_increment = 25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.mult_increment, card.ability.extra.mult_increment * G.GAME.global_vars.graverobber_card.destroyed } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.setting_blind and not context.repetition and not context.blueprint then
			if G.GAME.round_resets.blind.key == "bl_small" or G.GAME.round_resets.blind.key == "bl_big" then
				local other_joker = G.jokers.cards[1]
				if not other_joker.ability.eternal and other_joker ~= card then
					card_eval_status_text(card, "extra", nil, nil, nil, { message = localize{type='variable', key='a_mult', vars={card.ability.extra.mult_increment}}, colour = G.C.MULT })
					G.E_MANAGER:add_event(Event({
						func = function()
							G.jokers:remove_card(other_joker)
							other_joker:start_dissolve()
							return true
						end
					}))
				end
			end
		end
		
		if context.joker_main then
			return {
				message = localize{type='variable', key='a_mult', vars={card.ability.extra.mult_increment * G.GAME.global_vars.graverobber_card.destroyed}},
				mult_mod = card.ability.extra.mult_increment * G.GAME.global_vars.graverobber_card.destroyed
			}
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}

SMODS.Joker {
	key = 'seeing-sixes',
	blueprint_compat = false,
	loc_txt = {
		name = 'Seeing Sixes',
		text = {
			"If the first hand of the round", 
			"is a single {C:attention}6{}, convert", 
			"{C:attention}#1#{} random cards in your hand into",
			"a copy of it."
		}
	},
	config = { extra = {num_cards = 2} }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.num_cards } }
	end,
	rarity = 3,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 9,
	calculate = function(self, card, context)
		if context.after and not context.blueprint and #context.full_hand == 1 and context.full_hand[1]:get_id() == 6 then
			local other_card = context.full_hand[1]
			-- Get the cards to dupe
			local temp_hand = {}
			local duped_cards = {}
            for k, v in ipairs(G.hand.cards) do temp_hand[#temp_hand+1] = v end
            table.sort(temp_hand, function (a, b) return not a.playing_card or not b.playing_card or a.playing_card < b.playing_card end)
            pseudoshuffle(temp_hand, pseudoseed('seeing-sixes'))
			local n = card.ability.extra.num_cards
			if n > #temp_hand then
				n = #temp_hand
			end
            for i = 1, n do duped_cards[#duped_cards+1] = temp_hand[i] end
			
			-- Dupe the card
			local suit_prefix = string.sub(other_card.base.suit, 1, 1)..'_'
			for k, v in ipairs(duped_cards) do
				-- Set suit and rank (6)
				v:set_base(G.P_CARDS[suit_prefix..'6'])
				-- Set seal
				v:set_seal(other_card.seal)
				-- Set enhancement
				v:set_ability(other_card.config.center)
				-- Set edition
				v:set_edition(other_card.edition)
			end
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fusion", G.C.PURPLE, G.C.WHITE, 1.2 )
 	end,
}


SMODS.Joker {
	key = 'silvervine',
	blueprint_compat = true,
	loc_txt = {
		name = 'Silver',
		text = {
			"Played cards give {X:mult,C:white}X#1# {} Mult when scored.",
			"When you buy a Joker, destroy it, create #2# random consumables,", 
			"and increase this number by {X:mult,C:white}X#3# {} Mult.",
			"If you sell or destroy this Joker, you lose."
		}
	},
	config = { extra = { xmult = 1.0, consumables = 2, xmult_increment = 0.05 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult, card.ability.extra.consumables, card.ability.extra.xmult_increment } }
	end,
	rarity = 4,
	atlas = 'Silver',
	pos = { x = 0, y = 0 },
	cost = 20,
	calculate = function(self, card, context)
		-- Add mult to each scored card
		if context.individual and context.cardarea == G.play then
			card_eval_status_text(card, "extra", nil, nil, nil, { message = "Dark Magic", colour = G.C.FILTER })
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				x_mult = card.ability.extra.xmult
			}
		end
		
		if context.buying_card and not context.retrigger_joker and not context.blueprint and not (context.card == card) then
			if context.card.ability.set == "Joker" then
				card_eval_status_text(card, "extra", nil, nil, nil, { message = "Material Expended", colour = G.C.FILTER })
				G.E_MANAGER:add_event(Event({
					func = function()
						G.jokers:remove_card(context.card)
						context.card:start_dissolve()
						return true
					end
				}))
				card.ability.extra.xmult = card.ability.extra.xmult + card.ability.extra.xmult_increment
				for i=1,card.ability.extra.consumables do
					local key = pseudorandom_element(G.P_CENTER_POOLS.Consumeables, pseudoseed('silver')).key
					if key == 'c_soul' then
						key = 'c_black_hole'
					end
					local card = create_card("Consumable", G.consumeables, nil, nil, nil, nil, key, 'silver')
					G.consumeables:emplace(card)
				end
			end
		end
		
		--[[
		if context.selling_self then
			G.GAME.round_resets.hands = -9999
			G.GAME.round_resets.discards = -9999
			G.GAME.current_round.hands_left = -9999
			G.GAME.current_round.discards_left = -9999
			G.hand:change_size(-9999)
			
			if context.blind then
				for i,c in ipairs(G.hand.cards) do
					c:start_dissolve()
				end
			end
			
			return {
				message = "Die.",
				card = card
			}
		end
		]]--
		--[[
		if context.removed then
			G.GAME.round_resets.hands = -9999
			G.GAME.round_resets.discards = -9999
			G.GAME.current_round.hands_left = -9999
			G.GAME.current_round.discards_left = -9999
			G.hand:change_size(-9999)
			
			if context.blind then
				for i,c in ipairs(G.hand.cards) do
					c:start_dissolve()
				end
			end
			
			return {
				message = "Die.",
				card = card
			}
		end
		]]--
	end,
	
	remove_from_deck = function(self, card, from_debuff)
		if not from_debuff and self.name ~= "Blueprint" then
			card_eval_status_text(card, "extra", nil, nil, nil, { message = "\"Die.\"", colour = G.C.FILTER })
			G.GAME.round_resets.hands = -9999
			G.GAME.round_resets.discards = -9999
			G.GAME.current_round.hands_left = -9999
			G.GAME.current_round.discards_left = -9999
			G.hand:change_size(-9999)
			
			if G.hand.cards then
				for i,c in ipairs(G.hand.cards) do
					c:start_dissolve()
				end
			end
		end
	end,
	
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Lord of Goldpoint", G.C.BLACK, HEX("c9002fff"), 1.2 )
 	end,
}

-- Other non-fusion jokers will have custom badges as well, like "Unlucky Few", "Zenith" (Yuki has both), "Hallowleaves" or "Scourgebane"


SMODS.Joker {
	key = 'gino',
	blueprint_compat = false, --??? Maybe idk
	loc_txt = {
		name = 'Gino Fratelli',
		text = {
			"WIP",
			"",
			"BRING HONOR TO",
			"THE FRATELLI CLAN!!!"
		}
	},
	config = { extra = { xmult = 1.25 } }, 
	loc_vars = function(self, info_queue, card)
		return { vars = { card.ability.extra.xmult } }
	end,
	rarity = 2,
	atlas = 'Gino',
	pos = { x = 0, y = 0 },
	cost = 6,
	calculate = function(self, card, context)
		if context.other_joker and context.other_joker.config.center.rarity == 1 and card ~= context.other_joker then
			G.E_MANAGER:add_event(Event({
				func = function()
					context.other_joker:juice_up(0.5, 0.5)
					return true
				end
			}))
			return {
				message = localize{type='variable', key='a_xmult', vars={card.ability.extra.xmult}},
				Xmult_mod = card.ability.extra.xmult
			}
		end
	end,
	
	remove_from_deck = function(self, card, from_debuff)
		if not from_debuff then
			play_sound("gino_die", 1, 1)
		end
	end,
	set_badges = function(self, card, badges)
 		badges[#badges+1] = create_badge("Fettucine[sic] Alfredo", G.C.BLACK, G.C.WHITE, 1.2 )
 	end,
}

-- Hook for game init
-- Relevant Jokers:
--   1) Stale Popcorn
--   2) Gym Bro
--   3) Grave Robber
local igo = Game.init_game_object
function Game:init_game_object()
	local ret = igo(self)
	ret.current_round.stalepopcorn_card = { suit = 'Hearts' }
	ret.current_round.gymbro_card = {ranks = {false, false, false, false, false, false, false, false, false, false, false, false, false, false}}
	if not ret.global_vars then ret.global_vars = {} end
	ret.global_vars.graverobber_card = {}
	ret.global_vars.graverobber_card.destroyed = 0
	return ret
end
-- Hook for end of round
-- Relevant Jokers:
--   1) Stale Popcorn
--   2) Gym Bro
function SMODS.current_mod.reset_game_globals(run_start)
	-- The suit changes every round, so we use reset_game_globals to choose a suit.
	G.GAME.current_round.stalepopcorn_card = { suit = 'Hearts' }
	G.GAME.current_round.stalepopcorn_card.suit = pseudorandom_element({'Hearts', 'Spades', 'Diamonds', 'Clubs'}, pseudoseed('fus_stalepopcorn' .. G.GAME.round_resets.ante))
	G.GAME.current_round.gymbro_card.ranks = {false, false, false, false, false, false, false, false, false, false, false, false, false, false}
end
