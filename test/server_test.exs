defmodule AF.ServerTest do
  use ExUnit.Case, async: true
  
  setup do
    {:ok, actserv} = GenServer.start_link(AF.Server, [])
    {:ok, actserv: actserv}
  end
  
  @base_folder          "ActionFoldersTestDir"
  @folder_with_act      "#{@base_folder}/testfolder.act"
  @deep_folder_with_act "#{@base_folder}/testfolder.act/subfolder-no-act/subsubfolder-with-act"
  @deep_folder_no_act   "#{@base_folder}/testfolder.act/subfolder-no-act"
  @nonexistant_folder   "#{@base_folder}/this/should/not/exist!"
  @sample_file          "#{@base_folder}/sample.file"
  
  test "can watch new folder", %{actserv: actserv} do
    assert @base_folder = AF.Server.watch(actserv, @base_folder, "echo")
  end
  
  test "can get the list of folders being watched", %{actserv: actserv} do
    assert @base_folder = AF.Server.watch(actserv, @base_folder, "echo")
    
    action_folders = AF.Server.list_action_folders(actserv)
    assert is_list action_folders
    assert @base_folder in (action_folders |> Enum.map(&Map.fetch!(&1,:folder)))
  end
  
  #test "can get the list of folders which have actions (recursive)", %{actserv: actserv} do
  #  assert @base_folder = AF.Server.watch(actserv, @base_folder, "echo", true)
  #      
  #  folder = %AF.Folder{folder: @base_folder, flags: [recursive: true]}
  #  action_folders = AF.Server.list_action_folders(folder)
  #  assert is_list action_folders
  #  assert @deep_folder_with_act in action_folders
  #end
end
