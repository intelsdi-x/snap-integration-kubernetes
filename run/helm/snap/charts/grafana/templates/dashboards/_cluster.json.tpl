{
	"dashboard": {
		"__inputs": [{
			"name": "snap",
			"label": "snap",
			"description": "",
			"type": "datasource",
			"pluginId": "influxdb",
			"pluginName": "InfluxDB"
		}],
		"__requires": [{
			"type": "grafana",
			"id": "grafana",
			"name": "Grafana",
			"version": "4.2.0-beta1"
		}, {
			"type": "panel",
			"id": "graph",
			"name": "Graph",
			"version": ""
		}, {
			"type": "datasource",
			"id": "influxdb",
			"name": "InfluxDB",
			"version": "1.0.0"
		}],
		"annotations": {
			"list": []
		},
		"editable": true,
		"gnetId": null,
		"graphTooltip": 0,
		"hideControls": false,
		"id": null,
		"links": [],
		"refresh": "1m",
		"rows": [{
			"collapse": false,
			"height": 250,
			"panels": [{
				"alert": {
					"conditions": [{
						"evaluator": {
							"params": [
							    {{ .Values.server.alerting.nodes.cpu_usage }}
							],
							"type": "gt"
						},
						"operator": {
							"type": "and"
						},
						"query": {
							"params": [
								"B",
								"5m",
								"now"
							]
						},
						"reducer": {
							"params": [],
							"type": "avg"
						},
						"type": "query"
					}],
					"executionErrorState": "alerting",
					"frequency": "60s",
					"handler": 1,
					"name": "CPU Usage by Node alert",
					"noDataState": "no_data",
					"notifications": []
				},
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 2,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $tag_node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1s"
						],
						"type": "time"
					}, {
						"params": [
							"node"
						],
						"type": "tag"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"measurement": "intel/docker/stats/cgroups/cpu_stats/cpu_usage/per_cpu/value",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}, {
							"params": [
								"1s"
							],
							"type": "derivative"
						}, {
							"params": [
								" / 10000000"
							],
							"type": "math"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}, {
					"alias": "",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1s"
						],
						"type": "time"
					}, {
						"params": [
							"node"
						],
						"type": "tag"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"hide": true,
					"measurement": "intel/docker/stats/cgroups/cpu_stats/cpu_usage/per_cpu/value",
					"policy": "default",
					"refId": "B",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}, {
							"params": [
								"1s"
							],
							"type": "derivative"
						}, {
							"params": [
								" / 10000000"
							],
							"type": "math"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [{
					"colorMode": "critical",
					"fill": true,
					"line": true,
					"op": "gt",
					"value": 90
				}],
				"timeFrom": null,
				"timeShift": null,
				"title": "CPU Usage by Node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "percent",
					"label": null,
					"logBase": 1,
					"max": "100",
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
			"collapse": false,
			"height": 250,
			"panels": [{
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 3,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1s"
						],
						"type": "time"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"measurement": "intel/docker/stats/cgroups/cpu_stats/cpu_usage/per_cpu/value",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}, {
							"params": [
								"1s"
							],
							"type": "derivative"
						}, {
							"params": [
								" / 10000000"
							],
							"type": "math"
						}]
					],
					"tags": [{
						"key": "node",
						"operator": "=~",
						"value": "/^$node$/"
					}, {
						"condition": "AND",
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [],
				"timeFrom": null,
				"timeShift": null,
				"title": "Individual CPU Usage: $node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "percent",
					"label": null,
					"logBase": 1,
					"max": "100",
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
			"collapse": false,
			"height": 250,
			"panels": [{
				"alert": {
					"conditions": [{
						"evaluator": {
							"params": [
                                                            {{ .Values.server.alerting.nodes.memory_usage }}
							],
							"type": "gt"
						},
						"operator": {
							"type": "and"
						},
						"query": {
							"params": [
								"B",
								"5m",
								"now"
							]
						},
						"reducer": {
							"params": [],
							"type": "avg"
						},
						"type": "query"
					}],
					"executionErrorState": "alerting",
					"frequency": "60s",
					"handler": 1,
					"message": "HI!!!",
					"name": "Memory Usage by Node alert",
					"noDataState": "no_data",
					"notifications": []
				},
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 6,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $tag_node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1m"
						],
						"type": "time"
					}, {
						"params": [
							"node"
						],
						"type": "tag"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"measurement": "intel/docker/stats/cgroups/memory_stats/usage/usage",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}, {
					"alias": "",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1m"
						],
						"type": "time"
					}, {
						"params": [
							"node"
						],
						"type": "tag"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"hide": true,
					"measurement": "intel/docker/stats/cgroups/memory_stats/usage/usage",
					"policy": "default",
					"refId": "B",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [{
					"colorMode": "critical",
					"fill": true,
					"line": true,
					"op": "gt",
					"value": 54532577904
				}],
				"timeFrom": null,
				"timeShift": null,
				"title": "Memory Usage by Node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "bytes",
					"label": null,
					"logBase": 1,
					"max": "70000000000",
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
			"collapse": false,
			"height": 250,
			"panels": [{
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 5,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1m"
						],
						"type": "time"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"measurement": "intel/docker/stats/cgroups/memory_stats/usage/usage",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "mean"
						}]
					],
					"tags": [{
						"key": "node",
						"operator": "=~",
						"value": "/^$node$/"
					}, {
						"condition": "AND",
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [],
				"timeFrom": null,
				"timeShift": null,
				"title": "Individual Memory Usage: $node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "bytes",
					"label": null,
					"logBase": 1,
					"max": "70000000000",
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
			"collapse": false,
			"height": 250,
			"panels": [{
				"alert": {
					"conditions": [{
						"evaluator": {
							"params": [
							    {{ .Values.server.alerting.nodes.filesystem_usage }}
							],
							"type": "gt"
						},
						"operator": {
							"type": "and"
						},
						"query": {
							"params": [
								"C",
								"5m",
								"now"
							]
						},
						"reducer": {
							"params": [],
							"type": "avg"
						},
						"type": "query"
					}],
					"executionErrorState": "alerting",
					"frequency": "60s",
					"handler": 1,
					"name": "Filesystem Usage by Node alert",
					"noDataState": "no_data",
					"notifications": []
				},
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 12,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $tag_node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"node"
						],
						"type": "tag"
					}],
					"measurement": "intel/docker/stats/filesystem/usage",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}, {
					"alias": "Limit $tag_node",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"node"
						],
						"type": "tag"
					}],
					"measurement": "intel/docker/stats/filesystem/available",
					"policy": "default",
					"refId": "B",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}, {
					"alias": "",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"node"
						],
						"type": "tag"
					}],
					"hide": true,
					"measurement": "intel/docker/stats/filesystem/usage",
					"policy": "default",
					"refId": "C",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}]
					],
					"tags": [{
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [{
					"colorMode": "critical",
					"fill": true,
					"line": true,
					"op": "gt",
					"value": 500000000000
				}],
				"timeFrom": null,
				"timeShift": null,
				"title": "Filesystem Usage by Node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "bytes",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
			"collapse": false,
			"height": 250,
			"panels": [{
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 13,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $node",
					"dsType": "influxdb",
					"groupBy": [],
					"measurement": "intel/docker/stats/filesystem/usage",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}]
					],
					"tags": [{
						"key": "node",
						"operator": "=~",
						"value": "/^$node$/"
					}, {
						"condition": "AND",
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}, {
					"alias": "Limit $node",
					"dsType": "influxdb",
					"groupBy": [],
					"measurement": "intel/docker/stats/filesystem/available",
					"policy": "default",
					"refId": "B",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}]
					],
					"tags": [{
						"key": "node",
						"operator": "=~",
						"value": "/^$node$/"
					}, {
						"condition": "AND",
						"key": "docker_id",
						"operator": "=",
						"value": "root"
					}]
				}],
				"thresholds": [],
				"timeFrom": null,
				"timeShift": null,
				"title": "Individual Filesystem Usage: $node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "bytes",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": "0",
					"show": true
				}, {
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		}, {
                        "collapse": false,
      			"height": 250,
      			"panels": [{
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 14,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
				"points": false,
				"renderer": "flot",
				"seriesOverrides": [],
				"span": 12,
				"stack": false,
				"steppedLine": false,
				"targets": [{
					"alias": "Usage $tag_mount_point",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"mount_point"
						],
						"type": "tag"
					}],
					"measurement": "intel/psutil/disk/percent",
					"policy": "default",
					"refId": "A",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
                  				}]
					],
					"tags": [{
						"key": "node",
						"operator": "=~",
						"value": "/^$node$/"
                			},
					{
						"condition": "AND",
						"key": "mount_point",
						"operator": "=~",
						"value": "/^\\/opt\\/disks.g*/"
					}]
            			}],
				"thresholds": [],
				"timeFrom": null,
				"timeShift": null,
				"title": "Individual Disk Usage Percent: $node",
				"tooltip": {
					"shared": true,
					"sort": 0,
					"value_type": "individual"
				},
				"type": "graph",
				"xaxis": {
					"mode": "time",
					"name": null,
					"show": true,
					"values": []
				},
				"yaxes": [{
					"format": "percent",
					"label": null,
					"logBase": 1,
					"max": "100",
					"min": null,
					"show": true
				},
				{
					"format": "short",
					"label": null,
					"logBase": 1,
					"max": null,
					"min": null,
					"show": true
				}]
			}],
			"repeat": null,
			"repeatIteration": null,
			"repeatRowId": null,
			"showTitle": false,
			"title": "Dashboard Row",
			"titleSize": "h6"
		},
		{
			"collapse": false,
			"height": 250,
			"panels": [{
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 15,
				"legend": {
					"avg": false,
					"current": false,
					"max": false,
					"min": false,
					"show": true,
					"total": false,
					"values": false
				},
				"lines": true,
				"linewidth": 1,
				"links": [],
				"nullPointMode": "null",
				"percentage": false,
				"pointradius": 5,
					"points": false,
					"renderer": "flot",
					"seriesOverrides": [],
					"span": 12,
					"stack": false,
					"steppedLine": false,
					"targets": [{
						"alias": "Total $tag_mount_point",
						"dsType": "influxdb",
						"groupBy": [{
							"params": [
								"mount_point"
							],
							"type": "tag"
						}],
						"measurement": "intel/psutil/disk/total",
						"policy": "default",
						"refId": "A",
						"resultFormat": "time_series",
						"select": [
							[{
								"params": [
									"value"
								],
								"type": "field"
							}]
						],
						"tags": [{
							"key": "node",
							"operator": "=~",
							"value": "/^$node$/"
						},
						{
							"condition": "AND",
							"key": "mount_point",
							"operator": "=~",
							"value": "/^\\/opt\\/disks.g*/"
                				}]
            				},
            				{
              					"alias": "Used $tag_mount_point",
              					"dsType": "influxdb",
              					"groupBy": [{
							"params": [
								"mount_point"
							],
							"type": "tag"
						}],
						"measurement": "intel/psutil/disk/used",
						"policy": "default",
						"refId": "B",
						"resultFormat": "time_series",
						"select": [
							[{
								"params": [
									"value"
								],
                    						"type": "field"
                  					}]
						],
              					"tags": [{
                  					"key": "node",
							"operator": "=~",
							"value": "/^$node$/"
						},
                				{
                  					"condition": "AND",
                  					"key": "mount_point",
                  					"operator": "=~",
                  					"value": "/^\\/opt\\/disks.g*/"
                				}]
            				}],
      					"thresholds": [],
        				"timeFrom": null,
          				"timeShift": null,
          				"title": "Individual Disks Capacity: $node",
          				"tooltip": {
           					"shared": true,
            					"sort": 0,
            					"value_type": "individual"
          				},
          				"type": "graph",
          				"xaxis": {
            					"mode": "time",
            					"name": null,
            					"show": true,
            					"values": []
          				},
          				"yaxes": [{
              					"format": "bytes",
             					"label": null,
              					"logBase": 1,
              					"max": "10000000000",
              					"min": "0",
              					"show": true
            				},
            				{
              					"format": "short",
              					"label": null,
              					"logBase": 1,
              					"max": null,
              					"min": null,
              					"show": true
            				}]
        			}],
      				"repeat": null,
      				"repeatIteration": null,
     				"repeatRowId": null,
      				"showTitle": false,
      				"title": "Dashboard Row",
     				"titleSize": "h6"
    			}],
		"schemaVersion": 14,
		"style": "dark",
		"tags": [],
		"templating": {
			"list": [{
				"allValue": null,
				"current": {},
				"datasource": "snap",
				"hide": 0,
				"includeAll": false,
				"label": null,
				"multi": false,
				"name": "node",
				"options": [],
				"query": "SHOW TAG VALUES WITH KEY = \"node\" ",
				"refresh": 1,
				"regex": "",
				"sort": 0,
				"tagValuesQuery": "",
				"tags": [],
				"tagsQuery": "",
				"type": "query",
				"useTags": false
			}]
		},
		"time": {
			"from": "now-30m",
			"to": "now"
		},
		"timepicker": {
			"refresh_intervals": [
				"5s",
				"10s",
				"30s",
				"1m",
				"5m",
				"15m",
				"30m",
				"1h",
				"2h",
				"1d"
			],
			"time_options": [
				"5m",
				"15m",
				"1h",
				"6h",
				"12h",
				"24h",
				"2d",
				"7d",
				"30d"
			]
		},
		"timezone": "browser",
		"title": "Cluster",
		"version": 60
	}
}
