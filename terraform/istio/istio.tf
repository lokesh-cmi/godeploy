locals {
  istio_charts_url = "https://istio-release.storage.googleapis.com/charts"
}

resource "helm_release" "istio-base" {
  repository       = local.istio_charts_url
  chart            = "base"
  name             = "istio-base"
  timeout          = 120
  namespace        = "istio-system"
  version          = "1.17.1"
  create_namespace = true
  cleanup_on_fail  = true
  force_update     = false
}

resource "helm_release" "istiod" {
  repository       = local.istio_charts_url
  chart            = "istiod"
  name             = "istiod"
  timeout          = 120
  namespace        = "istio-system"
  create_namespace = true
  version          = "1.17.1"
  cleanup_on_fail  = true
  force_update     = false
  depends_on       = [helm_release.istio-base]
}


