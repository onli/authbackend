
class Mail
    attr_accessor :address

    def initialize(mail)
        self.address = mail
    end

    def confirm
        # TODO: this would now use the background threadpool to send an email to the address with a confirmation link
        # we assume that this works and instead wait for a bit before setting the local state to confirmed
        Backend::pool.process {
            sleep(5)
            Backend::mails[self.address] = true
        }
    end


    def confirmed?
        return Backend::mails.delete(self.address)
    end

end