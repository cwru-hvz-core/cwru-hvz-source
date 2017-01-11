# Seed code that runs in all environments should go here:

# Run seed file specific to the current environment:
load(Rails.root.join( 'db', 'seeds', "#{Rails.env.downcase}.rb"))