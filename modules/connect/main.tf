resource "aws_connect_instance" "main" {
  instance_alias            = var.instance_alias  
  identity_management_type  = "CONNECT_MANAGED" # can be SAML or EXISTING_DIRECTORY as well
  inbound_calls_enabled     = true              #reqd
  outbound_calls_enabled    = true              #reqd
  contact_lens_enabled      = false
  contact_flow_logs_enabled = true # for keeping logs during and after deploy
}

resource "aws_connect_hours_of_operation" "tf_hrs" {
  name        = "Std Hours"
  instance_id = aws_connect_instance.main.id
  time_zone   = var.time_zone
  description = "Standard Hours of Operation"
  config { # can use a for_each loop here
    day = "MONDAY"
    start_time {
      hours   = 9
      minutes = 0
    }
    end_time {
      hours   = 17
      minutes = 0
    }
  }
  config {
    day = "TUESDAY"
    start_time {
      hours   = 9
      minutes = 0
    }
    end_time {
      hours   = 17
      minutes = 0
    }
  }
  config {
    day = "WEDNESDAY"
    start_time {
      hours   = 9
      minutes = 0
    }
    end_time {
      hours   = 17
      minutes = 0
    }
  }
  config {
    day = "THURSDAY"
    start_time {
      hours   = 9
      minutes = 0
    }
    end_time {
      hours   = 17
      minutes = 0
    }
  }
  config {
    day = "FRIDAY"
    start_time {
      hours   = 9
      minutes = 0
    }
    end_time {
      hours   = 17
      minutes = 0
    }
  }
}

resource "aws_connect_queue" "tf_queue" {
  name                  = var.queue_name
  instance_id           = aws_connect_instance.main.id
  hours_of_operation_id = aws_connect_hours_of_operation.tf_hrs.hours_of_operation_id
  description           = "Queue for Connect"
  max_contacts          = 5

}

resource "aws_connect_routing_profile" "tf_route" {
  name                      = "tf-route"
  description               = "First Routing Profile"
  default_outbound_queue_id = aws_connect_queue.tf_queue.queue_id
  media_concurrencies {
    channel     = "VOICE" # VOICE,CHAT,TASK
    concurrency = 1       # Capped to 1 for voice
  }
  instance_id = aws_connect_instance.main.id
  queue_configs {
    queue_id = aws_connect_queue.tf_queue.queue_id
    channel  = "VOICE" # Have separate entries if multiple channels exist
    priority = 1
    delay    = 0
  }
}