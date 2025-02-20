# frozen_string_literal: true

class FiltersController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_filter, only: [:edit, :update, :destroy]
  before_action :set_cache_headers

  # @rbs () -> ActiveRecord::AssociationRelation
  def index
    @filters = current_account.custom_filters.includes(:keywords, :statuses).order(:phrase)
  end

  # @rbs () -> CustomFilterKeyword
  def new
    @filter = current_account.custom_filters.build(action: :warn)
    @filter.keywords.build
  end

  # @rbs () -> nil
  def edit; end

  # @rbs () -> (String | ActiveSupport::SafeBuffer)
  def create
    @filter = current_account.custom_filters.build(resource_params)

    if @filter.save
      redirect_to filters_path
    else
      render :new
    end
  end

  # @rbs () -> (ActiveSupport::SafeBuffer | String)
  def update
    if @filter.update(resource_params)
      redirect_to filters_path
    else
      render :edit
    end
  end

  # @rbs () -> String
  def destroy
    @filter.destroy
    redirect_to filters_path
  end

  private

  # @rbs () -> CustomFilter
  def set_filter
    @filter = current_account.custom_filters.find(params[:id])
  end

  # @rbs () -> void
  def resource_params
    params.require(:custom_filter).permit(:title, :expires_in, :filter_action, context: [], keywords_attributes: [:id, :keyword, :whole_word, :_destroy])
  end

  # @rbs () -> Hash[untyped, untyped]
  def set_cache_headers
    response.cache_control.replace(private: true, no_store: true)
  end
end
