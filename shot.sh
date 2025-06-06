#!/usr/bin/env bash

MODE="$1"   # должно быть "window", "output" или "region"
DIR="$screenShotsDir"

# Делаем скриншот нужного типа в $DIR
hyprshot -m "$MODE" -o "$DIR"

# Ждём чуть-чуть, чтобы файл дописался
sleep 0.1

# Находим самый "свежий" файл (предполагается, что именуются с датой+временем)
FILE="$(ls -t "$DIR" | head -n1)"

# Если файл реально создался, открываем в Swappy
if [ -f "$DIR/$FILE" ]; then
  swappy -f "$DIR/$FILE"
else
  # Если вдруг не нашёл — просто выходим без ошибки
  exit 1
fi
