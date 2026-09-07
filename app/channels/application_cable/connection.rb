module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_compte

    def connect
      self.current_compte = env["warden"].user(:compte) || reject_unauthorized_connection
    end
  end
end
