class CitiesController < ApplicationController
  def index
    @cities = City.all
  end

  def show
    @city = City.find(params[:id])
  end

  def new
    @city = City.new
    @regions = Region.all
  end

  def create
    @city = City.new(city_params)

    @regions = Region.all || []

    if @city.save
      redirect_to @city, notice: "City was successfully created."
    else
      @regions = Region.all || []
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @city = City.find(params[:id])
    @regions = Region.all
  end

  def update
    @city = City.find(params[:id])
    @regions = Region.all || []

    if @city.update(city_params)
      redirect_to cities_path, notice: "City updated"
    else
      @regions = Region.all || []
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @city = City.find(params[:id])
    @city.destroy
    redirect_to cities_path, notice: "City deleted", status: :see_other
  end

  private

  def city_params
    params.require(:city).permit(:region_code, :city_name, :city_code)
  end
end
