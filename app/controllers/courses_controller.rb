class CoursesController < ApplicationController

  before_action :student_logged_in, only: [:select, :quit, :list, :search,:sumCredit,:courseTable]
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
  #-------------------------for students----------------------
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

  def list
    if params[:department] == nil
      params[:department] = '0'
    end

    if params[:week] == nil
      params[:week] = '0'
    end

    if params[:course_time] == nil
      params[:course_time] = '0'
    end

    if params[:course_name] == nil
      params[:course_name] = ''
    end

    if params[:authenticity_token] == nil
      params[:authenticity_token] = ''
    end

    search_string = "true"
    if params[:submit] != nil
      params[:page] = 1   #每次查询都是从第一页开始的
      if params[:department] != '0'
        search_string += " and department = '" + params[:department] + "'"
      end
      if params[:week] != '0'
        search_string += " and course_day = '" + params[:week] + "'"
      end
      if params[:course_time] != '0'
        search_string += " and course_class = '" + params[:course_time] + "'"
      end
      if params[:course_name] != nil
        #模糊查询
        search_string += " and name like '%" + params[:course_name] + "%'"
      end
    end


    @course = Course.joins(:course_infos).where(search_string)
    @course=@course-current_user.courses

    #----------分页功能的实现---------#
    total = @course.count
    params[:total] = total
    if params[:page] == nil
      params[:page] = 1  #进行初始化
    end
    if total % $PageSize == 0
      params[:pageNum] = total / $PageSize
    else
      params[:pageNum] = total / $PageSize + 1
    end

    #计算分页的开始和结束位置
    params[:pageStart] = (params[:page].to_i - 1) * $PageSize

    if params[:pageStart].to_i + $PageSize <= params[:total].to_i
      params[:pageEnd] = params[:pageStart].to_i + $PageSize - 1
    else
      params[:pageEnd] = params[:total].to_i - 1  #最后一页
    end



  end

  #解决各种选课冲突
  def select
    @course=Course.find_by_id(params[:id])
    #课程没有余量
    if @course.limit_num == @course.student_num
      flash={:danger => "该课程已满: #{@course.name}"}
      redirect_to courses_path, flash: flash and return
    end

    #选择同一门课（不是一个班）
    current_user.courses.each do |c|
      if c.name == @course.name
        flash={:danger => "你过去已经选择了课程: #{@course.name}"}
        redirect_to courses_path, flash: flash and return
      end
    end


    #时间存在冲突
    @course=Course.find_by_id(params[:id])
    current_user.courses.each do |c|
      @course_info = CourseInfo.find_by_course_code(c.id)
      interval_c = @course_info.course_class.split('_')
      @course.course_infos.each do |ci|
        interval_ci = ci.course_class.split('_')
        #（情形1）开始早于已选课的开始，结束晚于已选课的开始
        if ci.course_day == @course_info.course_day
          if (interval_c[0].to_i > interval_ci[0].to_i && interval_c[0].to_i < interval_ci[1].to_i) ||
          #（情形2）开始晚于已选课的开始，结束早于已选课的结束
              (interval_c[0].to_i <= interval_ci[0].to_i && interval_c[1].to_i >= interval_ci[1].to_i) ||
          #（情形3）开始早于已选课的结束，结束晚于已选课的结束
              (interval_c[1].to_i > interval_ci[0].to_i && interval_c[1].to_i < interval_ci[1].to_i)
            flash={:danger => "课程:(#{@course.name}) 和课程:(#{c.name})在时间上存在冲突"}
            redirect_to courses_path, flash: flash and return
          end
        end
      end
    end

    #成功选课
    current_user.courses<<@course
    @course.update_attribute("student_num", (@course.student_num + 1))
    flash={:success => "成功选择课程: #{@course.name}"}
    redirect_to courses_path, flash: flash and return
  end


  #查看课程的详细信息
  def info
    @course=Course.find_by_id(params[:id])
  end



  def quit
    @course=Course.find_by_id(params[:id])
    current_user.courses.delete(@course)
    @course.update_attribute("student_num", (@course.student_num - 1))
    flash={:success => "成功退选课程: #{@course.name}"}
    redirect_to courses_path, flash: flash
  end


  #-------------------------for both teachers and students----------------------

  def index
    @course=current_user.teaching_courses if teacher_logged_in?
    @course=current_user.courses if student_logged_in?

    #----------分页功能的实现---------#
    total = @course.count
    params[:total] = total
    if params[:page] == nil
      params[:page] = 1  #进行初始化
    end
    if total % $PageSize == 0
      params[:pageNum] = total / $PageSize
    else
      params[:pageNum] = total / $PageSize + 1
    end

    #计算分页的开始和结束位置
    params[:pageStart] = (params[:page].to_i - 1) * $PageSize

    if params[:pageStart].to_i + $PageSize <= params[:total].to_i
      params[:pageEnd] = params[:pageStart].to_i + $PageSize - 1
    else
      params[:pageEnd] = params[:total].to_i - 1  #最后一页
    end

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
