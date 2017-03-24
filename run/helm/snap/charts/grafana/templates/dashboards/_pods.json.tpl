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
			"version": "4.1.2"
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
		"refresh": "5s",
		"rows": [{
			"collapse": false,
			"height": "250px",
			"panels": [{
				"alert": {
					"conditions": [{
						"evaluator": {
							"params": [
	                                                     {{ .Values.server.alerting.pods.cpu_usage }}
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
					"name": "Individual CPU Usage",
					"noDataState": "no_data",
					"notifications": []
				},
				"aliasColors": {},
				"bars": false,
				"datasource": "snap",
				"fill": 0,
				"id": 1,
				"interval": "",
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
					"alias": "CPU Usage $namespace $podname",
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
					"interval": "",
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
							"type": "max"
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
						"key": "io.kubernetes.pod.name",
						"operator": "=~",
						"value": "/^$podname$/"
					}, {
						"condition": "AND",
						"key": "io.kubernetes.pod.namespace",
						"operator": "=~",
						"value": "/^$namespace$/"
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
							"io.kubernetes.pod.name"
						],
						"type": "tag"
					}, {
						"params": [
							"null"
						],
						"type": "fill"
					}],
					"hide": true,
					"interval": "",
					"measurement": "intel/docker/stats/cgroups/cpu_stats/cpu_usage/per_cpu/value",
					"policy": "default",
					"refId": "C",
					"resultFormat": "time_series",
					"select": [
						[{
							"params": [
								"value"
							],
							"type": "field"
						}, {
							"params": [],
							"type": "max"
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
					"tags": []
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
				"title": "Individual CPU Usage: $namespace $podname",
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
							    {{ .Values.server.alerting.pods.memory_usage }}
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
					"name": "Individual Memory Usage aler",
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
					"alias": "Memory Usage $namespace $podname",
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
						"key": "io.kubernetes.pod.name",
						"operator": "=~",
						"value": "/^$podname$/"
					}, {
						"condition": "AND",
						"key": "io.kubernetes.pod.namespace",
						"operator": "=~",
						"value": "/^$namespace$/"
					}]
				}, {
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"1m"
						],
						"type": "time"
					}, {
						"params": [
							"io.kubernetes.pod.name"
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
					"tags": []
				}],
				"thresholds": [{
					"colorMode": "critical",
					"fill": true,
					"line": true,
					"op": "gt",
					"value": 20000000000
				}],
				"timeFrom": null,
				"timeShift": null,
				"title": "Individual Memory Usage: $namespace $podname",
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
					"max": "20000000000",
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
							     {{ .Values.server.alerting.pods.filesystem_usage }}
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
					"name": "Filesystem Usage alert",
					"noDataState": "no_data",
					"notifications": []
				},
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
					"alias": "Usage $namespace $podname",
					"dsType": "influxdb",
					"groupBy": [],
					"measurement": "intel/docker/stats/filesystem/usage",
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
						"key": "io.kubernetes.pod.name",
						"operator": "=~",
						"value": "/^$podname$/"
					}, {
						"condition": "AND",
						"key": "io.kubernetes.pod.namespace",
						"operator": "=~",
						"value": "/^$namespace$/"
					}]
				}, {
					"alias": "Limit $namespace $podname",
					"dsType": "influxdb",
					"groupBy": [],
					"measurement": "intel/docker/stats/filesystem/available",
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
						"key": "io.kubernetes.pod.name",
						"operator": "=~",
						"value": "/^$podname$/"
					}, {
						"condition": "AND",
						"key": "io.kubernetes.pod.namespace",
						"operator": "=~",
						"value": "/^$namespace$/"
					}]
				}, {
					"alias": "",
					"dsType": "influxdb",
					"groupBy": [{
						"params": [
							"io.kubernetes.pod.name"
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
					"tags": []
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
				"title": "Filesystem Usage: $namespace $podname",
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
				"name": "namespace",
				"options": [],
				"query": "SHOW TAG VALUES WITH KEY = \"io.kubernetes.pod.namespace\"",
				"refresh": 1,
				"regex": "",
				"sort": 0,
				"tagValuesQuery": "",
				"tags": [],
				"tagsQuery": "",
				"type": "query",
				"useTags": false
			}, {
				"allValue": null,
				"current": {},
				"datasource": "snap",
				"hide": 0,
				"includeAll": false,
				"label": null,
				"multi": false,
				"name": "podname",
				"options": [],
				"query": "SHOW TAG VALUES WITH KEY = \"io.kubernetes.pod.name\"",
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
			"from": "now-6h",
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
		"title": "Pods",
		"version": 0
	}
}
