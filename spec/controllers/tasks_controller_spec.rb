require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  render_views

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http success" do
      description = "then iterate on it"
      name = "Write a Todo App"
      position = "37"
      expect do
        params = {
          task: {
            created: false,
            description: description,
            position: position,
            name: name,
          },
        }
        post :create, params: params
        expect(response).to redirect_to(:tasks)
      end.to change { Task.count }.by(1)
      task = Task.last
      expect(task.description).to eq description
      expect(task.name).to eq name
      expect(task.position).to eq position.to_i
      expect(task.completed_at).to eq nil
    end
  end
end
