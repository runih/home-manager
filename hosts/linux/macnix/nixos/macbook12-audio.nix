{ config, lib, pkgs, ... }:

let
  macbook12AudioDriver = config.boot.kernelPackages.callPackage
    ({ stdenv, fetchFromGitHub, kernel, python3 }:
      stdenv.mkDerivation {
        pname = "macbook12-audio-driver";
        version = "unstable-2025-07";

        src = fetchFromGitHub {
          owner = "juicecultus";
          repo = "macbook12-audio-driver";
          rev = "75884e2b685c8c4ca249f66e23b921d8f69a98f9";
          hash = "sha256-Q7dDjufgryonhiWsy0Fz5xveKtWwv/YAS4xitWhY0nM=";
        };

        nativeBuildInputs = kernel.moduleBuildDependencies ++ [ python3 ];

        buildPhase = ''
          mkdir -p build
          tar -xJf ${kernel.src} \
              --strip-components=2 \
              --directory=build/ \
              --wildcards 'linux-*/sound/hda'

          mv build/hda/codecs/cirrus/cs420x.c build/hda/codecs/cirrus/cs420x.c.orig
          cp patch_cirrus/cs420x.c \
             patch_cirrus/patch_cirrus_a1534_setup.h \
             patch_cirrus/patch_cirrus_a1534_pcm.h \
             build/hda/codecs/cirrus/

          sed -i 's/\.free/.remove/' build/hda/codecs/cirrus/patch_cirrus_a1534_pcm.h

          # On this codec (MacBook10,1, CS4208 SSID 106b:6600), pin 0x1d (the
          # physical speaker) is wired only to converter NID 0x0a (confirmed via
          # /proc/asound/card0/codec#0: "Node 0x1d ... Connection: 1  0x0a").
          # The upstream driver hardcodes NID 0x04 here (comment claims "0x04 is
          # for speakers"), which was reverse-engineered from a MacBook9,1 and
          # doesn't match this pin's actual wiring -- NID 0x04 has no pin
          # connected to it at all, so every prior playback attempt streamed
          # audio into a dead end while producing no errors. Point playback at
          # the NID that's actually wired to the speaker.
          sed -i 's/info->stream\[SNDRV_PCM_STREAM_PLAYBACK\]\.nid = 0x04;.*/info->stream[SNDRV_PCM_STREAM_PLAYBACK].nid = 0x0a; \/\/ speaker pin 0x1d is wired only to NID 0x0a on this codec/' build/hda/codecs/cirrus/patch_cirrus_a1534_pcm.h

          python3 << 'PYEOF'
import re

with open('build/hda/codecs/cirrus/patch_cirrus_a1534_pcm.h', 'r') as f:
    src = f.read()

# The HDA framework caches the ops pointer before calling probe, so the
# cs_4208_patch_ops_explicit build_pcms/init functions are never reached.
# Instead, snd_hda_gen_build_pcms builds the PCM from autoconfig: the
# speaker pin 0x1d connects only to NID 0x0a (I2S), so hinfo->nid = 0x0a
# in the generic prepare.
#
# The generic prepare calls:
#   snd_hda_codec_setup_stream(codec, 0x0a, stream_tag, 0, format)
# which writes DIGI_CONVERT_1 from the SPDIF ctls cache (value = 0x01).
# This CLEARS bit 4 -- which is CS4208-vendor-specific and gates I2S data
# to the SSM3515 amplifier.  play_a1534() (called from the hook's OPEN
# action) had previously set DIGI_CONVERT_1 = 0x11 (bit 4 = 1 = I2S gate
# open), so the setup_stream call silences the speakers on every prepare.
#
# spec->gen.pcm_playback_hook (= cs_4208_playback_pcm_hook) IS called by the
# generic prepare, at HDA_GEN_PCM_ACT_PREPARE, immediately after
# setup_stream.  Its PREPARE action currently only logs.  Patch it to
# restore the two registers setup_stream clobbers:
#   - DIGI_CONVERT_1 = 0x11  (re-open the I2S gate)
#   - STREAM_FORMAT  = 0x4013 (44.1kHz, 16-bit, 4-channel I2S framing as
#                              expected by the SSM3515 slot mapping)
# CHANNEL_STREAMID on NID 0x0a is already correct -- setup_stream set it
# to the actual DMA stream tag, which is what we want.
src, n1 = re.subn(
    r'(\t+)(codec_dbg\(codec, "cs_4208_playback_pcm_hook HDA_GEN_PCM_ACT_PREPARE end"\);)',
    r'\1snd_hda_codec_write(codec, 0x0a, 0, AC_VERB_SET_DIGI_CONVERT_1, 0x11);\n'
    r'\1snd_hda_codec_write(codec, 0x0a, 0, AC_VERB_SET_STREAM_FORMAT, 0x4013);\n'
    r'\1\2',
    src
)
assert n1 == 1, f"hook PREPARE: expected 1 match, got {n1}"

# cs_4208_init_explicit is the .init callback in cs_4208_patch_ops_explicit.
# Due to the ops caching issue, the generic cs_init runs instead, but this
# patch is kept for correctness if the custom ops path is ever activated.
# After every D3->D0 power cycle the HDA controller calls .init; without
# play_a1534() the codec resets (GPIO0=0, SSM3515 disabled, NID 0x0a stream
# tag cleared).
src, n2 = re.subn(
    r'(\tcodec_dbg\(codec, "cs_4208_init_explicit end"\);)',
    r'\tplay_a1534(codec);\n\1',
    src
)
assert n2 == 1, f"cs_4208_init_explicit: expected 1 match, got {n2}"

with open('build/hda/codecs/cirrus/patch_cirrus_a1534_pcm.h', 'w') as f:
    f.write(src)
print("Patched patch_cirrus_a1534_pcm.h OK")
PYEOF

          cp patch_cirrus/Makefile_cs420x build/hda/codecs/cirrus/Makefile

          make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
              M=$(pwd)/build/hda/codecs/cirrus \
              modules
        '';

        installPhase = ''
          install -Dm644 build/hda/codecs/cirrus/snd-hda-codec-cs420x.ko \
              $out/lib/modules/${kernel.modDirVersion}/extra/snd-hda-codec-cs420x.ko
        '';
      }) {};

  # NixOS's depmod only processes modules listed in modules.order, which is
  # symlinked from the in-tree kernel and doesn't include extra/.  The patched
  # module therefore never appears in modules.dep and the unpatched in-tree
  # version loads instead.  Work around this by intercepting the load via an
  # install directive that insmod's the patched .ko directly.
  loadPatchedCs420x = pkgs.writeShellScript "load-cs420x-patched" ''
    set -e
    ${pkgs.kmod}/bin/modprobe --ignore-install snd-hda-core   || true
    ${pkgs.kmod}/bin/modprobe --ignore-install snd-hda-codec  || true
    ${pkgs.kmod}/bin/modprobe --ignore-install snd-hda-codec-generic || true
    exec ${pkgs.kmod}/bin/insmod \
      ${macbook12AudioDriver}/lib/modules/${config.boot.kernelPackages.kernel.modDirVersion}/extra/snd-hda-codec-cs420x.ko
  '';
in
{
  boot.extraModulePackages = [ macbook12AudioDriver ];

  boot.extraModprobeConfig = ''
    install snd_hda_codec_cs420x ${loadPatchedCs420x}
  '';
}
