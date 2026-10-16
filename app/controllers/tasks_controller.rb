class TasksController < ApplicationController
  def index
    @tasks = Task.all
  end
  def show
    @task = Task.find(params[:id])
  end
  def new
    @task = Task.new
    @cities = City.all || []
  end
  def create
    @task = Task.new(task_params)
    @cities = City.all || []

    if @task.valid? && Task.create(task_params)
      redirect_to tasks_path, notice: "Task created"
    else
      render :new, status: :unprocessable_entity
    end
  end
  def edit
    @task = Task.find(params[:id])
    @cities = City.all || []
  end
  def update
    @task = Task.find(params[:id])
    @cities = City.all || []

    if @task.update(task_params)
      redirect_to tasks_path, notice: "Task updated"
    else
      render :edit, status: :unprocessable_entity
    end
  end
  def destroy
    Task.destroy(params[:id])
    redirect_to tasks_path, notice: "Task deleted"
  end
  private
  def task_params
    params.require(:task).permit(:id, :title,  :first_name, :last_name, :age, :email, :contact, :city_name)
  end
end
