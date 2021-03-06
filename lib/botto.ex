
defmodule Botto do
  use Application
  alias Alchemy.Client
  alias Alchemy.Voice


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
    admins = Application.fetch_env!(:botto, :admins)
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
          Cogs.say "result: ```elixir\n#{inspect result}\n```\nenv: ```\n#{inspect env}```"
        rescue
          e -> Cogs.say "#{inspect e}"
        end
      else
        Cogs.say "nope you can't do this"
      end
    end

    Cogs.set_parser(:shell, &List.wrap/1)
    Cogs.def shell(cmdline) do
      if Botto.can_admin(message) do
        splitted = String.split cmdline, " ", parts: 2
        if Enum.count(splitted) < 2 do
          [command] = splitted
          args = []
        else
          [command, args] = splitted
          args = String.split args
        end

        try do
          {out, err_code} = System.cmd(command, args, stderr_to_stdout: true)
          Cogs.say "error code: #{err_code}\n```\n#{out}\n```"
        rescue
          e -> Cogs.say "Error while running the command: #{inspect e}"
        end
      else
        Cogs.say "dont hax me u fucking cunt"
      end
    end

    Cogs.set_parser(:play, &List.wrap/1)
    Cogs.def music(song_url) do
      if Botto.can_admin(message) do
        {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
        {:ok, guild} = Alchemy.Cache.guild(guild_id)

        states = guild.voice_states
        state = Enum.find(states, fn(state) -> state.user_id == message.author.id end)

        if state == nil do
          Cogs.say "No voice state found for you."
        else
          status = Voice.join(guild_id, state.channel_id)
          IO.inspect(status)

          r = Voice.play_url(guild_id, song_url, [{:vol, 100}])
          case r do
            {:error, err} -> Cogs.say(err)
            :ok -> Cogs.say("I'm playing it.. I guess.")
          end

          IO.inspect r

          Cogs.say "command execution finished"
          #Cogs.say "[wait_for_end]"
          #Voice.wait_for_end(guild)
          #Cogs.say "wait_for_end finished."

          #Voice.leave(guild.id)
          #Cogs.say "left voice"
        end

      else
        Cogs.say "You can't run music shit rEEE"
      end
    end

    Cogs.def play(url) do
      {:ok, id} = Cogs.guild_id()
      {:ok, guild} = Alchemy.Cache.guild(id)

      state = Enum.find(guild.voice_states, fn state ->
        state.user_id == message.author.id
      end)

      if state == nil do
        Cogs.say("no state rip")
      end

      IO.inspect(Voice.join(id, state.channel_id))
      IO.inspect(Voice.play_url(id, url, [{:vol, 120}]))

      Cogs.say "now playing #{url}"
    end

    Cogs.def current do
      {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
      c = Voice.which_channel(guild_id)
      IO.inspect c
      case c do
        nil -> Cogs.say "nothing"
        _ -> Cogs.say "something is running but i cant show it haha"
      end
    end

    Cogs.def leave do
      {:ok, guild_id} = Alchemy.Cache.guild_id(message.channel_id)
      case Voice.stop_audio(guild_id) do
        {:error, err} -> Cogs.say err
        :ok -> Cogs.say "ok stopaudio"
      end
      
      case Voice.leave(guild_id) do
        :ok -> Cogs.say "ok voiceleave"
        {:error, err} -> Cogs.say err
      end
    end

  end

  def start(_type, _args) do
    run = Client.start(Application.fetch_env!(:botto, :token))
    Alchemy.Cogs.set_prefix(Application.fetch_env!(:botto, :prefix))
    use Commands
    use Botto.Memes.Commands
    run
  end
end

