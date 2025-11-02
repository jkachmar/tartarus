{ ... }:

{
  # Common users & groups for a bunch of my NixOS systems.
  #
  # XXX: This is exactly the sort of thing that a tool like 'kanidm' should
  # handle...
  users.groups.media.gid = 1010;
  users.groups.downloads.gid = 1020;
}
