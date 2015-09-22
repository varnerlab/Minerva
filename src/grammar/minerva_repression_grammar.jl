function _parse_minerva_repression_sentence(sentence::Array{MinervaToken,1})

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
    return _parse_minerva_repression_relationship_token(sentence)
  elseif (isa(next_token.token_type,LPAREN) == true)
    # ( => we have a list. Recurse ...
    return _parse_minerva_repression_sentence(sentence)

  else
    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a biological symbol"
    return parser_error
  end
end


function _parse_minerva_repression_relationship_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,AND) || isa(next_token.token_type,OR))

    return _parse_minerva_repression_sentence(sentence)

  elseif (isa(next_token.token_type,RPAREN))
    return _parse_minerva_repression_represses_token(sentence)
  elseif (isa(next_token.token_type,SEMICOLON) == true)
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a OR and AND."
    return parser_error
  end
end

function _parse_minerva_repression_represses_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,REPRESSES))
    return _parse_minerva_repression_the_token(sentence)
  elseif (isa(next_token.token_type,SEMICOLON) == true)
    return nothing
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR in "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected a 'the' symbol"
    return parser_error
  end
end

function _parse_minerva_repression_transcription_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,TRANSCRIPTION))
    return _parse_minerva_repression_of_token(sentence)
  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected the 'transcription' or 'expression' symbol"
    return parser_error
  end
end

function _parse_minerva_repression_of_token(sentence::Array{MinervaToken,1})

  # grab the next token -
  next_token = pop!(sentence)
  if (isa(next_token.token_type,OF))

    return _parse_minerva_repression_sentence(sentence)

  else

    # not correct - throw an error
    parser_error = MinervaParserError()
    parser_error.error_message = "ERROR "*string(@__FILE__)*". Found unexpected token "*next_token.token_lexeme*". Expected the 'of' token."
    return parser_error
  end
end

function _parse_minerva_repression_the_token(sentence::Array{MinervaToken,1})

    # grab the next token -
    next_token = pop!(sentence)
    if (isa(next_token.token_type,THE) == true)
      return _parse_minerva_repression_transcription_token(sentence)
    elseif (isa(next_token.token_type,SEMICOLON) == true)
      return nothing
    else
      # not correct - throw an error
      parser_error = MinervaParserError()
      parser_error.error_message = "ERROR: Found unexpected token "*next_token.token_lexeme*". Expected the 'the' token."
      return parser_error
    end
end
