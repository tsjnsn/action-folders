defmodule AF.Config.Folder do
  defstruct folder: "", command: "", flags: []
end

#defmodule AF.Config do
#  defstruct folders: []
#end

defmodule AF.Config do

  def parse_file(filename) do
    dir = Path.dirname(filename)

    filename
    |> read_in
    |> String.split("\n")
    |> convert_lines_to_structs(dir)
  end

  def read_in(filename) do
    {:ok, confstr} = File.read filename
    confstr
  end

  def convert_lines_to_structs(rawconf, relative_to) do
    
    parse_opts = [
      strict: [
        folder: :string,
        command: :string,
        recursive: :boolean,
        allow_hidden: :boolean,
        allow_dir: :boolean
      ],
      aliases: [
        f: :folder,
        c: :command,
        r: :recursive,
        a: :allow_hidden,
        d: :allow_dir
      ]
    ]
    
    for line <- rawconf do
      { parsed, argv, errors } = OptionParser.parse(OptionParser.split(line), parse_opts)
     
      case argv do
        [ "watch" ] ->
          folder = Keyword.fetch!(parsed, :folder) |> Path.expand(relative_to)
          command = Keyword.fetch!(parsed, :command)
          r = Keyword.get(parsed, :recursive, false)
          a = Keyword.get(parsed, :allow_hidden, false)
          d = Keyword.get(parsed, :allow_dir, false)
          flags = [ recursive: r, allow_hidden: a, allow_dir: d ]
          %AF.Config.Folder{folder: folder, command: command, flags: flags}
        _ -> nil
      end
      
    end
    |> Enum.filter(&(!is_nil(&1)))
  end

  def default_path() do
    home = System.user_home!()
    Path.join(home, ".act")
  end

  def parse_default() do
    p = default_path()
    
    unless File.exists? p do
      File.touch!(p)
    end
    
    parse_file(p)
  end

end
