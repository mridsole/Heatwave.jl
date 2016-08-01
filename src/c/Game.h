#pragma once

#include <SFML/Graphics.hpp>
#include <string.h>
#include "Terminal.h"
#include "FontTextureBuilder.h"

namespace hw {

/*
   represents the game etc
*/
class Game
{
public:

    Game(
        sf::Vector2u windowDims, 
        std::string windowTitle, 
        sf::Vector2i termDims, 
        std::string fontPath,
        int fontSize
        );

    ~Game();

    void init(
        sf::Vector2u windowDims, 
        std::string windowTitle, 
        sf::Vector2i termDims, 
        std::string fontPath,
        int fontSize
        );
    
    // initialize SFML - create the window etc
    void initSFML(sf::Vector2u windowDims, std::string windowTitle);

    // tick the game - i.e. do drawing and event polling as necessary
    void tick();

    void getEvents();

    // the terminal font
    std::shared_ptr<sf::Font> termFont;

    // the map from characters to their texture rect
    std::shared_ptr<hw::FontCharMap> fontCharMap;

    // the generated font texture (not from font.getTexture!)
    std::shared_ptr<sf::Texture> fontTexture;
    
    // the window that we're using
    std::shared_ptr<sf::RenderWindow> renderWindow;

    std::shared_ptr<hw::Terminal> terminal;
};

}
