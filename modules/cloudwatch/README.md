# CloudWatch module

Creates map-driven CloudWatch log groups with retention and optional KMS encryption, metric filters, metric alarms, composite alarms, dashboards, and optional SNS topics. Metrics, namespaces, dimensions, thresholds, periods, statistics, comparison operators, and action ARNs are supplied by the consumer.

Alarm maps may reference module-created SNS topics using `alarm_topic_keys` or use existing notification ARNs with `alarm_actions`, `ok_actions`, and `insufficient_data_actions`. Dashboard bodies are supplied as consumer-generated JSON strings.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->

## Purpose

Provides reusable CloudWatch observability resources.

## Features

Log groups, retention, KMS encryption, metric filters, metric alarms, composite alarms, dashboards, and optional SNS topics.

## Requirements

Terraform `>= 1.6.0`; AWS provider `>= 5.0`.

## Providers

`hashicorp/aws`.

## Inputs

Provide map-driven log groups, alarms, composites, dashboards, filters, and SNS topics with consumer-defined metrics, namespaces, dimensions, thresholds, and actions.

## Outputs

Log group ARNs, metric/composite alarm ARNs, dashboard ARNs, and SNS topic ARNs.

## Usage

```hcl
module "cloudwatch" {
	source = "git::https://github.com/<organization>/terraform-env-modules.git//modules/cloudwatch?ref=v1.0.0"
	log_groups = var.log_groups
	alarms = var.alarms
	dashboards = var.dashboards
	environment = var.environment
	project = var.project
	owner = var.owner
}
```

## Dependencies

SNS topics, dashboards, and notification destinations may be consumer-managed or created through this module.

## Security considerations

Use KMS keys for sensitive logs and narrow alarm action permissions. Do not place credentials or secret values in metric patterns or dashboard bodies.
