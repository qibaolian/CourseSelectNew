class PasswordResetsController < ApplicationController
 before_action :get_user, only: [:edit, :update]
 before_action :valid_user, only: [:edit, :update]
 before_action :check_expiration, only: [:edit, :update]
  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "邮件已经成功发送到指定邮箱"
      redirect_to root_url
    else
      flash.now[:danger] = "该邮箱不存在"
      render 'new'
    end
  end
  def edit

  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "密码不能为空")
      render 'edit'
    elsif @user.update_attributes(user.params)
      log_in @user
      flash[:success] = "密码修改成功"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def get_user
    @user = User.find_by(email: params[:email])
  end

  def valid_user
    unless @user && @user.authenticated?(:reset, param[:id])
      redirect_to root_url
    end
  end

  #检查令牌是否过期
  def check_expiration
    if @user.password_reset_expired?
      flash[:dander] = "该重置密码网址已经过期，请重新重置密码"
      redirect_to new_password_reset_url
    end
  end

end
