#include "Terminal.h"

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

    // create the background texture - it's just one pixel ...
    sf::Image bgTexture_image;
    bgTexture_image.create(1, 1, sf::Color(255, 255, 255, 255));

    bgTexture.loadFromImage(bgTexture_image);

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

            // now, let's also set the background vertices - don't use padding this time

            // top-left corner - actually add the vertical padding values ... 
            this->bgVerts[first_idx].position.x = i * chDims.x;
            this->bgVerts[first_idx].position.y = j * chDims.y + padding.y;

            this->bgVerts[first_idx + 1].position.x = i * chDims.x;
            this->bgVerts[first_idx + 1].position.y = (j + 1) * chDims.y + padding.y;

            this->bgVerts[first_idx + 2].position.x = (i + 1) * chDims.x;
            this->bgVerts[first_idx + 2].position.y = (j + 1) * chDims.y + padding.y;

            this->bgVerts[first_idx + 3].position.x = (i + 1) * chDims.x;
            this->bgVerts[first_idx + 3].position.y = j * chDims.y + padding.y;

            // all quads should map to the same texture - which is just one pixel!
            this->bgVerts[first_idx].texCoords.x = 0;
            this->bgVerts[first_idx].texCoords.y = 0;
            this->bgVerts[first_idx + 1].texCoords.x = 0;
            this->bgVerts[first_idx + 1].texCoords.x = 0;
            this->bgVerts[first_idx + 2].texCoords.x = 0;
            this->bgVerts[first_idx + 2].texCoords.y = 0;
            this->bgVerts[first_idx + 3].texCoords.y = 0;
            this->bgVerts[first_idx + 3].texCoords.y = 0;

            // set the color to black
            this->setBgColor(sf::Color(0, 0, 0, 255), i, j);
        }
    }
}

void hw::Terminal::draw(sf::RenderTarget & target, sf::RenderStates states) const {

    // dont complain about not using render states
    (void)states;

    // draw the background
    target.draw(this->bgVerts, &this->bgTexture);
    
    // draw the characters
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
            
            this->setChar(chs[this->termDims.x * j + i], i, j);
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
            
            this->setCharColor(colors[this->termDims.x * j + i], i, j);
        }
    }
}

void hw::Terminal::setBgColor(sf::Color color, unsigned int i, unsigned int j) {
    
    unsigned int first_idx = (j * this->termDims.x + i) * 4;

    this->bgVerts[first_idx].color = color;
    this->bgVerts[first_idx + 1].color = color;
    this->bgVerts[first_idx + 2].color = color;
    this->bgVerts[first_idx + 3].color = color;
}

void hw::Terminal::setAllBgColors(sf::Color * colors) {
    
    // ch must be at least as big as the terminal dimensions!
    for (int i = 0; i < this->termDims.x; i++) {
        for (int j = 0; j < this->termDims.y; j++) {
            
            this->setBgColor(colors[this->termDims.x * j + i], i, j);
        }
    }
}

/*
 *  C INTERFACE
 *  
 *  Some notes:
 *   - In Julia we will have sf::Color as an immutable type
 *   - we don't want to have to deal with 'draw' calls from julia
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

    void hwTerminal_setBgColor(hw::Terminal * term,
        sf::Color color, unsigned int i, unsigned int j) {
        
        term->setBgColor(color, i, j);
    }

    void hwTerminal_setAllBgColors(hw::Terminal * term,
        sf::Color * colors) {

        term->setAllBgColors(colors);
    }

    // "incompatible with C" it'll be FINE BRO
    sf::Vector2i hwTerminal_getDims(hw::Terminal * term) {
        
        return term->termDims;
    }
};
