---
name: home-assistant
description: "Interact with Home Assistant using the `ha` CLI and REST API. Use it to list devices and entities, control smart devices, trigger services, and manage automations."
metadata: {
  "pepebot": {
    "emoji": "🏠",
    "requires": {
      "bins": ["ha", "curl"]
    },
    "install": [
      {
        "id": "ha-os",
        "kind": "info",
        "label": "Home Assistant CLI is included in Home Assistant OS and SSH addon"
      },
      {
        "id": "pip",
        "kind": "pip",
        "package": "homeassistant-cli",
        "bins": ["ha"],
        "label": "Install Home Assistant CLI (pip)"
      }
    ]
  }
}
---

# Home Assistant Control Skill

## Purpose
This skill allows the agent to discover Home Assistant devices, read entity states, and control smart devices using CLI or REST API.

---

# Concepts

- Device = physical hardware
- Entity = controllable item belonging to device
- Services = commands executed on entities

Each device is represented by one or more entities.  
Example: temperature sensor device exposes multiple entities (temperature, humidity).  

---

# CLI Usage

List system info:

    ha core info

Restart HA:

    ha core restart

List users:

    ha auth list

Check logs:

    ha core logs

---

# Get list of entities (REST)

Requires Long-Lived Access Token.

    curl -H "Authorization: Bearer TOKEN" \
         -H "Content-Type: application/json" \
         http://HOME_ASSISTANT:8123/api/states

This returns all entity states.

---

# Control devices (REST service call)

Turn light ON:

    curl -X POST \
      -H "Authorization: Bearer TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"entity_id":"light.living_room"}' \
      http://HOME_ASSISTANT:8123/api/services/light/turn_on

Turn OFF:

    curl -X POST \
      -H "Authorization: Bearer TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"entity_id":"light.living_room"}' \
      http://HOME_ASSISTANT:8123/api/services/light/turn_off

---

# List available services

    curl -H "Authorization: Bearer TOKEN" \
         http://HOME_ASSISTANT:8123/api/services

---

# Automations / scripts

Trigger automation:

    curl -X POST \
      -H "Authorization: Bearer TOKEN" \
      -H "Content-Type: application/json" \
      -d '{"entity_id":"automation.morning"}' \
      http://HOME_ASSISTANT:8123/api/services/automation/trigger

---

# Best practices

1. Always list entities first before controlling devices
2. Prefer entity_id when controlling devices
3. Confirm destructive operations (unlock, disable alarm)
4. Use REST API for remote control
5. Use CLI for local system management

---

# Example workflows

## List all smart devices
1. Call /api/states
2. Filter by domain (light.*, switch.*, sensor.*)

## Turn off all lights
Call service light.turn_off for each light entity

## Read temperature sensors
Filter entities starting with sensor.temperature

