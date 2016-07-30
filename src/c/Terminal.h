#include <SFML/Graphics.hpp>

namespace hw {

/*
    manages the vertex array map
*/
class Terminal : sf::Drawable
{
public:
    Terminal(sf::Vector2u term_dims, sf::Vector2u ch_dims);
    ~Terminal();

    void init();

    virtual void draw(sf::RenderTarget & target, sf::RenderStates states) const;

    // the font texture to use
    sf::Texture font_texture;
    
    // only the texture coords in these should change with time
    sf::VertexArray ch_verts;
    sf::VertexArray bg_verts;

    // the width * height of the terminal, in characters
    sf::Vector2u term_dims;

    // the dimensions of a single character, in pixels
    sf::Vector2u ch_dims; 
};

}
