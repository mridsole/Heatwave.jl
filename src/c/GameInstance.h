#pragma once

#include <SFML/Graphics.hpp>

namespace hw {

/*
   represents the game etc
*/
class Game
{
public:

    Game();
    ~Game();
    
    sf::RenderWindow renderWindow;
    
    // initialize SFML - create the window etc
    void initSFML();
};

}
