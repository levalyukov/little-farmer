#pragma once

#include <godot_cpp/classes/sprite2d.hpp>

namespace godot {

class CustomNode : public Node2D {
	GDCLASS(CustomNode, Node2D)

private:
	double time_passed;

protected:
	static void _bind_methods();

public:
	CustomNode();
	~CustomNode();

	void _process(double delta) override;
};

}