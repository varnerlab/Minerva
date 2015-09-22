function _parse_minerva_activates_sentence(sentence::Array{MinervaToken,1})

  # Ok, we have a repression statement, parse to make sure it is ok
  # {biological symbol} represses * {biological symbol}
  #
  # Example
  # (p_xylR|p_ccpA_pHpr-S46) represses the transcription of (g_xynP,g_xynB,g_xylA,g_xylB);


  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,BIOLOGICAL_SYMBOL) == true)
    # ok, we have a biological symbol, which is correct.
    # Go down again and check for type -
    return _parse_minerva_activates_relationship_token(sentence)

  elseif (isa(next_token.token_type,LPAREN) == true)

    # before we go any futher, do we have a matching )?
    if (_scan_token_array_for_matching_parenthesis(sentence))
      # ( => we have a list. Recurse ...
      return _parse_minerva_activates_sentence(sentence)
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

function _parse_minerva_activates_relationship_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,AND) || isa(next_token.token_type,OR))

    return _parse_minerva_activates_sentence(sentence)

  elseif (isa(next_token.token_type,RPAREN))
    return _parse_minerva_activates_activates_token(sentence)
  elseif (isa(next_token.token_type,ACTIVATES))
    return _parse_minerva_activates_biological_symbol(sentence)
  elseif (isa(next_token.token_type,SEMICOLON) == true)
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a OR and AND."
    return parser_error
  end
end

function _parse_minerva_activates_biological_symbol(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,BIOLOGICAL_SYMBOL))
    return _parse_minerva_activates_relationship_token(sentence)
  elseif (isa(next_token.token_type,LPAREN) == true)

    if (_scan_token_array_for_matching_parenthesis(sentence) == true)
      # ( => we have a list. Recurse ...
      return _parse_minerva_activates_sentence(sentence)
    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR in "*string(@__FILE__)*". Unbalanced parenthesis. Check for a missing )"
      return parser_error
    end
  elseif (isa(next_token.token_type,SEMICOLON) == true)
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a biological symbol, ) or ; symbol"
    return parser_error
  end
end

function _parse_minerva_activates_activates_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,ACTIVATES))
    return _parse_minerva_activates_sentence(sentence)
  elseif (isa(next_token.token_type,SEMICOLON) == true)
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected an 'activates' or a ; symbol"
    return parser_error
  end
end
