defmodule FlashcardQuiz.Repo do
  use Ecto.Repo,
    otp_app: :flashcard_quiz,
    adapter: Ecto.Adapters.SQLite3
end
