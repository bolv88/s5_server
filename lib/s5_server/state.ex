defmodule S5Server.State do
  @drive Access
  defstruct super_id: nil, socket: nil, client: nil, server: nil, number: 0
end

