#pragma once

#include <SFML/Graphics.hpp>

void burnInFontTexture(sf::Font * font, unsigned int charSize);
sf::Vector2u getCharDims(sf::Font * font, unsigned int charSize);
