class PasswordResetsController < ApplicationController
  before_action :set_user, only: %i(edit update)
  before_action :redirect_to_root_if_invalid_user, only: %i(edit update)
  before_action :redirect_to_new_password_reset_path_if_password_reset_expired, only: %i(edit update)

  def new
  end

  def create
    @user = User.find_by(email: session_params[:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if user_params[:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update(user_params)
      log_in @user
      @user.update_attribute(:reset_digest, nil)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  def session_params
    params.require(:password_reset).permit(:email)
  end

  def set_user
    @user = User.find_by(email: params[:email])
  end

  def redirect_to_root_if_invalid_user
    return if @user&.activated? && @user&.authenticated?(:reset, params[:id])

    redirect_to root_url
  end

  def redirect_to_new_password_reset_path_if_password_reset_expired
    if @user.password_reset_expired?
      flash[:danger] = "Password reset has expired."
      redirect_to new_password_reset_url
    end
  end
end
