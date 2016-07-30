#include "stdio.h"
#include <SFML/Graphics.hpp>

#include "../c/FontTextureBuilder.h"
#include "../c/Terminal.h"

int main() {
    
    // let's test the FontTextureBuilder

    // load font and obtain pointer
    std::shared_ptr<sf::Font> claconFont_ptr(new sf::Font());
    claconFont_ptr->loadFromFile("assets/clacon_changed.ttf");
    
    // make the font texture builder
    hw::FontTextureBuilder ftb(claconFont_ptr);

    // get a texture from the font texture builder
    std::shared_ptr<sf::Texture> fontTexture_ptr = ftb.buildFontTexture(24, 
        claconFont_ptr->getLineSpacing(24));

    // just testing - generate the font character map
    hw::FontCharMap_ptr fontCharMap_ptr = ftb.buildFontCharMap(24, 
        claconFont_ptr->getLineSpacing(24));

    // make a sprite with the texture
    sf::Sprite fontTextureSprite;
    fontTextureSprite.setTexture(*fontTexture_ptr, true);
    fontTextureSprite.setPosition(0.f, 0.f);

    hw::Terminal term(fontTexture_ptr, fontCharMap_ptr, sf::Vector2u(100, 50), 
        sf::Vector2u((*fontCharMap_ptr)['a'].textureRect.width, 
            claconFont_ptr->getLineSpacing(24)));

    // make the window
    sf::RenderWindow window(sf::VideoMode(800, 600), "Heatwave C++ Component Test");
    window.setFramerateLimit(60);

    term.setChar('a', 1, 1);
    term.setChar('b', 2, 1);
    term.setChar('c', 3, 1);
    term.setChar('d', 3, 2);

    //fontTextureSprite.setTextureRect((*fontCharMap_ptr)['a'].textureRect);

    while (true) {

        sf::Event event;
        while (window.pollEvent(event)) {}

        window.clear(sf::Color(0, 0, 0));
        
        window.draw(fontTextureSprite);
        window.draw(term);

        window.display();
    }
}
