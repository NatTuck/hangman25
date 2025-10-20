defmodule Hangman.Game do
  alias __MODULE__

  defstruct [:name, :word, :guesses, :cooldowns]

  def new(name) when is_binary(name) do
    %Game{
      name: name,
      word: hd(Enum.shuffle(words())),
      guesses: MapSet.new(),
      cooldowns: %{}
    }
  end

  def guess(%Game{} = gg, user, letter) do
    guesses = MapSet.put(gg.guesses, letter)
    cooldowns = Map.put(gg.cooldowns, user, DateTime.now("Etc/UTC"))
    %Game{gg | guesses: guesses, cooldowns: cooldowns}
  end

  def view(%Game{} = gg) do
    %{
      letters_view: letters_view(gg),
      bad_guesses: bad_guesses(gg),
      remaining_letters: remaining_letters(gg)
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
