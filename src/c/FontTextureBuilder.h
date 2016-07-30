#pragma once

#include <SFML/Graphics.hpp>
#include <map>
#include <memory>

namespace hw {

struct FontCharInfo 
{
    // the character that this represents
    char ch;

    // the bounding box in the texture created by FontTextureBuilder
    sf::IntRect textureRect;

    FontCharInfo(char ch, sf::IntRect textureRect):
        ch(ch), textureRect(textureRect)
    {}

    FontCharInfo() {}
};

struct FontInfo
{
    // width/height in pixels
    int charWidth;
    int charHeight;
};

using FontCharMap = std::map<char, FontCharInfo>;
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
    FontCharMap_ptr buildFontCharMap(unsigned int charSize, int charHeight = -1);

    std::shared_ptr<sf::Texture>  buildFontTexture(unsigned int charSize, int charHeight = -1);

    // the font that's being used to build these
    std::shared_ptr<sf::Font> font;
};

}
