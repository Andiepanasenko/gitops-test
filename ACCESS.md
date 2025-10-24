# 🔐 Доступ до сервісів

## 📊 ArgoCD (GitOps)

**Команда для доступу:**
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

**З'єднання:**
- URL: https://localhost:8080
- Username: `admin`
- Password: `DatJQojBvqBxHe-N`

**Повна команда отримання пароля:**
```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

---

## 📈 Grafana (Моніторинг)

**Команда для доступу:**
```bash
kubectl port-forward svc/victoria-metrics-grafana -n monitoring 3000:80
```

**З'єднання:**
- URL: http://localhost:3000
- Username: `admin`
- Password: `admin`

---

## 📊 VictoriaMetrics (Метрики)

**Команда для доступу:**
```bash
kubectl port-forward svc/vmsingle-victoria-metrics-victoria-metrics-k8s-stack -n monitoring 8428:8428
```

**З'єднання:**
- URL: http://localhost:8428
- Метрики: http://localhost:8428/metrics
- Без авторизації

---

## 🚀 spam2000 Application

**Команда для доступу:**
```bash
kubectl port-forward svc/spam2000 -n spam2000 3000:80
```

**З'єднання:**
- URL: http://localhost:3000
- Метрики: http://localhost:3000/metrics
- Health check: http://localhost:3000/health
- Без авторизації

---

## 📝 Швидкий доступ

### Всі команди разом:
```bash
# ArgoCD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Grafana
kubectl port-forward svc/victoria-metrics-grafana -n monitoring 3001:80

# spam2000
kubectl port-forward svc/spam2000 -n spam2000 3002:80
```

### Перевірка статусу:
```bash
# Всі поды
kubectl get pods -A

# Конкретний namespace
kubectl get pods -n spam2000
kubectl get pods -n monitoring
kubectl get pods -n argocd
```

---

## 🔍 Корисні команди

### Перевірка логів:
```bash
# spam2000
kubectl logs -n spam2000 -l app=spam2000 --tail=100

# ArgoCD
kubectl logs -n argocd argocd-server-xxx

# Grafana
kubectl logs -n monitoring victoria-metrics-grafana-xxx
```

### Перезапуск сервісів:
```bash
# spam2000
kubectl rollout restart deployment/spam2000 -n spam2000

# ArgoCD
kubectl rollout restart deployment/argocd-server -n argocd
```

---

## ⚠️ Важливо

1. **ArgoCD пароль** генерується автоматично при кожній установці
2. **Grafana пароль** по замовчуванню `admin` (рекомендується змінити після першого входу)
3. Після першого входу в ArgoCD видаліть початковий secret:
   ```bash
   kubectl -n argocd delete secret argocd-initial-admin-secret
   ```

---

## 📌 Порт-мейпінг

| Сервіс | Namespace | Локальний порт | Цільовий порт |
|--------|-----------|----------------|---------------|
| ArgoCD | argocd | 8080 | 443 |
| Grafana | monitoring | 3000 | 80 |
| spam2000 | spam2000 | 3000 | 80 |
| VictoriaMetrics | monitoring | 8428 | 8428 |

⚠️ **Увага:** Якщо порти конфліктують, використовуйте інші локальні порти в командах port-forward.

