#!/bin/sh
set -e
exec /opt/jre/bin/java -XX:+UseCompactObjectHeaders -XX:SoftMaxHeapSize=386M --enable-native-access=ALL-UNNAMED -Djdk.attach.allowAttachSelf=true -Dsun.net.useExclusiveBind=false -Dpbh.release=docker -Djava.awt.headless=true -XX:+UseG1GC -XX:G1PeriodicGCInterval=60000 -XX:MaxHeapFreeRatio=15 -XX:MinHeapFreeRatio=5 -Xss512k -XX:+UseStringDeduplication -XX:-ShrinkHeapInSteps -XX:MaxRAMPercentage=85.0 -jar PeerBanHelper.jar
