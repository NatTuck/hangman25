defmodule Hangman.GameServer do
  use GenServer

  alias Hangman.Game

  def start_link(name) do
    GenServer.start_link(__MODULE__, [name], name: reg(name))
  end

  def reg(name) do
    {:via, Registry, {Hangman.GameReg, name}}
  end

  def start(name) do
    spec = %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :temporary
    }

    DynamicSupervisor.start_child(Hangman.GameDynSup, spec)
  end

  def peek(name) do
    GenServer.call(reg(name), :peek)
  end

  def guess(name, letter) do
    GenServer.call(reg(name), {:guess, letter})
  end

  def reset(name) do
    GenServer.call(reg(name), :reset)
  end

  def init(_name) do
    {:ok, Game.new()}
  end

  def handle_call({:guess, letter}, _from, game) do
    game = Game.guess(game, letter)
    {:reply, Game.view(game), game}
  end

  def handle_call(:reset, _from, _game) do
    game = Game.new()
    {:reply, Game.view(game), game}
  end

  def handle_call(:peek, _from, game) do
    {:reply, Game.view(game), game}
  end
end
