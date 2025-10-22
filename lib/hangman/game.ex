defmodule Hangman.Game do
  alias __MODULE__

  defstruct [:name, :word, :guesses, :cooldowns, :last_action]

  def new(name) when is_binary(name) do
    %Game{
      name: name,
      word: hd(Enum.shuffle(words())),
      guesses: MapSet.new(),
      cooldowns: %{},
      last_action: ""
    }
  end

  def guess(%Game{} = gg, user, letter) do
    if on_cooldown?(gg, user) do
      # Ignore early guesses
      gg
    else
      guesses = MapSet.put(gg.guesses, letter)
      cooldowns = Map.put(gg.cooldowns, user, DateTime.now!("Etc/UTC"))
      %Game{gg | guesses: guesses, cooldowns: cooldowns, last_action: user}
    end
  end

  def on_cooldown?(%Game{cooldowns: cooldowns}, user) do
    case Map.fetch(cooldowns, user) do
      {:ok, cd} ->
        now = DateTime.now!("Etc/UTC")
        DateTime.diff(now, cd) <= 5

      :error ->
        false
    end
  end

  def view(%Game{} = gg) do
    %{
      letters_view: letters_view(gg),
      bad_guesses: bad_guesses(gg),
      remaining_letters: remaining_letters(gg),
      last_action: gg.last_action
    }
  end

  def letters_view(%Game{} = gg) do
    letters = String.split(gg.word, "", trim: true)

    for ll <- letters do
      if MapSet.member?(gg.guesses, ll) do
        ll
      else
        "_"
      end
    end
    |> Enum.join(" ")
  end

  def bad_guesses(%Game{} = gg) do
    word_letters = MapSet.new(String.split(gg.word, "", trim: true))
    Enum.count(gg.guesses, fn guess -> !MapSet.member?(word_letters, guess) end)
  end

  def remaining_letters(%Game{} = gg) do
    letters = MapSet.new(String.split("abcdefghijklmnopqrstuvwxyz", "", trim: true))

    MapSet.difference(letters, gg.guesses)
    |> Enum.into([])
  end

  def words() do
    [
      "jazz",
      "buzz",
      "jinx",
      "quiz",
      "fjord",
      "lymph",
      "crypt",
      "gawk",
      "hajj",
      "fluff",
      "nymph",
      "rhythm",
      "syzygy",
      "awkward",
      "bagpipes",
      "banjo",
      "beekeeper",
      "blizzard",
      "bookworm",
      "boxcar",
      "buckaroo",
      "cobweb",
      "croquet",
      "dwarves",
      "embezzle",
      "fishhook",
      "flapjack",
      "frazzled",
      "gazebo",
      "glowworm"
    ]
  end
end
