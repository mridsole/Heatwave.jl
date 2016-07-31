#include "FontTextureBuilder.h"
#include "FontUtils.h"
#include <assert.h>

hw::FontTextureBuilder::FontTextureBuilder(std::shared_ptr<sf::Font> font):
    font(font)
{}

hw::FontTextureBuilder::~FontTextureBuilder() {}

std::shared_ptr<hw::FontCharMap> hw::FontTextureBuilder::buildFontCharMap(
    sf::Vector2i padding, unsigned int charSize, int charHeight) {
    
    // construct and get pointer to a new FontCharMap
    FontCharMap_ptr fcm_ptr(new FontCharMap());

    if (charHeight == -1) {
        charHeight = this->font->getLineSpacing(charSize);
    }

    assert(charHeight > 0);

    // char width comes from any 'normal' glyph
    sf::Glyph aGlyph = this->font->getGlyph('a', charSize, false);
    int charWidth = round(aGlyph.advance);

    int rectWidth = charWidth + 2 * padding.x;
    int rectHeight = charHeight + 2 * padding.y;

    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {

            (*fcm_ptr)[(char)(j * 16 + i)] = FontCharInfo(
                (char)(j * 16 + i),
                sf::IntRect((rectWidth + 2 * padding.x) * i + padding.x, 
                    (rectHeight + 2 * padding.y) * j + padding.y, 
                    rectWidth, rectHeight)
                );
        }
    }

    return fcm_ptr;
}

std::shared_ptr<sf::Texture> hw::FontTextureBuilder::buildFontTexture(
    sf::Vector2i padding, unsigned int charSize, int charHeight) {
    
    // burn in the font texture
    burnInFontTexture(this->font.get(), charSize);

    // examine the glyph for the 'a' character
    sf::Glyph aGlyph = this->font->getGlyph('a', charSize, false);

    // from the glyph we get the width - the height comes from the font
    int charWidth = round(aGlyph.advance);

    if (charHeight == -1) {
        charHeight = round(this->font->getLineSpacing(charSize));
    }

    assert(charHeight > 0);

    // work with an image first - we'll move it to a texture later
    sf::Image fontImage;

    // account for padding in the image size
    fontImage.create(16 * (charWidth + 4 * padding.x), 
        16 * (charHeight + 4 * padding.y), 
        sf::Color(0, 0, 0, 0));

    // now get the automatically generated font texture as an image
    sf::Image defaultFontImage = this->font->getTexture(charSize).copyToImage();

    // copy each character in from the default font texture
    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {

            sf::Glyph gly = this->font->getGlyph((char)(j*16 + i), charSize, false);

            // copy in the pixels
            int destX = i * charWidth + gly.bounds.left + (2 * i + 1) * (2 * padding.x);
            int destY = j * charHeight + (charHeight + gly.bounds.top) + 
                (2 * j + 1) * (2 * padding.y);

            // careful! if the src rect is (0, 0, 0, 0), then it'll actually copy
            // the whole texture - seems like bad design on SFML's part
            if (gly.textureRect != sf::IntRect(0, 0, 0, 0)) {
                fontImage.copy(defaultFontImage, destX, destY, gly.textureRect, false);
            }
        }
    }
    
    // now make the texture
    std::shared_ptr<sf::Texture> texture_ptr(new sf::Texture());
    assert( texture_ptr->loadFromImage(fontImage) );

    texture_ptr->setSmooth(false);
    
    return texture_ptr;
}
