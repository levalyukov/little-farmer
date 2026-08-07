/************************************************/
/* BuildManager                                 */
/************************************************/
/* Центральный менеджер управления игровыми     */
/* объектами, террейнами и декором.				*/
/*                                              */
/* ЗОНА ОТВЕТСТВЕННОСТИ:                        */
/* - Хранение игровых объектов                  */
/* - Создание и удаление игровых объектов       */
/*                                              */
/************************************************/

#pragma once
#ifndef BUILD_MANAGER_HPP

#include <stdint.h>
#include <stdbool.h>
#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/variant/string.hpp>
#include <godot_cpp/variant/dictionary.hpp>
#include <godot_cpp/classes/global_constants.hpp>
#include "../interfaces/building.hpp"

#define GRID_IS_OK(mode) ( \
((mode) == NOTHING) 	|| \
((mode) == DESTROY) 	|| \
((mode) == WATERING) 	|| \
((mode) == FARMING) 	|| \
((mode) == HARVESTING) 	|| \
((mode) == BUILD))

class BuildManager : public godot::Node
{
    GDCLASS(BuildManager, Node)

  	public:
		enum GridModes 
		{
			NOTHING		= 0,
			DESTROY 	= 1,
			WATERING	= 2,
			FARMING		= 3,
			HARVESTING	= 4,
			BUILD		= 5
		};

		BuildManager(void);
		~BuildManager();

		bool add_building(Building* building);
		bool remove_building(Building* building);

		inline uint16_t get_max_distance(void) const
		{
			return MAX_DISTANCE;
		};

	private:
		static void init_nodes(void);
		static void deinit_nodes(void);

		godot::Array container;
		GridModes mode = NOTHING;
		const uint16_t MAX_DISTANCE = 250;

	protected:
		static void _bind_methods(void);

		inline godot::Array get_dictionary(void) const 
		{
			return container;
		};

		inline GridModes get_grid_mode(void) const
		{
			return mode;
		}

		inline void set_dictionary(godot::Array content) 
		{
			container = content;
		};

		inline void set_grid_mode(GridModes grid_mode)
		{
			if (GRID_IS_OK(grid_mode))
			{
				mode = grid_mode;
			}
		};
};

VARIANT_ENUM_CAST(BuildManager::GridModes);

#endif // BUILD_MANAGER_HPP