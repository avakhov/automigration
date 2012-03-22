#!/usr/bin/env rake
require "bundler/gem_tasks"

require "rubygems"
require "bundler/setup"
require 'rspec/core/rake_task'

namespace :db do
  desc "prepare db for specs"
  task "prepare" do
    system "cd spec/dummy && bundle exec rake db:drop"
    system "cd spec/dummy && bundle exec rake db:create db:migrate db:test:prepare"
  end
end

RSpec::Core::RakeTask.new(:spec)
