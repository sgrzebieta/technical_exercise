locals {
  name = "tasky"
}

resource "kubernetes_namespace" "tasky" {
  metadata {
    annotations = {
      name = local.name
    }

    name = local.name
  }

  depends_on = [
    module.gke
  ]
}

resource "kubernetes_deployment" "tasky" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.tasky.id
    labels = {
      app = local.name
    }
  }

  spec {
    selector {
      match_labels = {
        app = local.name
      }
    }
    replicas = 1
    template {
      metadata {
        labels = {
          app = local.name
        }
      }
      spec {
        service_account_name = "tasky"
        container {
          image = "australia-southeast1-docker.pkg.dev/wiz-tech-challenge/docker/tasky:latest"
          name  = local.name


          env {
            name  = "MONGODB_URI"
            value = "mongodb://wiztc:We!come123@10.20.10.3/[defaultauthdb]"
          }

          env {
            name  = "SECRET_KEY"
            value = "secret123"
          }

          port {
            container_port = 8080
          }

          resources {
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }

  depends_on = [
    module.gke
  ]
}

resource "kubernetes_service" "tasky" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.tasky.id

    annotations = {
      "cloud.google.com/neg" : "{\"ingress\": true}"
    }
  }

  spec {
    selector = {
      app = local.name
    }

    session_affinity = "ClientIP"

    port {
      port        = 8080
      protocol    = "TCP"
      target_port = 8080
    }

    type = "ClusterIP"
  }

  depends_on = [
    module.gke
  ]
}

resource "kubernetes_ingress_v1" "tasky" {
  metadata {
    name      = local.name
    namespace = kubernetes_namespace.tasky.id
  }

  spec {
    default_backend {
      service {
        name = local.name
        port {
          number = 8080
        }
      }
    }

    rule {
      http {
        path {
          backend {
            service {
              name = local.name
              port {
                number = 8080
              }
            }
          }

          path = "/"
        }
      }
    }
  }

  depends_on = [
    module.gke
  ]
}

resource "kubernetes_service_account" "tasky_sa" {
  metadata {
    name      = "tasky"
    namespace = kubernetes_namespace.tasky.id
  }
}

resource "kubernetes_cluster_role_binding" "tasky" {
  metadata {
    name = "tasky"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "tasky"
    namespace = kubernetes_namespace.tasky.id
  }
}