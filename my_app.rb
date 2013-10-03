require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra/reloader'
require 'sinatra/base'
require 'mongo'
require 'json/ext' # required for .to_json

class MyApp < Sinatra::Base

include Mongo

  configure do
    conn = MongoClient.new("localhost", 27017)
    set :mongo_connection, conn
    set :mongo_db, conn.db('carmanage')
  end

helpers do
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = object_id(id) if String === id
    settings.mongo_db['carmanage'].
      find_one(:_id => id).to_json
  end
end

get '/document/:id/?' do
  content_type :json
  document_by_id(params[:id]).to_json
end

  get "/" do
    content_type :json
    @car = settings.mongo_db['carmanage'].find.to_a.to_json
    @car = JSON.parse(@car)
    erb :"car/view"
  end

end
