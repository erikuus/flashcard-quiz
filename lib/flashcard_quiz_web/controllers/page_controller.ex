defmodule FlashcardQuizWeb.PageController do
  use FlashcardQuizWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
