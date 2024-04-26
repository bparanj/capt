class DatabaseCheck < OkComputer::Check
  def check
    if ActiveRecord::Base.connected?
      mark_message "Database is connected."
    else
      mark_failure
      mark_message "Unable to connect to the database."
    end
  end
end

