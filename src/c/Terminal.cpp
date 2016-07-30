#include "Terminal.h"

#include "stdio.h"

hw::Terminal::Terminal(
    std::shared_ptr<sf::Texture> fontTexture, 
    FontCharMap_ptr fontCharMap,
    sf::Vector2u termDims, 
    sf::Vector2u chDims):

    fontTexture(fontTexture), fontCharMap(fontCharMap), 
    termDims(termDims), chDims(chDims)
{
    this->init();
}

hw::Terminal::~Terminal() {
    
}

void hw::Terminal::init() {

    // set quads render type for character mask vertex arrays
    this->chVerts.setPrimitiveType(sf::Quads);
    this->bgVerts.setPrimitiveType(sf::Quads);

    // set appropriate size for vertex array masks
    this->chVerts.resize(termDims.x * termDims.y * 4);
    this->bgVerts.resize(termDims.x * termDims.y * 4);

    // set the render space positions for VA masks
    for (unsigned int i = 0; i < termDims.x; i++) {
        for (unsigned int j = 0; j < termDims.y; j++) {

            // four vertices to deal with here - each corner
            // these position values are invariant - the only things that
            // should be changed on these vertices are color and tex coords
            unsigned int first_idx = (j * termDims.x + i) * 4;

            // top-left corner
            this->chVerts[first_idx].position.x = i * chDims.x;
            this->chVerts[first_idx].position.y = j * chDims.y;

            // bottom-left corner
            this->chVerts[first_idx + 1].position.x = i * chDims.x;
            this->chVerts[first_idx + 1].position.y = (j + 1) * chDims.y;

            // bottom-right corner
            this->chVerts[first_idx + 2].position.x = (i + 1) * chDims.x;
            this->chVerts[first_idx + 2].position.y = (j + 1) * chDims.y;

            // top-right corner
            this->chVerts[first_idx + 3].position.x = (i + 1) * chDims.x;
            this->chVerts[first_idx + 3].position.y = chDims.y;
        }
    }
}

void hw::Terminal::draw(sf::RenderTarget & target, sf::RenderStates states) const {

    // TODO: draw the background as well

    states.texture = this->fontTexture.get();
    target.draw(this->chVerts, states);
}

void hw::Terminal::setChar(char ch, unsigned int i, unsigned int j) {
    
    // set the quad to the match the appropriate rect
    unsigned int first_idx = (j * this->termDims.x + i) * 4;

    // top-left corner
    this->chVerts[first_idx].texCoords.x = (*fontCharMap)[ch].textureRect.left;
    this->chVerts[first_idx].texCoords.y = (*fontCharMap)[ch].textureRect.top;

    // bottom-left corner
    this->chVerts[first_idx + 1].texCoords.x = (*fontCharMap)[ch].textureRect.left;
    this->chVerts[first_idx + 1].texCoords.y = (*fontCharMap)[ch].textureRect.top +
        (*fontCharMap)[ch].textureRect.height;

    // bottom-right corner
    this->chVerts[first_idx + 2].texCoords.x = (i + 1) * chDims.x +
        (*fontCharMap)[ch].textureRect.width; 
    this->chVerts[first_idx + 2].texCoords.y = (j + 1) * chDims.y +
        (*fontCharMap)[ch].textureRect.height;

    // top-right corner
    this->chVerts[first_idx + 3].texCoords.x = (i + 1) * chDims.x +
        (*fontCharMap)[ch].textureRect.width; 
    this->chVerts[first_idx + 3].texCoords.y = chDims.y;
}

void hw::Terminal::setCharColor(sf::Color color, unsigned int i, unsigned int j) {
    
    unsigned int first_idx = (j * this->termDims.x + i) * 4;

    this->chVerts[first_idx].color = color;
    this->chVerts[first_idx + 1].color = color;
    this->chVerts[first_idx + 2].color = color;
    this->chVerts[first_idx + 3].color = color;
}
