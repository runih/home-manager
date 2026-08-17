{ pkgs, ... }:

{
  # intel_gpu_top needs CAP_PERFMON to read GPU engine busy stats; wrap it
  # instead of loosening perf_event_paranoid system-wide.
  security.wrappers.intel_gpu_top = {
    owner = "root";
    group = "root";
    capabilities = "cap_perfmon+ep";
    source = "${pkgs.intel-gpu-tools}/bin/intel_gpu_top";
  };
}
