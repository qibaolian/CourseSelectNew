class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list,:sumCredit,:courseTable]
  before_action :teacher_logged_in, only: [:new, :create, :edit, :destroy, :update]
  before_action :logged_in, only: :index

  #-------------------------for teachers----------------------

  def new
    @course=Course.new
  end

  def create
    @course = Course.new(course_params)
    if @course.save
      current_user.teaching_courses<<@course
      redirect_to courses_path, flash: {success: "新课程申请成功"}
    else
      flash[:warning] = "信息填写有误,请重试"
      render 'new'
    end
  end

  def edit
    @course=Course.find_by_id(params[:id])
  end

  def update
    @course = Course.find_by_id(params[:id])
    if @course.update_attributes(course_params)
      flash={:info => "更新成功"}
    else
      flash={:warning => "更新失败"}
    end
    redirect_to courses_path, flash: flash
  end

  def destroy
    @course=Course.find_by_id(params[:id])
    current_user.teaching_courses.delete(@course)
    @course.destroy
    flash={:success => "成功删除课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

=begin
  #modified by liqingjian
  def open
    @course=Course.find_by_id(params[:id])
    @course.update_attribute(:open,true)

    redirect_to courses_path, flash: {:success => "已经成功开启该课程:#{ @course.name}"}
  end

  def close
    @course=Course.find_by_id(params[:id])
    @course.update_attribute(:open,false)
    redirect_to courses_path, flash: {:success => "已经成功关闭该课程:#{ @course.name}"}
  end

  #modified end
=end
  #-------------------------for students----------------------

  def list
    @course=Course.all
    @course=@course-current_user.courses
=begin
    #modified by liqingjian
    @course=Course.where("open=true")
    @course=@course-current_user.courses
    #modified end
=end
  end

  def sumCredit#lvfeng
    @courses=current_user.courses if student_logged_in?
    @sumc1=0
    @sumc2=0
    @sumc=0
    @courses.each do |course|
      @sumc=@sumc+course.credit.to_i
      if course.course_type=='公共选修课'
        @sumc1=@sumc1+course.credit.to_i
      elsif course.course_type=='专业核心课' || course.course_type=='一级学科核心课'
        @sumc2=@sumc2+course.credit.to_i
      end
    end
  end

  def courseTable#course table
    @courses=current_user.courses if student_logged_in?
    @courseT=Array.new(77,'')
    @courses.each do |i|
      @courseI=CourseInfo.find_by_course_code(i.id)
      j=@courseI
      if j.course_class.to_i>9
        a=Array(j.course_class.to_i-1..j.course_class[3,2].to_i-1)
      else
        a=Array(j.course_class.to_i-1..j.course_class[2,2].to_i-1)
      end
      a.each do |s|
        @courseT[s*7+(j.course_day.to_i-1)]=i.name+"["+i.course_week+"]"+"["+i.class_room+"]"
      end
    end
  end

  def select
    @course=Course.find_by_id(params[:id])
    current_user.courses<<@course
    flash={:success => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end

  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?
  end




  private

  # Confirms a student logged-in user.
  def student_logged_in
    unless student_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a teacher logged-in user.
  def teacher_logged_in
    unless teacher_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  def course_params
    params.require(:course).permit(:course_code, :name, :course_type, :teaching_type, :exam_type,
                                   :credit, :limit_num, :class_room, :course_time, :course_week)
  end


end
