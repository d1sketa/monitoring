#!/bin/bash

# Определяем IP адреса ваших виртуальных машин
VM_IPS=("192.168.0.76" "192.168.0.68" "192.168.0.42")

# Определяем логин пользователя
SSH_USER="userx"

# Имя для нашей сессии tmux (изменим имя, чтобы не конфликтовать с предыдущей попыткой)
TMUX_SESSION_NAME="vbox_servers_sendkeys"

echo "Подготовка к подключению к ВМ: ${VM_IPS[*]} под пользователем $SSH_USER используя send-keys..."

# Проверяем, установлен ли tmux
if ! command -v tmux &> /dev/null; then
    echo "Ошибка: tmux не найден. Пожалуйста, установите tmux на вашей локальной машине."
    exit 1
fi

# Проверяем, существует ли уже сессия с таким именем
tmux has-session -t $TMUX_SESSION_NAME 2>/dev/null

if [ $? == 0 ]; then
    echo "Сессия tmux '$TMUX_SESSION_NAME' уже существует. Подключаемся к ней."
    # Если сессия уже есть, просто подключаемся
    tmux attach-session -t $TMUX_SESSION_NAME
else
    echo "Создаем новую сессию tmux '$TMUX_SESSION_NAME' и запускаем подключения через send-keys..."

    # Создаем новую сессию tmux в отсоединенном режиме (-d)
    # Создаем первое окно с именем IP адреса
    tmux new-session -d -s $TMUX_SESSION_NAME -n "${VM_IPS[0]}"

    # Отправляем команду ssh в первое окно (индекс 0)
    # C-m эквивалентно нажатию Enter
    tmux send-keys -t $TMUX_SESSION_NAME:0 "ssh $SSH_USER@${VM_IPS[0]}" C-m

    # Добавляем остальные ВМ в новые окна tmux и отправляем команды ssh
    # Проходим по массиву IP адресов, начиная со второго элемента (индекс 1)
    for (( i=1; i<${#VM_IPS[@]}; i++ )); do
        # Создаем новое пустое окно (-n) в текущей сессии (-t) с именем IP адреса
        tmux new-window -t $TMUX_SESSION_NAME -n "${VM_IPS[$i]}"

        # Отправляем команду ssh в только что созданное окно (индекс окна будет равен i)
        # C-m эквивалентно нажатию Enter
        tmux send-keys -t $TMUX_SESSION_NAME:$i "ssh $SSH_USER@${VM_IPS[$i]}" C-m

        # Небольшая пауза может помочь в некоторых случаях, но часто не нужна
        # sleep 0.1
    done

    # Переключаемся на первое окно (индекс 0) перед подключением
    # Это гарантирует, что при подключении вы увидите окно с первой ВМ
    tmux select-window -t $TMUX_SESSION_NAME:0

    echo "Сессия tmux готова. Подключаемся..."

    # Подключаемся к созданной сессии tmux
    # Это откроет терминал и покажет вам окна tmux
    tmux attach-session -t $TMUX_SESSION_NAME

    echo "Сессия tmux завершена."
fi

exit 0
