
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

  def can_admin(message) do
    admins = Application.fetch_info(:botto, :admins)
    Enum.find(admins, fn(x) -> message.author.id == x end) != nil
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
      if Botto.can_admin(message) do
        Cogs.say(word)
      else
        Cogs.say "no"
      end
    end

    Cogs.def a do
      verb = Enum.random ["A", "B", "C", "D"]
      subject = Enum.random ["a", "b", "c", "d"]
      lower = String.downcase message.author.username
      Cogs.say "#{verb} my #{subject} and call me #{lower}"
    end

    Cogs.set_parser(:eval, &List.wrap/1)
    Cogs.def eval(code) do
      if Botto.can_admin(message) do
        try do
          {result, env} = code
          |> Botto.strip_markup
          |> Code.eval_string([msg: message])

          Client.add_reaction(message, "\u2705")

          env = Keyword.delete(env, :msg)
          Cogs.say "result: ```elixir\n#{result}\n```, env: ```\n#{inspect env}```"
        rescue
          e -> Cogs.say "#{inspect e}"
        end
      else
        Cogs.say "nope you can't do this"
      end
    end

    Cogs.set_parser(:shell, &List.wrap/1)
    Cogs.def shell(command) do
      if Botto.can_admin(message) do
        {out, err_code} = System.cmd(command, [])
        Cogs.say "#{inspect err_code} #{inspect out}"
      else
        Cogs.say "dont hax me u fucking cunt"
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

