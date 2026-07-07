### 1. Terraform & AWS (State Management)

**Scenario:** You are working in a team of 5 engineers. How do you manage Terraform state to ensure no two engineers apply changes simultaneously and that the state is secure and persistent?

> **Answer:** I’d use a remote S3 backend with native state locking (`use_lockfile = true`) as our single source of truth to safely prevent race conditions, while ensuring persistence and security via S3 versioning, encryption, and a least-privilege IAM policy limiting access to the CI/CD role; for example, if we are using Terraform, the configuration looks like this:

```hcl
 terraform {
   backend "s3" {
     bucket       = "my-fcmb-terraform-state"
     key          = "prod/terraform.tfstate"
     region       = "eu-west-1"
     encrypt      = true         # Encryption at rest
     use_lockfile = true         # Native S3 state locking (v1.10+)
   }
 } 

```

### 2. Kubernetes (Networking)

**Objective:** Explain the difference between a ClusterIP, NodePort, and LoadBalancer service type. In a production AWS environment using EKS, which is the preferred way to expose a web application to the public internet?

> **Answer:** The differences between the three Kubernetes service types are:
>
> - **ClusterIP**: Exposes the service on an internal IP address reachable only from within the Kubernetes cluster.
> - **NodePort**: Exposes the service on each node's IP address at a static port, allowing external traffic to hit the node directly.
> - **LoadBalancer**: Provisions an external cloud-native Load Balancer that routes traffic directly to the service.
>
> In a production AWS environment using EKS, the preferred method is to use an Ingress Controller, specifically the AWS Load Balancer Controller, combined with an Ingress Resource. This architecture is preferred because it consolidates traffic for multiple microservices behind a single Application Load Balancer, which significantly reduces cloud infrastructure costs compared to provisioning a dedicated Load Balancer for every single service. Furthermore, this approach enables advanced Layer 7 capabilities such as URL path-based routing, which allows you to direct traffic to different services based on the specific endpoint requested. Finally, it centralizes SSL/TLS termination at the load balancer, which prevents your application pods from wasting compute resources on encryption and decryption tasks.

### 3. ArgoCD (GitOps Strategy)

**Scenario:** You have a cluster where someone manually changed a deployment's replica count from 3 to 10 using kubectl. ArgoCD is configured for that app. What happens next, and how does "Self-Healing" vs. "Automated Pruning" play a role here?

> **Answer:** As soon as someone runs that scale command, ArgoCD is going to detect a drift between the live cluster state and the Git source of truth, immediately flagging the deployment as "OutOfSync." If I have Self-Healing enabled, ArgoCD will treat that manual `kubectl` change as a violation, automatically triggering a sync that overwrites the manual edit and forces the replica count back down to 3 to match the repository. Automated pruning isn't actually involved in this scenario, because pruning is specifically designed to delete resources that have been completely removed from Git, whereas here, the deployment still exists, it just has the wrong configuration.

### 4. Kafka (Scaling & Reliability)

**Objective:** If a Kafka consumer group is lagging significantly behind the producers, what are the three most effective ways to scale the consumption rate?

> **Answer:** If a consumer group is lagging, the first and most direct move is to increase the number of Kafka partitions and spin up additional consumer instances to match, because you are physically limited to having one active consumer per partition. If I’ve already hit that partition limit, I’d focus on optimizing the consumer code itself, perhaps by processing records in larger batches or introducing multithreading within the consumer to handle the throughput faster. Finally, I’d investigate if we have partition skew, where one consumer is stuck doing all the heavy lifting while others sit idle, which I’d resolve by changing our message keying strategy to ensure a more even distribution of data across all available consumers.

### 5. Helm (Templating)

**Scenario:** You need to deploy the same application to Dev, Staging, and Prod using a single Helm Chart. How do you manage environment-specific configurations like resource limits or ingress hostnames?

> **Answer:** I would handle this by creating separate environment-specific values files, such as `values-dev.yaml`, `values-staging.yaml`, and `values-prod.yaml`, to store the specific resource limits and hostnames unique to each environment. When I run the deployment command, I simply point Helm to the appropriate file using the `-f` flag, like `helm install my-app . -f values-prod.yaml`. This keeps the actual Helm chart templates completely generic and decoupled from the configuration, which follows the DRY principle and ensures we never have to modify the core chart logic just to update a simple environment variable.

### 6. GitHub Actions (Security)

**Objective:** How do you securely allow a GitHub Actions workflow to deploy resources to AWS without hardcoding long-lived AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY in GitHub Secrets?

> **Answer:** I would switch to OpenID Connect (OIDC) authentication, which is the best practice for eliminating long-lived credentials. I would configure an OIDC identity provider in AWS and create an IAM role with a trust policy that explicitly trusts my specific GitHub repository. Then, inside the GitHub Actions workflow, I would use the `aws-actions/configure-aws-credentials` action to assume that role, which provides a temporary, short-lived session token that expires automatically the moment the job finishes.

### 7. Kubernetes (Resource Management)

**Scenario:** An application in your cluster is intermittently crashing with an OOMKilled status, but the node still has plenty of free RAM. What is likely the cause?

> **Answer:** That happens because the Pod has a hard memory limit defined in its resource manifest, and Kubernetes enforces that limit strictly at the container level. Even if the underlying worker node has gigabytes of free RAM available, the kernel will immediately kill that container the moment it attempts to exceed its allocated `limit`. All I just need to do is check the Helm values or Deployment YAML, verify the memory usage patterns, and adjust the `resources.limits.memory` upward to accommodate the application's actual needs.

### 8. Terraform (Refactoring)

**Objective:** You have a monolithic Terraform file. You want to move the VPC logic into a reusable module. After moving the code, terraform plan shows it wants to destroy the existing VPC and recreate it. How do you fix this without downtime?

> **Answer:** The reason Terraform wants to destroy the VPC is because moving the code changed the resource's address in the state file, making Terraform think the old resource is gone and a new one is required. This can be solved without any downtime by using a `moved` block in the Terraform configuration, which explicitly maps the old resource address to the new module path. This updates the state file to reflect the new structure during the next plan, confirming the resource remains intact without triggering any destruction. Alternatively, I could use the `terraform state mv` command to manually update the state file, but the `moved` block is best practice because it keeps the migration logic directly in your codebase, therefore promoting visibility for the rest of the team.

```hcl
 moved {
   from = aws_vpc.main
   to   = module.vpc.aws_vpc.this
 }
```

### 9. Kafka & K8s (Storage)

**Scenario:** You are deploying a Kafka broker on Kubernetes. Which K8s object type would you use for the broker pods to ensure they maintain their identity and persistent storage across restarts?

> **Answer:** I would definitely go with a `StatefulSet` for Kafka brokers because, unlike a standard `Deployment` which gives pods random, ephemeral names, a `StatefulSet` provides each broker with a stable, predictable network identity like `kafka-0` or `kafka-1`, which is absolutely critical for maintaining reliable cluster membership. To handle the storage, I’d use `VolumeClaimTemplates` within that `StatefulSet`; this automatically provisions a unique, persistent volume for each specific broker instance, ensuring that if a pod restarts or moves to a new node, it instantly re-attaches to its original disk and retains all its local partition data.

### 10. CI/CD (Full Pipeline)

**Objective:** Describe the flow of a "Commit to Production" pipeline involving GitHub Actions and ArgoCD. Where does the CI end and the CD begin?

> **Answer:** The process begins when a developer pushes code to the repository, triggering a GitHub Actions workflow to handle the Continuous Integration phase. During this time, the runner executes unit tests, performs static analysis with SonarQube, runs Snyk container scans, and finally builds and pushes the new Docker image to your container registry. The Continuous Integration phase officially ends the moment that new image is successfully stored in the registry.
> The bridge between CI and CD occurs when the GitHub Actions workflow automatically commits an update to your separate Git manifest repository, changing the image tag in the Helm chart or Kubernetes YAML files to match the new version. Continuous Deployment begins the second ArgoCD detects that change in our manifest repository. ArgoCD, which is running as a controller inside our cluster, pulls the new manifest, compares it to the live state of the cluster, and executes the deployment to ensure the cluster matches your desired configuration. This shift to a pull-based model is what defines the CD portion of the process, as ArgoCD takes over the responsibility of orchestrating the rollout and maintaining state synchronization.

