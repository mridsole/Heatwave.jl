#pragma once

#include <SFML/Graphics.hpp>
#include <map>
#include <memory>

namespace hw {

struct FontCharInfo 
{
    // the character that this represents
    int ch;

    // the bounding box in the texture created by FontTextureBuilder
    sf::IntRect textureRect;

    FontCharInfo(int ch, sf::IntRect textureRect):
        ch(ch), textureRect(textureRect)
    {}

    FontCharInfo() {}
};

struct FontInfo
{
    // width/height in pixels
    sf::Vector2u charDims;

    sf::Vector2i padding;
};

using FontCharMap = std::map<int, FontCharInfo>;
using FontCharMap_ptr = std::shared_ptr<FontCharMap>;

/*
    Takes a monospaced font, and generates a texture where each character 
    has the same pixel dimensions - height determined by getLineSpacing,
    and width determined by the width of any character (i.e. monospaced).
*/
class FontTextureBuilder
{
public:

    FontTextureBuilder(std::shared_ptr<sf::Font> font);
    ~FontTextureBuilder();

    // construct the texture, given a character size
    FontCharMap_ptr buildFontCharMap(sf::Vector2i padding, 
        unsigned int charSize, int charHeight = -1);

    std::shared_ptr<sf::Texture>  buildFontTexture(sf::Vector2i padding,
        unsigned int charSize, int charHeight = -1);

    // the font that's being used to build these
    std::shared_ptr<sf::Font> font;
};

}
