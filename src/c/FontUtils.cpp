#include "FontUtils.h"

void burnInFontTexture(sf::Font * font, unsigned int charSize) {
    
    // generate a string with every character, to burn in the font texture
    std::string burnInStr = "";
    burnInStr.resize(256);
    for (int i = 0; i < 256; i++) {
        burnInStr[i] = (char)i;
    }

    // burn in the font texture - i think this should do it
    sf::Text burnInText(burnInStr, *font, charSize);
    font->getTexture(charSize);
}
