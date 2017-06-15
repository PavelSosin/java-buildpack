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
    class LanguageServerNodeCDX < JavaBuildpack::Component::VersionedDependencyComponent

      # Creates an instance
      #
      # @param [Hash] context a collection of utilities used the component
      def initialize(context)
        super(context)
        @logger = JavaBuildpack::Logging::LoggerFactory.instance.get_logger LanguageServerNodeCDX
      end


      # (see JavaBuildpack::Component::BaseComponent#compile)
      def compile
        @logger.debug { "Compile CDX" }
        # Install node js
        FileUtils.mkdir_p @droplet.root + "nodejs"
        nodedir = @droplet.sandbox + "nodejs"
        comp_version = @version
        comp_uri = @uri
        @version="8.0.0"
        @uri="https://buildpacks.cloudfoundry.org/dependencies/node/node-8.0.0-linux-x64-ade5a8e5.tgz"
        download_tar( target_directory=nodedir )
        #@version = comp_version
        #@uri = comp_uri

        nodeBin = "#{@application.root}/node/bin/*"
        @logger.debug { "NodeRoot: #{@application.root}   NodeBin: #{nodeBin}"}

        #FileUtils.chmod "a=rx", nodeBin
        FileUtils.ln_s "/home/vcap/app/.java-buildpack/language_server_node_cdx/nodejs/bin/npm", "/usr/bin/npm", force: true
      end

      # (see JavaBuildpack::Component::BaseComponent#release)
      def release

        @logger.debug { "Release CDX" }
        environment_variables = @droplet.environment_variables
        myIpc = @configuration["env"]["ipc"]
        @logger.debug { "CDX Env vars IPC:#{myIpc}" }
        myIpc.each do |key, value|
          environment_variables.add_environment_variable("CDX_" + key, value)
        end
      end

      protected

      # (see JavaBuildpack::Component::VersionedDependencyComponent#supports?)
      def supports?
        @application.environment.key?(LSPSERVERS) &&  @application.environment[LSPSERVERS].split(',').include?("cdx")
      end

      private

      LSPSERVERS = 'lspservers'.freeze

      private_constant :LSPSERVERS

      BINEXEC = 'exec'.freeze

      private_constant :BINEXEC

      
    end

  end
end
