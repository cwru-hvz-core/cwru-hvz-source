# Upon first setting up your dev environment, run `rake db:create` to create
# the dev environment database, followed by `rake db:setup` to load the schema
# and seed.
# To reset, run `rake db:reset`.
# Run this file ONLY in dev or test environments.

# Eventually, this should establish two games: One that has completed, and
# one that is ongoing.

# Name, Case ID, phone, DOB, is_oz?
person_list = [
  ["Lori Loehr", "lxl001", "1112223333", "1996-10-06", false],
  ["Oliver Ohanlon", "oxo001", "1112223333", "1996-10-06", false],
  ["Reginia Rousseau", "rxr001", "1112223333", "1996-10-06", false],
  ["Victor Villanueva", "vxv001", "1112223333", "1996-10-06", false],
  ["Rhoda Roher", "rxr002", "1112223333", "1996-10-06", false],
  ["Candra Chagolla", "cxc001", "1112223333", "1996-10-06", false],
  ["Ruthann Reyes", "rxr003", "1112223333", "1996-10-06", false],
  ["Markita Mccabe", "mxm001", "1112223333", "1996-10-06", false],
  ["Raven Right", "rxr004", "1112223333", "1996-10-06", false],
  ["Rick Reineck", "rxr005", "1112223333", "1996-10-06", false],
  ["Shaunte Stallcup", "sxs001", "1112223333", "1996-10-06", false],
  ["Rob Ritacco", "rxr006", "1112223333", "1996-10-06", false],
  ["Elayne Edelen", "exe001", "1112223333", "1996-10-06", false],
  ["Luciana Lankford", "lxl002", "1112223333", "1996-10-06", false],
  ["Alisa Avilez", "axa001", "1112223333", "1996-10-06", false],
  ["Enoch Edelson", "exe002", "1112223333", "1996-10-06", false],
  ["Jana Jablonowski", "jxj001", "1112223333", "1996-10-06", false],
  ["Crysta Cogley", "cxc002", "1112223333", "1996-10-06", false],
  ["Jade Jan", "jxj002", "1112223333", "1996-10-06", false],
  ["Craig Cyphers", "cxc003", "1112223333", "1996-10-06", false],
  ["Ramiro Reinhart", "rxr007", "1112223333", "1996-10-06", false],
  ["Anya Acy", "axa002", "1112223333", "1996-10-06", false],
  ["Agatha Askew", "axa003", "1112223333", "1996-10-06", false],
  ["Kathleen Kadlec", "kxk001", "1112223333", "1996-10-06", false],
  ["Josephina James", "jxj003", "1112223333", "1996-10-06", false],
  ["Deirdre Demoss", "dxd001", "1112223333", "1996-10-06", false],
  ["Dianne Dodd", "dxd002", "1112223333", "1996-10-06", false],
  ["Virgina Vise", "vxv001", "1112223333", "1996-10-06", false],
  ["Graham Grajeda", "gxg001", "1112223333", "1996-10-06", true],
  ["Trish Trickett", "txt001", "1112223333", "1996-10-06", true]
]

players = []

# Create each person
person_list.each do |name, case_id, phone, dob, is_oz|
  person = Person.new(name: name, phone: phone, date_of_birth: dob)
  # Case ID assignment must be done separately due to it being a protected attribute
  person.caseid = case_id
  person.save

  # Store ID and OZ status for later use
  players << [person.id, is_oz]
end

# Create the game
current_game = Game.create(
  short_name: "current-dev-env-game",
  registration_begins: 2.days.ago,
  registration_ends: 1.day.ago,
  game_begins: 2.hours.ago,
  game_ends: 6.days.from_now,
  is_current: true,
  information: "Automatically generated from script #{File.expand_path(File.dirname(__FILE__))}",
  rules: "No rules given.",
  oz_reveal: 1.hour.ago)

# Register each person for the game and submit a waiver for them
players.each do |person_id, is_oz|
  Registration.create(
    person_id: person_id,
    game_id: current_game.id,
    card_code: Registration.make_code,
    faction_id: is_oz ? 1 : 0,
    wants_oz: is_oz,
    is_oz: is_oz,
    score: 0)
  Waiver.create(
    person_id: person_id,
    game_id: current_game.id,
    studentid: 1234567,
    datesigned: Date.today,
    emergencyname: "Emergency Contact Name",
    emergencyrelationship: "Guardian",
    emergencyphone: "4445556666",
    signature: Person.where(id: person_id).first.name)
end
