# frozen_string_literal: true

ActiveSupport.on_load :active_record do
  ActiveRecord::Migrator.migrate(ActiveRecord::Migrator.migrations_paths)
end
