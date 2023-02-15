%{if length(custom_plugins) != 0~}
settings:
  custom_plugins: ${jsonencode(keys(custom_plugins))}
  custom_plugin_monitors:
    %{for name, config in custom_plugins~}
    "${name}": |-
        ${jsonencode(config)}
    %{endfor~}
%{endif~}