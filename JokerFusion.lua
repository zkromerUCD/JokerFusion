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
		
	end	
}
]]

SMODS.Joker {
	key = 'handbelisk',
	loc_txt = {
		name = 'Handbelisk',
		text = {
			"Gains +{X:mult,C:white}X#1# {} mult each time",
			"you play a hand of",
			"different size. Resets when",
			"you play two hands of the",
			"same size.",
			"Currently {X:mult,C:white}X#2# {} mult."
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
			if G.GAME.handbelisk_lengths_played[l] == true then
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
		if context.after then
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
	loc_txt = {
		name = 'Regicide',
		text = {
			"When a {C:attention}face{} card scores,",
			"it is destroyed and this",
			"joker gains +{X:mult,C:white}X#2# {} Mult.",
			"(Currently {X:mult,C:white}X#1# {} Mult)"
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
		if context.destroying_card and context.destroying_card:is_face() and not context.blueprint then
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

-- Missingno
-- TODO: This one will be hard AF to implement

SMODS.Joker {
	key = 'smearedpainting',
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
		if context.after and context.scoring_hand then
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
	loc_txt = {
		name = 'Meter Maid',
		text = {
			"Each {C:attention}face{} card held",
			"in has a #2# in #3# chance",
			"to give this joker +{X:mult,C:white}#4# {} Mult",
			"Currently {X:mult,C:white}#1# {} Mult."
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
					return {
						message = localize('k_debuffed'),
						colour = G.C.RED,
						card = context.other_card,
					}
				else
					if pseudorandom("fus_metermaid") < G.GAME.probabilities.normal/card.ability.extra.chance then
						card.ability.extra.mult = card.ability.extra.mult + card.ability.extra.mult_increment
						return {
							message = localize('k_upgrade_ex'),
							colour = G.C.MULT,
							card = card
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
	key = 'silvervine',
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
		
		if context.buying_card and not context.retrigger_joker and not (context.card == card) then
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
 		badges[#badges+1] = create_badge("Lord of Goldpoint", G.C.BLACK, G.C.RED, 1.2 )
 	end,
}

-- Other non-fusion jokers will have custom badges as well, like "Unlucky Few", "Zenith" (Yuki has both), "Hallowleaves" or "Scourgebane"


SMODS.Joker {
	key = 'gino',
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


