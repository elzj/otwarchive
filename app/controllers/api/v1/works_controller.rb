class Api::V1::WorksController < Api::V1::BaseController
  respond_to :json
  
  def show
    @work = Work.find(params[:id])
    respond_with @work
  end
end