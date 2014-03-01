require 'rubygems' if RUBY_VERSION < "1.9"
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/base'
require 'mongo'
require 'json/ext' # required for .to_json

class MyApp < Sinatra::Base

use Rack::Auth::Basic, "Restricted Area" do |username, password|
  username == 'nmontes' and password == 'admin_pass'
end

include Mongo

configure do
  db = MongoClient.new("172.17.0.32", 27017).db("carmanage")
  coll = db.collection("carmanage")
  set :coll, coll
  set :db, db
end

helpers do
  def object_id val
    BSON::ObjectId.from_string(val)
  end

  def document_by_id id
    id = object_id(id) if String === id
    settings.coll.find_one(:_id => id).to_json
  end
end

  get '/car/view/:id' do
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    erb :"car/view"
  end

  get '/car/add' do
    erb :"car/add"
  end

  post '/car/add/?' do
    puts params
    new_id = settings.coll.insert params
    redirect to('/')
  end

  get '/refuel/list/:id' do
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    @refuel = @car['refuel']
    puts @refuel
    erb :"refuel/list"
  end

  get '/refuel/add/:id' do
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    @carID = params[:id]
    erb :"refuel/add"
  end

  post '/refuel/add/:id' do
    id   = object_id(params[:id])
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    if params[:km].to_i > @car['km'].to_i
	refuelKm = params[:km].to_i - @car['km'].to_i
        carKm = params[:km].to_i
    else
        carKm =  @car['km'].to_i + params[:km].to_i
        refuelKm = params[:km]
    end
    settings.coll.update({"_id" => id}, {"$set" => {"km" => carKm.to_s}})
    settings.coll.update({"_id" => id}, {"$push" => {"refuel" => {"liter" => params[:liter], "km" => refuelKm.to_s, "station" => params[:station], "price" => params[:price], "date" => params[:date]}}})
    redirect to('/car/view/' + params[:id])
  end

  get '/repair/list/:id' do
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    @repair = @car['repair']
    erb :"repair/list"
  end

  get '/repair/add/:id' do
    @car = document_by_id(params[:id])
    @car = JSON.parse(@car)
    @carID = params[:id]
    erb :"repair/add"
  end

  post '/repair/add/:id' do
    id   = object_id(params[:id])
    settings.coll.update({"_id" => id}, {"$push" => {"repair" => {"km" => params[:km], "price" => params[:price], "date" => params[:date], "comment" => params[:comment]}}})
    redirect to('/car/view/' + params[:id])
  end

  get "/" do
    @listCar = settings.coll.find.to_a.to_json
    @listCar = JSON.parse(@listCar)
    erb :"car/list"
  end

end
