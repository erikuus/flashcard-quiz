defmodule FlashcardQuiz.Flashcards.Flashcard do
  use Ecto.Schema
  import Ecto.Changeset

  schema "flashcards" do
    field :front, :string
    field :back, :string

    timestamps()
  end

  @doc false
  def changeset(flashcard, attrs) do
    flashcard
    |> cast(attrs, [:front, :back])
    |> validate_required([:front, :back])
    |> validate_length(:front, min: 1, max: 1000)
    |> validate_length(:back, min: 1, max: 1000)
  end
end
