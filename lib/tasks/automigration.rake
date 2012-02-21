namespace :db do
  desc "Auto migration"
  task :auto => :environment do
    Rake::Task['db:create'].invoke
    Automigration::Migrator.new.update_schema!
    Rake::Task['db:migrate'].invoke
  end
end
