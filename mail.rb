
module Letsauth
    class Mail
        attr_accessor :address

        def initialize(mail)
            self.address = mail
        end

        def confirm
            # TODO: this would now use the background threadpool to send an email to the address with a confirmation link
            # we assume that this works and instead wait for a bit before setting the local state to confirmed
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
            Pony.mail(:to => self.adress,
                        :from => "letsauth@example.org",
                        :subject => "Confirm Login",
                        :body => "Please confirm your login by opening this link: \n\n: " + confirmationLink
                    )
        end

    end
end