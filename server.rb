#!/usr/bin/env ruby

require './mail.rb'
require './mailtoken.rb'
require './authtoken.rb'

require 'sinatra/base'
require 'thread/pool'
require 'json/jwt'
require 'httparty'

module Letsauth
    class Backend < Sinatra::Application

        # to prevent worrying about databases, this global hash will allow to keep the confirmed mails
        # TODO: This needs a timeout
        class << self; attr_accessor :mails end
        # Place to store the additional information needed, like the origin
        class << self; attr_accessor :authData end
        # threadpool for background tasks, like sending mails
        class << self; attr_accessor :pool end
        # helper variable, the url of this LA instance
        class << self; attr_accessor :serverURL end
        # private key for authToken signature
        class << self; attr_accessor :private_key end
        @mails = {}
        @authData = {}
        @pool = Thread.pool(2)
        @serverURL = "http://localhost:9292/"


        configure do
            if File.exists?('private_key')
                Backend::private_key = OpenSSL::PKey::EC.new(File.read('private_key'))
            else
                Backend::private_key = OpenSSL::PKey::EC.new('secp521r1').generate_key
                File.write('private_key', Backend::private_key.to_pem)
                # Aso generate public key, see https://github.com/ruby/openssl/issues/29 for why this sucks so much
                point = Backend::private_key.public_key
                pub = OpenSSL::PKey::EC.new(point.group)
                pub.public_key = point
                File.write('public/public_key', pub.to_pem)
            end
        end

        post '/confirm' do
            headers 'Access-Control-Allow-Origin' => '*'
            # The RP asks a mail to be confirmed
            Backend::authData[params[:mail]] = {:session_id => params[:session_id], :origin => request.env['HTTP_ORIGIN']}
            Mail.new(params[:mail]).confirm
        end

        get '/mailConfirm' do
            # If user clicks on the link in the confirmation mail, he and his token end here
            mail = params[:mail]
            if Mail.new(mail).confirmToken(params[:token])
                authToken = AuthToken.new(origin: Backend::authData[mail][:origin], mail: params[:mail], nonce: Backend::authData[mail][:session_id])
                Backend::authData.delete(mail)

                # The auth token has to be formated as in the specs: "The value of the id_token parameter is the ID Token, which is a signed JWT, containing three base64url encoded segments separated by period ('.') characters". The JWT gem shall take care of that in AuthToken.to_s                
                HTTParty.post(authToken.aud + '/la_validate', {:body => {"id_token" => authToken.to_s}})
                
                return "Login confirmed"
            else
                return "Something went wrong (invalid token?)"
            end
        end
        
    end
end