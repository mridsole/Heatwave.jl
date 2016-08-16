#==
    Grid for storing the render characters in before drawing them. 
==#

type StateRenderGrid
    
    # characters to draw
    chs::Array{UInt32, 2}

    # list of lists of objects from which characters are generated
    # the items in the arrays are assumed to be nullable
    # (and therefore implement isnull(...) and get(...))
    # 
    generators::Array{Any, 1}

    # internal use: mask used for the priority selection
    chs_generated::Array{Bool, 2}
    
    function StateRenderGrid(x::Int, y::Int)

        srg = new(
            Array{UInt32, 2}(x, y), 
            Array{Array{Any, 2}, 1}(),
            Array{Bool, 2}(x, y)
        )

        fill!(srg.chs, UInt32(' '))
        fill!(srg.chs_generated, false)

        return srg
    end
end

function generate!(srg::StateRenderGrid)
    
    # fill with default characters
    fill!(srg.chs, UInt32(' '))

    # fill the generated mask with false
    fill!(srg.chs_generated, false)
    
    # get dimensions
    dimx, dimy = size(srg.chs)
    
    # iterate through each position
    for x = 1:dimx, y = 1:dimy

        if srg.chs_generated[x, y] continue end

        # if we haven't generated, iterate through each generator
        for generator in srg.generators

            if !isnull(generator[x, y])

                srg.chs_generated[x, y] = true
                srg.chs[x, y] = char(get(generator[x, y]))
                break
            end
        end
    end
end
