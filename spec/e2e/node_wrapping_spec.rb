require 'spec_helper'

describe 'Node Wrapping' do
  class NWUser
    include Neo4j::ActiveNode
  end

  let(:user) { NWUser.create }
  before(:all) { Neo4j::ActiveNode::Labels::KNOWN_LABEL_MAPS.clear }

  after do
    NWUser.delete_all
    Neo4j::ActiveNode::Labels::KNOWN_LABEL_MAPS.clear
  end

  describe 'KNOWN_LABELS_MAP' do
    context 'when a class is discovered' do
      before { NWUser.create }

      it 'loads the node and adds the labels, class to the hash' do
        node = NWUser.first
        expect(Neo4j::ActiveNode::Labels::KNOWN_LABEL_MAPS).not_to be_empty
        expect(Neo4j::ActiveNode::Labels::KNOWN_LABEL_MAPS[node.labels]).to eq NWUser
      end

      # There appears to be a bug in JRuby that's keeping this from working.
      # We are testing it in MRI, we can confirm that it works as intended in JRuby.
      # If it didn't, all tests would fail.
      if RUBY_PLATFORM != 'java'
        it 'prevents subsequent calls to sorted_wrapper_class' do
          expect_any_instance_of(Neo4j::Node).to receive(:sorted_wrapper_class)
          NWUser.first
          expect_any_instance_of(Neo4j::Node).not_to receive(:sorted_wrapper_class)
          NWUser.first
        end
      end
    end
  end
end