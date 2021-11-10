defmodule Mix.Tasks.SecureX.Gen.Migrate do
  @moduledoc "The SecureX mix task: `mix help secure_x.gen.migrate`"
  use Mix.Task

  @shortdoc "Simply calls the SecureX.say/0 function."
  def run(_) do
    # calling our Hello.say() function from earlier
    SecureX.say()
  end
end