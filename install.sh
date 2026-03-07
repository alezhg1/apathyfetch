#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO="alezhg1/apathyfetch"
BRANCH="master"
# Исправлено: убраны лишние пробелы в URL
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
INSTALL_DIR="$HOME/.local/share/apathyfetch"
ZSH_RC="$HOME/.zshrc"

echo -e "${BLUE}==>${NC} apathyfetch installer"

if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗${NC} Только для macOS"
    exit 1
fi

if ! command -v kitty &> /dev/null && [[ "$TERM" != "xterm-kitty" ]]; then
    echo -e "${YELLOW}!${NC} Kitty не обнаружен. Изображения могут не работать."
fi

mkdir -p "$INSTALL_DIR/images"

# Скачиваем основные файлы
for file in apathyfetch install.sh README.md; do
    curl -fsSL "$RAW_BASE/$file" -o "$INSTALL_DIR/$file" || exit 1
done

echo -e "${BLUE}==>${NC} Загрузка изображения..."

# Приоритет: пытаемся скачать GIF, если нет — JPEG
IMG_DOWNLOADED=false

if curl -fsSL --max-time 15 "$RAW_BASE/images/wall.gif" -o "$INSTALL_DIR/images/wall.gif" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.gif загружен (анимация доступна)"
    IMG_DOWNLOADED=true
elif curl -fsSL --max-time 15 "$RAW_BASE/images/wall.jpeg" -o "$INSTALL_DIR/images/wall.jpeg" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.jpeg загружен"
    IMG_DOWNLOADED=true
else
    echo -e "${YELLOW}!${NC} Не удалось загрузить изображение, создаём заглушку..."
    # Создаем минимальный JPEG 1x1
    echo -n '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAn/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/gA==' | base64 -d > "$INSTALL_DIR/images/wall.jpeg" 2>/dev/null || touch "$INSTALL_DIR/images/wall.jpeg"
    echo -e "${BLUE}ℹ${NC} Создана заглушка. Замени image вручную на свой вкус."
fi

chmod +x "$INSTALL_DIR/apathyfetch"

# Настраиваем алиас
if [[ -f "$ZSH_RC" ]]; then
    if ! grep -q "alias apathyfetch=" "$ZSH_RC"; then
        echo -e "\n# apathyfetch" >> "$ZSH_RC"
        echo "alias apathyfetch='$INSTALL_DIR/apathyfetch'" >> "$ZSH_RC"
        echo -e "${GREEN}✓${NC} Алиас добавлен в $ZSH_RC"
    else
        echo -e "${BLUE}ℹ${NC} Алиас уже существует"
    fi
else
    echo -e "${YELLOW}!${NC} .zshrc не найден. Добавьте алиас вручную:"
    echo -e "   ${BLUE}alias apathyfetch='$INSTALL_DIR/apathyfetch'${NC}"
fi

# Финальная проверка
if [[ -f "$INSTALL_DIR/images/wall.gif" ]] || [[ -f "$INSTALL_DIR/images/wall.jpeg" ]]; then
    echo -e "\n${GREEN}✨ Установка завершена!${NC}"
    echo -e "Далее: ${BLUE}source ~/.zshrc${NC} && ${BLUE}apathyfetch${NC}"
    echo -e "Для анимации: ${BLUE}apathyfetch --gif${NC} или ${BLUE}apathyfetch --hello --gif${NC}"
else
    echo -e "${RED}✗${NC} Критическая ошибка: изображения не найдены."
    exit 1
fi