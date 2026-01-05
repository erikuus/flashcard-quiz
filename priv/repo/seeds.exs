# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     FlashcardQuiz.Repo.insert!(%FlashcardQuiz.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias FlashcardQuiz.Flashcards
alias FlashcardQuiz.Repo

# Clear existing data
Repo.delete_all(FlashcardQuiz.Flashcards.Flashcard)
Repo.delete_all(FlashcardQuiz.Flashcards.Pack)

# Create packs
{:ok, elixir_pack} = Flashcards.create_pack(%{name: "Elixir Basics"})
{:ok, phoenix_pack} = Flashcards.create_pack(%{name: "Phoenix Specifics"})

# Create sample Elixir flashcards
{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you sum all values in a list?",
    back: """
    ```elixir
    Enum.reduce([2, 4, 6], 0, &+/2)
    ```

    Or (expanded):

    ```elixir
    Enum.reduce([2, 4, 6], 0, fn x, acc -> x + acc end)
    ```
    """,
    pack_id: elixir_pack.id
  })

{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you pattern match a list?",
    back: """
    ```elixir
    [head | tail] = [1, 2, 3, 4]
    # head = 1, tail = [2, 3, 4]
    ```
    """,
    pack_id: elixir_pack.id
  })

elixir_cards = [
  %{
    front: "How do you transform every element in a list? (*2)",
    back: """
    ```elixir
    Enum.map([1, 2, 3], fn n -> n * 2 end)
    # => [2, 4, 6]
    ```

    Shorthand:

    ```elixir
    Enum.map([1, 2, 3], &(&1 * 2))
    ```
    """
  },
  %{
    front: "How do you print each item on its own line? (IO.puts)",
    back: """
    ```elixir
    Enum.each([\"a\", \"b\"], fn letter -> IO.puts(letter) end)
    ```

    Shorthand:

    ```elixir
    Enum.each([\"a\", \"b\"], &IO.puts/1)
    ```
    """
  },
  %{
    front: "How do you remove items that match a condition? (even numbers)",
    back: """
    ```elixir
    Enum.reject([1, 2, 3, 4], fn n -> rem(n, 2) == 0 end)
    # => [1, 3]
    ```

    Shorthand:

    ```elixir
    Enum.reject([1, 2, 3, 4], &(rem(&1, 2) == 0))
    ```
    """
  },
  %{
    front: "How do you group list by key function? (string length)",
    back: """
    ```elixir
    Enum.group_by([\"ant\", \"bear\", \"cat\"], fn word -> String.length(word) end)
    # => %{3 => [\"ant\", \"cat\"], 4 => [\"bear\"]}
    ```

    Shorthand:

    ```elixir
    Enum.group_by([\"ant\", \"bear\", \"cat\"], &String.length/1)
    ```

    Comment:

    ```elixir
    # Group items before rendering sections (e.g., by initial letter).
    groups = Enum.group_by(items, &String.first/1)
    ```
    """
  },
  %{
    front: "How do you group list of maps by key and value function?",
    back: """
    ```elixir
    rows = [
      %{country: \"US\", city: \"New York\"},
      %{country: \"US\", city: \"Chicago\"},
      %{country: \"FI\", city: \"Helsinki\"}
    ]

    Enum.group_by(rows, fn row -> row.country end, fn row -> row.city end)
    # => %{\"FI\" => [\"Helsinki\"], \"US\" => [\"New York\", \"Chicago\"]}
    ```

    Shorthand:

    ```elixir
    Enum.group_by(rows, & &1.country, & &1.city)
    ```

    Comment:

    ```elixir
    # Build grouped options for a select in LiveView.
    rows = [
      %{country: "US", city: "New York", id: 1},
      %{country: "US", city: "Chicago", id: 2},
      %{country: "FI", city: "Helsinki", id: 3}
    ]

    grouped_options = Enum.group_by(rows, & &1.country, &{&1.city, &1.id})
    # <.input type="select" options={grouped_options} />
    ```
    """
  },
  %{
    front: "How do you add indexes to a list? (0-based)",
    back: """
    ```elixir
    Enum.with_index([\"x\", \"y\"])
    # => [{\"x\", 0}, {\"y\", 1}]
    ```
    """
  },
  %{
    front: "How do you count items in a list?",
    back: """
    ```elixir
    Enum.count([:a, :b, :c])
    # => 3
    ```

    Comment:

    ```elixir
    # Common for showing counts or enabling/disabling UI.
    count = Enum.count(@uploads.photos.entries)
    ```
    """
  },
  %{
    front: "How do you check if a list is empty?",
    back: """
    ```elixir
    Enum.empty?([])
    # => true
    ```

    Comment:

    ```elixir
    # Toggle an empty state in assigns.
    assign(socket, :items_empty, Enum.empty?(items))
    ```
    """
  },
  %{
    front: "How do you get an item by index from a list? (index 1)",
    back: """
    ```elixir
    Enum.at([\"first\", \"second\"], 1)
    # => \"second\"
    ```
    """
  },
  %{
    front: "How do you read a value from a map with a default? (missing key)",
    back: """
    ```elixir
    Map.get(%{a: 1}, :b, 0)
    # => 0
    ```

    Comment:

    ```elixir
    # Typical for reading params with defaults.
    page = Map.get(params, \"page\", \"1\")
    ```
    """
  },
  %{
    front: "How do you add or update a key in a map? (:b => 2)",
    back: """
    ```elixir
    Map.put(%{a: 1}, :b, 2)
    # => %{a: 1, b: 2}
    ```
    """
  },
  %{
    front: "How do you merge two maps? (%{a: 1} + %{b: 2})",
    back: """
    ```elixir
    Map.merge(%{a: 1}, %{b: 2})
    # => %{a: 1, b: 2}
    ```
    """
  },
  %{
    front: "How do you update a map value with a function? (increment :count)",
    back: """
    ```elixir
    Map.update!(%{count: 1}, :count, fn n -> n + 1 end)
    # => %{count: 2}
    ```

    Shorthand:

    ```elixir
    Map.update!(%{count: 1}, :count, &(&1 + 1))
    ```
    """
  },
  %{
    front: "How do you split a string by whitespace? (\"one two three\")",
    back: """
    ```elixir
    String.split(\"one two three\")
    # => [\"one\", \"two\", \"three\"]
    ```
    """
  },
  %{
    front: "How do you replace all spaces with dashes? (\"hello world\")",
    back: """
    ```elixir
    String.replace(\"hello world\", \" \", \"-\")
    # => \"hello-world\"
    ```
    """
  },
  %{
    front: "How do you check if a string contains a substring? (\"lix\")",
    back: """
    ```elixir
    String.contains?(\"elixir\", \"lix\")
    # => true
    ```
    """
  },
  %{
    front: "How do you pad a number to two digits? (7 -> \"07\")",
    back: """
    ```elixir
    7 |> Integer.to_string() |> String.pad_leading(2, \"0\")
    # => \"07\"
    ```
    """
  },
  %{
    front: "How do you join path segments safely? (/tmp/reports/today.txt)",
    back: """
    ```elixir
    Path.join([\"/tmp\", \"reports\", \"today.txt\"])
    # => \"/tmp/reports/today.txt\"
    ```
    """
  },
  %{
    front: "How do you read a file into a string? (/tmp/notes.txt)",
    back: """
    ```elixir
    File.read(\"/tmp/notes.txt\")
    # => {:ok, \"...\"}
    ```
    """
  },
  %{
    front: "How do you build a query string from a map? (page=2&sort=name)",
    back: """
    ```elixir
    URI.encode_query(%{page: 2, sort: \"name\"})
    # => \"page=2&sort=name\"
    ```

    Comment:

    ```elixir
    # Common when building pagination or sort links.
    query = URI.encode_query(%{page: page, sort: sort})
    ```
    """
  },
  %{
    front: "How do you compute a time difference in seconds? (90 seconds)",
    back: """
    ```elixir
    start = DateTime.utc_now()
    finish = DateTime.add(start, 90, :second)
    DateTime.diff(finish, start, :second)
    # => 90
    ```
    """
  },
  %{
    front: "How do you remove all digits from a string with a regex? (\"a1b2c3\")",
    back: """
    ```elixir
    Regex.replace(~r/\\d+/, \"a1b2c3\", \"\")
    # => \"abc\"
    ```
    """
  },
  %{
    front: "How do you encode binary data for URLs? (\"token\")",
    back: """
    ```elixir
    Base.url_encode64(\"token\")
    # => \"dG9rZW4=\"
    ```
    """
  },
  %{
    front: "How do you fetch a required environment variable? (API_KEY)",
    back: """
    ```elixir
    System.fetch_env!(\"API_KEY\")
    ```
    """
  }
]

Enum.each(elixir_cards, fn card ->
  {:ok, _} =
    Flashcards.create_flashcard(
      Map.put(card, :pack_id, elixir_pack.id)
    )
end)

# Create sample Phoenix flashcards
{:ok, _} =
  Flashcards.create_flashcard(%{
    front: "How do you create a LiveView route?",
    back: """
    ```elixir
    live "/path", MyLive
    ```
    """,
    pack_id: phoenix_pack.id
  })

IO.puts(
  "Seeded #{Enum.count(Flashcards.list_packs())} packs and #{Enum.count(Flashcards.list_flashcards())} flashcards!"
)
