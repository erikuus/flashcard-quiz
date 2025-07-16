defmodule FlashcardQuiz.Flashcards.Flashcard do
  use Ecto.Schema
  import Ecto.Changeset

  alias FlashcardQuiz.Flashcards.Pack

  schema "flashcards" do
    field :front, :string
    field :back, :string

    belongs_to :pack, Pack

    timestamps()
  end

  @doc false
  def changeset(flashcard, attrs) do
    flashcard
    |> cast(attrs, [:front, :back, :pack_id])
    |> validate_required([:front, :back])
    |> validate_length(:front, min: 1, max: 500)
    |> validate_length(:back, min: 1, max: 2000)
    |> foreign_key_constraint(:pack_id)
  end
end
