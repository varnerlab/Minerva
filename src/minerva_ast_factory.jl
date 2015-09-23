# Using statements -
using LightXML

# include statements -
include("minerva_scanner.jl")

# Global -
type_prefix_dictionary = Dict{String,String}()

# Methods to build an XML-based abstract syntax tree from the sentence array
# We then use this AST to generate our model code. It is assumed that the
# sentences have been validated *before* they are passed into this function
function build_ast_from_sentence_array(sentence_vector::Array{MinervaSentence,1})

  # function declarations -
  model_ast = XMLDocument()
  root = create_root(model_ast, "minerva_ast")


  # main children -
  list_of_types = new_child(root, "list_of_types")
  list_of_species = new_child(root,"list_of_species")
  list_of_transcription_rates = new_child(root,"list_of_transcription_rates")
  list_of_translation_rates = new_child(root,"list_of_translation_rates")

  # parse -
  while !isempty(sentence_vector)

    # Pop a sentence off the sentence array
    sentence = pop!(sentence_vector)

    # ok, we have a sentence, we need to build ast for each type of sentence
    # process types -
    if (_is_type_statement(sentence,TYPE))

      # get the first and penultimate token -
      sentence_value = sentence.sentence
      symbol_token = sentence_value[1]
      type_token = sentence_value[length(sentence_value)-1]

      # ok, we have a type -
      type_node = new_child(list_of_types, "type_node")
      set_attribute(type_node, "type", type_token.token_lexeme)
      set_attribute(type_node, "symbol", symbol_token.token_lexeme)

      # Cache the type prefix -
      type_prefix_dictionary[type_token.token_lexeme] = symbol_token.token_lexeme

    elseif (_is_type_statement(sentence,TRANSCRIBES))
    elseif (_is_type_statement(sentence,TRANSLATES))
    elseif (_is_type_statement(sentence,REPRESSES))
    elseif (_is_type_statement(sentence,INHIBITS))
    elseif (_is_type_statement(sentence,ACTIVATES))
    elseif (_is_type_statement(sentence,PHOSPHORYLATES))
    elseif (_is_type_statement(sentence,DEPHOSPHORYLATES))
    elseif (_is_type_statement(sentence,CATALYZE))
    elseif (_is_type_statement(sentence,COMPLEX) && _is_type_statement(sentence,FORM))
    else

      # ok, we have a gene assignment statement -
      sentence_value = reverse(sentence.sentence)
      _recursive_extract_genetic_symbols(sentence_value,list_of_species)
    end

  end

  # return the ast -
  return model_ast
end

function _recursive_extract_genetic_symbols(sentence::Array{MinervaToken,1},parent::XMLElement)

  next_token = pop!(sentence)
  if (isa(next_token.token_type,LPAREN) == true)
    _recursive_extract_genetic_symbols(sentence,parent)
  elseif (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)

    # Get types -
    mRNA_type_prefix = type_prefix_dictionary["mRNA_SYMBOL"]
    gene_type_prefix = type_prefix_dictionary["GENE_SYMBOL"]
    protein_type_prefix = type_prefix_dictionary["PROTEIN_SYMBOL"]

    # build a gene species node, add to tree -
    gene_species_node = new_child(parent, "species_node")
    set_attribute(gene_species_node, "type", "GENE_SYMBOL")
    set_attribute(gene_species_node, "initial_amount", "1.0")
    set_attribute(gene_species_node, "symbol", next_token.token_lexeme)

    # build an mRNA species node ...
    mRNA_symbol_string = replace(next_token.token_lexeme,gene_type_prefix,mRNA_type_prefix)
    mRNA_species_node = new_child(parent, "species_node")
    set_attribute(mRNA_species_node, "type", "mRNA_SYMBOL")
    set_attribute(mRNA_species_node, "initial_amount", "0.0")
    set_attribute(mRNA_species_node, "symbol", mRNA_symbol_string)

    # build an protein species node ...
    protein_symbol_string = replace(next_token.token_lexeme,gene_type_prefix,protein_type_prefix)
    protein_species_node = new_child(parent, "species_node")
    set_attribute(protein_species_node, "type", "PROTEIN_SYMBOL")
    set_attribute(protein_species_node, "initial_amount", "0.0")
    set_attribute(protein_species_node, "symbol", protein_symbol_string)

    # go down again ...
    _recursive_extract_genetic_symbols(sentence,parent)
  elseif (isa(next_token.token_type,AND) || isa(next_token.token_type,OR))
    _recursive_extract_genetic_symbols(sentence,parent)
  elseif (isa(next_token.token_type,RPAREN) == true)
    _recursive_extract_genetic_symbols(sentence,parent)
  elseif (isa(next_token.token_type,ARE))
    return nothing
  end
end
