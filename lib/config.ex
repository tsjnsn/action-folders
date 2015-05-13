defmodule AF.Config do

  @parse_opts [
    strict: [
      folder: :string,
      command: :string,
      args: :string,
      recursive: :boolean,
      allow_hidden: :boolean,
      allow_dir: :boolean
    ],
    aliases: [
      f: :folder,
      cmd: :command,
      r: :recursive,
      a: :allow_hidden,
      d: :allow_dir
    ]
  ]

  def parse_file(filename) do
    dir = Path.dirname(filename)

    filename
    |> read_in
    |> String.split("\n")
    |> convert_lines_to_structs(dir)
  end

  defp read_in(filename) do
    {:ok, confstr} = File.read filename
    confstr
  end

  def convert_lines_to_structs(rawconf, relative_to) do
    for line <- rawconf do
      { parsed, argv, _errors } = OptionParser.parse(OptionParser.split(line), @parse_opts)
     
      case argv do
        [ "action" | rest ] when not is_nil rest ->
          folder = Keyword.fetch!(parsed, :folder) |> Path.expand(relative_to)
          [ command | args ] = rest
          args = for x <- args, do: x |> String.lstrip(?") |> String.rstrip(?")

          r = Keyword.get(parsed, :recursive, false)
          a = Keyword.get(parsed, :allow_hidden, false)
          d = Keyword.get(parsed, :allow_dir, false)

          flags = [ recursive: r, allow_hidden: a, allow_dir: d ]
          %AF.Folder{folder: folder, command: command, args: args, flags: flags}
        _ -> nil
      end
      
    end
    |> Enum.reject(&is_nil/1)
  end

  def default_path() do
    System.user_home! |> Path.join(".act")
  end

  def parse_default() do
    p = default_path()
    
    unless File.exists? p do
      File.touch!(p)
    end
    
    parse_file(p)
  end

end
