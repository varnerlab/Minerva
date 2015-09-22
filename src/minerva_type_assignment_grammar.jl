# Include statements -
#include("minerva_scanner.jl")

# --------- TYPE GRAMMER --------------------------------------------- #
function _parse_minerva_type_are_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,ARE) == true)

    # ok, we have an are. Look for type
    return _parse_minerva_type_token(sentence)

  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected an \"are\""
    return parser_error
  end
end

function _parse_minerva_type_of_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,OF) == true)

    # ok, we have an are. Look for type
    return _parse_minerva_reserved_type_symbol_token(sentence)

  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected an \"of\""
    return parser_error
  end
end

function _parse_minerva_reserved_type_symbol_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,GENE_SYMBOL) || isa(next_token.token_type,PROTEIN_SYMBOL) || isa(next_token.token_type,mRNA_SYMBOL) || isa(next_token.token_type,METABOLITE_SYMBOL))
    return _parse_minerva_semicolon_symbol_token(sentence)
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found Found unexpected token "*next_token.token_lexeme*". Expected a reserved model type (GENE_SYMBOL | PROTEIN_SYMBOL | METABOLITE_SYMBOL | mRNA_SYMBOL)"
    return parser_error
  end
end

function _parse_minerva_type_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,TYPE) == true)
    return _parse_minerva_type_of_token(sentence)
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected \"type\""
    return parser_error
  end
end

function _parse_minerva_type_sentence(sentence::Array{MinervaToken,1})

  # Ok, we have a type assignment, parse to make sure it is ok
  # {type prefix} * {type|types} * {GENE_SYMBOL|mRNA_SYMBOL|PROTEIN_SYMBOL|METABOLITE_SYMBOL}

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)
    # ok, we have a biological symbol, which is correct.
    # Go down again and check for type -
    return _parse_minerva_type_are_token(sentence)
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected a biological symbol"
    return parser_error
  end

end
