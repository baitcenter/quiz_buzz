defmodule QuizBuzz.Quizzes.Setup do
  alias QuizBuzz.Quizzes.{Player, Team}

  def add_team(_quiz, ""), do: {:error, "Name must not be blank"}

  def add_team(%{state: :setup} = quiz, name) do
    if quiz.teams |> Enum.any?(&(&1.name == name)) do
      {:error, "That name has already been taken"}
    else
      quiz = %{quiz | teams: [Team.new(name) | quiz.teams]}
      {:ok, quiz}
    end
  end

  def add_team(_quiz, _), do: {:error, "The quiz has already started"}

  def join_quiz(_quiz, ""), do: {:error, "Name must not be blank"}

  def join_quiz(%{state: :setup} = quiz, name) do
    team_players = quiz.teams |> Enum.flat_map(& &1.players)

    if (quiz.players ++ team_players) |> Enum.any?(&(&1.name == name)) do
      {:error, "That name has already been taken"}
    else
      quiz = %{quiz | players: [Player.new(name) | quiz.players]}
      {:ok, quiz}
    end
  end

  def join_quiz(_quiz, _), do: {:error, "The quiz has already started"}

  def join_team(%{state: :setup} = quiz, team, player) do
    quiz = %{
      quiz
      | teams: add_player_to_team(quiz.teams, team, player),
        players: remove_player(quiz.players, player)
    }

    {:ok, quiz}
  end

  def join_team(_quiz, _, _), do: {:error, "The quiz has already started"}

  defp add_player_to_team(teams, team, player) do
    teams |> Enum.map(&update_team_if_matches(&1, team, player))
  end

  defp update_team_if_matches(team, team, player) do
    %{team | players: [player | team.players]}
  end

  defp update_team_if_matches(team, _, _), do: team

  defp remove_player(players, player) do
    players |> Enum.reject(&(&1 == player))
  end
end