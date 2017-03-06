class TasksController < ApplicationController
  def index
    show_completed = !params[:show_completed].nil?
    @tasks = Task.display_list(show_completed).limit(20)
  end

  def new
    @task = Task.new(position: Task.next_position)
  end

  def create
    if Task.new.update_with_side_effects(article_params)
      redirect_to :tasks
    else
      render :new
    end
  end

  def update
    @task = Task.find(params[:id])
    @task.update_with_side_effects(article_params)

    if @task.save
      redirect_to :tasks
    else
      render plain: params.inspect
    end
  end

  def edit
    @task = Task.find(params[:id])
  end

  def destroy
    @task = Task.find(params[:id])
    @task.destroy

    redirect_to tasks_path
  end

  private

  def article_params
    params.require(:task).permit(:name, :description, :completed, :position)
  end
end
