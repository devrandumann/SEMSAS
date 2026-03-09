# MySQL Database Setup Instructions

## Quick Start

To set up the complete SEMSAS database in MySQL, run:

```bash
mysql -u root -p StoreManagement < mysql_init.sql
```

This will:
- Create all 12 tables
- Insert sample data (5 stores, 10 products, 20 employees, etc.)
- Create Users table with admin and manager accounts

## What's Included

### Tables Created (12 total)
1. **Store** - 5 stores
2. **Category** - 5 categories (Dairy, Beverages, Snacks, Bakery, Produce)
3. **Brand** - 5 brands (Nestle, Coca-Cola, Farmer Fresh, BakeHouse, OrganicValley)
4. **Product** - 10 products
5. **Shelf** - 25 shelves across all stores
6. **Employee** - 20 employees (4 per store)
7. **Batch_Lot** - 12 batch lots
8. **Inventory** - 25 inventory records
9. **Alert** - 15 alerts
10. **Price_History** - 15 price changes
11. **Promotion** - 10 active promotions
12. **Users** - 6 users (1 admin + 5 managers)

### Login Credentials

> **⚠️ SECURITY WARNING:** The passwords below are placeholders. Please refer to your local `.env.sh` or database configuration for the actual credentials. **Never** commit real passwords to GitHub.

**Admin:**
- Username: `admin`
- Password: `<YOUR_ADMIN_PASSWORD_HERE>`

**Managers:**
- 6517 / `<YOUR_MANAGER_PASSWORD_HERE>` (Birol Sezer - Dolayoba M)
- 5244 / `<YOUR_MANAGER_PASSWORD_HERE>` (Temel Reis - Esref Bitlis Mjet)
- 3277 / `<YOUR_MANAGER_PASSWORD_HERE>` (Sefacan Ozgun - Velibaba Mjet)
- 4456 / `<YOUR_MANAGER_PASSWORD_HERE>` (Bektas Baltaci - Bosna Mjet)
- 8696 / `<YOUR_MANAGER_PASSWORD_HERE>` (Kadir Ozyilmaz - Baku M)

**Demo Account (Publicly accessible/restricted capabilities):**
- Username: `demo`
- Password: `demo`

## Files

- **mysql_init.sql** - Complete MySQL setup (USE THIS)

## Notes

- The script uses `INSERT IGNORE` so it's safe to run multiple times
- Foreign key constraints are properly set up
- All manager names match the Employee table
- Password hashes are bcrypt-generated

---

**Ready to use!** Just run the command above and your database will be fully set up.
