# Include statements -
using Debug

include("minerva_scanner.jl")
include("minerva_type_assignment_grammar.jl")
include("minerva_transcribes_grammar.jl")
include("minerva_translates_grammar.jl")
include("minerva_repression_grammar.jl")
include("minerva_inhibits_grammar.jl")
include("minerva_activates_grammar.jl")
include("minerva_gene_symbol_assignment_grammar.jl")
include("minerva_phosphorylates_grammar.jl")
include("minerva_dephosphorylates_grammar.jl")
include("minerva_complex_grammar.jl")
include("minerva_catalyzes_grammar.jl")

type MinervaParserError
  error_message::String
  #line_mumber::Int
  #column_number::UnitRange{Int64}

  function MinervaParserError()
    this = new ()
  end

end

# Methods to parse the token array from the scanner -
function parse_token_array(sentence_vector::Array{MinervaSentence,1})

  # function variables -
  error_vector = MinervaParserError[]

  # parse -
  while !isempty(sentence_vector)

    # Pop a sentence off the sentence array
    sentence = pop!(sentence_vector)

    # Analysis of the sentence will define command to parse this sentence -
    if (_is_type_statement(sentence,TYPE))

      # We have a type asignment - parse
      parser_error = _parse_minerva_type_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,TRANSCRIBES))

      # We have a transcribes statement - parse
      parser_error = _parse_minerva_transcribes_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,TRANSLATES))

      # @show sentence

      # We have a translated statement - parse
      parser_error = _parse_minerva_translates_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,REPRESSES))

      # We have a represses statement - parse
      parser_error = _parse_minerva_repression_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,INHIBITS))

      # We have a inhibits statement - parse
      parser_error = _parse_minerva_inhibits_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,ACTIVATES))

      # We have a activates statement - parse
      parser_error = _parse_minerva_activates_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    elseif (_is_type_statement(sentence,PHOSPHORYLATES))

      @show sentence
      
    elseif (_is_type_statement(sentence,DEPHOSPHORYLATES))

      @show sentence

    elseif (_is_type_statement(sentence,CATALYZE))

      @show sentence

    elseif (_is_type_statement(sentence,COMPLEX) && _is_type_statement(sentence,FORM))

      @show sentence

    else
      # ok ... we have done everything else ...
      # we have a gene symbol assignment statement
      parser_error = _parse_minerva_gene_symbol_assignment_sentence(reverse(sentence.sentence))
      if (parser_error != nothing)
        push!(error_vector,parser_error)
      end

    end
  end

  # return -
  return error_vector

end

function _is_type_statement{T}(minerva_sentence::MinervaSentence,test_token_type::T)

  sentence = minerva_sentence.sentence
  for token in sentence

    if (isa(token.token_type,test_token_type))

      # @show sentence token.token_type

      return true
    end
  end


  return false
end


function _parse_minerva_semicolon_symbol_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,SEMICOLON))

    # ok, we have a SEMICOLON. Return nothing -
    return nothing
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected a \";\""
    return parser_error
  end
end

@debug function _scan_token_array_for_matching_parenthesis(sentence::Array{MinervaToken,1})

  for token in sentence
    if (isa(token.token_type,LPAREN))
      return false
    end
  end

  for token in sentence
    if (isa(token.token_type,RPAREN))
      return true
    end
  end

  # default is false -
  return false
end
