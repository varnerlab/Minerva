# Include statements -
#include("minerva_scanner.jl")

function _parse_minerva_transcribes_sentence(sentence::Array{MinervaToken,1})

  # Ok, we have a type assignment, parse to make sure it is ok
  # {biological symbol} transcribes * GENE_SYMBOLS;

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)
    # ok, we have a biological symbol, which is correct.
    # Go down again and check for type -
    return _parse_minerva_transcribes_transcribes_token(sentence)
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected a biological symbol"
    return parser_error
  end
end

function _parse_minerva_transcribes_transcribes_token(sentence::Array{MinervaToken,1})

    # grab the next token -
    next_token = pop!(sentence)
    if (isa(next_token.token_type,TRANSCRIBES) == true)
      return _parse_minerva_transcribes_the_token(sentence)
    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected the 'transcribes' token."
      return parser_error
    end
end

function _parse_minerva_transcribes_the_token(sentence::Array{MinervaToken,1})

    # grab the next token -
    next_token = pop!(sentence)
    if (isa(next_token.token_type,THE) == true)
      return _parse_minerva_transcribes_reserved_symbol_token(sentence)

    elseif (isa(next_token.token_type,MY) == true)
      return _parse_minerva_transcribes_reserved_symbol_token(sentence)

    elseif (isa(next_token.token_type,ALL) == true)
      return _parse_minerva_transcribes_the_token(sentence)

    elseif (isa(next_token.token_type,GENE_SYMBOL) ||
      isa(next_token.token_type,PROTEIN_SYMBOL) ||
      isa(next_token.token_type,mRNA_SYMBOL) ||
      isa(next_token.token_type,METABOLITE_SYMBOL))

      return _parse_minerva_semicolon_symbol_token(sentence)

    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected the 'the' token."
      return parser_error
    end
end

function _parse_minerva_transcribes_reserved_symbol_token(sentence::Array{MinervaToken,1})

    # grab the next token -
    next_token = pop!(sentence)
    if (isa(next_token.token_type,GENE_SYMBOL) || isa(next_token.token_type,PROTEIN_SYMBOL) || isa(next_token.token_type,mRNA_SYMBOL) || isa(next_token.token_type,METABOLITE_SYMBOL))
      return _parse_minerva_semicolon_symbol_token(sentence)
    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected a reserved model type (GENE_SYMBOL | PROTEIN_SYMBOL | METABOLITE_SYMBOL | mRNA_SYMBOL)"
      return parser_error
    end
end
