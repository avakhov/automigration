namespace :db do
  desc "Auto migration"
  task :auto => :environment do
    Rake::Task['db:create'].invoke
    HappyKernel::ActiveRecordExt::AutoMigration.new.update_schema!
    Rake::Task['db:migrate'].invoke
  end
end
