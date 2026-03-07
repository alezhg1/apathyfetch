#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

INSTALL_DIR="$HOME/.local/share/apathyfetch"
ZSH_RC="$HOME/.zshrc"

echo -e "${BLUE}==>${NC} Проверка системы для apathyfetch..."



if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}Error:${NC} Этот скрипт предназначен только для macOS."
    exit 1
fi

if ! command -v kitty &> /dev/null && [ "$TERM" != "xterm-kitty" ]; then
    echo -e "${RED}Warning:${NC} Кажется, Kitty не установлен или не запущен."
    echo -e "apathyfetch требует протокола Kitty для вывода картинок."
fi

echo -e "${BLUE}==>${NC} Копирование файлов в $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
cp -r . "$INSTALL_DIR"
chmod +x "$INSTALL_DIR/apathyfetch"

if [ -f "$ZSH_RC" ]; then
    if ! grep -q "alias apathyfetch=" "$ZSH_RC"; then
        echo -e "\n# apathyfetch setup" >> "$ZSH_RC"
        echo "alias apathyfetch='$INSTALL_DIR/apathyfetch'" >> "$ZSH_RC"
        echo -e "${GREEN}OK:${NC} Алиас добавлен в $ZSH_RC"
    else
        echo -e "${BLUE}info:${NC} Алиас уже прописан."
    fi
else
    echo -e "${RED}Error:${NC} .zshrc не найден. Создайте его или добавьте алиас вручную."
fi

if [ ! -f "$INSTALL_DIR/images/wall.jpeg" ]; then
    echo -e "${RED}!${NC} Файл изображения не найден по пути $INSTALL_DIR/images/wall.jpeg"
fi

echo -e "\n${GREEN}✨ Установка завершена успешно!${NC}"
echo -e "Чтобы начать, выполните: ${BLUE}source ~/.zshrc${NC} и затем ${BLUE}apathyfetch${NC}"
