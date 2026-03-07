#!/bin/bash
set -e  # Выход при ошибке

# Цвета
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Настройки
REPO_URL="https://github.com/alezhg1/apathyfetch"
BRANCH="master"
INSTALL_DIR="$HOME/.local/share/apathyfetch"
ZSH_RC="$HOME/.zshrc"

echo -e "${BLUE}==>${NC} apathyfetch installer v1.1"
echo -e "${BLUE}==>${NC} Репозиторий: ${REPO_URL}"

# Проверка ОС
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo -e "${RED}✗${NC} Этот скрипт предназначен только для macOS."
    exit 1
fi

# Проверка Kitty (мягкая)
if ! command -v kitty &> /dev/null && [[ "$TERM" != "xterm-kitty" ]]; then
    echo -e "${YELLOW}!${NC} Kitty не обнаружен. Изображения могут не отображаться."
    echo -e "   Установите: ${BLUE}brew install --cask kitty${NC}"
fi

# Создаём временную директорию
TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

echo -e "${BLUE}==>${NC} Загрузка файлов из репозитория..."

# Скачиваем основные файлы напрямую из raw-ссылок
FILES=("apathyfetch" "install.sh" "README.md")
mkdir -p "$TEMP_DIR/images"

for file in "${FILES[@]}"; do
    curl -fsSL "https://raw.githubusercontent.com/alezhg1/apathyfetch/${BRANCH}/${file}" -o "$TEMP_DIR/${file}" || {
        echo -e "${RED}✗${NC} Не удалось загрузить ${file}"
        exit 1
    }
done

# Картинка (опционально, с фоллбэком)
if curl -fsSL "https://raw.githubusercontent.com/alezhg1/apathyfetch/${BRANCH}/images/wall.jpeg" -o "$TEMP_DIR/images/wall.jpeg" 2>/dev/null; then
    echo -e "${GREEN}✓${NC} Изображение загружено"
else
    echo -e "${YELLOW}!${NC} Не удалось загрузить изображение, создаём заглушку..."
    # Создаём минимальный валидный JPEG 1x1 (серый пиксель)
    echo -n '/9j/4AAQSkZJRgABAQEAYABgAAD/2wBDAAgGBgcGBQgHBwcJCQgKDBQNDAsLDBkSEw8UHRofHh0aHBwgJC4nICIsIxwcKDcpLDAxNDQ0Hyc5PTgyPC4zNDL/2wBDAQkJCQwLDBgNDRgyIRwhMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjIyMjL/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAn/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwA/gA==' | base64 -d > "$TEMP_DIR/images/wall.jpeg" 2>/dev/null || touch "$TEMP_DIR/images/wall.jpeg"
fi

# Копируем в целевую директорию
echo -e "${BLUE}==>${NC} Установка в ${INSTALL_DIR}..."
mkdir -p "$INSTALL_DIR"
cp -r "$TEMP_DIR"/* "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/apathyfetch"

# Настраиваем алиас в .zshrc
if [[ -f "$ZSH_RC" ]]; then
    if ! grep -q "alias apathyfetch=" "$ZSH_RC"; then
        echo -e "\n# apathyfetch" >> "$ZSH_RC"
        echo "alias apathyfetch='$INSTALL_DIR/apathyfetch'" >> "$ZSH_RC"
        echo -e "${GREEN}✓${NC} Алиас добавлен в $ZSH_RC"
    else
        echo -e "${BLUE}ℹ${NC} Алиас уже существует в $ZSH_RC"
    fi
else
    echo -e "${YELLOW}!${NC} .zshrc не найден. Создайте его или добавьте алиас вручную:"
    echo -e "   ${BLUE}alias apathyfetch='$INSTALL_DIR/apathyfetch'${NC}"
fi

# Финальный чек
if [[ -f "$INSTALL_DIR/apathyfetch" ]]; then
    echo -e "\n${GREEN}✨ Установка завершена!${NC}"
    echo -e "Далее выполните:"
    echo -e "  ${BLUE}source ~/.zshrc${NC}  # или перезапустите терминал"
    echo -e "  ${BLUE}apathyfetch${NC}      # запустите фечер"
    echo -e "\n${BLUE}📖 Документация:${NC} $REPO_URL"
else
    echo -e "${RED}✗${NC} Что-то пошло не так. Проверьте права доступа к $INSTALL_DIR"
    exit 1
fi