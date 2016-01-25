#!/usr/bin/env ruby

require './mail.rb'
require './token.rb'

require 'sinatra/base'
require 'thread/pool'

module Letsauth

    class Backend < Sinatra::Application

        # to prevent worrying about databases, this global hash will allow to keep the confirmed mails
        # TODO: This needs a timeout
        class << self; attr_accessor :mails end
        # RPs need to have a way to confirm that an access token is valid, easiest way is to ask. Thus it has to be stored
        class << self; attr_accessor :validTokens end
        # threadpool for background tasks, like sending mails
        class << self; attr_accessor :pool end
        # helfer variable, the url of this LA instance
        class << self; attr_accessor :serverURL end 
        @mails = {}
        @validTokens = {}
        @pool = Thread.pool(2)
        @serverURL = "http://localhost:9292/"

        post '/confirm' do
            headers 'Access-Control-Allow-Origin' => '*'
            # The RP asks a mail to be confirmed
            Mail.new(params[:mail]).confirm
        end

        get '/confirmtest' do
            # The RP asks a mail to be confirmed
            Mail.new(params[:mail]).confirm
        end


        get '/confirm' do
            headers 'Access-Control-Allow-Origin' => '*'
            # periodically (till we have a better solution) the RP will ask whether the mail is confirmed.
            # Tell him yes (200) or no (403)
            # TODO: this would something to protect it from other parties than the original RP
            if Mail.new(params[:mail]).confirmed?
                token = Token.new
                Backend::validTokens[token.to_s] = params[:mail]
                return token.to_s
            else
                status 403
            end
        end

        get '/mailConfirm' do
            # If user clicks on the link in the confirmation mail, he and his token end here
            if Mail.new(params[:mail]).confirmToken(params[:token])
                return "Login confirmed"
            else
                return "Something went wrong (invalid token?)"
            end
        end

        get '/validate' do
            # confirm to RP that access token is valid
            mail = Backend::validTokens.delete(params[:token])
            if mail
                return mail
            else
                status 403
            end
        end
    end

end