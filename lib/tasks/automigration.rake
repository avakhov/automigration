namespace :db do
  task :auto => :environment do
    puts "[DEPRICATION] db:auto was deprecated. Use rake db:migrate instead."
  end
end

task :automigration => :environment do
  Automigration::Migrator.new.update_schema!
end

Rake::Task['db:migrate'].enhance ['automigration']
