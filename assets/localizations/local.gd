extends Node

func _ready():
	tr('letter.for_new_player.header')		# Letter
	tr('letter.for_new_player.content')		# For
	tr('letter.for_new_player.signature')	# New Player

	tr('letter.public_well_announcement_header')
	tr('letter.public_well_announcement_content')
	tr('letter.korney_korneich.signature')

	tr('letter.gardener_dobrynya')
	tr('letter.reminder_season_header')
	tr('letter.reminder_season_description_spring_->_summer')
	tr('letter.reminder_season_description_summer_->_autumn')
	tr('letter.reminder_season_description_autumn_->_winter')
	tr('letter.reminder_season_description_winter_->_spring')

	tr('letter.start_little_water_header')
	tr('letter.start_little_water_content')

	tr('npc.dobrynya')	# Names
	tr('npc.kuzma')		# NPC
	tr('npc.vance')		# 
	# All Blueprints
	tr('blueprints.path.caption')
	tr('blueprints.path.description')
	tr('blueprints.path_blueprint.caption')
	tr('blueprints.path_blueprint.description')
	
	tr('blueprints.water_body.caption')
	tr('blueprints.water_body.description')
	tr('blueprints.water_body_blueprints.caption')
	tr('blueprints.water_body_blueprints.description')

	tr('blueprints.wooden_sign.caption')
	tr('blueprints.wooden_sign.description')
	tr('blueprints.wooden_sign_blueprint.caption')
	tr('blueprints.wooden_sign_blueprint.description')

	tr('blueprints.composter.caption')
	tr('blueprints.composter.description')
	tr('blueprints.composter_blueprint.caption')
	tr('blueprints.composter_blueprint.description')
	
	tr('blueprints.well.caption')
	tr('blueprints.well.description')
	tr('blueprints.well_blueprint.caption')
	tr('blueprints.well_blueprint.description')
	
	tr('blueprints.barn.caption')
	tr('blueprints.barn.description')
	tr('blueprints.barn_blueprint.caption')
	tr('blueprints.barn_blueprint.description')
	
	tr('blueprints.silo.caption')
	tr('blueprints.silo.description')
	tr('blueprints.silo_blueprint.caption')
	tr('blueprints.silo_blueprint.description')

	tr('blueprints.greenhouse.caption')
	tr('blueprints.greenhouse.description')
	tr('blueprints.greenhouse_blueprint.caption')
	tr('blueprints.greenhouse_blueprint.description')

	tr('blueprints.lantern_post.caption')
	tr('blueprints.lantern_post.description')
	tr('blueprints.lantern_post_blueprints.caption')
	tr('blueprints.lantern_post_blueprints.description')

	tr('blueprints.stone_path.caption')
	tr('blueprints.stone_path.description')
	tr('blueprints.stone_path_blueprint.caption')
	tr('blueprints.stone_path_blueprint.description')

	tr('blueprints.stone_forge.caption')
	tr('blueprints.stone_forge.description')
	tr('blueprints.stone_forge_blueprint.caption')
	tr('blueprints.stone_forge_blueprint.description')

	tr('blueprints.radio.caption')
	tr('blueprints.radio.description')
	tr('blueprints.radio_blueprint.caption')
	tr('blueprints.radio_blueprint.description')

	tr('blueprints.sawbench.caption')
	tr('blueprints.sawbench.description')
	tr('blueprints.sawbench_blueprint.caption')
	tr('blueprints.sawbench_blueprint.description')

	tr('blueprints.fence.caption')
	tr('blueprints.fence.description')
	tr('blueprints.fence_blueprint.caption')
	tr('blueprints.fence_blueprint.description')

	tr('blueprints.beehive.caption')
	tr('blueprints.beehive.description')
	tr('blueprints.beehive_blueprint.caption')
	tr('blueprints.beehive_blueprint.description')
	# All Items
	
	#	items.type.building_materials
	tr('items.log.caption')
	tr('items.log.description')
	tr('items.type.building_materials')

	tr('items.plank.caption')
	tr('items.plank.description')

	tr('items.stone.caption')
	tr('items.stone.description')

	tr('items.cobblestone.caption')
	tr('items.cobblestone.description')

	#	items.type.ores
	tr('items.coal.caption')
	tr('items.coal.description')
	tr('items.type.ores')

	tr('items.copper_ore.caption')
	tr('items.copper_ore.description')

	tr('items.iron_ore.caption')
	tr('items.iron_ore.description')

	tr('items.bauxite_ore.caption')
	tr('items.bauxite_ore.description')

	tr('items.copper_ingot.caption')
	tr('items.copper_ingot.description')

	tr('items.iron_ingot.caption')
	tr('items.iron_ingot.description')

	tr('items.aluminum_ingot.caption')
	tr('items.aluminum_ingot.description')

	#	items.type.seeds
	tr('items.carrot_seeds.caption')
	tr('items.carrot_seeds.description')
	tr('items.type.seeds')

	tr('items.potato_seeds.caption')
	tr('items.potato_seeds.description')

	tr('items.radish_seeds.caption')
	tr('items.radish_seeds.description')

	tr('items.cabbage_seeds.caption')
	tr('items.cabbage_seeds.description')

	tr('items.onion_seeds.caption')
	tr('items.onion_seeds.description')

	tr('items.cucumber_seeds.caption')
	tr('items.cucumber_seeds.description')

	tr('items.tomato_seeds.caption')
	tr('items.tomato_seeds.description')

	tr('items.eggplant_seeds.caption')
	tr('items.eggplant_seeds.description')

	tr('items.pepper_seeds.caption')
	tr('items.pepper_seeds.description')

	tr('items.corn_seeds.caption')
	tr('items.corn_seeds.description')

	tr('items.parsnip_seeds.caption')
	tr('items.parsnip_seeds.description')

	tr('items.garlic_seeds.caption')
	tr('items.garlic_seeds.description')

	tr('items.beet_seeds.caption')
	tr('items.beet_seeds.description')

	tr('items.turnip_seeds.caption')
	tr('items.turnip_seeds.description')

	tr('items.bean_seeds.caption')
	tr('items.bean_seeds.description')

	#	items.type.harvest
	tr('items.carrot.caption')
	tr('items.carrot.description')
	tr('items.type.harvest')

	tr('items.potato.caption')
	tr('items.potato.description')

	tr('items.radish.caption')
	tr('items.radish.description')

	tr('items.cabbage.caption')
	tr('items.cabbage.description')

	tr('items.onion.caption')
	tr('items.onion.description')

	tr('items.cucumber.caption')
	tr('items.cucumber.description')

	tr('items.tomato.caption')
	tr('items.tomato.description')

	tr('items.eggplant.caption')
	tr('items.eggplant.description')

	tr('items.pepper.caption')
	tr('items.pepper.description')

	tr('items.corn.caption')
	tr('items.corn.description')

	tr('items.parsnip.caption')
	tr('items.parsnip.description')

	tr('items.garlic.caption')
	tr('items.garlic.description')

	tr('items.beet.caption')
	tr('items.beet.description')

	tr('items.turnip.caption')
	tr('items.turnip.description')

	tr('items.bean.caption')
	tr('items.bean.description')

	# items.type.waste
	tr('items.rotten_carrot.caption')
	tr('items.rotten_carrot.description')
	tr('items.type.waste')

	tr('items.rotten_potato.caption')
	tr('items.rotten_potato.description')

	tr('items.rotten_radish.caption')
	tr('items.rotten_radish.description')

	tr('items.rotten_cabbage.caption')
	tr('items.rotten_cabbage.description')

	tr('items.rotten_onion.caption')
	tr('items.rotten_onion.description')

	tr('items.rotten_cucumber.caption')
	tr('items.rotten_cucumber.description')

	tr('items.rotten_tomato.caption')
	tr('items.rotten_tomato.description')

	tr('items.rotten_eggplant.caption')
	tr('items.rotten_eggplant.description')

	tr('items.rotten_pepper.caption')
	tr('items.rotten_pepper.description')

	tr('items.rotten_corn.caption')
	tr('items.rotten_corn.description')

	tr('items.rotten_parsnip.caption')
	tr('items.rotten_parsnip.description')

	tr('items.rotten_garlic.caption')
	tr('items.rotten_garlic.description')

	tr('items.rotten_beet.caption')
	tr('items.rotten_beet.description')

	tr('items.rotten_turnip.caption')
	tr('items.rotten_turnip.description')

	tr('items.rotten_beans.caption')
	tr('items.rotten_beans.description')

	tr('items.crop_residue.caption')
	tr('items.crop_residue.description')

	tr('items.broken_branch.caption')
	tr('items.broken_branch.description')

	tr('items.weeds.caption')
	tr('items.weeds.description')

	#	items.type.fertilizer
	tr('items.basic_compost.caption')
	tr('items.basic_compost.description')
	tr('items.type.fertilizer')

	tr('items.premium_compost.caption')
	tr('items.premium_compost.description')

	# items.type.items.type.own_production
	tr('items.honey.caption')
	tr('items.honey.description')
	tr('items.type.own_production')

	# 	Crops
	# Spring
	tr('crops.carrot')
	tr('crops.potato')
	tr('crops.radish')
	tr('crops.cabbage')
	tr('crops.onion')
	# Summer
	tr('crops.cucumber')
	tr('crops.tomato')
	tr('crops.eggplant')
	tr('crops.pepper')
	tr('crops.corn')
	# Autumn
	tr('crops.parsnips')
	tr('crops.garlic')
	tr('crops.beet')
	tr('crops.turnip')
	tr('crops.bean')

	# Radio
	tr('station.radio_cultura.caption')