# Run this file using rake db:seed. Run it ONLY in dev or test environments.
# This is meant to be run on a new server. It will not delete records from previous seeds.

# I think I'd like two games; one that already passed, with a combination of humans
# and zombies, and one either ongoing or in the future, with all humans. But for now,
# I'm just going with one arbitrary game

person_list = [
  ["Lori Loehr", "lxl001", "1112223333", "1996-10-06"],
  ["Oliver Ohanlon", "oxo001", "1112223333", "1996-10-06"],
  ["Reginia Rousseau", "rxr001", "1112223333", "1996-10-06"],
  ["Victor Villanueva", "vxv001", "1112223333", "1996-10-06"],
  ["Rhoda Roher", "rxr002", "1112223333", "1996-10-06"],
  ["Candra Chagolla", "cxc001", "1112223333", "1996-10-06"],
  ["Ruthann Reyes", "rxr003", "1112223333", "1996-10-06"],
  ["Markita Mccabe", "mxm001", "1112223333", "1996-10-06"],
  ["Raven Right", "rxr004", "1112223333", "1996-10-06"],
  ["Rick Reineck", "rxr005", "1112223333", "1996-10-06"],
  ["Shaunte Stallcup", "sxs001", "1112223333", "1996-10-06"],
  ["Rob Ritacco", "rxr006", "1112223333", "1996-10-06"],
  ["Elayne Edelen", "exe001", "1112223333", "1996-10-06"],
  ["Luciana Lankford", "lxl002", "1112223333", "1996-10-06"],
  ["Alisa Avilez", "axa001", "1112223333", "1996-10-06"],
  ["Enoch Edelson", "exe002", "1112223333", "1996-10-06"],
  ["Jana Jablonowski", "jxj001", "1112223333", "1996-10-06"],
  ["Crysta Cogley", "cxc002", "1112223333", "1996-10-06"],
  ["Jade Jan", "jxj002", "1112223333", "1996-10-06"],
  ["Craig Cyphers", "cxc003", "1112223333", "1996-10-06"],
  ["Ramiro Reinhart", "rxr007", "1112223333", "1996-10-06"],
  ["Anya Acy", "axa002", "1112223333", "1996-10-06"],
  ["Agatha Askew", "axa003", "1112223333", "1996-10-06"],
  ["Kathleen Kadlec", "kxk001", "1112223333", "1996-10-06"],
  ["Josephina James", "jxj003", "1112223333", "1996-10-06"],
  ["Deirdre Demoss", "dxd001", "1112223333", "1996-10-06"],
  ["Dianne Dodd", "dxd002", "1112223333", "1996-10-06"],
  ["Virgina Vise", "vxv001", "1112223333", "1996-10-06"],
  ["Graham Grajeda", "gxg001", "1112223333", "1996-10-06"],
  ["Trish Trickett", "txt001", "1112223333", "1996-10-06"]
]

person_ids = []

# Create each person
person_list.each do |name, case_id, phone, dob|
  p = Person.new(name: name, phone: phone, date_of_birth: dob)
  # Case ID assignment must be done separately due to it being a protected attribute
  p.caseid = case_id
  p.save

  # Store ID for later use
  person_ids << p.id
end

# Create the game
Game.create(
  short_name: "dev-env-game",
  registration_begins: 2.days.ago,
  registration_ends: 1.days.ago,
  game_begins: 1.hour.ago,
  game_ends: 6.days.from_now,
  is_current: true,
  information: "Automatically generated from script #{File.expand_path(File.dirname(__FILE__))}",
  rules: "No rules given.",
  oz_reveal: 1.days.from_now)

game_id = Game.last.id

# Register each person for the game and submit a waiver for them
person_ids.each do |person_id|
  Registration.create(
    person_id: person_id,
    game_id: game_id,
    card_code: Registration.make_code,
    faction_id: 0,
    human_type: "Resistance")
  Waiver.create(
    person_id: person_id,
    game_id: game_id,
    studentid: 1234567,
    datesigned: Date.today,
    emergencyname: "Emergency Contact Name",
    emergencyrelationship: "Some Relationship",
    emergencyphone: "4445556666",
    signature: Person.where(id: person_id).first.name)
end
