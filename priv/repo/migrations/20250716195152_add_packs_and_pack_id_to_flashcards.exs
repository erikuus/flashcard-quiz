defmodule FlashcardQuiz.Repo.Migrations.AddPacksAndPackIdToFlashcards do
  use Ecto.Migration

  def change do
    create table(:packs) do
      add :name, :string, null: false
      add :description, :text

      timestamps()
    end

    create unique_index(:packs, [:name])

    alter table(:flashcards) do
      add :pack_id, references(:packs, on_delete: :delete_all)
    end

    create index(:flashcards, [:pack_id])
  end
end
