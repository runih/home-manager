{ ... }:

{
  # Runtime tuning for this host's server-ish workload (kea DHCP, docker, a
  # Minecraft JVM, btrfs snapshots on NVMe). The kernel itself is the Raspberry
  # Pi vendor fork's general-purpose config — none of this needs a recompile.

  # zram: compressed RAM swap, used *before* the on-disk btrfs swapfile.
  # NixOS gives zram priority 5; the /swap/swapfile from hardware-configuration.nix
  # keeps its default (negative) priority and only takes overflow once zram is full.
  # ~50% of 8 GiB RAM as zstd-compressed swap (real capacity is higher after
  # compression), so the JVM heap can be pushed to cheap RAM-backed swap under
  # page-cache pressure instead of the kernel dropping useful cache or hitting NVMe.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  boot.kernel.sysctl = {
    # Stock desktop default is 60. Bias toward keeping anonymous memory (the
    # Minecraft heap) resident, but still allow swapping to zram under real
    # pressure. Raise toward 100+ if you want to lean harder on zram.
    "vm.swappiness" = 20;

    # Keep the btrfs inode/dentry cache around longer (default 100 = reclaim it
    # as eagerly as page cache). Helps the snapshot/subvolume-heavy workload.
    "vm.vfs_cache_pressure" = 50;

    # Smaller writeback batches (defaults 10/20) so bursty writes to the NVMe
    # flush more smoothly instead of stalling everything at the hard limit.
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_ratio" = 15;
  };
}
