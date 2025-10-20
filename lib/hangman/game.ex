defmodule Hangman.Game do
  alias __MODULE__

  defstruct [:word, :guesses]

  def new() do
    %Game{
      word: hd(Enum.shuffle(words())),
      guesses: MapSet.new()
    }
  end

  def guess(%Game{} = gg, letter) do
    %Game{gg | guesses: MapSet.put(gg.guesses, letter)}
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
