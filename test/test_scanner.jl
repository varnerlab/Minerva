using MinervaCompiler
using Base.Test
using LightXML

# Setup load file test -
model_file_path = "/Users/jeffreyvarner/Desktop/julia_work/minerva/bin/BSubCCRNetwork.net"
@test typeof(load_model_statements(model_file_path)) == Array{String,1}
statement_vector = load_model_statements(model_file_path)

# Look at list of tokens and errors -
(error_vector,token_vector) = scan_model_statements(statement_vector)
for error in error_vector
  println(error.error_message)
end

# Parse the list of tokens -
parse_error_vector = parse_token_array(token_vector)
if (isempty(parse_error_vector))

  # retokenize ... (we destroy the token stack when we parse it)
  (error_vector,token_vector) = scan_model_statements(statement_vector)

  # ok, we have no parser errors - build the AST
  model_tree = build_ast_from_sentence_array(token_vector)

  # Do what we need with the AST
  # ...

  # clean up my memory ...
  free(model_tree)

end
