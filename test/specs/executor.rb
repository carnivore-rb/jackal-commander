require 'fileutils'
require 'jackal-commander'

describe Jackal::Commander::Executor do

  before do
    FileUtils.mkdir_p('/tmp/.jackal-commander-test')
    #https://github.com/carnivore-rb/jackal/blob/master/lib/jackal/utils/spec/helpers.rb
    @runner = run_setup(:test)
  end

  after do
    FileUtils.rm_rf('/tmp/.jackal-commander-test')
    @runner.terminate if @runner && @runner.alive?
  end

  let(:commander) do
    Carnivore::Supervisor.supervisor[:jackal_commander_input]
  end

  describe 'command execution' do

    it 'should execute single command' do
      commander.transmit(
        Jackal::Utils.new_payload(
          :test, :commander => {:action => :toucher}
        )
      )
      source_wait(1) do
        File.exists?('/tmp/.jackal-commander-test/touched')
      end
      File.exists?('/tmp/.jackal-commander-test/touched').must_equal true
    end

    it 'should execute multiple commands' do
      commander.transmit(
        Jackal::Utils.new_payload(
          :test, :commander => {:actions => [:toucher, :toucher2]}
        )
      )
      source_wait(1) do
        File.exists?('/tmp/.jackal-commander-test/touched2')
      end
      File.exists?('/tmp/.jackal-commander-test/touched').must_equal true
      File.exists?('/tmp/.jackal-commander-test/touched2').must_equal true
    end

    it 'should execute mixed commands' do
      commander.transmit(
        Jackal::Utils.new_payload(
          :test, :commander => {:action => :toucher, :actions => [:toucher2, :toucher3]}
        )
      )
      source_wait(1) do
        File.exists?('/tmp/.jackal-commander-test/touched3')
      end
      File.exists?('/tmp/.jackal-commander-test/touched').must_equal true
      File.exists?('/tmp/.jackal-commander-test/touched2').must_equal true
      File.exists?('/tmp/.jackal-commander-test/touched3').must_equal true
    end

    it 'should execute single command with arguments' do
      commander.transmit(
        Jackal::Utils.new_payload(
          :test, :commander => {
            :action => {
              :name => :custom_touch,
              :arguments => '/tmp/.jackal-commander-test/custom'
            }
          }
        )
      )
      source_wait(1) do
        File.exists?('/tmp/.jackal-commander-test/custom')
      end
      File.exists?('/tmp/.jackal-commander-test/custom').must_equal true
    end

    it 'should execute multiple commands with and without arguments' do
      commander.transmit(
        Jackal::Utils.new_payload(
          :test, :commander => {
            :action => :toucher,
            :actions => [
              :toucher2,
              :toucher3,
              {
                :name => :custom_touch,
                :arguments => '/tmp/.jackal-commander-test/custom2'
              }
            ]
          }
        )
      )
      source_wait(1) do
        File.exists?('/tmp/.jackal-commander-test/custom2')
      end
      File.exists?('/tmp/.jackal-commander-test/touched').must_equal true
      File.exists?('/tmp/.jackal-commander-test/touched2').must_equal true
      File.exists?('/tmp/.jackal-commander-test/touched3').must_equal true
      File.exists?('/tmp/.jackal-commander-test/custom2').must_equal true
    end

  end

end
