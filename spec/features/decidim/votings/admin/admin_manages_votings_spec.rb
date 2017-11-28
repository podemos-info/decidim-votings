# frozen_string_literal: true

require 'spec_helper'

describe 'Admin manages votings', type: :feature, serves_map: true do
  let(:manifest_name) { 'votings' }
  let!(:voting) { create :voting, feature: current_feature }

  include_context 'feature admin'

  it_behaves_like 'manage votings'
end
