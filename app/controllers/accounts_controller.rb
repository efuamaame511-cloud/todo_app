class AccountsController < ApplicationController
  skip_before_action :require_sign_in
  layout "sign_in"

  def new
  end

  def create
    @account = Account.new(username: params[:username].to_s.strip, password: params[:password].to_s)

    if @account.save
      redirect_to sign_in_path, notice: "Account created. Sign in to continue."
    else
      flash.now[:alert] = Account.find(@account.username) ? "That username is already created" : "Enter a username and password"
      render :new, status: :unprocessable_entity
    end
  end
end
