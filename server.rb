#!/usr/bin/env ruby

require './mail.rb'

require 'sinatra/base'
require 'thread/pool'

class Backend < Sinatra::Application

    # to prevent worrying about databases, this global hash will allow to keep the confirmed mails
    # TODO: This needs a timeout
    class << self; attr_accessor :mails end 
    class << self; attr_accessor :pool end 
    @mails = {}
    @pool = Thread.pool(14)

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
            return ""
        else
            status 403
        end
    end

end