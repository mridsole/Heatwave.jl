#include "Terminal.h"

#include <iostream>
#include "stdio.h"

hw::Terminal::Terminal(
    std::shared_ptr<sf::Texture> fontTexture, 
    FontCharMap_ptr fontCharMap,
    sf::Vector2i termDims, 
    sf::Vector2i chDims,
    sf::Vector2i padding):

    fontTexture(fontTexture), fontCharMap(fontCharMap), 
    termDims(termDims), chDims(chDims), padding(padding)
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

    std::cout << chDims.x << chDims.y << std::endl;

    // set the render space positions for VA masks
    for (int i = 0; i < termDims.x; i++) {
        for (int j = 0; j < termDims.y; j++) {

            // four vertices to deal with here - each corner
            // these position values are invariant - the only things that
            // should be changed on these vertices are color and tex coords
            unsigned int first_idx = (j * termDims.x + i) * 4;

            // top-left corner
            this->chVerts[first_idx].position.x = i * chDims.x - padding.x;
            this->chVerts[first_idx].position.y = j * chDims.y - padding.y;

            // bottom-left corner
            this->chVerts[first_idx + 1].position.x = i * chDims.x - padding.x;
            this->chVerts[first_idx + 1].position.y = (j + 1) * chDims.y + padding.y;

            // bottom-right corner
            this->chVerts[first_idx + 2].position.x = (i + 1) * chDims.x + padding.x;
            this->chVerts[first_idx + 2].position.y = (j + 1) * chDims.y + padding.y;

            // top-right corner
            this->chVerts[first_idx + 3].position.x = (i + 1) * chDims.x + padding.x;
            this->chVerts[first_idx + 3].position.y = j * chDims.y - padding.y;
        }
    }
}

void hw::Terminal::draw(sf::RenderTarget & target, sf::RenderStates states) const {

    // dont complain about not using render states
    (void)states;

    // TODO: draw the background as well
    
    target.draw(this->chVerts, this->fontTexture.get());
}

void hw::Terminal::setChar(int ch, unsigned int i, unsigned int j) {
    
    // set the quad to the match the appropriate rect
    unsigned int first_idx = (j * this->termDims.x + i) * 4;

    sf::IntRect texRect = (*fontCharMap)[ch].textureRect;

    // top-left corner
    this->chVerts[first_idx].texCoords.x = texRect.left;
    this->chVerts[first_idx].texCoords.y = texRect.top;

    // bottom-left corner
    this->chVerts[first_idx + 1].texCoords.x = texRect.left;
    this->chVerts[first_idx + 1].texCoords.y = texRect.top + texRect.height;

    // bottom-right corner
    this->chVerts[first_idx + 2].texCoords.x = texRect.left + texRect.width; 
    this->chVerts[first_idx + 2].texCoords.y = texRect.top + texRect.height;

    // top-right corner
    this->chVerts[first_idx + 3].texCoords.x = texRect.left + texRect.width; 
    this->chVerts[first_idx + 3].texCoords.y = texRect.top;
}

void hw::Terminal::setAllChars(int * chs) {
    
    // ch must be at least as big as the terminal dimensions!
    for (int i = 0; i < this->termDims.x; i++) {
        for (int j = 0; j < this->termDims.y; j++) {
            
            this->setChar(chs[this->termDims.y * j + i], i, j);
        }
    }
}

void hw::Terminal::setCharColor(sf::Color color, unsigned int i, unsigned int j) {
    
    unsigned int first_idx = (j * this->termDims.x + i) * 4;

    this->chVerts[first_idx].color = color;
    this->chVerts[first_idx + 1].color = color;
    this->chVerts[first_idx + 2].color = color;
    this->chVerts[first_idx + 3].color = color;
}

void hw::Terminal::setAllCharColors(sf::Color * colors) {

    // ch must be at least as big as the terminal dimensions!
    for (int i = 0; i < this->termDims.x; i++) {
        for (int j = 0; j < this->termDims.y; j++) {
            
            this->setCharColor(colors[this->termDims.y * j + i], i, j);
        }
    }
}

/*
 *  C INTERFACE
 *  
 * 
 */
extern "C" {

    void hwTerminal_setChar(hw::Terminal * term, 
        int ch, unsigned int i, unsigned int j) {
        
        term->setChar(ch, i, j);
    }

    void hwTerminal_setAllChars(hw::Terminal * term, int * chs) {

        term->setAllChars(chs);
    }

    void hwTerminal_setCharColor(hw::Terminal * term, 
        sf::Color color, unsigned int i, unsigned int j) {

        term->setCharColor(color, i, j);
    }

    void hwTerminal_setAllCharColors(hw::Terminal * term, sf::Color * colors) {

        term->setAllCharColors(colors);
    }
};
