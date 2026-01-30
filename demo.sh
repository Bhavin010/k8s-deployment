#!/bin/bash

# Professional Color Palette
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

function run_phase() {
    local phase_name=$1
    local desc=$2
    local cmds=$3

    clear

    echo -e "${BOLD}PHASE: $phase_name${NC}"
    echo -e "${BLUE}GOAL:  $desc${NC}"

    echo -e "${CYAN}COMMANDS TO BE EXECUTED:${NC}"
    echo -e "$cmds"

    
    read -p "Execute this phase? (y/n): " confirm
    
    if [[ $confirm == [yY] ]]; then
        echo -e "\n${YELLOW}--- STARTING EXECUTION ---${NC}"
        return 0
    else
        echo -e "${RED}Skipping phase...${NC}\n"
        return 1
    fi
}

function pause_for_result() {

    read -p "Press [Enter] to proceed to the next phase..." 
}

# --- START OF DEMO ---

# PHASE 1
CMDS_1="  > minikube start\n  > minikube addons enable ingress\n  > minikube tunnel"
if run_phase "1. Cluster Initialization" "Activating the Kubernetes cluster and networking gateway." "$CMDS_1"; then
    minikube start
    if ! pgrep -f "minikube tunnel" > /dev/null; then
        nohup minikube tunnel > /dev/null 2>&1 &
        sleep 2
    fi
    minikube status
    pause_for_result
fi

# PHASE 2
CMDS_2="  > kubectl apply -f k8s/\n  > kubectl get pods -n app-deployment -o wide"
if run_phase "2. Deployment and Identity" "Provisioning 3 replicas with unique internal networking." "$CMDS_2"; then
    kubectl apply -f k8s/
    kubectl wait --for=condition=ready pod -l app=my-app -n app-deployment --timeout=60s
    kubectl get pods -n app-deployment -o wide
    pause_for_result
fi

# PHASE 3
CMDS_3="  > kubectl logs -l app=my-app --prefix --max-log-requests 5\n  > curl http://myapp.local/ (Traffic Simulation)"
if run_phase "3. Load Balancing Verification" "Demonstrating request distribution across active pods via logs." "$CMDS_3"; then
    echo -e "${YELLOW}Observing real-time traffic routing...${NC}"
    kubectl logs -l app=my-app -n app-deployment -f --prefix --max-log-requests 5 &
    LOG_PID=$!
    sleep 2
    
    for i in {1..10}; do 
        curl -s http://myapp.local/ > /dev/null
        echo -n ". "
        sleep 0.3
    done
    echo ""
    
    sleep 2
    kill $LOG_PID
    pause_for_result
fi

# PHASE 4
CMDS_4="  > kubectl delete pod [PodName] --force\n  > kubectl get pods"
if run_phase "4. High Availability and Self-Healing" "Simulating a node failure and observing automated recovery." "$CMDS_4"; then
    POD_NAME=$(kubectl get pods -n app-deployment -l app=my-app -o jsonpath='{.items[0].metadata.name}')
    echo -e "${RED}Terminating instance: $POD_NAME${NC}"
    kubectl delete pod $POD_NAME -n app-deployment --force --grace-period=0
    echo "Verifying cluster state recovery..."
    sleep 2
    kubectl get pods -n app-deployment
    pause_for_result
fi

# PHASE 5
CMDS_5="  > kubectl scale deployment my-app --replicas=5\n  > kubectl get pods"
if run_phase "5. Horizontal Scaling" "Instant expansion of application capacity to 5 instances." "$CMDS_5"; then
    kubectl scale deployment my-app --replicas=5 -n app-deployment
    sleep 2
    kubectl get pods -n app-deployment
    pause_for_result
fi

clear
echo -e "      DEMO COMPLETE - SYSTEM STABLE        "

