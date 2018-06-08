class WizardPartsController < ApplicationController
  include Wicked::Wizard
  steps :request_role, :patient_intake, :therapist_credentials

  def show
    render_wizard
  end
end
