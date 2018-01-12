 class AdminController < ApplicationController
  before_action :admin_logged_in
  def default
  end
  private

  # Confirms a admin logged-in user.
  def admin_logged_in
    unless admin_logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end

  # Confirms a  logged-in user.
  def logged_in
    unless logged_in?
      redirect_to root_url, flash: {danger: '请登陆'}
    end
  end
end
