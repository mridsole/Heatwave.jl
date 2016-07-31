#pragma once

#include <SFML/Graphics.hpp>
#include <memory>
#include "FontTextureBuilder.h"

namespace hw {

/*
    manages the vertex array map
*/
class Terminal : public sf::Drawable
{
public:

    Terminal(
        std::shared_ptr<sf::Texture> fontTexture, 
        FontCharMap_ptr fontCharMap, 
        sf::Vector2i termDims, 
        sf::Vector2i chDims,
        sf::Vector2i padding
        );

    ~Terminal();

    void init();

    virtual void draw(sf::RenderTarget & target, sf::RenderStates states) const;
    void setChar(int ch, unsigned int i, unsigned int j);
    void setCharColor(sf::Color color, unsigned int i, unsigned int j);

    // the font texture to use - generated (not default font texture)
    std::shared_ptr<sf::Texture> fontTexture;

    // map from characters to their texture rects in the generated font texture
    FontCharMap_ptr fontCharMap;
    
    // only the texture coords in these should change with time
    sf::VertexArray chVerts;
    sf::VertexArray bgVerts;

    // the width * height of the terminal, in characters
    sf::Vector2i termDims;

    // the dimensions of a single character, in pixels
    sf::Vector2i chDims;

    // the the padding to be added to each character in screen space
    sf::Vector2i padding;
};

}
