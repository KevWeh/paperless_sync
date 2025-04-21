# 🗂️ Paperless Archive Sync Script

A lightweight and reliable shell script to **synchronize the Paperless-ngx archive directory** to a mounted SMB share, integrated with `systemd` for automated and recurring execution. Designed for use on LXC containers running under **Proxmox**, this tool supports structured logging, daily log rotation, and resilient Docker container checks.

---

## ✨ Features

- 📁 **Archive Synchronization**: Syncs Paperless-ngx archive to an external directory via `rsync`
- 🔄 **Systemd Timer Integration**: Runs every 5 minutes using a `systemd.timer` unit
- 📝 **Daily Log Files**: Logs are stored per day and automatically purged after 5 days
- 🐳 **Docker Awareness**: Verifies the Paperless container is running before syncing
- 🔒 **Security-Oriented**: Uses `systemd` hardening options for secure operation

---

## ⚙️ Prerequisites

Ensure the following components are installed and properly configured:

- [Docker](https://docs.docker.com/)
- [Paperless-ngx](https://docs.paperless-ngx.com/)
- `rsync`
- `systemd` (most Linux systems)
- SMB mount available at `/mnt/archive`
- Optional: Running inside an [LXC container](https://linuxcontainers.org/lxc/introduction/) under [Proxmox VE](https://www.proxmox.com/)

---

## 📦 Installation

1. **Clone or copy the script to your container**:
   ```bash
   sudo mkdir -p /usr/local/bin
   sudo cp paperless_sync.sh /usr/local/bin/
   sudo chmod +x /usr/local/bin/paperless_sync.sh
   ```

2. **Create the systemd service unit**  
   Save as: `/etc/systemd/system/paperless_sync.service`
   ```ini
   [Unit]
   Description=Sync Paperless archive to mounted SMB share
   After=network.target docker.service
   Wants=network-online.target

   [Service]
   Type=oneshot
   ExecStart=/usr/local/bin/paperless_sync.sh
   User=paperless
   Group=paperless
   Nice=10
   ProtectSystem=full
   PrivateTmp=true
   NoNewPrivileges=true
   StandardOutput=journal
   StandardError=journal
   ```

3. **Create the systemd timer unit**  
   Save as: `/etc/systemd/system/paperless_sync.timer`
   ```ini
   [Unit]
   Description=Run Paperless archive sync every 5 minutes

   [Timer]
   OnBootSec=5min
   OnUnitActiveSec=5min
   AccuracySec=30s
   Persistent=true

   [Install]
   WantedBy=timers.target
   ```

4. **Enable and start the timer**:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable --now paperless_sync.timer
   ```

---

## ▶️ Usage

You can control the script using standard systemd commands:

- **Start immediately**:
  ```bash
  sudo systemctl start paperless_sync.service
  ```

- **Check timer status**:
  ```bash
  systemctl status paperless_sync.timer
  ```

- **View recent logs**:
  ```bash
  journalctl -u paperless_sync.service
  ```

By default, the sync runs **every 5 minutes**.

---

## ⚙️ Configuration

You can customize the script by editing these variables at the top of `paperless_sync.sh`:

| Variable                | Description                                                   |
|-------------------------|---------------------------------------------------------------|
| `PAPERLESS_ARCHIVE_DIR` | Path to Paperless archive inside the container                |
| `PAPERLESS_ARCHIVE_MOUNT` | Mount point of the external SMB share                        |
| `SERVICE_NAME`          | Name of the Docker container to check (`docker ps`)           |
| `LOG_DIR`               | Location where log files are stored                           |

Make sure the `User` defined in the service file (e.g., `paperless`) has appropriate read/write permissions on these paths.

---

## 🧾 Logging

- Logs are written to: `/var/log/paperless/YYYY-MM-DD-sync.log`
- Each log file contains detailed sync activity with timestamps
- Log files older than **5 days** are automatically deleted on each script run
- Optionally view logs via systemd journal:
  ```bash
  journalctl -u paperless_sync.service
  ```

---

## 🧪 License

This project is licensed under the [MIT License](LICENSE).

---

## 📌 Notes

- For maximum resilience, ensure your SMB mount is persistent and properly mounted before the timer executes.
- This tool is ideal for home server setups or small business environments running Paperless under Proxmox LXC containers.

---

## 🧰 Contribution & Feedback

Pull requests, issues, and feature suggestions are welcome. Let us know how you're using this tool and help improve it!
