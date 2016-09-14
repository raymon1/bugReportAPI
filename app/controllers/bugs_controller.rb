class BugsController < ApplicationController
  before_action :set_bug, only: [:edit, :update, :destroy]
  before_action :set_bug_by_number, only: [:show]

  # GET /bugs
  # GET /bugs.json
  def index
    if params[:q].nil?
      @bugs = Bug.all
    else
      @bugs = Bug.search params[:q]
    end
  end

  # GET /bugs/1
  # GET /bugs/1.json
  def show
  end

  # GET /bugs/new
  def new
    @bug = Bug.new
  end

  # GET /bugs/1/edit
  def edit
  end

  # POST /bugs
  # POST /bugs.json
  def create
    num = Bug.get_next_number(bug_params[:application_token])
    bug_params[:number] = num
    rabbitq = RabbitQueau.new()
    rabbitq.perform("bug", bug_params, num)
    respond_to do |format|
        format.json { render json: { number: num}, status: :created, location: @bug }
    end
  end

  # PATCH/PUT /bugs/1
  # PATCH/PUT /bugs/1.json
  def update
    respond_to do |format|
      if @bug.update(bug_params)
        format.html { redirect_to @bug, notice: 'Bug was successfully updated.' }
        format.json { render :show, status: :ok, location: @bug }
      else
        format.html { render :edit }
        format.json { render json: @bug.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /bugs/1
  # DELETE /bugs/1.json
  def destroy
    @bug.destroy
    respond_to do |format|
      format.html { redirect_to bugs_url, notice: 'Bug was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def count
    count = Bug.fetch_count(params[:application_token])
    respond_to do |format|
      format.json { render json: { count: count}, status: :created, location: @bug }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_bug
      @bug = Bug.find(params[:id])
    end

    def set_bug_by_number
      @bug = Bug.find_by(number: params[:number], application_token: params[:application_token])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def bug_params
      params[:bug][:state_attributes] = params[:state] if params[:state]
      params.require(:bug).permit(:application_token, :status, :priority, :comment, state_attributes: [:device, :os, :memory, :storage])
    end
end
