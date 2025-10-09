#!/usr/bin/env bash
# Авто-commit и push с текущим timestamp в сообщение
# Использование:
#   ./autopush.sh
# Или сделать исполняемым:
#   chmod +x autopush.sh && ./autopush.sh
#
# Настройки, которые можно поменять:
#   TIME_FORMAT - формат времени для commit message
#   PREFIX      - префикс сообщения коммита

set -euo pipefail

TIME_FORMAT="%Y-%m-%dT%H:%M:%S%z"   # Можно заменить, напр. "%F %T" или "+%s" (epoch)
PREFIX="Auto commit"

# Проверка что внутри git репо
if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
  echo "❌ Скрипт нужно запускать внутри git репозитория."
  exit 1
fi

# Проверка наличия удалённого origin
if ! git remote get-url origin >/dev/null 2>&1; then
  echo "❌ Удалённый репозиторий 'origin' не настроен."
  echo "   Пример: git remote add origin git@github.com:user/repo.git"
  exit 1
fi

# Текущая ветка (или хеш, если detatched HEAD)
current_branch=$(git symbolic-ref --quiet --short HEAD 2>/dev/null || git rev-parse --short HEAD)
if [[ -z "${current_branch}" ]]; then
  echo "❌ Не удалось определить текущую ветку."
  exit 1
fi

# Проверка наличия изменений
if [[ -z "$(git status --porcelain)" ]]; then
  echo "ℹ️  Нет изменений для коммита. (Рабочее дерево чистое)"
  echo "   Всё равно пушим (если есть несинхронизированные коммиты локально)..."
  git push origin "${current_branch}"
  exit 0
fi

echo "➡ Добавляю изменения..."
git add .

# Повторная проверка (вдруг git add ничего не подобрал)
if [[ -z "$(git diff --cached --name-only)" ]]; then
  echo "ℹ️  После 'git add .' изменений для индекса нет. Завершение."
  exit 0
fi

timestamp=$(date +"${TIME_FORMAT}")
commit_message="${PREFIX}: ${timestamp}"

echo "➡ Делаю commit: ${commit_message}"
git commit -m "${commit_message}"

# Проверка есть ли уже upstream
if git rev-parse --abbrev-ref --symbolic-full-name "@{u}" >/dev/null 2>&1; then
  echo "➡ Пушу в origin/${current_branch}"
  git push origin "${current_branch}"
else
  echo "➡ Первый push (устанавливаю upstream) в origin/${current_branch}"
  git push -u origin "${current_branch}"
fi

echo "✅ Готово."

