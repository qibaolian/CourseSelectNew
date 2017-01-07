class ApplyController < ApplicationController
  before_action :admin_logged_in
  require "prawn"
  hashh=Hash.new
  hashh[0]='--请选择班级--'
  Institute.all.each do |f|
    hashh[f.id]=f.class_code.to_s
  end
  $Sclass=hashh

  def index
    @ins=Institute.all
    search_string = "false"
    if params[:submit] != nil
      if params[:sclass] != '0'
        search_string = "student_class = '" + $Sclass[params[:sclass].to_i] + "'"
        banji=$Sclass[params[:sclass].to_i]
        Prawn::Document.generate("public/selectCourse/"+banji+".pdf") do
          font_families.update("Arial" => {
              :normal => "#{Rails.root}/app/assets/fonts/华文楷体.ttf",
          })
          font "Arial"
          text "****班级："+banji+"****"
          text "--------------------------------------------------------------------------------------"
          @user = User.where(search_string)
          @user.each do |i|
            text "学生姓名："+i.name
            @course=i.courses
            @course.each do |j|
              text "------"+j.name
            end
          text "\n"
          text "学生签字："
          text "--------------------------------------------------------------------------------------"
          end
        end
        send_file "public/selectCourse/"+banji+".pdf"
      end
      if params[:sclass] == '0'
      flash[:warning] = "请选择要打印成绩单的班级"
      end
    end
  end
  def admin_logged_in
    unless admin_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
end
