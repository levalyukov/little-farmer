#pragma once

#include "../interfaces/building.hpp"

class Grid : public Building
{
    public:
        Grid(void);
        ~Grid() override;
};