#include "GameInstance.h"

// ...
hw::Game::Game() {
    
}

hw::Game::~Game() {
    
}

void hw::Game::initSFML() {
    
}

// our C interface
extern "C" {
    
    hw::Game* hwGame_create() {
        return new hw::Game();
    }

    void hwGame_destroy(hw::Game* game) {
        delete game;
    }

    void hwGame_initSFML(hw::Game* game) {
        game->initSFML();
    }
}
