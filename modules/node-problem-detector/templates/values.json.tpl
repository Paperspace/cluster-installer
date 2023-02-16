%{if length(custom_plugins) != 0}
{
  "settings": {
    "custom_plugin_monitors": ${jsonencode(custom_plugins)},
    "custom_monitor_definitions": ${jsonencode(plugin_configs)}
  }
}
%{endif}