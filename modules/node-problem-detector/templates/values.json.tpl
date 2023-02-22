%{if length(custom_plugins) != 0~}
{
  %{ if length(image) != 0 ~}
  "image": {
    "repository": ${image.repository},
    "tag": ${image.tag},
  },
  %{ endif ~}
  "settings": {
    "custom_plugin_monitors": ${jsonencode(custom_plugins)},
    "custom_monitor_definitions": ${jsonencode(plugin_configs)}
  },
  "extraVolumeMounts": ${jsonencode(extra_volume_mounts)},
  "extraVolumes": ${jsonencode(extra_volumes)}
}
%{endif~}