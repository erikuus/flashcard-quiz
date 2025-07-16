defmodule FlashcardQuiz.Repo.Migrations.CreateFlashcards do
  use Ecto.Migration

  def change do
    create table(:flashcards) do
      add :front, :text, null: false
      add :back, :text, null: false

      timestamps()
    end

    create index(:flashcards, [:inserted_at])
  end
end
