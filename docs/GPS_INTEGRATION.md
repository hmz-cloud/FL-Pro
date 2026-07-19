# GPS Provider Integration Guide

## How It Works
FleetOps is GPS-agnostic. Connect your existing hardware
via REST API — FleetOps layers cost, compliance, driver,
and operational data on top of live positions.

## Samsara
  const res = await fetch(
    'https://api.samsara.com/fleet/vehicles/locations',
    { headers: { 'Authorization': 'Bearer ' + SAMSARA_API_KEY } }
  );
  const { data } = await res.json();
  data.forEach(v => updateVehicleGPS(
    v.id, v.gps.latitude, v.gps.longitude, v.gps.speedMilesPerHour
  ));

## Wialon (Gurtam)
  const auth = await fetch(
    'https://hst-api.wialon.com/wialon/ajax.html' +
    '?svc=token/login&params={"token":"' + WIALON_TOKEN + '"}'
  );
  const { eid } = await auth.json();
  // use eid for all subsequent requests

## Traccar (self-hosted or cloud)
  const res = await fetch(TRACCAR_URL + '/api/positions', {
    headers: {
      'Authorization': 'Basic ' + btoa(user + ':' + pass)
    }
  });

## Custom / Generic API
  // FleetOps expects this shape per vehicle:
  {
    fleetNumber: "FL-001",
    lat: 24.7136,
    lng: 46.6753,
    speed: 60,
    online: true,
    lastPing: "2026-06-07T09:14:00Z"
  }

## Sync Strategy
- Poll every 30-60s for live tracking view
- Store last position in Supabase vehicles table
- Use Supabase Realtime to push to all connected clients
- No GPS hardware = FleetOps still works 100%
