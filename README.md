# 🛒 SEMSAS — Smart Expiry Management & Shelf Alert System

A web-based store management application built with **Flask** and **MySQL**. SEMSAS helps retail stores track product inventory, monitor expiry dates, manage shelves, and receive alerts for low stock or near-expiry products — all from a centralized dashboard.

---

## ✨ Features

- 🔐 **Role-based authentication** — Admin, Manager, and Demo roles
- 📦 **Product & inventory management** — Add, view, and delete products across stores
- 📅 **Expiry date tracking** — Alerts for products expiring within 30 days
- 🏪 **Multi-store support** — Admins see all stores; managers see only their store
- 🔔 **Real-time alerts** — Low stock and expiry warnings
- 🏷️ **Promotions & pricing** — Track active promotions and price history
- 🗂️ **Shelf management** — Organize products by shelf location and temperature type
- 📊 **CSV export** — Generate and download inventory reports

---

## 🛠️ Tech Stack

| Layer      | Technology                   |
|------------|------------------------------|
| Backend    | Python 3, Flask              |
| Auth       | Flask-Login, bcrypt          |
| Database   | MySQL                        |
| Frontend   | HTML, CSS, JavaScript        |
| API        | RESTful JSON API (Flask)     |

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/devrandumann/SEMSAS.git
cd SEMSAS
```

### 2. Create a Virtual Environment

```bash
python3 -m venv .venv
source .venv/bin/activate   # Windows: .venv\Scripts\activate
```

### 3. Install Dependencies

```bash
pip install -r requirements.txt
```

### 4. Set Up the Database

Make sure MySQL is running, then import the database schema and sample data:

```bash
mysql -u root -p StoreManagement < mysql_init.sql
```

> This creates 12 tables with sample data: 5 stores, 10 products, 20 employees, 6 users, and more.  
> See [DATABASE_SETUP.md](DATABASE_SETUP.md) for full details.

### 5. Configure Environment Variables (Optional)

You can override default database settings via environment variables or the `.env.sh` file:

```bash
export DB_HOST=localhost
export DB_USER=root
export DB_PASSWORD=your_password
export DB_NAME=StoreManagement
export DB_PORT=3306
export SECRET_KEY=your-secret-key
```

Or source the provided script:

```bash
source .env.sh
```

### 6. Run the Application

```bash
python app.py
```

Open your browser at: **http://localhost:8000**

---

## 🔑 Login Credentials

> **Note:** Admin and Store Manager accounts have private, restricted passwords for security reasons.

However, you can explore the application using the **Demo** role! Demo users can view all data but cannot add, edit, or delete anything.

### Demo User
| Username | Password |
|----------|----------|
| `demo`   | `demo`   |


---

## 📁 Project Structure

```
SEMSAS/
├── app.py               # Main Flask application & all API routes
├── mysql_init.sql       # Full database setup with sample data
├── requirements.txt     # Python dependencies
├── .env.sh              # Environment variable configuration
├── static/              # CSS, JS, images
├── templates/           # Jinja2 HTML templates
├── DATABASE_SETUP.md    # Database setup guide
└── SQL_EXAMPLES.md      # Example SQL queries
```

---

## 📡 Key API Endpoints

| Method | Endpoint                      | Description                  |
|--------|-------------------------------|------------------------------|
| POST   | `/api/login`                  | User login                   |
| POST   | `/api/logout`                 | User logout                  |
| GET    | `/api/dashboard/summary`      | Dashboard stats              |
| GET    | `/api/products`               | List all products            |
| POST   | `/api/products`               | Add a new product            |
| DELETE | `/api/products/<id>`          | Delete a product             |
| GET    | `/api/products/expiring`      | Products expiring in 30 days |
| GET    | `/api/alerts`                 | Recent alerts                |
| GET    | `/api/stores`                 | List stores                  |
| GET    | `/api/shelves`                | List shelves                 |
| GET    | `/api/promotions`             | Active promotions            |
| GET    | `/api/reports/generate`       | Download CSV report          |

---

## 📄 License

This project is for educational purposes.
