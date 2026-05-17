#!/bin/bash
set -e

VNC_PASSWORD="${VNC_PASSWORD:-zorin}"
VNC_RESOLUTION="${VNC_RESOLUTION:-1920x1080}"
VNC_DEPTH="${VNC_DEPTH:-24}"

mkdir -p "$HOME/.vnc"
echo "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd" 2>/dev/null
chmod 600 "$HOME/.vnc/passwd"

touch "$HOME/.Xresources"

cat > "$HOME/.vnc/xstartup" << 'XEOF'
#!/bin/bash
xrdb "$HOME/.Xresources"
export $(dbus-launch)
startxfce4
XEOF
chmod +x "$HOME/.vnc/xstartup"

vncserver -kill :1 2>/dev/null || true

sudo service dbus start 2>/dev/null || sudo dbus-daemon --system --fork 2>/dev/null || true

vncserver :1 -geometry "$VNC_RESOLUTION" -depth "$VNC_DEPTH" -localhost no

(
    sleep 4
    export DISPLAY=:1
    export HOME="$HOME"

    xfconf-query -c xsettings -p /Net/ThemeName -s "ZorinBlue-Dark" 2>/dev/null || true
    xfconf-query -c xsettings -p /Net/IconThemeName -s "Zorin" 2>/dev/null || true
    xfconf-query -c xfwm4 -p /general/theme -s "ZorinBlue-Dark" 2>/dev/null || true

    WALLPAPER="/usr/share/backgrounds/zorin/picsum-3.jpg"
    if [ -f "$WALLPAPER" ]; then
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s "$WALLPAPER" 2>/dev/null || true
        for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep "last-image"); do
            xfconf-query -c xfce4-desktop -p "$prop" -s "$WALLPAPER" 2>/dev/null || true
        done
    fi
) &

websockify --web /usr/share/novnc 6080 localhost:5901 &

echo "========================================="
echo "  Zorin OS Docker VNC"
echo "  VNC:  localhost:5901"
echo "  Web:  http://localhost:6080/vnc.html"
echo "  User: zorin / pass: $VNC_PASSWORD"
echo "========================================="

wait
