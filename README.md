# 🚀 GitOps Infrastructure для spam2000

Цей проект містить повну GitOps інфраструктуру для розгортання додатку spam2000 з системою моніторингу.

## 📋 Вміст

- [Технічний стек](#технічний-стек)
- [Архітектура](#архітектура)
- [Вимоги](#вимоги)
- [Встановлення](#встановлення)
- [Використання](#використання)
- [GitOps](#gitops)
- [Моніторинг](#моніторинг)
- [Структура проекту](#структура-проекту)

## 🛠 Технічний стек

| Компонент | Технологія | Призначення |
| --- | --- | --- |
| **Orchestration** | Minikube | Локальний Kubernetes кластер |
| **Monitoring** | VictoriaMetrics | Збір та зберігання метрик |
| **Visualization** | Grafana | Дашборди та візуалізація |
| **Package Manager** | Helm | Управління Kubernetes застосунками |
| **GitOps** | ArgoCD | Автоматичне синхронізування з Git |
| **Application** | spam2000 | Додаток який генерує метрики |

## 🏗 Архітектура

```
┌─────────────────────────────────────────────────────────────┐
│                        Minikube Cluster                      │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │   ArgoCD     │  │ VictoriaMetrics│ │   Grafana   │      │
│  │  (GitOps)    │  │  (Metrics DB) │ │ (Dashboards) │      │
│  └──────────────┘  └──────────────┘  └──────────────┘      │
│                                                               │
│  ┌────────────────────────────────────────────────────┐     │
│  │            spam2000 Application                    │     │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐        │     │
│  │  │   Pod 1  │  │   Pod 2  │  │   Pod N  │        │     │
│  │  └──────────┘  └──────────┘  └──────────┘        │     │
│  └────────────────────────────────────────────────────┘     │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

## ✅ Вимоги

Перед початком встановлення переконайтеся, що у вас встановлено:

- **kubectl** >= 1.24
- **helm** >= 3.8
- **minikube** >= 1.28
- **git** (для клонування репозиторію)

### Перевірка вимог

```bash
kubectl version --client
helm version
minikube version
```

## 🚀 Встановлення

### 1. Клонуйте репозиторій

```bash
git clone https://github.com/Andiepanasenko/gitops-test.git
cd gitops-test
```

### 2. Запустіть скрипт встановлення

```bash
./setup.sh
```

Цей скрипт автоматично виконає всі необхідні кроки:
- ✅ Запустить Minikube кластер
- ✅ Встановить ArgoCD для GitOps
- ✅ Встановить VictoriaMetrics для моніторингу
- ✅ Встановить Grafana з попередньо налаштованими дашбордами
- ✅ Розгорне spam2000 додаток
- ✅ Налаштує GitOps синхронізацію

**Час виконання:** ~5-10 хвилин

## 📖 Використання

### Доступ до ArgoCD (GitOps UI)

```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

- URL: https://localhost:8080
- Username: `admin`
- Password: (отримайте командою нижче)

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Доступ до Grafana

```bash
kubectl port-forward svc/grafana -n monitoring 3000:80
```

- URL: http://localhost:3000
- Username: `admin`
- Password: `admin`

### Доступ до додатку spam2000

```bash
kubectl port-forward svc/spam2000 -n spam2000 3000:80
```

- URL: http://localhost:3000
- Метрики: http://localhost:3000/metrics

### Перевірка статусу додатку

```bash
# Перевірка pod'ів
kubectl get pods -n spam2000

# Перевірка сервісів
kubectl get svc -n spam2000

# Перевірка всіх ресурсів
kubectl get all -n spam2000
```

### Перевірка моніторингу

```bash
# Перевірка VictoriaMetrics
kubectl get pods -n monitoring

# Перевірка Grafana
kubectl get pods -n monitoring | grep grafana

# Перевірка метрик
kubectl port-forward svc/victoria-metrics-k8s-stack-victoria-metrics -n monitoring 8428:8428
curl http://localhost:8428/metrics
```

## 🔄 GitOps

### Налаштування GitOps після створення репозиторію

1. **Оновіть URL в манифесті:**
   ```bash
   # Відредагуйте файл manifests/argocd-app.yaml
   # Замініть Andiepanasenko/gitops-test якщо потрібно
   ```

2. **Створіть репозиторій на GitHub:**
   ```bash
   git init
   git add .
   git commit -m "Initial commit: GitOps infrastructure"
   git remote add origin https://github.com/Andiepanasenko/gitops-test.git
   git push -u origin main
   ```

3. **Застосуйте ArgoCD Application:**
   ```bash
   kubectl apply -f manifests/argocd-app.yaml
   ```

4. **Перевірте в ArgoCD UI:**
   - Відкрийте https://localhost:8080
   - Зайдіть як admin
   - Перевірте статус додатку

### Як працює GitOps

1. ArgoCD моніторить ваш Git репозиторій
2. При зміні конфігурації в Git, ArgoCD автоматично синхронізує зміни
3. Kubernetes ресурси оновлюються автоматично

### Тестування GitOps

1. Відредагуйте `helm/spam2000/values.yaml`:
   ```yaml
   replicas: 3  # Змініть з 2 на 3
   ```

2. Закомітьте зміни:
   ```bash
   git add helm/spam2000/values.yaml
   git commit -m "Scale spam2000 to 3 replicas"
   git push
   ```

3. ArgoCD автоматично виявить зміни та оновить deployment

4. Перевірте в ArgoCD UI або командою:
   ```bash
   kubectl get pods -n spam2000
   ```

### Manual синхронізація

```bash
# Через UI ArgoCD або CLI
argocd app sync spam2000-app
```

## 📊 Моніторинг

### Дашборди Grafana

Після запуску ви отримаєте два готові дашборди:

1. **Kubernetes Cluster Overview** - моніторинг кластера
   - CPU Usage
   - Memory Usage
   - Pod Status
   - Node Status

2. **spam2000 Application Monitoring** - моніторинг додатку
   - HTTP Requests Rate
   - Active Pods
   - Pod CPU Usage
   - Pod Memory Usage
   - Request Latency

### Метрики spam2000

Додаток автоматично експортує метрики в Prometheus формат:
- `http_requests_total` - кількість HTTP запитів
- `http_request_duration_seconds` - затримка запитів

## 📁 Структура проекту

```
pdffiller-infra/
├── setup.sh                          # Основний скрипт встановлення
├── README.md                          # Ця документація
├── main.py                            # Старий файл (можна видалити)
│
├── helm/                              # Helm charts
│   └── spam2000/
│       ├── Chart.yaml                 # Опис chart'у
│       ├── values.yaml                # Конфігурація за замовчуванням
│       └── templates/
│           ├── deployment.yaml        # Kubernetes Deployment
│           ├── service.yaml           # Kubernetes Service
│           └── servicemonitor.yaml   # Prometheus ServiceMonitor
│
├── manifests/                         # Kubernetes manifests
│   ├── argocd-app.yaml               # ArgoCD Application
│   └── grafana-dashboards.yaml       # Grafana dashboards ConfigMap
│
└── dashboards/                        # JSON файли дашбордів
    ├── cluster-overview.json          # Dashboard для кластера
    └── spam2000-app.json             # Dashboard для додатку
```

## ⚙️ Конфігурація

### Зміна параметрів spam2000

Відредагуйте `helm/spam2000/values.yaml`:

```yaml
replicas: 2                    # Кількість копій додатку
env:
  requestRate: "10"            # Інтенсивність запитів
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### Оновлення через GitOps

```bash
# 1. Змініть values.yaml
# 2. Коміт та push
git add helm/spam2000/values.yaml
git commit -m "Update spam2000 configuration"
git push

# 3. ArgoCD автоматично синхронізує зміни
```

## 🧹 Очищення

### Видалення всіх компонентів

```bash
# Видалення ArgoCD
helm uninstall argocd -n argocd
kubectl delete namespace argocd

# Видалення spam2000
helm uninstall spam2000 -n spam2000
kubectl delete namespace spam2000

# Видалення моніторингу
helm uninstall victoria-metrics -n monitoring
helm uninstall grafana -n monitoring
kubectl delete namespace monitoring

# Зупинка Minikube
minikube stop
minikube delete
```

### Повне очищення

```bash
minikube delete
```

## 🐛 Troubleshooting

### Проблеми з Minikube

```bash
# Перевірка статусу
minikube status

# Перезапуск
minikube stop
minikube start

# Перегляд логів
minikube logs
```

### Проблеми з подами

```bash
# Перевірка логів
kubectl logs -n spam2000 <pod-name>

# Опис пода
kubectl describe pod -n spam2000 <pod-name>

# Перезапуск додатку
kubectl rollout restart deployment/spam2000 -n spam2000
```

### Проблеми з метриками

```bash
# Перевірка ServiceMonitor
kubectl get servicemonitor -n spam2000

# Перевірка метрик
kubectl port-forward svc/spam2000 -n spam2000 8080:80
curl http://localhost:8080/metrics
```

## 📝 Ліцензія

Цей проект створено для тестового завдання DevOps Engineer.

## 👤 Автор

Ваше ім'я

---

**Успіхів з розгортанням! 🚀**

