module ActiveAdmin
  module ViewsHelper
    include StructureHelper
    include Admin::EvaluationHelper
    include EvaluationRestitutionSituationsHelper
    include Admin::DashboardHelper
    include ErreurHelper
    include PriseEnMainHelper
    include TranscriptionHelper
    include QuestionHelper
    include OpcoHelper
  end
end
