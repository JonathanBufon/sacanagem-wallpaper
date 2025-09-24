#!/bin/sh
#
# Script para definir como papel de parede uma imagem do diretório atual
# Funciona em GNOME, KDE Plasma, XFCE, LXDE, MATE e i3/feh
#

# pega a primeira imagem encontrada no diretório atual
IMG="$(find "$(pwd)" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.bmp' \) | head -n 1)"

if [ -z "$IMG" ]; then
  echo "Nenhuma imagem encontrada no diretório atual."
  exit 1
fi

echo "Definindo papel de parede: $IMG"

# Detectar ambiente gráfico
DESKTOP=$(echo "$XDG_CURRENT_DESKTOP" | tr '[:upper:]' '[:lower:]')

case "$DESKTOP" in
  *gnome*|*unity*)
    gsettings set org.gnome.desktop.background picture-uri "file://$IMG"
    gsettings set org.gnome.desktop.background picture-uri-dark "file://$IMG" 2>/dev/null
    ;;
  *kde*)
    # KDE Plasma usa um script em JavaScript via qdbus
    qdbus org.kde.plasmashell /PlasmaShell org.kde.PlasmaShell.evaluateScript "
      var Desktops = desktops();
      for (i=0;i<Desktops.length;i++) {
        d = Desktops[i];
        d.wallpaperPlugin = 'org.kde.image';
        d.currentConfigGroup = Array('Wallpaper','org.kde.image','General');
        d.writeConfig('Image', 'file://$IMG');
      }"
    ;;
  *xfce*)
    # Para XFCE
    xfconf-query --channel xfce4-desktop --property /backdrop/screen0/monitor0/workspace0/last-image --set "$IMG"
    ;;
  *lxde*)
    pcmanfm --set-wallpaper="$IMG" --wallpaper-mode=fit
    ;;
  *mate*)
    gsettings set org.mate.background picture-filename "$IMG"
    ;;
  *i3*|*openbox*|*fluxbox*)
    # Usando feh (precisa estar instalado)
    feh --bg-scale "$IMG"
    ;;
  *)
    echo "Ambiente de desktop não detectado ou não suportado ($DESKTOP)."
    echo "Tente instalar e usar: feh --bg-scale \"$IMG\""
    ;;
esac
