using MinervaCompiler
using Base.Test

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
parse_token_array(token_vector)
