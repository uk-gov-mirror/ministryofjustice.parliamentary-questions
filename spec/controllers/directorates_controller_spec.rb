require 'spec_helper'

describe DirectoratesController, type: :controller do
  describe 'Get index' do
    it 'lists the Directorates sorted alphabetically by active then inactive states' do
      create_directorates
      expect(PQUserFilter).to receive(:before).and_return(true)
      expect(controller).to receive(:authenticate_user!).and_return(true)
      get :index
      expect(response.status).to eq(200)
      expect(assigns(:directorates).map(&:name)).to eq expected_order_of_directorates
    end
  end
end

def create_directorates
  FactoryBot.create(:directorate, name: 'Directorate A', updated_at: DateTime.now.to_datetime, deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate B', updated_at: DateTime.now.to_datetime, deleted: true)
  FactoryBot.create(:directorate, name: 'Directorate C', updated_at: 1.day.ago.to_datetime,    deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate D', updated_at: 1.day.ago.to_datetime,    deleted: true)
  FactoryBot.create(:directorate, name: 'Directorate E', updated_at: 2.days.ago.to_datetime,   deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate F', updated_at: 2.days.ago.to_datetime,   deleted: true)
  FactoryBot.create(:directorate, name: 'Directorate G', updated_at: DateTime.now.to_datetime, deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate H', updated_at: DateTime.now.to_datetime, deleted: true)
  FactoryBot.create(:directorate, name: 'Directorate I', updated_at: 1.day.ago.to_datetime,    deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate J', updated_at: 1.day.ago.to_datetime,    deleted: true)
  FactoryBot.create(:directorate, name: 'Directorate K', updated_at: 2.days.ago.to_datetime,   deleted: false)
  FactoryBot.create(:directorate, name: 'Directorate L', updated_at: 2.days.ago.to_datetime,   deleted: true)
end

def expected_order_of_directorates
  [
    'Directorate A',
    'Directorate C',
    'Directorate E',
    'Directorate G',
    'Directorate I',
    'Directorate K',
    'Directorate B',
    'Directorate D',
    'Directorate H',
    'Directorate J'
  ]
end
