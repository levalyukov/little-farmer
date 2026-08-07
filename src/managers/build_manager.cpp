#include "build_manager.hpp"

void BuildManager::_bind_methods(void) 
{
    godot::ClassDB::bind_method(godot::D_METHOD("get_grid_mode"), &BuildManager::get_grid_mode);
    godot::ClassDB::bind_method(godot::D_METHOD("set_grid_mode", "GridModes"), &BuildManager::set_grid_mode);
    
    BIND_ENUM_CONSTANT(GridModes::NOTHING);
    BIND_ENUM_CONSTANT(GridModes::DESTROY);
    BIND_ENUM_CONSTANT(GridModes::WATERING);
    BIND_ENUM_CONSTANT(GridModes::FARMING);
    BIND_ENUM_CONSTANT(GridModes::HARVESTING);
    BIND_ENUM_CONSTANT(GridModes::BUILD);

    godot::ClassDB::add_property(
        "BuildManager", 
        godot::PropertyInfo(
            godot::Variant::INT, 
            "grid_modes",
            godot::PROPERTY_HINT_ENUM,
            "Nothing, Destroy, Watering, Farming, Harvesting, Build"
        ),
        "set_grid_mode", 
        "get_grid_mode"
    );

    godot::ClassDB::bind_method(godot::D_METHOD("get_build_container"), &BuildManager::get_dictionary);
    godot::ClassDB::bind_method(godot::D_METHOD("set_build_container", "Buildings"), &BuildManager::set_dictionary);
    godot::ClassDB::add_property(
        "BuildManager", 
        godot::PropertyInfo(
            godot::Variant::ARRAY, 
            "buildings"
        ),
        "set_build_container", 
        "get_build_container"
    );
}

BuildManager::BuildManager(void)
{
    init_nodes();
}

BuildManager::~BuildManager()
{
    deinit_nodes();
}

bool BuildManager::add_building(Building* building)
{
    bool flag = true;

    if (!building)
    {
        flag = false;
    }

    if (flag)
    {
        container.append(building);
        this->add_child(building);
    }
    
    return flag;
}

bool BuildManager::remove_building(Building* building)
{
    bool flag = true;

    if (!building)
    {
        flag = false;
    }

    if (flag && container.has(building))
    {
        this->remove_child(building);
        container.erase(building);
    }

    return flag;
}

void BuildManager::init_nodes(void)
{}

void BuildManager::deinit_nodes(void)
{}