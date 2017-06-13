# Encoding: utf-8
# Cloud Foundry Java Buildpack
# Copyright 2013-2017 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require 'java_buildpack/component/versioned_dependency_component'
require 'java_buildpack/framework'
require 'fileutils'
require 'java_buildpack/util/qualify_path'
require 'java_buildpack/logging/logger_factory'

module JavaBuildpack
  module Framework

    # Installs JDT based LSP server component.
    class LanguageServerBinExecJDT < JavaBuildpack::Component::VersionedDependencyComponent

      # Creates an instance
      #
      # @param [Hash] context a collection of utilities used the component
      def initialize(context)
        super(context)
        @logger = JavaBuildpack::Logging::LoggerFactory.instance.get_logger LanguageServerBinExecJDT
      end


      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        @logger.debug { "Compile JDT"}
        download_tar
        # Install LSP Server bin from from repository as a Versioned component
        @droplet.copy_resources
        FileUtils.mkdir_p @droplet.root + '.m2'
        FileUtils.cp_r(@droplet.sandbox + '.m2/.', @droplet.root + '.m2' )
        FileUtils.mkdir_p @droplet.root + 'di_ws_root'
        FileUtils.mkdir_p @droplet.root + 'jdt_ws_root'
        ipcval = @configuration["env"]["IPC"]
        @logger.debug { "IPC VAL:#{ipcval}"}
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release

        environment_variables = @droplet.environment_variables
        myBasedir = @configuration["env"]["basedir"]
        environment_variables.add_environment_variable("JAVA-" + key, myBasedir)        
        myWorkdir = @configuration["env"]["workdir"]
        environment_variables.add_environment_variable("JAVA-" + key, myWorkdir)
        myExec = @configuration["env"]["exec"]
        environment_variables.add_environment_variable("JAVA-" + key, myExec)
        
        myIpc = @configuration["env"]["ipc"]
        @logger.debug { "JDT Env vars IPC:#{myIpc}" }
        myIpc.each do |key, value|
          environment_variables.add_environment_variable("JAVA-" + key, value)
        end
        
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @application.environment.key?(LSPSERVERS) && @application.environment[LSPSERVERS].split(',').include?("java")
      end

      private

      LSPSERVERS = 'lspservers'.freeze

      private_constant :LSPSERVERS

      IPC = 'jdt-ipc'.freeze

      private_constant :IPC

      

    end

  end
end
