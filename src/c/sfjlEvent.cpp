#include "sfjlEvent.h"
#include "SFML/Window.hpp"
#include "stdio.h"

// um
extern "C" {

    sf::Event::EventType sfjlEvent_getType(
        sf::Event * e) {
        
        return e->type;
    }
    
    sf::Event::JoystickButtonEvent sfjlEvent_getJoystickButtonEvent(
        sf::Event * e) {
        
        return e->joystickButton;
    }
    
    sf::Event::JoystickConnectEvent sfjlEvent_getJoystickConnectEvent(
        sf::Event * e) {
        
        return e->joystickConnect;
    }
    
    sf::Event::JoystickMoveEvent sfjlEvent_getJoystickMoveEvent(
        sf::Event * e) {
        
        return e->joystickMove;
    }
    
    sf::Event::KeyEvent sfjlEvent_getKeyEvent(
        sf::Event * e) {
        
        sf::Event::KeyEvent retEvent = e->key;
        return retEvent;
    }

    sf::Event::MouseButtonEvent sfjlEvent_getMouseButtonEvent(
        sf::Event * e) {
        
        return e->mouseButton;
    }

    sf::Event::MouseMoveEvent sfjlEvent_getMouseMoveEvent(
        sf::Event * e) {
       
        return e->mouseMove;
    }

    sf::Event::MouseWheelEvent sfjlEvent_getMouseWheelEvent(
        sf::Event * e) {
       
        return e->mouseWheel;
    }

    sf::Event::MouseWheelScrollEvent sfjlEvent_getMouseWheelScrollEvent(
        sf::Event * e) {
       
        return e->mouseWheelScroll;
    }

    sf::Event::SensorEvent sfjlEvent_getSensorEvent(
        sf::Event * e) {
        
        return e->sensor;
    }

    sf::Event::TextEvent sfjlEvent_getTextEvent(
        sf::Event * e) {
        
        return e->text;
    }

    sf::Event::TouchEvent sfjlEvent_getTouchEvent(
        sf::Event * e) {
        
        return e->touch;
    }
}
