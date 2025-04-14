# frozen_string_literal: true

module ActiveAdmin
  module Views
    class Footer < Component
      def build(_namespace)
        render partial: "components/footer"
      end
    end
  end
end
