module MinervaCompiler

  # Include the components of the compiler, a scanner and parser
  include("minerva_scanner.jl")
  include("minerva_parser.jl")

  # export symbols -
  export load_model_statements,scan_model_statements,MinervaScannerError,MinervaParserError,MinervaToken,parse_token_array

end
