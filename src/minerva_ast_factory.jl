# Using statements -
using LightXML

# include statements -
include("minerva_scanner.jl")

# Methods to build an XML-based abstract syntax tree from the sentence array
# We then use this AST to generate our model code. It is assumed that the
# sentences have been validated *before* they are passed into this function
function build_ast_from_sentence_array(sentence_vector::Array{MinervaSentence,1})

  # function declarations -
  model_ast = XMLDocument()
  root = create_root(model_ast, "model_ast")

  # parse -
  while !isempty(sentence_vector)

    # Pop a sentence off the sentence array
    sentence = pop!(sentence_vector)

    # ok, we have a sentence, we need to build ast for each type of sentence
    # ...

  end

  # return the ast -
  return model_ast
end
