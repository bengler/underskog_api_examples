class Application < Sinatra::Base

  configure do |config|
    config.set :views, File.expand_path('..', __FILE__)
    config.set :haml, :layout => :'layout'
  end

  configure :production do |config|
    config.set :show_exceptions, false
  end

  configure :development do |config|
    config.set :show_exceptions, true
    config.register Sinatra::Reloader
    config.also_reload '*.rb'
  end

  before do
    @user_id = session[:user_id]
    if (token = session[:token])
      client = OAuth2::Client.new(UNDERSKOG_API_KEY, UNDERSKOG_SECRET,
        site: 'https://underskog.no/')
      @token = OAuth2::AccessToken.new(client, token)
      @user = @token.get("/api/v1/users/current").parsed['data']
    end
  end

  get '/?' do
    unless @token
      return haml :not_logged_in
    end
    @messages = @token.get('/api/v1/messages').parsed['data']
    haml :index
  end

  get '/login' do
    redirect to("/auth/underskog")
  end

  get '/logout' do
    session.delete(:user_id)
    session.delete(:token)
    redirect to('/')
  end

  get '/auth/failure' do
  end

  get '/auth/underskog/callback' do
    auth_data = request.env['omniauth.auth']
    session[:user_id] = auth_data['uid']
    session[:token] = auth_data['credentials']['token']
    redirect to('/')
  end

end