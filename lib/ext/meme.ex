defmodule Botto.Memes do
  alias Alchemy.Client

  defmodule Commands do
    use Alchemy.Cogs

    Cogs.def meme() do
      Cogs.say "testing from another cog"
    end
  end
end

