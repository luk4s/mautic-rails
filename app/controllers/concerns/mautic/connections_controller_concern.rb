module Mautic
  module ConnectionsControllerConcern
    extend ActiveSupport::Concern

    included do

      before_action :set_mautic_connection, only: [:show, :edit, :update, :destroy, :oauth2, :authorize]

    end


    # GET /mautic_connections
    def index
      @mautic_connections = Mautic::Connection.order(:url)
      respond_to do |format|
        format.html { render layout: !request.xhr? }
        format.json { render json: @mautic_connections }
      end
    end

    # GET /mautic_connections/1
    def show
      respond_to do |format|
        format.html { render layout: !request.xhr? }
      end
    end

    # GET /mautic_connections/new
    def new
      @mautic_connection = Mautic::Connection.new
      respond_to do |format|
        format.html { render layout: !request.xhr? }
      end
    end

    # GET /mautic_connections/1/edit
    def edit
      respond_to do |format|
        format.html { render layout: !request.xhr? }
      end
    end

    # POST /mautic_connections
    def create
      @mautic_connection = Mautic::Connection.new(mautic_connection_params)

      respond_to do |format|
        if @mautic_connection.save
          format.html { render(:edit, notice: t('mautic.text_mautic_connection_created')) }
          format.js { head :no_content }
          format.json { render json: @mautic_connection }
        else
          format.html { render :new }
          format.js { head :unprocessable_entity }
          format.json { render json: @mautic_connection.errors, status: :unprocessable_entity }
        end
      end
    end

    # PATCH/PUT /mautic_connections/1
    def update
      respond_to do |format|
        if @mautic_connection.update(mautic_connection_params)
          format.html { redirect_to({ action: :index }, notice: t('mautic.text_mautic_connection_updated')) }
          format.js { head :no_content }
          format.json { render json: @mautic_connection }
        else
          format.html { render :edit }
          format.js { head :unprocessable_entity }
          format.json { render json: @mautic_connection.errors, status: :unprocessable_entity }
        end
      end
    end

    # DELETE /mautic_connections/1
    def destroy
      @mautic_connection.destroy
      respond_to do |format|
        format.html { redirect_to action: "index", notice: t('mautic.text_mautic_connection_destroyed') }
        format.js { render js: "document.getElementById('#{view_context.dom_id(@mautic_connection)}').remove()" }
        format.json { render json: @mautic_connection }
      end
    end

    # ==--==--==--==--

    def authorize
      redirect_to @mautic_connection.authorize(self)
    end

    def oauth2
      begin
        response = @mautic_connection.get_code(params.require(:code), self)
        @mautic_connection.update(token: response.token, refresh_token: response.refresh_token)
        return render plain: t('mautic.text_mautic_authorize_successfully')
      rescue OAuth2::Error => e
        flash[:error] = e.message
      end

      render :show
    end

    private

    # Use callbacks to share common setup or constraints between actions.
    def set_mautic_connection
      @mautic_connection = Mautic::Connection.find(params[:id])
    rescue ActiveRecord::RecordNotFound => e
      return render head: 404, plain: e.message
    end

    # Only allow a trusted parameter "white list" through.
    def mautic_connection_params
      params.require(:connection).permit(:url, :client_id, :secret, :type)
    end

  end
end