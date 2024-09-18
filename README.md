# go-web-app
Go lang application deploying in kubernetes


# Go Web Application

This is a simple website written in Golang. It uses the `net/http` package to serve HTTP requests.

## Running the server

To run the server, execute the following command:

```bash
go run main.go
```

The server will start on port 8080. You can access it by navigating to `http://localhost:8080/courses` in your web browser.

## Looks like this

![Website](static/images/golang-website.png)

## Flux CD Theory

## Flux Control Loop and Controllers
	• A control loop in Kubernetes is a process that keeps checking the state of your cluster and makes changes to match the desired setup.
	• In Flux, controllers are these control loops. They watch the cluster and adjust things to match what you want.
## Custom Resource
	• A custom resource lets you add new features to Kubernetes.
	• Developers can create their own resources using Custom Resource Definitions (CRDs).
	• A controller can manage these custom resources, making Kubernetes more flexible.
## Operator Pattern
	• An Operator is a combination of a custom resource and a controller.
	• The custom resource defines what you want, and the controller works to keep it that way.
	• Operators often run as pods in your cluster and have the necessary permissions (using ClusterRole and ClusterRoleBinding) to make changes.
## Kustomize-controller (in FluxCD)
	• The Kustomize-controller is a special operator in FluxCD.
	• It looks for a custom resource called Kustomization.
	• The Kustomization resource tells it what the desired state of the cluster is (using Kubernetes manifests), and the controller applies those changes.
## Key Terms
	• Kustomize and kustomization.yml are part of Kubernetes.
	• Kustomize-controller and Kustomization custom resource are part of FluxCD.
## Kustomize (in Kubernetes)
	• Kustomize helps you modify Kubernetes resources without directly changing the original files.
	• It’s useful when managing different environments (like development, staging, and production).
	• Kustomization.yml is the file Kustomize uses to know what resources to modify.
## kustomization.yml
	• kustomization.yml is a file that lists which resources Kustomize should work with.
	• It can add labels, make changes to certain fields, and create variations for different environments.
## Patching in Kustomize and FluxCD
	• Patching lets you modify part of an existing setup without redoing everything.
	• Two types of patches are commonly used:
		1. JSON Patch: Precise control, changing only specific parts.
		2. Strategic Merge Patch: Kubernetes-friendly, only changes the fields you specify while keeping the rest intact.
## Custom Kustomization Resource (in FluxCD)
	• The Kustomize-controller in FluxCD watches a custom resource called Kustomization.
	• This resource tells the controller where the manifest files are and what needs to be applied to the cluster.
	• The controller runs kustomize build to apply these resources and keeps them up-to-date.
## Overlays in Kustomize
	• Overlays allow you to set up a common base configuration and then apply small changes for different environments.
	• This is like an "inheritance" pattern, where most of the setup stays the same, but each environment has its own tweaks.


## Simple Summary
	• The Kustomize-controller in FluxCD monitors a custom resource called Kustomization.
	• This resource points to the manifests that describe what you want in your cluster.
	• The controller applies those changes and keeps the cluster in the correct state.
	• It works like Kustomize in Kubernetes, allowing you to use patches and overlays to customize resources for different environments.

