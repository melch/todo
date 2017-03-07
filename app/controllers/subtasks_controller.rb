class SubtasksController < ApplicationController
  def new
    @task_id = params[:task_id]
    @subtask = Subtask.new(task_id: @task_id)
    # @task = Task.new(position: Task.next_position)
  end

  def create
    @subtask = Subtask.new
    @subtask.attributes = subtask_params.except(:completed)
    @task_id = subtask_params[:task_id]

    if @subtask.save
      redirect_to edit_task_path(subtask_params[:task_id])
    else
      render :new
    end
  end

  private

  def subtask_params
    params.require(:subtask).permit(:name, :description, :completed, :position, :task_id)
  end
end
