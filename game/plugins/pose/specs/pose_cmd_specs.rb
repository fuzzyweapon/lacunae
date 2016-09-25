require_relative "../../plugin_test_loader"

module AresMUSH
  module Pose
    describe PoseCmd do
      include CommandHandlerTestHelper
  
      before do
        init_handler(PoseCmd, "pose")
        SpecHelpers.stub_translate_for_testing
      end
      
      describe :handle do
        it "should emit to the room" do
          room = double
          client.stub(:room) { room }
          handler.stub(:message) { "a message" }
          Pose.should_receive(:emit_pose).with(client, "a message", false, false)
          handler.handle
        end
      end
      
      describe :message do
        before do
          client.stub(:name) { "Bob" }          
        end
        
        it "should format an emit message" do
          cmd.stub(:args) { "test" }
          set_root({ :pose => false, :say => false, :emit => true, :ooc => false }) 
          PoseFormatter.should_receive(:format).with("Bob", "\\test") { "formatted msg" }
          handler.message.should eq "formatted msg"
        end

        it "should format a say message" do
          cmd.stub(:args) { "test" }
          set_root({ :pose => false, :say => true, :emit => false, :ooc => false }) 
          PoseFormatter.should_receive(:format).with("Bob", "\"test") { "formatted msg" }
          handler.message.should eq "formatted msg"
        end

        it "should format a pose message" do
          cmd.stub(:args) { "test" }
          set_root({ :pose => true, :say => false, :emit => false, :ooc => false }) 
          PoseFormatter.should_receive(:format).with("Bob", ":test") { "formatted msg" }
          handler.message.should eq "formatted msg"
        end

        it "should format an ooc say message" do
          cmd.stub(:args) { "test" }
          Global.stub(:read_config).with("pose", "ooc_color") { '%xc' }
          set_root({ :pose => false, :say => false, :emit => false, :ooc => true }) 
          PoseFormatter.should_receive(:format).with("Bob", "test") { "formatted msg" }
          handler.message.should eq "%xc<OOC>%xn formatted msg"
        end
      end
  
      def set_root(args)
        cmd.stub(:root_is?).with("pose") { args[:pose] }
        cmd.stub(:root_is?).with("say") { args[:say] }
        cmd.stub(:root_is?).with("emit") { args[:emit] }
        cmd.stub(:root_is?).with("ooc") { args[:ooc] }
      end        
    end
  end
end