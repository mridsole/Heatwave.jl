#include "stdio.h"
#include <iostream>
#include <SFML/Graphics.hpp>

#include "../c/FontTextureBuilder.h"
#include "../c/Terminal.h"

#define TERM_FONT_SIZE 16

int main() {
    
    // let's test the FontTextureBuilder

    // load font and obtain pointer
    std::shared_ptr<sf::Font> termFont_ptr(new sf::Font());
    termFont_ptr->loadFromFile("assets/FSEX300.ttf");
    
    // make the font texture builder
    hw::FontTextureBuilder ftb(termFont_ptr);

    // character padding 
    sf::Vector2i padding(0, 4);

    // get a texture from the font texture builder
    std::shared_ptr<sf::Texture> fontTexture_ptr = ftb.buildFontTexture(
        padding,
        TERM_FONT_SIZE, 
        termFont_ptr->getLineSpacing(TERM_FONT_SIZE));

    // just testing - generate the font character map
    hw::FontCharMap_ptr fontCharMap_ptr = ftb.buildFontCharMap(
        padding,
        TERM_FONT_SIZE, 
        termFont_ptr->getLineSpacing(TERM_FONT_SIZE));

    // make a sprite with the texture
    sf::Sprite fontTextureSprite;
    fontTextureSprite.setTexture(*fontTexture_ptr, true);
    fontTextureSprite.setPosition(0.f, 0.f);

    sf::Vector2i charDims((*fontCharMap_ptr)['a'].textureRect.width, 
        termFont_ptr->getLineSpacing(TERM_FONT_SIZE));

    hw::Terminal term(fontTexture_ptr, fontCharMap_ptr, sf::Vector2i(200, 100), charDims, padding);

    // make the window
    sf::RenderWindow window(sf::VideoMode(1280, 720), "Heatwave C++ Component Test");
    window.setFramerateLimit(60);

    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {
            term.setChar(16 * j + i, i, j);
        }
    }

    //fontTextureSprite.setTextureRect((*fontCharMap_ptr)['a'].textureRect);
    fontTextureSprite.setPosition(sf::Vector2f(300.f, 300.f));

    while (true) {

        sf::Event event;
        while (window.pollEvent(event)) {}

        for (int i = 0; i < 200; i++) {
            for (int j = 0; j < 100; j++) {

                term.setChar('a', i, j);
                term.setChar('[', 15, 15);

                // this works
                term.setCharColor(sf::Color::Red, i, j);
                term.setBgColor(sf::Color(i * j / 5, i * j / 10, 120, 255), i, j);
                term.setBgColor(sf::Color::Green, 15, 15);
            }
        }

        window.clear(sf::Color(0, 0, 0));
        
        //window.draw(fontTextureSprite);
        window.draw(term);

        window.display();
    }
}
