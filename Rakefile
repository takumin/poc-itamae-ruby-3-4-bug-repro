# frozen_string_literal: true

# require
# unless File.exist?('.bundle/config')
#   system('bundle config set bin .bin')
#   system('bundle config set path .bundle')
# end

require 'rspec/core/rake_task'

desc 'Run unit and integration specs.'
task :spec => ['spec:integration:all']

TEST_IMAGE = ENV["TEST_IMAGE"] || "ubuntu:trusty"

namespace :spec do
  namespace :integration do
    container_name = 'itamae'

    task :all => ['spec:integration:docker']

    desc "Run provision and specs"
    task :docker => [
      "docker:boot", 
      "docker:provision", 
      "docker:serverspec", 
      'docker:clean_docker_container'
    ]

    namespace :docker do
      desc "Run docker"
      task :boot do
        sh "docker run --privileged -d --name #{container_name} #{TEST_IMAGE} /sbin/init"
      end

      desc "Run itamae"
      task :provision do
        suites = [
          [
            "recipes/repro.rb",
          ],
        ]
        suites.each do |suite|
          cmd = %w!bundle exec ruby -w .bin/itamae docker!
          cmd << "-l" << (ENV['LOG_LEVEL'] || 'debug')
          cmd << "--container" << container_name
          cmd << "--tag" << "itamae:latest"
          cmd << "--tmp-dir" << (ENV['ITAMAE_TMP_DIR'] || '/tmp/itamae_tmp')
          cmd += suite

          p cmd
          unless system(*cmd)
            raise "#{cmd} failed"
          end
        end
      end

      desc "Run serverspec tests"
      RSpec::Core::RakeTask.new(:serverspec) do |t|
        ENV['DOCKER_CONTAINER'] = container_name
        t.ruby_opts = '-I ./spec'
        t.pattern = "spec/repro.rb"
      end

      desc 'Clean a docker container for test'
      task :clean_docker_container do
        sh('docker', 'rm', '-f', container_name)
      end
    end
  end
end

task :default => :spec
