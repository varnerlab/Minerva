function _parse_minerva_gene_symbol_assignment_sentence(sentence::Array{MinervaToken,1})

  # Ok, we have a gene symbols statement, parse to make sure it is ok
  # {biological symbol} are GENE_SYMBOLS;
  #
  # Example
  # (g_xynP,g_xynB,g_xylA,g_xylB,g_xylR,g_ccpA,g_Hpr,g_HprK,g_eI,g_eIIA,g_eIIB,g_IIC) are GENE_SYMBOLS;

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)
    # ok, we have a biological symbol, which is correct.
    # Go down again and check for type -
    return _parse_minerva_gene_symbol_relationship_token(sentence)

  elseif (isa(next_token.token_type,LPAREN) == true)

    # before we go any futher, do we have a matching )?
    if (_scan_token_array_for_matching_parenthesis(sentence))
      # ( => we have a list. Recurse ...
      return _parse_minerva_gene_symbol_assignment_sentence(sentence)
    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR in "*string(@__FILE__)*". Missing a )?"
      return parser_error
    end

  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a biological symbol"
    return parser_error
  end
end

function _parse_minerva_gene_symbol_relationship_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,AND) || isa(next_token.token_type,OR))
    return _parse_minerva_gene_symbol_assignment_sentence(sentence)
  elseif (isa(next_token.token_type,RPAREN))
    return _parse_minerva_gene_symbol_symbol_token(sentence)
  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected an OR, AND or )."
    return parser_error
  end
end

function _parse_minerva_gene_symbol_symbol_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,GENE_SYMBOL))
    return _parse_minerva_gene_symbol_symbol_token(sentence)
  elseif (isa(next_token.token_type,ARE))
    return _parse_minerva_gene_symbol_symbol_token(sentence)
  elseif (isa(next_token.token_type,SEMICOLON))
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a GENE_SYMBOL, ARE or ; token."
    return parser_error

  end
end
