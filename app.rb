require 'sinatra'
require 'json'
require 'logger'
require 'active_record'
require 'pg'

require_relative 'models/init'

logdir = File.dirname(__FILE__) + "/logs"
Log = ::Logger.new(logdir + '/app.log')

# DB設定ファイルの読み込み
ActiveRecord::Base.configurations = YAML.load_file('config/database.yml')
ActiveRecord::Base.establish_connection(:development)

get '/' do
  erb :todo_list
end

post '/create' do
  Log.info "foo"
  params = JSON.parse request.body.read
  Log.info params
  params.each do |param|
    param_done = param["done"] == "true"
    topic = Topic.new(title: param["title"], done: false, order_num: param["order"])
    topic.save
  end
  JSON.generate({status: "success"})
end

get '/index' do
  @topics = Topic.order("created_at DESC").limit(10)
  erb '/topic/index'.to_sym
end