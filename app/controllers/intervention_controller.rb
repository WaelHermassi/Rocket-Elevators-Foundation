class InterventionController < ApplicationController
    skip_before_action :verify_authenticity_token
    before_action :authenticate_user!
    def show
    end
    def interventions; end
    def intervention
        @interventions = Intervention.where(:author => current_user.id)
    end
    def get_building
     if params[:customer].present?
         @buildings = Customer.find(params[:customer]).buildings
     else
         puts params[:customer]
     end
     if request.xhr?
         respond_to do |f|
             f.json {
                 render json: {buildings: @buildings}
             }
         end
     end
    end
    def get_battery
    if params[:building].present?
       @batteries = Building.find(params[:building]).batteries
    else
       @batteries = Building.all
    end
    if request.xhr?
       respond_to do |f|
           f.json {
               render json: {batteries: @batteries}
           }
       end
    end
    end
   # listing the columns belonging to the battery
    def get_column
       if params[:battery].present?
           @columns = Battery.find(params[:battery]).columns
       else
           @columns = Battery.all
       end
       if request.xhr?
           respond_to do |f|
               f.json {
                   render json: {columns: @columns}
               }
           end
       end
    end
   # Listing the elevators belonging to the column
    def get_elevator
       if params[:column].present?
           @elevators = Column.find(params[:column]).elevators
       else
           @elevators = Column.all
       end
       if request.xhr?
           respond_to do |f|
               f.json {
                   render json: {elevators: @elevators}
               }
           end
       end
    end
    def new
    @intervention = Intervention.new
    end
    def author_intervention
    @interventions = Intervention.where(:user_id => current_user.id)
end



    def create 
        
    
       @intervention = Intervention.new(intervention_params)
       @intervention.author = current_user.id
       @intervention.customer_id = params[:customer]
       @intervention.building_id = params[:building]
       @intervention.battery_id = params[:battery]
       @intervention.column_id = params[:column]
       @intervention.elevator_id = params[:elevator]
       @intervention.employee_id = params[:employee]
       @intervention.result = "Incomplete"  #  Default value
       @intervention.report = params[:report]
       @intervention.status = "Pending"   # Default value
       @intervention.save
       respond_to do |format|
       if @intervention.save
        format.html { redirect_to intervention_url(@intervention), notice: "Intervention was successfully created." }
        format.json { render :show, status: :created, location: @intervention }
       end
    end
    end 

    def intervention_params
        params.permit( :employee_id, :customer_id, :building_id, :battery_id, :column_id, :elevator_id, :result, :report, :status)
    end
end
