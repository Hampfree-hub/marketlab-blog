// Скрипт для коммита и пуша изменений в GitHub
// Использование: node commit-now.js

import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

console.log('📝 Коммит изменений в GitHub...\n');

const repoPath = __dirname.replace(/\\/g, '/');

try {
    // Переходим в директорию проекта
    process.chdir(repoPath);
    console.log(`📁 Директория: ${repoPath}\n`);

    // Шаг 0: Сохранить незакоммиченные изменения (stash)
    console.log('[0/6] Сохранение незакоммиченных изменений...');
    try {
        const status = execSync('git status --porcelain', { encoding: 'utf-8' });
        if (status.trim()) {
            console.log('Найдены незакоммиченные изменения, сохраняем...');
            execSync('git stash push -m "Auto-stash before commit"', { stdio: 'inherit' });
            console.log('✅ Изменения сохранены\n');
        } else {
            console.log('Нет незакоммиченных изменений\n');
        }
    } catch (e) {
        console.log('⚠️ Не удалось сохранить изменения\n');
    }

    // Шаг 0.5: Переключиться на ветку main
    console.log('[0.5/6] Переключение на ветку main...');
    try {
        execSync('git checkout main', { stdio: 'inherit' });
        console.log('✅ На ветке main\n');
    } catch (e) {
        // Если ветки нет, создаём её
        try {
            execSync('git checkout -b main', { stdio: 'inherit' });
            console.log('✅ Создана ветка main\n');
        } catch (e2) {
            console.log('⚠️ Проблема с веткой, продолжаем...\n');
        }
    }

    // Восстановить сохранённые изменения
    try {
        execSync('git stash pop', { stdio: 'inherit' });
        console.log('✅ Изменения восстановлены\n');
    } catch (e) {
        // Если stash пустой, это нормально
    }

    // Шаг 1: Получить изменения с GitHub
    console.log('[1/6] Получение изменений с GitHub...');
    try {
        execSync('git pull github main --no-rebase', { stdio: 'inherit' });
        console.log('✅ Изменения получены\n');
    } catch (e) {
        console.log('⚠️ Не удалось получить изменения (возможно, первый коммит)\n');
    }

    // Шаг 2: Проверка статуса
    console.log('[2/6] Проверка статуса git...');
    try {
        const status = execSync('git status --short', { encoding: 'utf-8' });
        if (status.trim()) {
            console.log(status);
        } else {
            console.log('Нет изменений для коммита');
        }
    } catch (e) {
        console.log('Статус проверен');
    }
    console.log('');

    // Шаг 3: Добавление изменений
    console.log('[3/6] Добавление всех изменений...');
    execSync('git add .', { stdio: 'inherit' });
    console.log('✅ Файлы добавлены\n');

    // Шаг 4: Создание коммита
    console.log('[4/6] Создание коммита...');
    const commitMessage = [
        'Упрощение проекта: смягчённая палитра + светлая тема Windows',
        '',
        '- Смягчённая зелёная палитра (не режет глаза)',
        '- Светлая тема в стиле Windows (серо-голубая)',
        '- Переключатель темы в Header',
        '- Упрощённая структура компонентов',
        '- Исправлен git remote на GitHub',
        '- Убран base path для локальной разработки',
        '- Исправлен RSS feed'
    ].join('\n');

    try {
        execSync(`git commit -m "${commitMessage.replace(/"/g, '\\"')}"`, { stdio: 'inherit' });
        console.log('✅ Коммит создан\n');
    } catch (e) {
        console.log('⚠️ Коммит не создан (возможно, нет изменений или уже закоммичено)\n');
    }

    // Шаг 5: Проверка remotes
    console.log('[5/6] Проверка remotes...');
    const remotes = execSync('git remote -v', { encoding: 'utf-8' });
    console.log(remotes);
    console.log('');

    // Шаг 6: Push в GitHub
    console.log('[6/6] Отправка в GitHub...');
    const remoteList = execSync('git remote', { encoding: 'utf-8' });
    
    // Используем только github remote (origin теперь тоже GitHub)
    if (remoteList.includes('github')) {
        console.log('Используем remote: github');
        try {
            execSync('git push github main', { stdio: 'inherit' });
            console.log('\n✅ Изменения отправлены в GitHub!');
        } catch (e) {
            // Если push отклонён, пробуем force (осторожно!)
            console.log('\n⚠️ Push отклонён. Пробуем с --force-with-lease (безопасный force)...');
            execSync('git push github main --force-with-lease', { stdio: 'inherit' });
            console.log('\n✅ Изменения отправлены в GitHub!');
        }
    } else {
        console.log('Используем remote: origin (должен быть GitHub)');
        try {
            execSync('git push origin main', { stdio: 'inherit' });
            console.log('\n✅ Изменения отправлены!');
        } catch (e) {
            console.log('\n⚠️ Push отклонён. Пробуем с --force-with-lease...');
            execSync('git push origin main --force-with-lease', { stdio: 'inherit' });
            console.log('\n✅ Изменения отправлены!');
        }
    }

    console.log('\n✅ Готово!');
} catch (error) {
    console.error('\n❌ Ошибка:', error.message);
    process.exit(1);
}

