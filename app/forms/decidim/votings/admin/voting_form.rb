# frozen_string_literal: true

module Decidim
  module Votings
    module Admin
      # This class holds a Form to create/update votings from
      # Decidim's admin panel.
      class VotingForm < Decidim::Form
        include TranslatableAttributes
        include TranslationsHelper

        translatable_attribute :title, String
        translatable_attribute :description, String

        attribute :start_date, Decidim::Attributes::TimeWithZone
        attribute :end_date, Decidim::Attributes::TimeWithZone
        attribute :status, String
        attribute :image, String
        attribute :scopes_enabled, Boolean
        attribute :decidim_scope_id, Integer
        attribute :importance, Integer
        attribute :census_date_limit, Decidim::Attributes::TimeWithZone
        attribute :voting_system, String
        attribute :voting_url, String
        attribute :voting_identifier, String
        attribute :shared_key, String

        validates :title, translatable_presence: true
        validates :description, translatable_presence: true
        validates :image, file_size: { less_than_or_equal_to: ->(_image) { Decidim.maximum_attachment_size } }
        validates :importance, numericality: { only_integer: true }
        validates :start_date, presence: true, date: { before: :end_date }
        validates :end_date, presence: true, date: { after: :start_date }

        validates :current_feature, presence: true
        validates :scope, presence: true, if: ->(form) { form.decidim_scope_id.present? }


        validate :voting_range_in_process_bounds

        def map_model(voting)
          self.scopes_enabled = voting.scope.present?
        end

        def process_scope
          current_feature.participatory_space.scope
        end

        def scope
          return unless current_feature
          @scope ||= current_feature.scopes.where(id: decidim_scope_id).first || process_scope
        end

        private

        # Validates that start_date and end_date are inside participatory process bounds.
        def voting_range_in_process_bounds
          return unless steps?

          unless included_in_steps?(start_date)
            errors.add(:start_date, I18n.t('activemodel.errors.voting.voting_range.outside_process_range'))
          end

          unless included_in_steps?(end_date)
            errors.add(:end_date, I18n.t('activemodel.errors.voting.voting_range.outside_process_range'))
          end
        end

        def included_in_steps?(date)
          return true if date.blank?
          steps_containing_date = steps.select do |step|
            step_range = step.start_date.to_time..step.end_date.to_time
            step_range.include? date.to_time
          end
          steps.empty? || steps_containing_date.any?
        end

        def steps?
          context.current_feature.participatory_space.respond_to? :steps
        end

        def steps
          context.current_feature.participatory_space.steps
        end
      end
    end
  end
end