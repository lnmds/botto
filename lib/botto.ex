
defmodule Botto do
  use Application
  alias Alchemy.Client

  def get_important(lst) do
    l = Enum.count(lst)
    Enum.slice(lst, 1, l - 2)
  end

  def strip_markup(code) do
    if String.starts_with?(code, "```") and String.ends_with?(code, "```") do
      String.split(code, "\n")
      |> Botto.get_important
      |> Enum.join("\n")
    else
      String.trim(code)
    end
  end

  defmodule Commands do
    use Alchemy.Cogs


    Cogs.def ping do
      time1 = System.monotonic_time()
      {:ok, p} = Cogs.say "."
      time2 = System.monotonic_time()
      sec = System.convert_time_unit(1, :millisecond, :native)
      delta = (time2 - time1) / sec
      Client.edit_message(p, "#{delta}ms")
    end

    Cogs.def echo do
      Cogs.say("some word lol")
    end

    Cogs.set_parser(:echo, &List.wrap/1)
    Cogs.def echo(word) do
      if message.author.id != "162819866682851329" do
        Cogs.say "nope"
      else
        Cogs.say word
      end
    end

    Cogs.def a do
      verb = Enum.random ["A", "B", "C", "D"]
      subject = Enum.random ["a", "b", "c", "d"]
      lower = String.downcase message.author.username
      Cogs.say "#{verb} my #{subject} and call me #{lower}"
    end

    Cogs.def b do
      case message.author.id do
        "162819866682851329" ->
          Cogs.say "ur dum"
        "97104885337575424" -> 
          Cogs.say "get bac to d.py!!1!!!!!1"
        _ ->
          Cogs.say "nothing 4 u sorry"
      end
    end

    Cogs.set_parser(:eval, &List.wrap/1)
    Cogs.def eval(code) do
      case message.author.id do
        "162819866682851329" ->
          try do
            {result, env} = code
            |> Botto.strip_markup
            |> Code.eval_string

            Client.add_reaction(message, "\u2705")

            Cogs.say "result: #{inspect result}, env: #{inspect env}"
          rescue
            e -> Cogs.say "#{inspect e}"
          end
        _ ->
          Cogs.say "nope you can't do this"
      end
    end

  end


  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:botto, :token))
    Alchemy.Cogs.set_prefix("fuck ")
    use Commands
    run
  end
end

