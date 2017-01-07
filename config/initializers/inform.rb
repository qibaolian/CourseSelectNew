module Inform
  class ApplicationController < ActionController::Base
    include SessionsHelper
    before_action :admin_logged_in
    private
    main_app_name = Proc.new { |controller| ["CourseSelect", "控制面板"] }
    # Confirms a admin logged-in user.
    def admin_logged_in
      unless current_user.try(:admin?)
        redirect_to main_app.root_url, flash: {danger: '请先以管理员身份登陆'}
      end
    end
  end
end