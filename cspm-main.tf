# Create a dedicated Org-unit under the root one
resource "dome9_organizational_unit" "my-org-unit" {
  name      = var.cspm-org-unit
}

resource "dome9_cloudaccount_kubernetes" "cspm-cluster" {
  name = var.k8s-cluster-name
  organizational_unit_id = dome9_organizational_unit.my-org-unit.id

  image_assurance {
    enabled = true
  }
  admission_control {
    enabled = true
  }
}

# Create a new Notification Policy
resource "dome9_continuous_compliance_notification" "cspm-cluster-notification" {
  name           = "mail-${var.k8s-cluster-name}"
  description    = "Send mail to ${var.cspm-mail} - Built and maintained with Terraform"
  alerts_console = true

  change_detection {
    email_sending_state = "Disabled"
  }
  scheduled_report {
    email_sending_state = "Enabled"

    schedule_data {
      cron_expression = "0 0 12 * * ?"
      type            = "Summary"
      recipients      = ["${var.cspm-mail}"]
    } 
  }
}

# Create a new Continuous Policy with Kubernetes NIST.SP.800-190
resource "dome9_continuous_compliance_policy" "cspm-cluster-policy" {
  target_id    = dome9_cloudaccount_kubernetes.cspm-cluster.id
  ruleset_id   = -52
  target_type  = "Kubernetes"
  notification_ids = ["${dome9_continuous_compliance_notification.cspm-cluster-notification.id}"]
}

# Create a new IA Policy with Container Image Assurance 1.0 with Control on Deployed Images
resource "dome9_image_assurance_policy" "ia-cluster-policy" {
  target_id    = dome9_cloudaccount_kubernetes.cspm-cluster.id
  ruleset_id   = -2002
  target_type  = "Environment"
  admission_control_action            = "Detection"
  admission_control_unscanned_action  = "Detection"
  notification_ids    = ["${dome9_continuous_compliance_notification.cspm-cluster-notification.id}"]
}