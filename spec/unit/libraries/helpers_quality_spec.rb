require 'spec_helper'

describe DeliveryTruck::Helpers::Quality do
  let(:node) { Chef::Node.new }

  describe '.has_kitchen_ec2_tests?' do
    context 'when .kitchen.ec2.yml does not exist' do
      before do
        node.default['delivery']['workspace']['repo'] = '/tmp/repo'
        allow(File).to receive(:exists?).and_call_original
        allow(File).to receive(:exists?).with("/tmp/repo/.kitchen.ec2.yml").and_return(false)
      end

      it 'returns false' do
        expect(described_class.has_kitchen_ec2_tests?(node)).to eql(false)
      end
    end

    context 'when .kitchen.ec2.yml exists' do
      before do
        node.default['delivery']['workspace']['repo'] = '/tmp/repo'
        allow(File).to receive(:exists?).and_call_original
        allow(File).to receive(:exists?).with("/tmp/repo/.kitchen.ec2.yml").and_return(true)
      end

      it 'returns true' do
        expect(described_class.has_kitchen_ec2_tests?(node)).to eql(true)
      end
    end
  end
end