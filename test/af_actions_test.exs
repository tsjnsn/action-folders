defmodule AF.ActionsTest do
  use ExUnit.Case
  
  @base_folder "ActionFoldersTestDir"
  @sample_script Path.expand("#{@base_folder}/sample script.exs")
  @sample_script_relative "#{@base_folder}/sample script.exs"
  @sample_file "#{@base_folder}/sample.file"
  
  test "can call an action" do
    # call action on file
    # check if file was changed appropriately
    assert {:ok, _} = AF.Actions.act_on_file(@sample_script, @sample_file)
  end
  
  test "can call an action on relatively path'd script" do
    # call action on file
    # check if file was changed appropriately
    assert {:ok, _} = AF.Actions.act_on_file(@sample_script_relative, @sample_file)
  end
  
  # test "cannot call an action on a non-executable" do
  #   assert {:error, _} = Actions.act_on_file(Path.expand("./ActionFoldersTestDir/sample script non-exec.exs"), [Path.expand("./ActionFoldersTestDir/sample.file")])
  # end
  
end
