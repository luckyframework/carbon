module Carbon
  alias AttachFile = NamedTuple(file_path: String, file_name: String?, mime_type: String?)
  alias AttachIO = NamedTuple(io: IO, file_name: String, mime_type: String?)
  alias ResourceFile = NamedTuple(file_path: String, cid: String, file_name: String?, mime_type: String?)
  alias ResourceIO = NamedTuple(io: IO, cid: String, file_name: String, mime_type: String?)
  alias Attachment = AttachFile | AttachIO | ResourceFile | ResourceIO
end
