#  Vinu AWS – DevOps Task 2

Bu proje, üç katmanlı (Frontend, Backend, Database) bir uygulamanın **Dockerize edilmesi**, **AWS üzerinde Terraform ile EC2 kurulumu**, **ECR üzerinden image yönetimi**, ve **GitHub Actions ile CI/CD süreci** kullanılarak deployment edilmesini kapsar.  

## 📂 Proje Yapısı

Vinu-AWS
│
├── backend
│ ├── app.py # Flask uygulaması (DB health check ile)
│ └── Dockerfile 
├── frontend
│ ├── html/index.html # Statik HTML frontend
│ ├── Dockerfile (nginx tabanlı)
│ └── nginx.conf # Reverse proxy ayarları
├── infra
│ ├── main.tf 
│ ├── variables.tf 
│ ├── outputs.tf 
├── docker-compose.yaml 
└── .github/workflows
└── deploy.yml 

---

## Kullanılan Teknolojiler

- **Backend:** Python (Flask)  
- **Frontend:** Nginx + static HTML  
- **Database:** MySQL 8.4  
- **Orkestration:** Docker & Docker Compose  
- **Infrastructure:** Terraform + AWS (EC2, ECR, VPC)  
- **Reverse Proxy:** Nginx  
- **CI/CD:** GitHub Actions  

---

## İzlenen Yöntem

1. **Lokal Test (Docker Compose)**
   - Frontend, Backend ve Database servisleri `docker-compose.yaml` ile ayağa kaldırıldı.
   - Testler:
     - `http://localhost/` → frontend  
     - `http://localhost/api/hello` → backend + DB health check  

2. **Containerization**
   - Backend ve Frontend için Dockerfile yazıldı.  
   - MySQL için official image (`mysql:8.4`) kullanıldı.  

3. **AWS Altyapısı (Terraform)**
   - Terraform ile bir EC2 instance oluşturuldu.  
   - `outputs.tf` ile EC2 public IP çıktı olarak alındı.  

4. **ECR Repository & Image Push**
   - AWS ECR üzerinde `vinu-frontend` ve `vinu-backend` repo’ları oluşturuldu.  
   - Docker imajları build edilip ECR’a push edildi.  

5. **CI/CD Pipeline (GitHub Actions)**
   - Kod `main` branch’e push edilince pipeline tetiklendi.  
   - Pipeline adımları:
     1. Repo checkout  
     2. AWS credentials configure  
     3. ECR login  
     4. Frontend & Backend image build & push  
     5. EC2’ye SSH ile bağlan → `docker compose pull && docker compose up -d`  

6. **Deployment & Test**
   - EC2 public IP üzerinden erişim test edildi:
     - `http://<EC2_IP>/` → frontend  
     - `http://<EC2_IP>/api/hello` → backend + DB kontrol  

---

## 🔄 CI/CD Akışı

1. Developer kodu `main` branch’e push eder.  
2. GitHub Actions pipeline çalışır:  
   - Docker image build  
   - ECR’a push  
   - EC2’ye SSH ile bağlanma  
   - Yeni imajları çekme ve container’ları ayağa kaldırma  
3. Kullanıcı EC2 public IP üzerinden uygulamaya erişir.  

---

