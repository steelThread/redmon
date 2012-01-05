class Redmon::App < Sinatra::Base

  set :haml, :format => :html5
  set :views, ::File.expand_path('../../../haml', __FILE__)
  set :public, ::File.expand_path('../../../public', __FILE__)

  helpers do
    include Rack::Utils
    alias_method :h, :escape_html
  end

  get '/' do
    haml :app
  end
end