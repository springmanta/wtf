players = %w[Simao Rui Miguel Joao Pedro Tiago Bruno Nuno].map do |name|
  Player.find_or_create_by!(name: name)
end

if Game.none?
  game = Game.create!(
    played_on: Date.current.prev_occurring(:wednesday),
    location: "Municipal Pitch",
    team_one_name: "Light",
    team_two_name: "Dark",
    team_one_score: 5,
    team_two_score: 3
  )

  players.each_with_index do |player, index|
    team = index.even? ? "team_one" : "team_two"
    goals = index.zero? ? 3 : (index == 1 ? 2 : 0)
    game.appearances.create!(player: player, team: team, goals: goals)
  end
end
