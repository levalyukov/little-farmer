#include "build_manager.hpp"


void BuildManager::_bind_methods(void) 
{
    godot::ClassDB::bind_method(godot::D_METHOD("get_build_container"), &BuildManager::get_dictionary);
    godot::ClassDB::bind_method(godot::D_METHOD("set_build_container", "buildings"), &BuildManager::set_dictionary);
    godot::ClassDB::add_property(
        "BuildManager", 
        godot::PropertyInfo(
            godot::Variant::DICTIONARY, 
            "Buildings"
        ),
        "set_build_container", 
        "get_build_container"
    );
}

BuildManager::BuildManager(void) 
{}

BuildManager::~BuildManager(void) 
{}

bool BuildManager::add_build(void)
{
    bool flag = false;
    return flag;
}

godot::Building* BuildManager::get_build(const unsigned int index) const
{
    return container.has(index) ? godot::Object::cast_to<godot::Building>(container[index]) : nullptr;
}

bool BuildManager::remove_build(void)
{
    bool flag = false;
    return flag;
}