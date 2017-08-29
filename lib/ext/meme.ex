defmodule Botto.Memes do
  alias Alchemy.Client

  defmodule Commands do
    use Alchemy.Cogs

    Cogs.def meme() do
      Cogs.say "testing from another cog"
    end

    Cogs.def xkcd() do
      Client.trigger_typing message.channel_id
      raw = HTTPoison.get! "https://xkcd.com/info.0.json"
      {:ok, comic_data} = Poison.decode raw.body
      Cogs.say comic_data["img"]
    end

    Cogs.def xkcd(num) do
      Client.trigger_typing message.channel.id

      raw = HTTPoison.get! "https://xkcd.com/#{num}/info.0.json"
      {:ok, comic_data} = Poison.decode raw.body

      Cogs.say comic_data["img"]
    end
  end
end

