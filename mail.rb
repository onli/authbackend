
module Letsauth
    class Mail
        attr_accessor :address

        def initialize(mail)
            self.address = mail
        end

        def confirm
            Backend::pool.process {
                token = Token.new()
                Backend::mails[self.address] = token
                self.askConfirmation(token)
            }
        end


        def confirmed?
            if Backend::mails[self.address] == true
                return Backend::mails.delete(self.address)
            end
        end

        def confirmToken(token)
            if Backend::mails[self.address].token == token
                Backend::mails[self.address] = true
                return true
            end
            return false
        end

        def askConfirmation(token)
            confirmationLink = Backend::serverURL + "mailConfirm?mail=" + self.address + '&token=' + token.to_s
            Pony.mail(:to => self.address,
                        :from => "letsauth@example.org",
                        :subject => "Confirm Login",
                        :body => "Please confirm your login by opening this link: \n\n " + confirmationLink
                    )
        end

    end
end