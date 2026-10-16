class SessionsController < ApplicationController
  skip_before_action :require_sign_in
  layout "sign_in"

  def new
  end

  def create
    account = Account.authenticate(params[:username], params[:password])

    if account
      session[:username] = account.username
      session[:avatar] = session[:username][0].upcase
      redirect_to tasks_path, notice: "Signed in successfully"
    else
      flash.now[:alert] = "Username or password is incorrect"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to sign_in_path, notice: "You have been signed out"
  end
end
