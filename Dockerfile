FROM scratch

LABEL com.redhat.component="maistra-istio-operator-metadata-container" \
      com.redhat.delivery.appregistry=true \
      name="maistra/istio-ubi8-operator-metadata" \
      summary="Maistra (Istio) Operator Metadata OpenShift container image" \
      description="Operator metadata for Maistra (Istio)" \
      io.openshift.expose-services="" \
      io.openshift.tags="istio" \
      io.k8s.display-name="Maistra (Istio) Operator Metadata" \
      maintainer="Istio Feedback <istio-feedback@redhat.com>" \
      version="1.1.0"

ADD manifests /manifests
