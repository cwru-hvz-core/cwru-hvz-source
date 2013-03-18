module RegistrationsHelper
  def faction_id_to_class_human(registration)
    case registration.faction_id
    when 0
      return "Human"
    when 1
      return "Zombie"
    when 2
      return "Deceased"
    when nil
      return "Unknown"
    else
      return "Invalid!"
    end
  end
end
