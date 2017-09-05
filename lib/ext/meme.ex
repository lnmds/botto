defmodule Botto.Memes do
  alias Alchemy.Client
  alias Alchemy.Embed

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
      Client.trigger_typing message.channel_id

      raw = HTTPoison.get! "https://xkcd.com/#{num}/info.0.json"

      case Poison.decode raw.body do
        {:ok, comic_data} -> Cogs.say comic_data["img"]
        {:error, err} -> Cogs.say "Error while decoding: #{inspect err}"
        _ -> Cogs.say "how did this happen??(not supposed to happen piece of code)"
      end

    end

    Cogs.def embed do
      e = %Embed{}
      |> Embed.title("the best embed suck my dick.")
      |> Embed.description("fuck slice 2017")
      |> Embed.image("https://phoxgirls.are-pretty.sexy/d23c39.png")

      Client.send_message(message.channel_id, "testing bitch", [embed: e])
    end

    Cogs.def ship(a_id, b_id) do
      guild_id = Alchemy.Cogs.guild_id()
      member_a = Alchemy.Cache.member(guild_id, a_id)
      member_b = Alchemy.Cache.member(guild_id, b_id)

      member_a_int = Integer.parse(a_id)
      member_b_int = Integer.parse(b_id)

      :rand.seed({:exrop, [member_a_int | member_a_int]})
      a_score = :rand.uniform(100)

      :rand.seed({:exrop, [member_b_int | member_b_int]})
      b_score = :rand.uniform(100)

      ship_score = (a_score + b_score) / 2

      Cogs.say "Ship score: **#{ship_score}%**"
    end

  end
end

