defmodule HangmanWeb.GameChannel do
  use HangmanWeb, :channel

  alias Hangman.GameServer

  @impl true
  def join("game:" <> name, payload, socket) do
    if authorized?(payload) do
      socket =
        socket
        |> assign(:name, name)

      GameServer.start(name)
      game = GameServer.peek(name)

      {:ok, %{view: game}, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("guess", %{"letter" => letter}, socket) do
    game =
      socket.assigns[:name]
      |> GameServer.guess(letter)

    {:reply, {:ok, game}, socket}
  end

  def handle_in("reset", _params, socket) do
    game =
      socket.assigns[:name]
      |> GameServer.reset()

    {:reply, {:ok, game}, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
