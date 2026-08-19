
output "cluster_name" {
  value = aws_ecs_cluster.memos_cl.name
}

output "service_name" {
  value = aws_ecs_service.memos_service.name
}

output "task_definition_arn" {
  value = aws_ecs_task_definition.memos_task.arn
}
