# CI/CD Pipeline for Containerized Application

This project is a demonstration of a modern CI/CD (Continuous Integration / Continuous Deployment) pipeline using GitHub Actions, Docker, and Node.js. 

It is designed as a portfolio piece for an **OCI Infrastructure Engineering** role, demonstrating the ability to take raw source code, test it, package it into an immutable container image, and push it to a secure registry.

## 🚀 Pipeline Flow Diagram

```mermaid
graph LR
    A[Developer Pushes Code] --> B(GitHub Repository)
    B --> C{GitHub Actions Triggered}
    
    subgraph CI [Continuous Integration]
    C --> D[Install Dependencies]
    D --> E[Run Automated Tests]
    end
    
    subgraph CD [Continuous Deployment Prep]
    E -->|If Tests Pass| F[Docker Build]
    F --> G[Tag Image with SHA & Latest]
    G --> H[Authenticate to Registry]
    H --> I[(GitHub Container Registry)]
    end
    
    I -.-> J[Ready for OCI Deployment (OKE/Instances)]
```

## 🛠️ Components

### 1. The Application
A simple Node.js Express API. It has two main endpoints:
* `/`: A root endpoint that returns a welcome message.
* `/health`: A standard health check endpoint that returns HTTP 200 and a JSON status. This is critical for cloud environments where load balancers or orchestrators (like Kubernetes) need to constantly verify if the container is healthy and ready to receive traffic.

### 2. Containerization (Docker)
The application is packaged using a `Dockerfile`.
* **Base Image**: We use `node:18-alpine` because it is incredibly lightweight and reduces our attack surface, which is a major security best practice.
* **Layer Caching**: We copy the `package.json` first and install dependencies, and *then* copy the rest of the application code. This means if we only change a line of code in `server.js`, Docker uses the cached dependency layer, making builds significantly faster.
* **Security**: We use the built-in `node` user instead of running the container as `root`.

### 3. The CI/CD Pipeline (GitHub Actions)
Located in `.github/workflows/ci-cd.yml`, this pipeline automatically triggers on every push to the `main` branch.
1. **CI Job**: Sets up Node.js, installs dependencies, and runs our tests. If this job fails, the pipeline stops immediately.
2. **CD Job**: Only runs if the CI job succeeds. It logs into the GitHub Container Registry (GHCR) using a securely injected `GITHUB_TOKEN`, builds the Docker image, tags it with the specific Git Commit SHA (and `latest`), and pushes it. Tagging with the Git SHA ensures every image is immutable and can be traced exactly back to the code that built it.

## ☁️ OCI Infrastructure Relevance (Why this matters)

For an **OCI (Oracle Cloud Infrastructure) Infrastructure Engineer**, the work doesn't stop at the code level. The pipeline built here is the crucial bridge between Development and Operations.

* **Immutable Infrastructure**: By containerizing the app, we guarantee that it will run exactly the same way on a developer's laptop as it does on a massive OCI Compute Instance.
* **Registry Integration**: This project pushes to GHCR, but the exact same mechanics apply to pushing to the **OCI Container Registry (OCIR)**.
* **Deployment Targets**: The final artifact of this pipeline (the Docker Image) is now ready to be pulled and run on OCI compute services. For example:
    * **OCI Container Instances**: A serverless way to quickly spin up this container.
    * **Oracle Container Engine for Kubernetes (OKE)**: A managed Kubernetes cluster that can pull this image and scale it to thousands of instances. The `/health` endpoint we built would be used by OKE's Liveness and Readiness probes.

## 💻 Local Testing Guide

If you have Docker installed on your machine, you can run this locally before pushing to GitHub.

1. **Build the image**:
   ```bash
   docker build -t my-node-app:local .
   ```
   *(This reads the Dockerfile, executes the instructions, and tags the resulting image as `my-node-app:local`)*

2. **Run the container**:
   ```bash
   docker run -p 8080:8080 my-node-app:local
   ```
   *(This starts the container and maps port 8080 on your host machine to port 8080 inside the container)*

3. **Verify**:
   Open a browser and navigate to `http://localhost:8080` or `http://localhost:8080/health`.

## 🔄 How to Trigger a Deployment

1. Make a change to the code (for example, edit the message in `server.js`).
2. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: updated welcome message"
   ```
3. Push to the `main` branch:
   ```bash
   git push origin main
   ```
4. Navigate to the **Actions** tab in your GitHub repository to watch the pipeline execute.
5. Once complete, navigate to the **Packages** section on the main page of your repository to see your published Docker image!
