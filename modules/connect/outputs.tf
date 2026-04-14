output "connect_instance_id" {
  value = aws_connect_instance.main.id
}

output "connect_instance_arn" {
  value = aws_connect_instance.main.arn
}

output "connect_queue_id" {
  value = aws_connect_queue.tf_queue.queue_id
}

output "connect_hours_of_operation_id" {
  value = aws_connect_hours_of_operation.tf_hrs.hours_of_operation_id
}

output "connect_routing_profile_id" {
  value = aws_connect_routing_profile.tf_route.routing_profile_id
}