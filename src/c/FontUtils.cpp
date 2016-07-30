#include "FontUtils.h"

void burnInFontTexture(sf::Font * font, unsigned int charSize) {
    
    // get texture after requesting every possible glyph
    for (int i = 0; i < 256; i++) {
        font->getGlyph((char)i, charSize, false);
        font->getTexture(charSize);
    }
}
