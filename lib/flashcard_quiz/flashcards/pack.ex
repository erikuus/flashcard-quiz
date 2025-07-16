defmodule FlashcardQuiz.Flashcards.Pack do
  use Ecto.Schema
  import Ecto.Changeset

  alias FlashcardQuiz.Flashcards.Flashcard

  schema "packs" do
    field :name, :string
    field :description, :string

    has_many :flashcards, Flashcard

    timestamps()
  end

  @doc false
  def changeset(pack, attrs) do
    pack
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> unique_constraint(:name)
  end
end
