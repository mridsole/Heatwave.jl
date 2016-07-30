#include "stdio.h"
#include <SFML/Graphics.hpp>
#include "../c/FontTextureBuilder.h"

int main() {
    
    // let's test the FontTextureBuilder

    // load font and obtain pointer
    std::shared_ptr<sf::Font> claconFont_ptr(new sf::Font());
    claconFont_ptr->loadFromFile("assets/clacon_changed.ttf");
    
    // make the font texture builder
    hw::FontTextureBuilder ftb(claconFont_ptr);

    // get a texture from the font texture builder
    sf::Texture fontTexture = *ftb.buildFontTexture(24, 
        claconFont_ptr->getLineSpacing(24) - 4);

    // just testing - generate the font character map
    ftb.buildFontCharMap(24,
        claconFont_ptr->getLineSpacing(24) - 4);

    // make a sprite with the texture
    sf::Sprite fontTextureSprite;
    fontTextureSprite.setTexture(fontTexture, true);
    fontTextureSprite.setPosition(0.f, 0.f);

    // make the window
    sf::RenderWindow window(sf::VideoMode(800, 600), "Heatwave C++ Component Test");

    while (true) {

        sf::Event event;
        while (window.pollEvent(event)) {}

        window.clear(sf::Color(0, 0, 0));
        
        window.draw(fontTextureSprite);

        window.display();
    }
}
