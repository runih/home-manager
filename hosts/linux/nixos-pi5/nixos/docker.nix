{ ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      #storageDriver = "ext4";
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
    oci-containers = {
      backend = "docker";
    };
  };
}

