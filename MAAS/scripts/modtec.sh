#!/bin/bash
#
#   Repository https://github.com/mc-b/modtec - Moderne und Architekturrelevante Architekturen
#

# IoT Umgebung
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/iot/mosquitto.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/iot/nodered.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/compiler/mbed-cli.yaml

# Messaging Umgebung
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/zookeeper.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/kafka.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/mqtt-kafka-bridge.yaml

# Kafka Streams
kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-alert.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-consumer.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-pipe.yaml

# BPMN Umgebung und Upload BPMN Prozess
kubectl apply -f https://raw.githubusercontent.com/mc-b/misegr/master/bpmn/camunda.yaml

wget https://raw.githubusercontent.com/mc-b/misegr/master/bpmn/RechnungStep3.bpmn -O data/RechnungStep3.bpmn

for i in {1..150}; do # timeout for 5 minutes
   curl http://camunda:8080 &> /dev/null
   if [ $? -eq 0 ]; then
      break
  fi
  sleep 2
done

cd data
curl -k -w "\n" \
-H "Accept: application/json" \
-F "deployment-name=rechnung" \
-F "enable-duplicate-filtering=true" \
-F "deploy-changed-only=true" \
-F "Rechnung.bpmn=@RechnungStep3.bpmn" \
http://camunda:8080/engine-rest/deployment/create

