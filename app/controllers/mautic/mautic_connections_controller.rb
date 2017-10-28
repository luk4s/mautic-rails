module Mautic
  class MauticConnectionsController < ApplicationController
    before_action :set_mautic_connection, only: [:show, :edit, :update, :destroy, :oauth2, :authorize]

    # GET /mautic_connections
    def index
      @mautic_connections = MauticConnection.order(:url)
    end

    # GET /mautic_connections/1
    def show
    end

    # GET /mautic_connections/new
    def new
      @mautic_connection = MauticConnection.new
    end

    # GET /mautic_connections/1/edit
    def edit
    end

    # POST /mautic_connections
    def create
      @mautic_connection = MauticConnection.new(mautic_connection_params)

      if @mautic_connection.save
        redirect_to @mautic_connection, notice: t('mautic.text_mautic_connection_created')
      else
        render :new
      end
    end

    # PATCH/PUT /mautic_connections/1
    def update
      if @mautic_connection.update(mautic_connection_params)
        redirect_to @mautic_connection, notice: t('mautic.text_mautic_connection_updated')
      else
        render :edit
      end
    end

    # DELETE /mautic_connections/1
    def destroy
      @mautic_connection.destroy
      redirect_to :mautic_connections, notice: t('mautic.text_mautic_connection_destroyed')
    end
    
    # ==--==--==--==--

    def authorize
      redirect_to @mautic_connection.authorize
    end

    def oauth2
      begin
        response = @mautic_connection.get_code(params.require(:code))
        @mautic_connection.update(token: response.token, refresh_token: response.refresh_token)
        return redirect_to mautic.mautic_connection_path(@mautic_connection), notice: t('mautic.text_mautic_authorize_successfully')
      rescue OAuth2::Error => e
        flash[:error] = e.message
      end

      render :show
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_mautic_connection
        @mautic_connection = MauticConnection.find(params[:id])
      rescue ActiveRecord::RecordNotFound => e
        return render head: 404, plain: e.message
      end

      # Only allow a trusted parameter "white list" through.
      def mautic_connection_params
        params.require(:mautic_connection).permit(:url, :client_id, :secret, :type)
      end
  end
end
