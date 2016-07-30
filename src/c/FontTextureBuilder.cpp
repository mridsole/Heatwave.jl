#include "FontTextureBuilder.h"
#include "FontUtils.h"
#include <assert.h>

hw::FontTextureBuilder::FontTextureBuilder(std::shared_ptr<sf::Font> font):
    font(font)
{}

hw::FontTextureBuilder::~FontTextureBuilder() {}

std::shared_ptr<hw::FontCharMap> hw::FontTextureBuilder::buildFontCharMap(
    unsigned int charSize, int charHeight) {
    
    // construct and get pointer to a new FontCharMap
    FontCharMap_ptr fcm_ptr(new FontCharMap());

    if (charHeight == -1) {
        charHeight = this->font->getLineSpacing(charSize);
    }

    assert(charHeight > 0);

    // char width comes from any 'normal' glyph
    sf::Glyph aGlyph = this->font->getGlyph('a', charSize, false);
    int charWidth = round(aGlyph.advance);

    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {

            (*fcm_ptr)[(char)(i * 16 + j)] = FontCharInfo(
                (char)(i * 16 + j),
                sf::IntRect(charWidth * i, charHeight * j, charWidth, charHeight)
                );
        }
    }

    return fcm_ptr;
}

std::shared_ptr<sf::Texture> hw::FontTextureBuilder::buildFontTexture(
    unsigned int charSize, int charHeight) {
    
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
    fontImage.create(17 * charWidth, 17 * charHeight, sf::Color(0, 0, 0, 0));

    // now get the automatically generated font texture as an image
    sf::Image defaultFontImage = this->font->getTexture(charSize).copyToImage();

    // copy each character in from the default font texture
    for (int i = 0; i < 16; i++) {
        for (int j = 0; j < 16; j++) {

            sf::Glyph gly = this->font->getGlyph((char)(i*16 + j), charSize, false);

            // copy in the pixels
            int destX = i * charWidth + gly.bounds.left;
            int destY = j * charHeight + (charHeight + gly.bounds.top);

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
    
    return texture_ptr;
}
