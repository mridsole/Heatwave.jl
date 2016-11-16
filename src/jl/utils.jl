#==
    Utilities
==#

"""
    @imcp Type OriginalInstance NewValues
Macro for changing some number of fields of an immutable (or actually, 
any type) to obtain a new instance with only those fields changed.  This is 
a pretty bad hack but there's no alternative for constructing large immutables
from existing ones.

# Examples

```
new_state = @imcp CarrierState carrier.state begin
    x = 1
    y = 2
end
```

"""
macro imcp(typsym, oldsym, newvals)
    
    # Get the type by evaluating.
    typ = eval(typsym)
    @assert typeof(typ) == DataType

    # Start constructing the expression with a call to the constructor.
    expr = :($(typsym)())
    
    # Decompose newvals into a dictionary of symbols mapping to new value 
    # expressions.
    newvalsdict = Dict{Symbol, Any}()
    for eqnexpr in newvals.args

        # skip anything that isn't an equation
        if eqnexpr.head != :(=) continue end
        
        newvalsdict[eqnexpr.args[1]] = eqnexpr.args[2]
    end

    for fieldsym in fieldnames(typ)

        if fieldsym in keys(newvalsdict)
            push!(expr.args, newvalsdict[fieldsym])
        else
            push!(expr.args, :($(oldsym).$(fieldsym)))
        end
    end
    
    return expr
end

"""
    bare_enum(name, start, [args...])

Generates an expression for an enum type, implemented as a bare module.

# Examples

```
bare_enum(
    :KeyCodes, -1,
    :A, :B, ...
) |> eval
```

"""
function bare_enum(name, start, args...)
    
    module_body = quote end

    i = Int64(start)
    
    for arg in args
        push!(module_body.args, :(const $(arg) = $(i)))
        i += 1
    end

    Expr(:module, false, name, module_body)
end

# Exports
export imcp
export bare_enum
