module ActiveAdmin
  module Views
    module Pages
      class Base
        def build_flash_messages
          render(partial: "layouts/flash")
        end
      end
    end
  end
end
