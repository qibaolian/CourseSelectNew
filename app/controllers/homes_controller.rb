class HomesController < ApplicationController
  def index
    #@articles = inform::articles.all
    @announcement=Inform::Article.all
  end
  def inform_content
    #@articles = inform::articles.all
    @announcement1=Inform::Article.all
    #find_by_title(params[:request])

    #@user_request = UserRequest.find(params[:request])
  end


end
