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

    int w = charDims.x + 2 * padding.x;
    int h = charDims.y + 2 * padding.y;

    sf::VertexArray minimalExample(sf::Quads, 8);
    minimalExample[0].position = sf::Vector2f(500, 500);
    minimalExample[1].position = sf::Vector2f(500, 500 + h);
    minimalExample[2].position = sf::Vector2f(500 + w, 500 + h);
    minimalExample[3].position = sf::Vector2f(500 + w, 500);

    sf::IntRect texRect = (*fontCharMap_ptr)['$'].textureRect;
    minimalExample[0].texCoords = sf::Vector2f(texRect.left, texRect.top);
    minimalExample[1].texCoords = sf::Vector2f(texRect.left, texRect.top + texRect.height);
    minimalExample[2].texCoords = sf::Vector2f(texRect.left + texRect.width, texRect.top + texRect.height);
    minimalExample[3].texCoords = sf::Vector2f(texRect.left + texRect.width, texRect.top);

    // ROUND TWO!
    minimalExample[4].position = sf::Vector2f(520, 520);
    minimalExample[5].position = sf::Vector2f(520, 520 + h);
    minimalExample[6].position = sf::Vector2f(520 + w, 520 + h);
    minimalExample[7].position = sf::Vector2f(520 + w, 520);

    texRect = (*fontCharMap_ptr)['Q'].textureRect;
    minimalExample[4].texCoords = sf::Vector2f(texRect.left, texRect.top);
    minimalExample[5].texCoords = sf::Vector2f(texRect.left, texRect.top + texRect.height);
    minimalExample[6].texCoords = sf::Vector2f(texRect.left + texRect.width, texRect.top + texRect.height);
    minimalExample[7].texCoords = sf::Vector2f(texRect.left + texRect.width, texRect.top);

    //fontTextureSprite.setTextureRect((*fontCharMap_ptr)['a'].textureRect);
    fontTextureSprite.setPosition(sf::Vector2f(300.f, 300.f));

    // SOME PRINT DEBUGGING ...
    auto va = term.chVerts;
    auto v1 = va[0];
    auto v2 = va[1];
    auto v3 = va[2];
    auto v4 = va[3];

    (void)v1;
    (void)v2;
    (void)v3;
    (void)v4;

    while (true) {

        sf::Event event;
        while (window.pollEvent(event)) {}

        for (int i = 0; i < 200; i++) {
            for (int j = 0; j < 100; j++) {
                term.setChar('a', i, j);
            }
        }

        window.clear(sf::Color(0, 0, 0));
        
        window.draw(fontTextureSprite);
        window.draw(term);

        window.draw(minimalExample, fontTexture_ptr.get());

        window.display();
    }
}
