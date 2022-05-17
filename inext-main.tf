resource "inext_kubernetes_profile" "appsec-k8s-profile" {
  name                      = "AKS Terraform Profile"
  profile_sub_type          = "AppSec"
  max_number_of_agents      = 100
}

resource "inext_web_app_asset" "aks-terraform-juiceshop" {
  name            = "app-aks-terraform-juiceshop"
  profiles        = [inext_kubernetes_profile.appsec-k8s-profile.id]
  urls            = ["http://juiceshop-protected.${azurerm_dns_zone.mydns-public-zone.name}"]

  practice {
    main_mode = "Learn" # enum of ["Prevent", "Inactive", "Disabled", "Learn"]
    sub_practices_modes = {
      IPS    = "AccordingToPractice" # enum of ["Detect", "Prevent", "Inactive", "AccordingToPractice", "Disabled", "Learn", "Active"]
      WebBot = "Disabled" # enum of ["Detect", "Prevent", "Inactive", "AccordingToPractice", "Disabled", "Learn", "Active"]
      Snort  = "Disabled"            # enum of ["Detect", "Prevent", "Inactive", "AccordingToPractice", "Disabled", "Learn", "Active"]
    }
    id         = inext_web_app_practice.my-webapp-practice.id # required
    triggers   = [inext_log_trigger.my-webapp-trigger.id]
  }

  source_identifier {
    identifier = "SourceIP" # enum of ["SourceIP", "XForwardedFor", "HeaderKey", "Cookie"]
  }
}

resource "inext_log_trigger" "my-webapp-trigger" {
  name                             = "AKS Log Trigger"
  access_control_allow_events      = false
  access_control_drop_events       = true
  threat_prevention_detect_events  = true
  threat_prevention_prevent_events = true
  web_body                         = false
  web_headers                      = false
  web_requests                     = false
  web_url_path                     = true
  web_url_query                    = true
  response_body                    = false
  response_code                    = true
  extend_logging                   = true
  extend_logging_min_severity      = "Critical" # enum of ["High", "Critical"]
  log_to_agent                     = false
  log_to_cef                       = false
  log_to_cloud                     = true
  log_to_syslog                    = false
  verbosity                        = "Standard" # enum of ["Minimal", "Standard", "Extended"]
}

resource "inext_web_app_practice" "my-webapp-practice" {
  name = "EU Fog Web Protection"
  ips {
    performance_impact    = "MediumOrLower"    # enum of ["VeryLow", "LowOrLower", "MediumOrLower", "HighOrLower"]
    severity_level        = "MediumOrAbove" # enum of ["LowOrAbove", "MediumOrAbove", "HighOrAbove", "Critical"]
    protections_from_year = "2016"       # enum of ["1999", "2010", "2011", "2012", "2013", "2014", "2015", "2016", "2017", "2018", "2019", "2020"] Note! need to add Y at the beginning for mgmt
    high_confidence       = "Prevent"     # enum of ["Detect", "Prevent", "Inactive"]
    medium_confidence     = "Prevent"     # enum of ["Detect", "Prevent", "Inactive"]
    low_confidence        = "Detect"     # enum of ["Detect", "Prevent", "Inactive"]
  }
  web_attacks {
    minimum_severity = "High" # enum of ["Critical", "High", "Medium"]
    advanced_setting {
      csrf_protection      = "Prevent"             # enum of ["Disabled", "Learn", "Prevent", "AccordingToPractice"]
      open_redirect        = "Disabled"            # enum of ["Disabled", "Learn", "Prevent", "AccordingToPractice"]
      error_disclosure     = "AccordingToPractice" # enum of ["Disabled", "Learn", "Prevent", "AccordingToPractice"]
      body_size            = 1000000
      url_size             = 32768
      header_size          = 102400
      max_object_depth     = 100
      illegal_http_methods = false
    }
  }
}
