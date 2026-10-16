class UsersController < ApplicationController
  def show
    @user = {
      username: session[:username] || "Admin User",
      avatar: session[:avatar] || "A",
      color: session[:avatar_color] || "#d78d4d"
    }
  end

  def update
    username = params[:username].to_s.strip
    avatar = params[:avatar].to_s.strip[0, 2]

    if username.blank? || avatar.blank?
      @user = { username: username, avatar: avatar, color: params[:color] }
      flash.now[:alert] = "Name and avatar are required"
      render :show, status: :unprocessable_entity
    else
      session[:username] = username
      session[:avatar] = avatar
      session[:avatar_color] = params[:color].presence || "#d78d4d"
      redirect_to user_path, notice: "Profile updated"
    end
  end
end
