class AddressesController < ApplicationController
  def index
    @addresses = Address.all
  end

  def show
    @address = Address.find(params[:id])
  end

  def new
    @address = Address.new
    @cities = City.all || []
    @tasks = available_tasks
  end

  def create
    @address = Address.new(address_params)
    @cities = City.all || []
    @tasks = available_tasks

    if @address.save
      redirect_to addresses_path, notice: "Address created"
    else
      @cities = City.all || []
      @tasks = available_tasks
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @address = Address.find(params[:id])
    @cities = City.all || []
    @tasks = available_tasks(exclude_address: @address)
  end

  def update
    @address = Address.find(params[:id])
    @cities = City.all || []
    @tasks = available_tasks(exclude_address: @address)

    if @address.update(address_params)
      redirect_to addresses_path, notice: "Address updated"
    else
      @cities = City.all || []
      @tasks = available_tasks(exclude_address: @address)
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @address = Address.find(params[:id])
    @address.destroy
    redirect_to addresses_path, notice: "Address deleted"
  end

  private

  def address_params
    params.require(:address).permit(:id, :name, :home_address, :work_address, :street_address, :city_name)
  end

  def available_tasks(exclude_address: nil)
    used_names = Address.all
                         .reject { |a| exclude_address && a.id == exclude_address.id }
                         .map { |a| a.name.to_s.downcase }

    Task.all.reject { |t| used_names.include?(t.full_name.downcase) }
  end
end
