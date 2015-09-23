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
  user_ribosome_symbol = nothing
  user_rna_polymerase_symbol = nothing

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

      # Grab the first element (which is the RNAP polymerase symbol)
      sentence_value = sentence.sentence
      user_rna_polymerase_symbol = sentence_value[1].token_lexeme

    elseif (_is_type_statement(sentence,TRANSLATES))

      # Grab the first element (which is the ribosome symbol)
      sentence_value = sentence.sentence
      user_ribosome_symbol = sentence_value[1].token_lexeme

    elseif (_is_type_statement(sentence,REPRESSES))
    elseif (_is_type_statement(sentence,INHIBITS))
    elseif (_is_type_statement(sentence,ACTIVATES))
    elseif (_is_type_statement(sentence,PHOSPHORYLATES))
    elseif (_is_type_statement(sentence,DEPHOSPHORYLATES))
    elseif (_is_type_statement(sentence,CATALYZE))
    elseif (_is_type_statement(sentence,COMPLEX) && _is_type_statement(sentence,FORM))
    else

      # Get types -
      mRNA_type_prefix = type_prefix_dictionary["mRNA_SYMBOL"]
      gene_type_prefix = type_prefix_dictionary["GENE_SYMBOL"]
      protein_type_prefix = type_prefix_dictionary["PROTEIN_SYMBOL"]

      # ok, we have a gene assignment statement -
      sentence_value = reverse(sentence.sentence)
      _recursive_extract_genetic_symbols(copy(sentence_value),list_of_species)

      # Add the mRNA and protein nodes -
      mRNA_node_array = XMLElement[]
      protein_node_array = XMLElement[]
      gene_node_array = XMLElement[]
      for gene_node in child_elements(list_of_species)

        # grab the list of gene nodes for later ...
        push!(gene_node_array,gene_node)

        # Add transcription rate to tree -
        _add_transcription_rate_nodes_to_tree(gene_node,list_of_transcription_rates,rna_polymerase_symbol=user_rna_polymerase_symbol)

        # Build a temp mRNA node -
        gene_symbol = attribute(gene_node, "symbol"; required=true)
        mRNA_symbol_string = replace(gene_symbol,gene_type_prefix,mRNA_type_prefix)
        mRNA_species_node = new_element("species")
        set_attribute(mRNA_species_node, "type", "mRNA_SYMBOL")
        set_attribute(mRNA_species_node, "initial_amount", "0.0")
        set_attribute(mRNA_species_node, "symbol", mRNA_symbol_string)
        push!(mRNA_node_array,mRNA_species_node)

        # Build a temp protein node -
        protein_symbol_string = replace(gene_symbol,gene_type_prefix,protein_type_prefix)
        protein_species_node = new_element("species")
        set_attribute(protein_species_node, "type", "PROTEIN_SYMBOL")
        set_attribute(protein_species_node, "initial_amount", "0.0")
        set_attribute(protein_species_node, "symbol", protein_symbol_string)
        push!(protein_node_array,protein_species_node)
      end

      # Add the mRNA nodes to the tree -
      for mRNA_node in mRNA_node_array
          add_child(list_of_species,mRNA_node)

          # add translation rates to tree --
          _add_translation_rate_nodes_to_tree(mRNA_node,list_of_translation_rates,ribosome_symbol=user_ribosome_symbol)
      end

      # Add protein nodes to the tree -
      for protein_node in protein_node_array
        add_child(list_of_species,protein_node)

      end
    end



  end

  # return the ast -
  return model_ast
end

function _add_translation_rate_nodes_to_tree(mRNA_node::XMLElement,parent::XMLElement;ribosome_symbol="RIBOSOME")

  # Get the mRNA symbol -
  mRNA_symbol = attribute(mRNA_node,"symbol")

  # Build a translation rate node for this mRNA -
  translation_rate_node = new_child(parent,"translation_rate")
  set_attribute(translation_rate_node, "infrastructure",ribosome_symbol)

  # create parameter child -
  parameter_node = new_child(translation_rate_node,"parameter")
  set_attribute(parameter_node, "type","rate_constant_parameter")
  set_attribute(parameter_node, "symbol","k_translation_"*mRNA_symbol)
  set_attribute(parameter_node, "value","0.1")

  parameter_node_sat_constant = new_child(translation_rate_node,"parameter")
  set_attribute(parameter_node_sat_constant, "type","saturation_constant_parameter")
  set_attribute(parameter_node_sat_constant, "symbol","K_translation_"*mRNA_symbol)
  set_attribute(parameter_node_sat_constant, "value","1.0")

  # create the species node -
  species_reference_node = new_child(translation_rate_node,"species_reference")
  set_attribute(species_reference_node, "symbol",mRNA_symbol)

end

function _add_transcription_rate_nodes_to_tree(gene_node::XMLElement,parent::XMLElement;rna_polymerase_symbol="RNAP")

  # Get the gene symbol -
  gene_symbol = attribute(gene_node,"symbol")

  # Build a transcription rate node for this mRNA -
  transcription_rate_node = new_child(parent,"transcription_rate")
  set_attribute(transcription_rate_node, "infrastructure",rna_polymerase_symbol)

  # create parameter child -
  parameter_node = new_child(transcription_rate_node,"parameter")
  set_attribute(parameter_node, "type","rate_constant_parameter")
  set_attribute(parameter_node, "symbol","k_transcription_"*gene_symbol)
  set_attribute(parameter_node, "value","0.1")

  # create the species node -
  species_reference_node = new_child(transcription_rate_node,"species_reference")
  set_attribute(species_reference_node, "symbol",gene_symbol)

end

function _recursive_extract_genetic_symbols(sentence::Array{MinervaToken,1},parent::XMLElement)

  next_token = pop!(sentence)
  if (isa(next_token.token_type,LPAREN) == true)
    _recursive_extract_genetic_symbols(sentence,parent)
  elseif (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)

    # build a gene species node, add to tree -
    gene_species_node = new_child(parent, "species")
    set_attribute(gene_species_node, "type", "GENE_SYMBOL")
    set_attribute(gene_species_node, "initial_amount", "1.0")
    set_attribute(gene_species_node, "symbol", next_token.token_lexeme)

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
