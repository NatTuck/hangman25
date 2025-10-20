defmodule Hangman.GameSup do
  use Supervisor

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  @impl true
  def init(_arg) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Hangman.GameDynSup},
      {Registry, keys: :unique, name: Hangman.GameReg}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
