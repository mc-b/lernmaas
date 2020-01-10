#!/bin/bash
#
#   Repository https://github.com/mc-b/modtec - Moderne und Architekturrelevante Architekturen
#

# IoT Umgebung (werden als Teil einer Uebung gestartet)
# kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/iot/mosquitto.yaml
# kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/iot/nodered.yaml

# Messaging Umgebung (MQTT - Kafka Bridget neu mit Node-RED)
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/zookeeper.yaml
kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/kafka.yaml
# kubectl apply -f https://raw.githubusercontent.com/mc-b/duk/master/kafka/mqtt-kafka-bridge.yaml

# Kafka Streams (werden als Teil einer Uebung gestartet)
# kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-alert.yaml
# kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-consumer.yaml
# kubectl apply -f https://raw.githubusercontent.com/mc-b/iot.kafka/master/iot-kafka-pipe.yaml

# SSH Key fuer Zugriff auf VM freigeben, bzw. via http://<IP>/data/.ssh/id_rsa zugreifbar machen
sudo ln -s $HOME/data /var/www/html/data
sudo chmod 755 $HOME/data/.ssh
chmod 644 $HOME/data/.ssh/id_rsa $HOME/data/.ssh/id_rsa.ppk

# BPMN Umgebung und Upload BPMN Prozess
sudo docker pull camunda/camunda-bpm-platform
kubectl apply -f https://raw.githubusercontent.com/mc-b/misegr/master/bpmn/camunda.yaml

cd $HOME
wget https://raw.githubusercontent.com/mc-b/misegr/master/bpmn/RechnungStep3.bpmn -O data/RechnungStep3.bpmn

sleep 10
for i in {1..150}; do # timeout for 5 minutes
   curl -k https://localhost:30443/engine-rest/deployment &> /dev/null
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
https://localhost:30443/engine-rest/deployment/create

