defmodule HangmanWeb.PageController do
  use HangmanWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
