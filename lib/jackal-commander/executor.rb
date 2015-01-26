require 'jackal-commander'

module Jackal
  module Commander
    # Run executions
    class Executor < Jackal::Callback

      # @return [String] root path for process output files
      attr_reader :process_output_root

      # default temp storage directory for process outputs
      DEFAULT_PROCESS_OUTPUT_ROOT = '/tmp/jackal-executor'

      # Setup the callback
      def setup(*_)
        require 'shellwords'
        require 'tempfile'
        require 'childprocess'
        require 'fileutils'
        @process_output_root = config.fetch(:process_output_root, DEFAULT_PROCESS_OUTPUT_ROOT)
        FileUtils.mkdir_p(process_output_root)
      end

      # Determine validity of message
      #
      # @param message [Carnivore::Message]
      # @return [Truthy, Falsey]
      def valid?(message)
        super do |payload|
          payload.get(:data, :commander, :action) ||
            payload.get(:data, :commander, :actions)
        end
      end

      # Execute requested action
      #
      # @param message [Carnivore::Message]
      def execute(message)
        failure_wrap(message) do |payload|
          actions = [
            payload.get(:data, :commander, :action),
            payload.get(:data, :commander, :actions)
          ].flatten.compact.uniq
          cmds = actions.map do |action|
            if(action.is_a?(Hash))
              extra_args = action[:arguments]
              action = action[:name]
            else
              extra_args = ''
            end
            if(cmd = config.get(:actions, action))
              debug "Action maps to command: #{cmd.inspect}"
              [action, cmd, extra_args]
            else
              error "No command mapping configured for requested action: #{action}"
              raise KeyError.new("Invalid command mapping. Key not found: `#{action}`")
            end
          end
          results = cmds.map do |action, command, extra_args|
            if(extra_args.is_a?(String))
              command = "#{command} #{extra_args}"
            end
            cmd_input = Shellwords.shellsplit(command)
            if(extra_args.is_a?(Array))
              cmd_input += extra_args
            end
            process = ChildProcess.build(*cmd_input)
            stdout = File.open(File.join(process_output_root, [payload[:id], 'stdout'].join('-')), 'w+')
            stderr = File.open(File.join(process_output_root, [payload[:id], 'stderr'].join('-')), 'w+')
            process.io.stdout = stdout
            process.io.stderr = stderr
            debug "Running requested action: #{action} (#{command})"
            process.start
            debug "Process started. Waiting for process completion (#{action})"
            status = process.wait
            stdout.rewind
            stderr.rewind
            if(status == 0)
              info "Successfully executed action: #{action}"
              info "STDOUT (#{action}): #{stdout.read.gsub("\n", '')}"
            else
              error "Failed to successfully execute action: #{action}"
              error "Failed action exit code (#{action}): #{process.exit_code}"
              error "STDOUT (#{action}): #{stdout.read.gsub("\n", '')}"
              error "STDERR (#{action}): #{stderr.read.gsub("\n", '')}"
              raise "Execution of action `#{action}` failed! (#{message})"
            end
            [action, {:exit_code => process.exit_code}]
          end
          payload.set(:data, :commander, :results, results)
          job_completed(:commander, payload, message)
        end
      end

    end
  end
end
