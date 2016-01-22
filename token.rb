
module Letsauth
    class Token

        attr_accessor :token

        def initialize(token = nil)
            self.token = token
            self.token = SecureRandom.hex if token.nil?
        end
        
    end
end