require 'rails_helper'

RSpec.describe TasksController, type: :controller do
  render_views

  describe "GET #index" do
    it "returns http success" do
      get :index
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET #show" do
    it "returns http success" do
      task = Task.create!(name: "Test actions")
      get :show, id: task.id
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST #create" do
    it "returns http success" do
      expect do
        params = {
          task: {
            created: false,
            description: "then iterate on it",
            name: "Write a Todo App",
          },
        }
        post :create, params
        expect(response).to redirect_to(:tasks)
      end.to change { Task.count }.by(1)
    end
  end
end
