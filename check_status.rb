require 'sinatra'
require 'nokogiri'
require 'sanitize'
require 'open-uri'
require 'json'

set :raise_errors, false
set :show_exceptions, false
set :public_folder, 'public'

get '/' do
  erb :index
end

get '/status.json' do
  content_type :json

  url = "http://192.168.1.254/cgi-bin/dslstatistics.ha"

  data = Nokogiri::HTML(open(url))

  @status_percent = 0

  @status_1 = Sanitize.clean(data.css('.col2')[0]).delete("\n").strip
  @status_2 = Sanitize.clean(data.css('.col2')[1]).delete("\n").strip

  @status_percent = 20 if @status_1 == "ACTIVATING"
  @status_percent = 40 if @status_1 == "TRAINING"
  @status_percent = 60 if @status_1 == "ANALYSIS"
  @status_percent = 80 if @status_1 == "EXCHANGE"

  if @status_2 == "Up"
    @status_percent = 100
  else
    @status_percent = 90 if @status_2 != "Up" if @status_1 == "Up"
    @status_percent = 95 if @status_2 == "No IP Address"
  end

  { :status_percent => @status_percent, :status_1 => @status_1, :status_2 => @status_2 }.to_json
end


error do
  "Error"
end
