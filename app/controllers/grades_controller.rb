class GradesController < ApplicationController

  before_action :teacher_logged_in, only: [:update, :mystore]

  respond_to :html, :xls

  def update
    @grade=Grade.find_by_id(params[:id])
    if @grade.update_attributes!(:grade => params[:grade][:grade])
      flash={:success => "#{@grade.user.name} #{@grade.course.name}的成绩已成功修改为 #{@grade.grade}"}
    else
      flash={:danger => "上传失败.请重试"}
    end
    redirect_to grades_path(course_id: params[:course_id]), flash: flash
  end

  def index
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end

  def excel
    if teacher_logged_in?
      a = Time.now            #调用现在时间
      @a = (a.to_i* 1000)

      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
      respond_with @grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end
  end


  def declare
    if teacher_logged_in?
      @course=Course.find_by_id(params[:course_id])
      @grades=@course.grades
    elsif student_logged_in?
      @grades=current_user.grades
    else
      redirect_to root_path, flash: {:warning=>"请先登陆"}
    end

  end

  def mystore


    @course = Course.find_by_id(params[:course_id])
    @grades=@course.grades
    up_file = params[:localfile]
    myfile = AvatarUploader.new
    myfile.store!(up_file)

    file_path = "#{Rails.root}/public/public/my/upload/directory/"+up_file.original_filename

    @file = Roo::Excel.new(file_path)

    i=2
    while @file.row(i)[0]
    @user = User.find_by_num(@file.row(i)[0])
    if @user
        @grade = Grade.where(:user_id => @user.id, :course_id => @course.id)
        @grade.update_all(grade: @file.row(i)[3])
    end
      i+=1
    end
  end


  private

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

end
