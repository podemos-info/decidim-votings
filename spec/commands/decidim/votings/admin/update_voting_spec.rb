# frozen_string_literal: true

require 'spec_helper'

module Decidim
  module Votings
    module Admin
      describe UpdateVoting do
        let(:organization) { create(:organization) }
        let(:participatory_process) do
          create :participatory_process, organization: organization
        end
        let(:current_feature) do
          create :voting_feature, participatory_space: participatory_process
        end

        let(:context) do
          {
            current_organization: organization,
            current_feature: current_feature
          }
        end

        let(:voting) { create(:voting, feature: current_feature) }

        let(:title) { Decidim::Faker::Localized.sentence(3) }
        let(:description) { Decidim::Faker::Localized.sentence(3) }
        # let(:image) {'img.png'}
        let(:image) { Decidim::Dev.test_file('city.jpeg', 'image/jpeg') }
        let(:start_date) { (Date.today + 1.days).strftime('%Y-%m-%d') }
        let(:end_date) { (Date.today + 5.days).strftime('%Y-%m-%d') }
        let(:decidim_scope_id) { 5 }
        let(:importance) { ::Faker::Number.number(2).to_i }
        let(:census_date_limit) { Date.today.strftime('%Y-%m-%d') }
        let(:status) { 'simulation' }
        let(:voting_system) { 'nVotes' }
        let(:voting_url) { 'https://test.org' }
        let(:form) do
          double(
            invalid?: invalid,
            title: title,
            description: description,
            image: image,
            start_date: start_date,
            end_date: end_date,
            decidim_scope_id: decidim_scope_id,
            importance: importance,
            census_date_limit: census_date_limit,
            status: status,
            voting_system: voting_system,
            voting_url: voting_url
          )
        end
        let(:invalid) { false }
        subject { described_class.new(form, voting) }

        context 'when the form is not valid' do
          let(:invalid) { true }

          it 'is not valid' do
            expect { subject.call }.to broadcast(:invalid)
          end
        end

        context 'when everything is ok' do
          let(:updated_voting) { Decidim::Votings::Voting.last }

          it 'sets all attributes received from the form' do
            subject.call
            expect(updated_voting.title).to eq title
            expect(updated_voting.description).to eq description
            expect(updated_voting.image.path.split('/').last).to eq 'city.jpeg'
            expect(updated_voting.start_date.strftime('%Y-%m-%d')).to eq start_date
            expect(updated_voting.end_date.strftime('%Y-%m-%d')).to eq end_date
            expect(updated_voting.decidim_scope_id).to eq decidim_scope_id
            expect(updated_voting.importance).to eq importance
            expect(updated_voting.census_date_limit.strftime('%Y-%m-%d')).to eq census_date_limit
            expect(updated_voting.status).to eq status
            expect(updated_voting.voting_system).to eq voting_system
            expect(updated_voting.voting_url).to eq voting_url
          end
        end
      end
    end
  end
end
