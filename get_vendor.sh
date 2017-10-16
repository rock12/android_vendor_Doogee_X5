#!/bin/bash

SOURCE=$1
TARGET=.

#
# wifi and gsm firmware's
#
FIRMWARE="/etc/firmware/"

#
# wmt_loader init kernel device modules, and loades a driver for /dev/stpwmt, then
# 6620_launcher load a firmware to the CPU using /dev/stpwmt.
# mt6572_82_patch_e1_0_hdr.bin, mt6572_82_patch_e1_1_hdr.bin - wifi firmware.
#
WIFI="/etc/wifi/ /bin/6620_wmt_lpbk /bin/6620_launcher /bin/6620_wmt_concurrency /bin/wmt_loader"

# 
# gralloc && hwcomposer - hardware layer. rest is userspace lib.so layer.
#
GL="/lib/egl/libGLESv1_CM_mali.so /lib/egl/libGLESv2_mali.so /lib/egl/libEGL_mali.so \
/lib/libm4u.so /lib/hw/hwcomposer.mt6580.so /lib/hw/gralloc.mt6580.so \
/lib/libdpframework.so /lib/libion.so /lib/libMali.so"

#
# ccci_mdinit starts, depends on additional services:
# - drvbd - unix socket connection
# - nvram - folders /data/nvram, modem settings like IMEI
# - gsm0710muxd - /dev/radio/ ports for accessing the modem 
# - mdlogger
# - ccci_fsd
#
# ccci_mdinit loads modem_1_wg_n.img firmware to the CPU, waits for NVRAM to init using ENV variable.
# then starts the modem CPU. on success starts rest services mdlogger, gsm0710muxd ...
#
RIL="/lib/mtk-ril.so /lib/librilmtk.so /lib/libaed.so \
/bin/nvram_daemon /bin/nvram_agent_binder /lib/libnvram.so /lib/libcustom_nvram.so /lib/libnvram_sec.so \
/lib/libhwm.so /lib/libnvram_platform.so /lib/libfile_op.so /lib/libnvram_daemon_callback.so /lib/libmtk_drvb.so \
/bin/gsm0710muxd /bin/ccci_mdinit /bin/drvbd /bin/aee_aed /bin/aee /bin/mdlogger \
/bin/dualmdlogger /bin/emcsmdlogger /lib/libmdloggerrecycle.so /bin/ccci_fsd"

AUDIO="/lib/libaudio.primary.default.so /lib/libblisrc.so /lib/libspeech_enh_lib.so /lib/libaudiocustparam.so /lib/libaudiosetting.so \
/lib/libaudiocompensationfilter.so /lib/libbessound_mtk.so /lib/libcvsd_mtk.so /lib/libmsbc_mtk.so /lib/libaudiocomponentengine.so \
/lib/libblisrc32.so /lib/libbessound_hd_mtk.so /lib/libmtklimiter.so /lib/libmtkshifter.so /lib/libaudiodcrflt.so \
/lib/libbluetoothdrv.so"

SYSTEM="$FIRMWARE $WIFI $GL $RIL $AUDIO"

# get data from a device
if [ -z $SOURCE ]; then
  for FILE in $SYSTEM ; do
    T=$TARGET/$FILE
    adb pull /system/$FILE $T
  done
  exit 0
fi

# get data from folder
for FILE in $SYSTEM ; do
  S=$SOURCE/$FILE
  T=$TARGET/$FILE
  mkdir -p $(dirname $T) || exit 1
  rsync -av --delete $S $T || exit 1
done
exit 0

