# frozen_string_literal: true

module Admin
  class InstancesController < BaseController
    before_action :set_instances, only: :index
    before_action :set_instance, except: :index

    # @rbs () -> Array[untyped]
    def index
      authorize :instance, :index?
      preload_delivery_failures!
    end

    # @rbs () -> Admin::ActionLog::ActiveRecord_Relation
    def show
      authorize :instance, :show?
      @time_period = (6.days.ago.to_date...Time.now.utc.to_date)
      @action_logs = Admin::ActionLogFilter.new(target_domain: @instance.domain).results.limit(5)
    end

    # @rbs () -> String?
    def destroy
      authorize :instance, :destroy?
      Admin::DomainPurgeWorker.perform_async(@instance.domain)
      log_action :destroy, @instance
      redirect_to admin_instances_path, notice: I18n.t('admin.instances.destroyed_msg', domain: @instance.domain)
    end

    # @rbs () -> String
    def clear_delivery_errors
      authorize :delivery, :clear_delivery_errors?
      @instance.delivery_failure_tracker.clear_failures!
      redirect_to admin_instance_path(@instance.domain)
    end

    # @rbs () -> String
    def restart_delivery
      authorize :delivery, :restart_delivery?

      if @instance.unavailable?
        @instance.delivery_failure_tracker.track_success!
        log_action :destroy, @instance.unavailable_domain
      end

      redirect_to admin_instance_path(@instance.domain)
    end

    # @rbs () -> String
    def stop_delivery
      authorize :delivery, :stop_delivery?
      unavailable_domain = UnavailableDomain.create!(domain: @instance.domain)
      log_action :create, unavailable_domain
      redirect_to admin_instance_path(@instance.domain)
    end

    private

    # @rbs () -> Instance
    def set_instance
      @instance = Instance.find_or_initialize_by(domain: TagManager.instance.normalize_domain(params[:id]&.strip))
    end

    # @rbs () -> Instance::ActiveRecord_Relation
    def set_instances
      @instances = filtered_instances.page(params[:page])
    end

    # @rbs () -> Array[untyped]
    def preload_delivery_failures!
      warning_domains_map = DeliveryFailureTracker.warning_domains_map(@instances.map(&:domain))

      @instances.each do |instance|
        instance.failure_days = warning_domains_map[instance.domain]
      end
    end

    # @rbs () -> Instance::ActiveRecord_Relation
    def filtered_instances
      InstanceFilter.new(limited_federation_mode? ? { allowed: true } : filter_params).results
    end

    # @rbs () -> ActionController::Parameters
    def filter_params
      params.slice(*InstanceFilter::KEYS).permit(*InstanceFilter::KEYS)
    end
  end
end
