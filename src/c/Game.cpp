#include "Game.h"
#include <assert.h>
#include <iostream>

// ...
hw::Game::Game(
    sf::Vector2u windowDims, 
    std::string windowTitle, 
    sf::Vector2i termDims, 
    std::string fontPath,
    int fontSize
    )
{
    
    init(windowDims, windowTitle, termDims, fontPath, fontSize);
}

hw::Game::~Game() {
    
}

void hw::Game::init(
    sf::Vector2u windowDims, 
    std::string windowTitle, 
    sf::Vector2i termDims, 
    std::string fontPath,
    int fontSize
) {

    // initialize SFML (make the render window etc)
    this->initSFML(windowDims, windowTitle);
    
    // load the font
    this->termFont = std::shared_ptr<sf::Font>(new sf::Font());
    if (!termFont->loadFromFile(fontPath)) {

        std::cout << "Couldn't load terminal font! (path " << 
            fontPath << std::endl;

        return;
    }
    
    // make a font texture builder
    FontTextureBuilder fontTextureBuilder(termFont);

    sf::Vector2i padding(0, 4);

    // and the font char map
    // (padding heuristic used here - anything above a certain amount
    // doesn't matter, as long as it's enough.)
    this->fontCharMap = fontTextureBuilder.buildFontCharMap(padding, fontSize);

    // build the font texture
    this->fontTexture = fontTextureBuilder.buildFontTexture(padding, fontSize);

    // construct the terminal
    this->terminal = std::shared_ptr<hw::Terminal>(
        new hw::Terminal(this->fontTexture, this->fontCharMap,
            termDims, fontTextureBuilder.fontInfo.charDims, 
            fontTextureBuilder.fontInfo.padding
            )
        );
}

void hw::Game::initSFML(sf::Vector2u windowDims, std::string windowTitle) {
    
    this->renderWindow = std::shared_ptr<sf::RenderWindow>(
        new sf::RenderWindow(sf::VideoMode(windowDims.x, windowDims.y),
            windowTitle
            )
        );
}

void hw::Game::tick() {
    
    // for now - just poll and throw away all the events
    // we will eventually need access to these in julia, though
    sf::Event event;
    while (this->renderWindow->pollEvent(event)) {}

    // clear, draw the terminal, then display
    this->renderWindow->clear();
    this->renderWindow->draw(*this->terminal);
    this->renderWindow->display();
}

// our C interface
extern "C" {
    
    hw::Game* hwGame_create(
        sf::Vector2u windowDims,
        char * windowTitle,
        sf::Vector2i termDims,
        char * fontPath,
        int fontSize
        ) {

        return new hw::Game(windowDims, std::string(windowTitle), 
            termDims, std::string(fontPath), fontSize);
    }

    void hwGame_destroy(hw::Game * game) {

        delete game;
    }

    void hwGame_tick(hw::Game * game) {
        
        game->tick();
    }

    hw::Terminal * hwGame_getTerminal(hw::Game * game) {
        
        return game->terminal.get();
    }
}
