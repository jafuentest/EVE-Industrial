class SystemsController < ApplicationController
  helper_method :sort_column, :sort_direction
  
  # GET /systems
  # GET /systems.json
  def index
    if params.has_key? :region_id
      @systems = Region.find(params[:region_id]).systems.sort_by { |s| s[:name] }
    else
      @systems = System.order(sort_column + ' ' + sort_direction).paginate :page => params[:page]
    end
    
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @systems }
    end
  end
  
  # GET /systems/1
  # GET /systems/1.json
  def show
    @system = System.find(params[:id])
    
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @system }
    end
  end
  
  # GET /systems/1/edit
  def edit
    @regions = Region.all
    @system = System.find(params[:id])
  end
  
  # PUT /systems/1
  # PUT /systems/1.json
  def update
    @system = System.find(params[:id])
    
    respond_to do |format|
      if @system.update_attributes(params[:system])
        format.html { redirect_to @system, notice: 'System was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @system.errors, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def sort_column
    System.column_names.include?(params[:sort]) ? params[:sort] : 'name'
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : 'asc'
  end
end
