require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'
set :database, "sqlite3:leprosoriumhq.db"

class Post < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  belongs_to :user
end

class Comment < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
  
  validates :content, presence: true
end

class User < ActiveRecord::Base
  has_many :comments, dependent: :destroy
  has_many :posts, dependent: :destroy
  
  validates :name, presence: true
  validates :phone, presence: true
  validates :phone, uniqueness: true
end

get '/' do
  @posts = Post.all
  erb :posts
end

get '/new' do
  @post = 
  erb :new
end

post '/new' do
  @user_p = params[:user]
  @post_p = params[:post]
  
  @user = User.find_by phone: @user_p[:phone]  
  if @user && @user.name != @user_p[:name]
    @error = "This phone number: #{@user.phone} belongs another author"
    return erb :new
  end
  
  unless @user
    @user = User.create @user_p
    if @user.invalid?
      @error = @user.errors.full_messages.join ', '
      return erb :new
    end
  end
  
  @post = @user.posts.new @post_p
  unless @post_p
    if @post.invalid?
      @error = @post.errors.full_messages.join ', '
      return erb :new
    end 
  end
  @post.save
  
  @message = "You add new post"
  @posts = Post.all
  erb :posts
  
end

get '/post/:id' do
  @post = Post.find params[:id]
  
  erb :post
end

post '/post/:id' do
  @post = Post.find params[:id]

  @user_p = params[:user]
  @comment_p = params[:comment]

  @user = User.find_by phone: @user_p[:phone]  
  if @user && @user.name != @user_p[:name]
    @error = "This phone number: #{@user.phone} belongs another author"
    return erb :post
  end
  
  unless @user
    @user = User.create @user_p
    if @user.invalid?
      @error = @user.errors.full_messages.join ', '
      return erb :post
    end
  end
  
  #@comment_p[:user_id] = @user.id
  
  @comment = @post.comments.new @comment_p
  @comment.user = @user
  if @comment.invalid?
    @error = @comment.errors.full_messages.join ', '
    return erb :post
  end
  @comment.save
  
  erb :post
end
