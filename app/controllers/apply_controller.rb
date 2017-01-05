class ApplyController < ApplicationController
  $Sclass = {
      0 => '--请选择班级--',
      1 => '20160713'
  }
  def index
    if params[:sclass] == nil
      params[:sclass] = '0'
    end




    search_string = "false"
    if params[:submit] != nil
      if params[:sclass] != '0'
        search_string = " true and student_class = '" + params[:sclass] + "'"
      end
    end


      @user = User.joins(:student_class).where(search_string)

  end
end
