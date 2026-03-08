#!/bin/bash
set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

REPO="alezhg1/apathyfetch"
BRANCH="master"
RAW_BASE="https://raw.githubusercontent.com/$REPO/$BRANCH"
INSTALL_DIR="$HOME/.local/share/apathyfetch"
ZSH_RC="$HOME/.zshrc"

echo -e "${BLUE}==>${NC} apathyfetch installer"

# 1. Проверка ОС
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗${NC} Только для macOS"
    exit 1
fi

# 2. Проверка Kitty
if ! command -v kitty &> /dev/null && [[ "$TERM" != "xterm-kitty" ]]; then
    echo -e "${YELLOW}!${NC} Kitty не обнаружен. Изображения могут не работать."
    echo -e "   Установите: ${BLUE}brew install --cask kitty${NC}"
fi

# 3. Создание папок
mkdir -p "$INSTALL_DIR/images"

# 4. Скачивание основных скриптов
echo -e "${BLUE}==>${NC} Загрузка скриптов..."
for file in apathyfetch install.sh README.md; do
    if ! curl -fsSL "$RAW_BASE/$file" -o "$INSTALL_DIR/$file"; then
        echo -e "${RED}✗${NC} Не удалось загрузить $file"
        exit 1
    fi
done
chmod +x "$INSTALL_DIR/apathyfetch"

# 5. Скачивание изображений (Приоритет: GIF -> JPG -> JPEG -> PNG)
echo -e "${BLUE}==>${NC} Загрузка изображений..."
IMG_FOUND=false

# Пробуем скачать GIF
if curl -fsSL --max-time 10 "$RAW_BASE/images/wall.gif" -o "$INSTALL_DIR/images/wall.gif" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.gif загружен"
    IMG_FOUND=true
fi

# Пробуем скачать JPG
if curl -fsSL --max-time 10 "$RAW_BASE/images/wall.jpg" -o "$INSTALL_DIR/images/wall.jpg" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.jpg загружен"
    IMG_FOUND=true
fi

# Пробуем скачать JPEG
if curl -fsSL --max-time 10 "$RAW_BASE/images/wall.jpeg" -o "$INSTALL_DIR/images/wall.jpeg" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.jpeg загружен"
    IMG_FOUND=true
fi

# Пробуем скачать PNG
if curl -fsSL --max-time 10 "$RAW_BASE/images/wall.png" -o "$INSTALL_DIR/images/wall.png" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} wall.png загружен"
    IMG_FOUND=true
fi

# Если ничего не скачалось — создаем заглушку
if [[ "$IMG_FOUND" == false ]]; then
    echo -e "${YELLOW}!${NC} Изображения не найдены в репозитории. Создаю заглушку..."
    # Минимальный серый JPEG 1x1
    echo -n '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAn/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/gA==' | base64 -d > "$INSTALL_DIR/images/wall.jpeg"
    echo -e "${BLUE}ℹ${NC} Заглушка создана. Замените файл вручную на свой вкус."
fi

# 6. Настройка алиаса
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
    echo -e "   alias apathyfetch='$INSTALL_DIR/apathyfetch'"
fi

# 7. Финал
echo -e "\n${GREEN}✨ Установка завершена!${NC}"
echo -e "Далее выполните:"
echo -e "  ${BLUE}source ~/.zshrc${NC}"
echo -e "  ${BLUE}apathyfetch${NC}      # обычный режим"
echo -e "  ${BLUE}apathyfetch --gif${NC} # режим анимации (если есть wall.gif)"