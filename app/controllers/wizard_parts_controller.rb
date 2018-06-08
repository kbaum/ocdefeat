class WizardPartsController < ApplicationController
  skip_before_action :login_required, only: [:index, :show]

  include Wicked::Wizard
  steps :request_role, :patient_intake, :therapist_credentials

  def show
    render_wizard
  end
end
