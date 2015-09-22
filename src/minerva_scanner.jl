# Import statements -

# Declare scanner types -
abstract AbstractToken
abstract AbstractTokenType


type LPAREN <: AbstractTokenType
end

type RPAREN <: AbstractTokenType
end

type TRANSCRIBES <: AbstractTokenType
end

type TRANSLATES <: AbstractTokenType
end

type TRANSCRIPTION <: AbstractTokenType
end

type TRANSLATION <: AbstractTokenType
end

type CATALYZE <: AbstractTokenType
end

type AND <: AbstractTokenType
end

type OR <: AbstractTokenType
end

type SPACE <: AbstractTokenType
end

type ARE <: AbstractTokenType
end

type IS <: AbstractTokenType
end

type TO <: AbstractTokenType
end

type RTO <: AbstractTokenType
end

type MY <: AbstractTokenType
end

type ALL <: AbstractTokenType
end

type IN <: AbstractTokenType
end

type MODEL <: AbstractTokenType
end

type THE <: AbstractTokenType
end

type GENE_SYMBOL <: AbstractTokenType
end

type mRNA_SYMBOL <: AbstractTokenType
end

type PROTEIN_SYMBOL <: AbstractTokenType
end

type METABOLITE_SYMBOL <: AbstractTokenType
end

type TYPE <: AbstractTokenType
end

type OF <: AbstractTokenType
end

type SEMICOLON <: AbstractTokenType
end


type REPRESSES <: AbstractTokenType
end

type ACTIVATES <: AbstractTokenType
end

type INHIBITS <: AbstractTokenType
end


type BIOLOGICAL_SYMBOL <: AbstractTokenType
end

immutable MinervaToken <: AbstractToken
  token_lexeme::String
  token_type::AbstractTokenType
end

immutable MinervaSentence
  sentence::Array{MinervaToken,1}
end

immutable MinervaScannerError
  error_message::String
  line_mumber::Int
  column_number::UnitRange{Int64}
end


function build_tokenized_sentence(model_statement::String,token_type_dictionary::Dict{String,MinervaToken})

  # function variables -
  token_vector = MinervaToken[]
  char_stack = Char[]
  counter = 0

  try

    # turn statement into an array, and then reverse the order -
    local_statement_char_array = reverse(collect(model_statement))
    while !isempty(local_statement_char_array)

      # update counter -
      counter+=1

      # pop -
      test_char = pop!(local_statement_char_array)

      # ok, do we have one our special *stop* chars?
      if (test_char == ',' || test_char == ' ' || test_char == '|' || test_char == ';' || test_char == ')')

        # What do we have on our stack?
        if (length(char_stack)>0)

          # ok, we have a legit creature on the stack -
          test_key = string(hash(join(char_stack)))
          if (haskey(token_type_dictionary,test_key) == true)

            # we have a key - kia the stack -
            empty!(char_stack)

            # grab the token_instance -
            token_instance = token_type_dictionary[test_key]

            # push the instance onto the token_vector
            push!(token_vector,token_instance)
          else

            # lexeme
            lexeme = join(char_stack)

            # We have chars in the stack, but not in our token_type_dictionary
            token_instance = MinervaToken(lexeme,BIOLOGICAL_SYMBOL())

            # push the instance onto the token_vector
            push!(token_vector,token_instance)

            # we have a key - kia the stack -
            empty!(char_stack)
          end
        end

        if (test_char == ',')

          # Build the token instance
          token_instance = MinervaToken(",",AND())

          # push the instance onto the token_vector
          push!(token_vector,token_instance)

        elseif (test_char == '|')

          # Build the token instance
          token_instance = MinervaToken("|",OR())

          # push the instance onto the token_vector
          push!(token_vector,token_instance)

        elseif (test_char == ';')

          # Build the token instance
          token_instance = MinervaToken(";",SEMICOLON())

          # push the instance onto the token_vector
          push!(token_vector,token_instance)

        elseif (test_char == ')')

          # Build the token instance
          token_instance = MinervaToken(")",RPAREN())

          # push the instance onto the token_vector
          push!(token_vector,token_instance)

        end

      else

        # Cache the test_char
        push!(char_stack,test_char)

        # we do *not* have a stop char, build a test_key and check in the token_type_dictionary
        test_key = string(hash(join(char_stack)))
        if (haskey(token_type_dictionary,test_key) == true)

          # we have a key - kia the stack -
          empty!(char_stack)

          # grab the token_instance -
          token_instance = token_type_dictionary[test_key]

          # push the instance onto the token_vector
          push!(token_vector,token_instance)
        end
      end
    end

  catch error
    showerror(STDOUT, error, backtrace());println()
  end

  return MinervaSentence(token_vector)

end

function scan_model_statements(model_statement_vector::Array{String,1})

  # function vars -
  line_counter = 1
  error_vector = MinervaScannerError[]
  sentence_vector = MinervaSentence[]

  # Setup the token dictionary (we could load this from a file ...)
  token_type_dictionary = Dict{String,MinervaToken}()
  token_type_dictionary[string(hash("("))] = MinervaToken("(",LPAREN())
  token_type_dictionary[string(hash(")"))] = MinervaToken(")",RPAREN())
  token_type_dictionary[string(hash("transcribes"))] = MinervaToken("transcribes",TRANSCRIBES())
  token_type_dictionary[string(hash("transcription"))] = MinervaToken("transcription",TRANSCRIPTION())
  token_type_dictionary[string(hash("translation"))] = MinervaToken("translation",TRANSLATION())
  token_type_dictionary[string(hash("expression"))] = MinervaToken("transcription",TRANSCRIPTION())
  token_type_dictionary[string(hash("translates"))] = MinervaToken("translates",TRANSLATES())
  token_type_dictionary[string(hash(","))] = MinervaToken(",",AND())
  token_type_dictionary[string(hash("and"))] = MinervaToken("and",AND())
  token_type_dictionary[string(hash("|"))] = MinervaToken("|",OR())
  token_type_dictionary[string(hash("or"))] = MinervaToken("or",OR())
  token_type_dictionary[string(hash("to"))] = MinervaToken("to",TO())
  token_type_dictionary[string(hash("reversible_to"))] = MinervaToken("reversible_to",RTO())
  token_type_dictionary[string(hash("->"))] = MinervaToken("to",TO())
  oken_type_dictionary[string(hash("<->"))] = MinervaToken("reversible_to",RTO())
  token_type_dictionary[string(hash("are"))] = MinervaToken("are",ARE())
  token_type_dictionary[string(hash("="))] = MinervaToken("=",ARE())
  token_type_dictionary[string(hash("is"))] = MinervaToken("is",IS())
  #token_type_dictionary[string(hash("in"))] = MinervaToken("in",IN())
  token_type_dictionary[string(hash("model"))] = MinervaToken("model",MODEL())
  token_type_dictionary[string(hash("catalyzes"))] = MinervaToken("catalyze",CATALYZE())
  token_type_dictionary[string(hash("catalyzed"))] = MinervaToken("catalyze",CATALYZE())
  token_type_dictionary[string(hash("catalyze"))] = MinervaToken("catalyze",CATALYZE())
  token_type_dictionary[string(hash("GENE_SYMBOLS"))] = MinervaToken("GENE_SYMBOL",GENE_SYMBOL())
  token_type_dictionary[string(hash("mRNA_SYMBOLS"))] = MinervaToken("mRNA_SYMBOL",mRNA_SYMBOL())
  token_type_dictionary[string(hash("PROTEIN_SYMBOLS"))] = MinervaToken("PROTEIN_SYMBOL",PROTEIN_SYMBOL())
  token_type_dictionary[string(hash("METABOLITE_SYMBOLS"))] = MinervaToken("METABOLITE_SYMBOL",METABOLITE_SYMBOL())
  token_type_dictionary[string(hash("types"))] = MinervaToken("TYPE",TYPE())
  token_type_dictionary[string(hash("of"))] = MinervaToken("of",OF())
  token_type_dictionary[string(hash("the"))] = MinervaToken("the",THE())
  token_type_dictionary[string(hash("represses"))] = MinervaToken("represses",REPRESSES())
  token_type_dictionary[string(hash("inhibits"))] = MinervaToken("inhibits",INHIBITS())
  token_type_dictionary[string(hash("activates"))] = MinervaToken("activates",ACTIVATES())
  token_type_dictionary[string(hash("my"))] = MinervaToken("my",MY())
  token_type_dictionary[string(hash("all"))] = MinervaToken("all",ALL())

  try

    # process the vector of model statements -
    while !isempty(model_statement_vector)

      # ok, we have a statement, are there any crazy chars in this statement?
      local_statement = pop!(model_statement_vector)

      # Crazy chars?
      if (isempty(search(local_statement,r"[<>\%\&\#\@\!]")) == false)

        # what column number?
        column_number = search(local_statement,r"[<>\%\&\#\@\!]")

        # ok, we have an error (funky char)
        error_message = "ERROR: Invalid character in statement \""*local_statement*"\" at line_mumber: "*string(line_counter)*" and column_number: "*string(column_number[1])
        error_object = MinervaError(error_message,line_counter,column_number)

        # add this to the error vector -
        push!(error_vector,error_object)

      else

        # build vector of tokens -
        local_token_vector = build_tokenized_sentence(local_statement,token_type_dictionary)

        # store -
        push!(sentence_vector,local_token_vector)
      end

      # update the line counter -
      line_counter += 1
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end

  # return token
  return (error_vector,sentence_vector)

end


function load_model_statements(path_to_model_file::String)

  # We are going to load the sentences in the file into a vector
  # if not a valid model file, then throw an error -
  statement_vector = String[]

  try

    # Open the model file, and read each line into a vector -
    open(path_to_model_file,"r") do model_file
      for line in eachline(model_file)

          if (contains(line,"//") == false && search(line,"\n")[1] != 1)
            push!(statement_vector,chomp(line))
          end
      end
    end

  catch err
    showerror(STDOUT, err, backtrace());println()
  end


  # return - (I know we don't need the return, but I *** hate *** the normal Julia convention)
  return statement_vector
end
