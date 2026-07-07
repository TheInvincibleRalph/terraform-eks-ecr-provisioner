output "repository_arn" {
  description = "ARN of the ECR repository."
  value       = aws_ecr_repository.image_repo.arn
}

output "repository_url" {
  description = "URL of the ECR repository."
  value       = aws_ecr_repository.image_repo.repository_url
}

output "repository_name" {
  description = "Name of the ECR repository."
  value       = aws_ecr_repository.image_repo.name
}

output "registry_id" {
  description = "Registry ID of the ECR repository."
  value       = aws_ecr_repository.image_repo.registry_id
}
