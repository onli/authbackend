
module Letsauth
    class AuthToken
        # see http://openid.net/specs/openid-connect-core-1_0.html#id_tokenExample

        # issue, this LA instance url
        attr_accessor :iss
        
        # audience, the RP for which this token is for. We get this from the origin
        attr_accessor :aud
        
        # when the token expires
        attr_accessor :exp

        # for which email the token is
        attr_accessor :sub

        # we pass the session id as nonce 
        attr_accessor :nonce


        def initialize(origin:, mail:, nonce:)
            self.iss = Backend::serverURL
            self.aud = origin
            self.exp = Time.now.to_i + 60   # make it valid for one minute
            self.sub = mail
            self.nonce = nonce
        end

        # create a postable and signed string
        def to_s
            jwt = JSON::JWT.new(
                iss: self.iss,
                aud: self.aud,
                exp: self.exp,
                sub: self.sub,
                nonce: self.nonce
            )
            
            jws = jwt.sign(Backend::private_key, :ES512)
            return jws.to_s
        end
    end
end