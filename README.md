# Kindle SmartHome Proxy — Home Assistant Add-on

A Home Assistant Add-on that runs the WebSocket proxy for the [Kindle SmartHome Dashboard](https://github.com/yatharth5/kindle-smarthome-dashboard-master) project. It bridges a jailbroken Kindle Paperwhite 2 to Home Assistant, translating the Kindle's legacy WebSocket protocol into HA's modern WebSocket API.

---

## Prerequisites

- Home Assistant OS or Supervised installation (Add-on support required)
- A jailbroken Kindle Paperwhite 2 with [KUAL](https://kindlemodding.org/jailbreaking/) installed
- A long-lived access token from Home Assistant

---

## Installation

### 1. Add this repository to Home Assistant

1. Go to **Settings → Add-ons → Add-on Store**
2. Click **⋮ (three dots) → Repositories**
3. Add the URL: `https://github.com/yatharth5/kindle-smarthome-ha-addon`
4. Refresh the page

### 2. Install the add-on

- Find **"Kindle SmartHome Proxy"** in the add-on store
- Click **Install**

### 3. Generate a long-lived access token

1. In HA, click your **profile avatar** (bottom-left)
2. Scroll to **Long-Lived Access Tokens**
3. Click **Create Token**, name it (e.g. `Kindle Proxy`), and copy the value

### 4. Configure the add-on

Go to the **Configuration** tab of the add-on and fill in:

| Field | Description | Example |
|---|---|---|
| `ha_url` | Your HA HTTP base URL | `http://192.168.1.x:8123` |
| `ha_token` | Long-lived access token from step 3 | `eyJ0...` |
| `kindle_token` | Any secret string the Kindle uses to authenticate | `mysecrettoken` |

Click **Save**, then go to the **Info** tab and click **Start**.

### 5. Verify the add-on is running

Check the **Log** tab. A successful startup looks like:

```
[kindle-display] Starting WebSocket server on port 4365
[homeassistant] Connecting to http://your-ha-ip:8123
[homeassistant] Successfully authenticated
```

---

## Connecting the Kindle

### 1. Prepare the Kindle extension

From the [Kindle SmartHome Dashboard](https://github.com/yatharth5/kindle-smarthome-dashboard-master) repository:

```bash
cp smarthomedisplay/mesquite/config.sample.js smarthomedisplay/mesquite/config.js
```

Edit `config.js` and set:

```js
var WS_URL = 'ws://<your-ha-ip>:4365?accessToken=<your-kindle-token>';
```

Replace:
- `<your-ha-ip>` — your Home Assistant host IP address
- `<your-kindle-token>` — the `kindle_token` you set in the add-on configuration

Optionally configure:

```js
var WEATHER_PARAMS = 'lat=<latitude>&lon=<longitude>';   // your location
var DISPLAY_CALENDARS = ['calendar.your_calendar'];       // your HA calendar entity IDs
```

### 2. Copy to the Kindle

1. Connect the Kindle via USB — it appears as a drive
2. Copy the entire `smarthomedisplay/` folder into the Kindle's `extensions/` directory

```
Kindle/
└── extensions/
    └── smarthomedisplay/    ← place it here
```

### 3. Launch the dashboard

1. Open **KUAL** on the Kindle
2. Tap **"Launch SmartHome Display"**

A successful connection appears in the add-on log:

```
[kindle-display] Connection from ::ffff:192.168.x.x
```

---

## Customising the Dashboard

The `index.html` file in `smarthomedisplay/mesquite/` contains entity IDs hardcoded to the original developer's home. Replace all `data-entity-id="..."` values with your own HA entity IDs.

### Required HA helper entities

Create these in **Settings → Devices & Services → Helpers**:

| Entity ID | Type | Description |
|---|---|---|
| `input_button.kindle_display_refresh` | Button | Triggers an e-ink refresh |
| `input_button.kindle_display_reload_page` | Button | Reloads the dashboard page |
| `input_number.kindle_display_brightness` | Number (0–5) | Controls screen brightness |

---

## Architecture

```
[Kindle Browser]
  → WebSocket ws://<ha-ip>:4365?accessToken=<kindle_token>
  → [Add-on: Node.js proxy — port 4365]
  → WebSocket ws://<ha-ip>:8123/api/websocket (with ha_token)
  → [Home Assistant Core]
```

---

## Troubleshooting

### `ReferenceError: WebSocket is not defined`

Occurs when Node.js < 22 is installed (Alpine 3.19 ships Node 20 which has no global `WebSocket`). Fixed in this add-on via an `entrypoint.mjs` wrapper that polyfills `globalThis.WebSocket` using the `ws` package before loading the proxy.

### Kindle shows "WebSocket connection closed, reconnecting in 10s"

- Verify `config.js` exists on the Kindle (not just `config.sample.js`)
- Confirm the `kindle_token` in `config.js` matches the one in the add-on configuration
- Check port 4365 is reachable: `nc -zv <ha-ip> 4365`

### Dashboard is blank / no entity data

The entity IDs in `index.html` are from the original developer's setup. Edit the file to use your HA entity IDs. Also ensure the three helper entities listed above exist in your HA instance.

### After updating the add-on, changes don't apply

HA's **Rebuild** button may use cached source files. For guaranteed fresh source:
1. Uninstall the add-on
2. Remove and re-add the repository URL
3. Reinstall
