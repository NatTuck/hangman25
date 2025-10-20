defmodule HangmanWeb.GameChannel do
  use HangmanWeb, :channel

  alias Hangman.GameServer

  @impl true
  def join("game:" <> name, %{"user" => user}, socket) do
    IO.puts("User #{user} joining game #{name}")

    if authorized?(user) do
      socket =
        socket
        |> assign(:user, user)
        |> assign(:name, name)

      GameServer.start(name)
      game = GameServer.peek(name)

      Phoenix.PubSub.subscribe(Hangman.PubSub, "gamex:" <> name)

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

  @impl true
  def handle_info({:update, view}, socket) do
    broadcast!(socket, "update", view)
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
