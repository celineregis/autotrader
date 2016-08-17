require "pstore"
module Token	
	
	def get_token(token_type)
		tokens = PStore.new("tokens.pstore")
		token = ""
		tokens.transaction(true) do 
			token = tokens.fetch(token_type.to_sym).to_s
		end
		token
	end

	def store_token(token, token_type)
		tokens = PStore.new("tokens.pstore")
		tokens.transaction do 
			tokens[token_type.to_sym] = token
		end
	end

end