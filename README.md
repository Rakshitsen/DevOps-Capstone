# DevOps-Capstone

# 🚀 DevOps CI/CD Project: Kubernetes Deployment with Jenkins, Docker, Terraform & Ansible

This project demonstrates a complete end-to-end CI/CD pipeline using industry-standard DevOps tools to deploy a containerized application on a Kubernetes cluster — fully automated from infrastructure provisioning to live app deployment.

---

## 🧰 Tech Stack

- **Version Control**: Git + GitHub  
- **CI/CD**: Jenkins (Pipeline Jobs)  
- **Containerization**: Docker  
- **Orchestration**: Kubernetes  
- **Infrastructure as Code**: Terraform  
- **Configuration Management**: Ansible  
- **Cloud Provider**: AWS EC2

---

## 🏗️ Infrastructure Overview

Provisioned using **Terraform**:
- A VPC with 2 public subnets across different availability zones
- 4 EC2 Instances:
  - Jenkins Master (CI/CD Server)
  - Jenkins Slave + K8s Master Node
  - 2 Kubernetes Worker Nodes
- Internet Gateway, Route Table, Security Groups

Configured using **Ansible**:
- Installed and configured Jenkins, Docker, Kubernetes (Master + Worker nodes)

---

## 🔁 CI/CD Workflow

### ✅ CI Pipeline (`ci-pipeline.groovy`)
- Triggered by GitHub webhook
- Clones repo → builds Docker image → tags it with `BUILD_NUMBER`
- Pushes image to DockerHub
- Runs test container on port 85
- If successful → triggers CD pipeline

### 🚀 CD Pipeline (`cd-pipeline.groovy`)
- Triggered by CI pipeline
- Replaces image tag in `deployment.yaml`
- Deploys to Kubernetes via `kubectl apply`
- Exposes app via NodePort Service

---

## 📁 Folder Structure
├── terraform/ # EC2 Infra provisioning
├── ansible/ # Jenkins + K8s setup
├── jenkins/ # Pipeline groovy files
│ ├── ci-pipeline.groovy
│ └── cd-pipeline.groovy
├── k8s/ # K8s manifests
│ ├── deployment.yaml
│ └── service.yaml
├── Dockerfile # App Dockerfile
├── README.md # This file




## 👨‍💻 Author

**Rakshit Sen**  
🔗 GitHub: [github.com/rakshitsen](https://github.com/rakshitsen)  
🔗 LinkedIn: [linkedin.com/in/rakshitsen](https://linkedin.com/in/rakshitsen)

---

## ✅ What You’ll Learn

- Real-world CI/CD workflow using Jenkins
- Docker image versioning and testing
- Automated K8s deployments via pipeline
- Terraform + Ansible integration for cloud infra

---

##  Future Enhancements

- Add Ingress Controller with HTTPS
- Add Slack notifications on Jenkins builds

---




