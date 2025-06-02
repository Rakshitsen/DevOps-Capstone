output "K8s_ec2_private_ips" {
  value = aws_instance.K8s_ec2[*].private_ip
}

output "K8s_ec2_public_ips" {
  value = aws_instance.K8s_ec2[*].public_ip
}

output "jenkins_ec2_private_ips" {
  value = aws_instance.jenkins_ec2.private_ip
}

output "jenkins_ec2_public_ips" {
  value = aws_instance.jenkins_ec2.public_ip
}
