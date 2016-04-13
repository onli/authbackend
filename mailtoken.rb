
module Letsauth
    class MailToken

        attr_accessor :token

        def initialize(token = nil)
            self.token = token
            self.token = SecureRandom.hex if token.nil?
        end

        def to_s
            return self.token.to_s
        end
    end
end