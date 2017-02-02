---
max-failures: 10
schedule:
  interval: 5s
  type: simple
version: 1
workflow:
  collect:
    config:
      /intel/docker:
        procfs: /proc_host
    metrics:
      /intel/docker/*/spec/*: {}
      /intel/docker/*/stats/cgroups/cpu_stats/*: {}
      /intel/docker/*/stats/cgroups/memory_stats/*: {}
    publish:
    - plugin_name: file
      config:
        file: /tmp/snap-docker-file.log
