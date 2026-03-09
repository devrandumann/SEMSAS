# SEMSAS - SQL Examples Guide

Bu dokümanda SEMSAS (Smart Expiry Management & Shelf Alert System) projesine özel SQL örnekleri bulunmaktadır.

---

## 1. Creation (CREATE) - Tablo Oluşturma

### Örnek 1: Primary Key ve Foreign Key ile Tablo
```sql
-- Yeni bir tablo oluşturma: Supplier (Tedarikçi)
CREATE TABLE Supplier (
    Supplier_ID INT PRIMARY KEY,
    Supplier_Name VARCHAR(100) NOT NULL,
    Contact_Person VARCHAR(100),
    Phone VARCHAR(20),
    Email VARCHAR(100),
    Address TEXT,
    CONSTRAINT chk_phone CHECK (Phone LIKE '___-____')
);
```

### Örnek 2: Foreign Key Constraint ile Tablo
```sql
-- Tedarikçi ile ürün ilişkisi için tablo
CREATE TABLE Product_Supplier (
    Product_Supplier_ID INT PRIMARY KEY AUTO_INCREMENT,
    Product_ID INT NOT NULL,
    Supplier_ID INT NOT NULL,
    Supply_Date DATE,
    Unit_Price DECIMAL(10, 2),
    FOREIGN KEY (Product_ID) REFERENCES Product(Product_ID) ON DELETE CASCADE,
    FOREIGN KEY (Supplier_ID) REFERENCES Supplier(Supplier_ID) ON DELETE RESTRICT
);
```

---

## 2. Insertion (INSERT) - Veri Ekleme

### Örnek 1: Tek Kayıt Ekleme
```sql
-- Yeni bir mağaza ekleme
INSERT INTO Store (Store_ID, Name, Address, Contact_Info)
VALUES (9999, 'Kadikoy M', 'Kadikoy Street', '850 229 9999');
```

### Örnek 2: Çoklu Kayıt Ekleme
```sql
-- Birden fazla kategori ekleme
INSERT INTO Category (Category_ID, Category_Name) VALUES
(6, 'Frozen Foods'),
(7, 'Meat & Poultry'),
(8, 'Cleaning Supplies');
```

### Örnek 3: Mevcut Veriden Yeni Kayıt Oluşturma
```sql
-- Süresi yaklaşan ürünler için otomatik promosyon oluşturma
INSERT INTO Promotion (Promotion_ID, Promotion_Name, Start_Date, End_Date, Discount_Type, Discount_Value, Product_ID)
SELECT 
    (SELECT MAX(Promotion_ID) + 1 FROM Promotion),
    CONCAT('Urgent Sale - ', p.Product_Name),
    CURDATE(),
    bl.Expiry_Date,
    'Percentage',
    40.00,
    p.Product_ID
FROM Product p
JOIN Batch_Lot bl ON p.Product_ID = bl.Product_ID
WHERE bl.Expiry_Date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
LIMIT 1;
```

---

## 3. Updating (UPDATE) - Veri Güncelleme

### Örnek 1: Basit Güncelleme
```sql
-- Bir ürünün fiyatını güncelleme
UPDATE Product
SET Current_Price = 4.00
WHERE Product_ID = 101;
```

### Örnek 2: WHERE ile Koşullu Güncelleme
```sql
-- Belirli bir mağazadaki tüm rafların kapasitesini artırma
UPDATE Shelf
SET Capacity = Capacity * 1.2
WHERE Store_ID = 6517 AND Temperature_Type = 'Ambient';
```

### Örnek 3: JOIN ile Güncelleme
```sql
-- Süresi geçmiş ürünlerin stok durumunu güncelleme
UPDATE Inventory i
JOIN Batch_Lot bl ON i.Batch_Lot_ID = bl.Batch_Lot_ID
SET i.Status = 'Expired'
WHERE bl.Expiry_Date < CURDATE() AND i.Status = 'On Shelf';
```

### Örnek 4: Fiyat Geçmişi ile Güncelleme
```sql
-- Ürün fiyatını güncellerken fiyat geçmişine kayıt ekleme
-- Önce fiyat geçmişine ekle
INSERT INTO Price_History (Price_History_ID, Product_ID, Employee_ID, Old_Price, New_Price)
SELECT 
    (SELECT COALESCE(MAX(Price_History_ID), 0) + 1 FROM Price_History),
    101,
    1,
    Current_Price,
    5.00
FROM Product WHERE Product_ID = 101;

-- Sonra ürün fiyatını güncelle
UPDATE Product
SET Current_Price = 5.00
WHERE Product_ID = 101;
```

---

## 4. Deletion (DELETE) - Veri Silme

### Örnek 1: Basit Silme
```sql
-- Belirli bir promosyonu silme
DELETE FROM Promotion
WHERE Promotion_ID = 5;
```

### Örnek 2: Koşullu Silme
```sql
-- Süresi geçmiş ve çözülmüş uyarıları silme
DELETE FROM Alert
WHERE Alert_Date < DATE_SUB(CURDATE(), INTERVAL 30 DAY)
AND Status = 'Resolved';
```

### Örnek 3: Subquery ile Silme
```sql
-- Stokta olmayan ürünlerin batch kayıtlarını silme
DELETE FROM Batch_Lot
WHERE Batch_Lot_ID NOT IN (
    SELECT DISTINCT Batch_Lot_ID 
    FROM Inventory 
    WHERE Quantity > 0
)
AND Expiry_Date < CURDATE();
```

---

## 5. Selection (SELECT) - Veri Sorgulama

### Örnek 1: Basit SELECT
```sql
-- Tüm ürünleri listele
SELECT * FROM Product;
```

### Örnek 2: Belirli Sütunları Seçme
```sql
-- Ürün adı ve fiyatlarını listele
SELECT Product_Name, Current_Price
FROM Product
ORDER BY Current_Price DESC;
```

### Örnek 3: JOIN ile İlişkili Veriler
```sql
-- Ürünleri kategori ve marka bilgileriyle birlikte listele
SELECT 
    p.Product_ID,
    p.Product_Name,
    p.Current_Price,
    c.Category_Name,
    b.Brand_Name
FROM Product p
LEFT JOIN Category c ON p.Category_ID = c.Category_ID
LEFT JOIN Brand b ON p.Brand_ID = b.Brand_ID
ORDER BY p.Product_Name;
```

### Örnek 4: Aggregate Functions (Toplam Fonksiyonlar)
```sql
-- Her mağazadaki toplam çalışan sayısı
SELECT 
    s.Name AS Store_Name,
    COUNT(e.Employee_ID) AS Employee_Count,
    COUNT(CASE WHEN e.Position = 'Manager' THEN 1 END) AS Manager_Count
FROM Store s
LEFT JOIN Employee e ON s.Store_ID = e.Store_ID
GROUP BY s.Store_ID, s.Name
ORDER BY Employee_Count DESC;
```

---

## 6. Filtering (WHERE) - Filtreleme

### Örnek 1: Karşılaştırma Operatörleri (=, <>, >, <, >=, <=)
```sql
-- Fiyatı 3 TL'den pahalı ürünler
SELECT Product_Name, Current_Price
FROM Product
WHERE Current_Price > 3.00;

-- Fiyatı tam 2.50 TL olan ürünler
SELECT Product_Name, Current_Price
FROM Product
WHERE Current_Price = 2.50;

-- Fiyatı 2 TL'den farklı olan ürünler
SELECT Product_Name, Current_Price
FROM Product
WHERE Current_Price <> 2.00;
```

### Örnek 2: Mantıksal Operatörler (AND, OR, NOT)
```sql
-- Süt ürünleri VE fiyatı 4 TL'den az olanlar
SELECT p.Product_Name, p.Current_Price, c.Category_Name
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
WHERE c.Category_Name = 'Dairy' AND p.Current_Price < 4.00;

-- Beverages VEYA Snacks kategorisindeki ürünler
SELECT p.Product_Name, c.Category_Name
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
WHERE c.Category_Name = 'Beverages' OR c.Category_Name = 'Snacks';

-- Nestle markası OLMAYAN ürünler
SELECT p.Product_Name, b.Brand_Name
FROM Product p
JOIN Brand b ON p.Brand_ID = b.Brand_ID
WHERE NOT b.Brand_Name = 'Nestle';
```

### Örnek 3: BETWEEN, IN, LIKE
```sql
-- Fiyatı 2-4 TL arasında olan ürünler
SELECT Product_Name, Current_Price
FROM Product
WHERE Current_Price BETWEEN 2.00 AND 4.00;

-- Belirli kategorilerdeki ürünler
SELECT p.Product_Name, c.Category_Name
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
WHERE c.Category_Name IN ('Dairy', 'Beverages', 'Bakery');

-- İsmi 'Milk' içeren ürünler
SELECT Product_Name
FROM Product
WHERE Product_Name LIKE '%Milk%';
```

### Örnek 4: Tarih Filtreleme
```sql
-- Son 7 gün içinde süresi dolacak ürünler
SELECT 
    p.Product_Name,
    bl.Expiry_Date,
    DATEDIFF(bl.Expiry_Date, CURDATE()) AS Days_Until_Expiry
FROM Batch_Lot bl
JOIN Product p ON bl.Product_ID = p.Product_ID
WHERE bl.Expiry_Date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 7 DAY)
ORDER BY bl.Expiry_Date;
```

---

## 7. Sorting (ORDER BY) - Sıralama

### Örnek 1: Artan Sıralama (ASC)
```sql
-- Ürünleri fiyata göre ucuzdan pahalıya sırala
SELECT Product_Name, Current_Price
FROM Product
ORDER BY Current_Price ASC;
```

### Örnek 2: Azalan Sıralama (DESC)
```sql
-- Ürünleri fiyata göre pahalıdan ucuza sırala
SELECT Product_Name, Current_Price
FROM Product
ORDER BY Current_Price DESC;
```

### Örnek 3: Çoklu Sütun Sıralama
```sql
-- Önce kategoriye göre, sonra fiyata göre sırala
SELECT 
    c.Category_Name,
    p.Product_Name,
    p.Current_Price
FROM Product p
JOIN Category c ON p.Category_ID = c.Category_ID
ORDER BY c.Category_Name ASC, p.Current_Price DESC;
```

### Örnek 4: Hesaplanan Değere Göre Sıralama
```sql
-- Ürünleri son kullanma tarihine göre en yakından en uzağa sırala
SELECT 
    p.Product_Name,
    bl.Expiry_Date,
    DATEDIFF(bl.Expiry_Date, CURDATE()) AS Days_Remaining
FROM Batch_Lot bl
JOIN Product p ON bl.Product_ID = p.Product_ID
WHERE bl.Expiry_Date >= CURDATE()
ORDER BY Days_Remaining ASC;
```

---

## 8. Subqueries (SUBQUERY) - Alt Sorgular

### Örnek 1: SELECT içinde SELECT
```sql
-- Her ürün için ortalama fiyatın üzerinde olanları bul
SELECT 
    Product_Name,
    Current_Price,
    (SELECT AVG(Current_Price) FROM Product) AS Average_Price
FROM Product
WHERE Current_Price > (SELECT AVG(Current_Price) FROM Product)
ORDER BY Current_Price DESC;
```

### Örnek 2: WHERE'de Subquery
```sql
-- En pahalı ürünün bulunduğu kategoriyi bul
SELECT Category_Name
FROM Category
WHERE Category_ID = (
    SELECT Category_ID
    FROM Product
    ORDER BY Current_Price DESC
    LIMIT 1
);
```

### Örnek 3: FROM'da Subquery
```sql
-- Her mağazadaki ortalama stok miktarı
SELECT 
    Store_Name,
    AVG(Total_Stock) AS Avg_Stock_Per_Shelf
FROM (
    SELECT 
        s.Name AS Store_Name,
        sh.Shelf_ID,
        COALESCE(SUM(i.Quantity), 0) AS Total_Stock
    FROM Store s
    JOIN Shelf sh ON s.Store_ID = sh.Store_ID
    LEFT JOIN Inventory i ON sh.Shelf_ID = i.Shelf_ID
    GROUP BY s.Name, sh.Shelf_ID
) AS shelf_stocks
GROUP BY Store_Name;
```

### Örnek 4: IN ile Subquery
```sql
-- Aktif promosyonu olan ürünleri listele
SELECT Product_Name, Current_Price
FROM Product
WHERE Product_ID IN (
    SELECT DISTINCT Product_ID
    FROM Promotion
    WHERE End_Date >= CURDATE()
    AND Product_ID IS NOT NULL
);
```

### Örnek 5: EXISTS ile Subquery
```sql
-- Stokta olan ürünleri bul
SELECT p.Product_Name
FROM Product p
WHERE EXISTS (
    SELECT 1
    FROM Batch_Lot bl
    JOIN Inventory i ON bl.Batch_Lot_ID = i.Batch_Lot_ID
    WHERE bl.Product_ID = p.Product_ID
    AND i.Quantity > 0
);
```

### Örnek 6: Karmaşık Subquery - En Çok Uyarı Alan Mağaza
```sql
-- En çok uyarı alan mağazayı ve detaylarını bul
SELECT 
    s.Name AS Store_Name,
    alert_counts.Total_Alerts,
    alert_counts.Pending_Alerts,
    alert_counts.Critical_Alerts
FROM Store s
JOIN (
    SELECT 
        e.Store_ID,
        COUNT(*) AS Total_Alerts,
        SUM(CASE WHEN a.Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Alerts,
        SUM(CASE WHEN a.Alert_Type = 'Critical Expiry' THEN 1 ELSE 0 END) AS Critical_Alerts
    FROM Alert a
    JOIN Employee e ON a.Employee_ID = e.Employee_ID
    GROUP BY e.Store_ID
) AS alert_counts ON s.Store_ID = alert_counts.Store_ID
ORDER BY alert_counts.Total_Alerts DESC
LIMIT 1;
```

---

## 9. Kompleks Örnekler - SEMSAS Özel

### Örnek 1: Kritik Stok Raporu
```sql
-- Stok seviyesi düşük ve süresi yaklaşan ürünler
SELECT 
    s.Name AS Store_Name,
    p.Product_Name,
    SUM(i.Quantity) AS Total_Stock,
    bl.Expiry_Date,
    DATEDIFF(bl.Expiry_Date, CURDATE()) AS Days_Until_Expiry,
    CASE 
        WHEN DATEDIFF(bl.Expiry_Date, CURDATE()) <= 2 THEN 'CRITICAL'
        WHEN DATEDIFF(bl.Expiry_Date, CURDATE()) <= 7 THEN 'WARNING'
        ELSE 'OK'
    END AS Alert_Level
FROM Inventory i
JOIN Batch_Lot bl ON i.Batch_Lot_ID = bl.Batch_Lot_ID
JOIN Product p ON bl.Product_ID = p.Product_ID
JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
JOIN Store s ON sh.Store_ID = s.Store_ID
WHERE bl.Expiry_Date >= CURDATE()
GROUP BY s.Name, p.Product_Name, bl.Expiry_Date, bl.Batch_Lot_ID
HAVING Total_Stock < 50
ORDER BY Days_Until_Expiry ASC, Total_Stock ASC;
```

### Örnek 2: Mağaza Performans Raporu
```sql
-- Her mağazanın detaylı performans raporu
SELECT 
    s.Name AS Store_Name,
    COUNT(DISTINCT sh.Shelf_ID) AS Total_Shelves,
    COUNT(DISTINCT e.Employee_ID) AS Total_Employees,
    COUNT(DISTINCT p.Product_ID) AS Unique_Products,
    COALESCE(SUM(i.Quantity), 0) AS Total_Stock_Items,
    COUNT(DISTINCT a.Alert_ID) AS Total_Alerts,
    SUM(CASE WHEN a.Status = 'Pending' THEN 1 ELSE 0 END) AS Pending_Alerts
FROM Store s
LEFT JOIN Shelf sh ON s.Store_ID = sh.Store_ID
LEFT JOIN Employee e ON s.Store_ID = e.Store_ID
LEFT JOIN Inventory i ON sh.Shelf_ID = i.Shelf_ID
LEFT JOIN Batch_Lot bl ON i.Batch_Lot_ID = bl.Batch_Lot_ID
LEFT JOIN Product p ON bl.Product_ID = p.Product_ID
LEFT JOIN Alert a ON a.Employee_ID = e.Employee_ID
GROUP BY s.Store_ID, s.Name
ORDER BY Total_Stock_Items DESC;
```

### Örnek 3: Gelir Kaybı Analizi
```sql
-- Süresi geçmiş ürünlerden kaynaklanan potansiyel gelir kaybı
SELECT 
    s.Name AS Store_Name,
    p.Product_Name,
    bl.Expiry_Date,
    i.Quantity AS Wasted_Quantity,
    p.Current_Price,
    (i.Quantity * p.Current_Price) AS Revenue_Loss
FROM Inventory i
JOIN Batch_Lot bl ON i.Batch_Lot_ID = bl.Batch_Lot_ID
JOIN Product p ON bl.Product_ID = p.Product_ID
JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
JOIN Store s ON sh.Store_ID = s.Store_ID
WHERE bl.Expiry_Date < CURDATE()
AND i.Status = 'On Shelf'
ORDER BY Revenue_Loss DESC;
```

---

## 🎯 Sunum İçin Önerilen Sorgular

### 1. Dashboard Özet Sorgusu
```sql
SELECT 
    (SELECT COUNT(*) FROM Store) AS Total_Stores,
    (SELECT COUNT(*) FROM Product) AS Total_Products,
    (SELECT COUNT(*) FROM Alert WHERE Status = 'Pending') AS Pending_Alerts,
    (SELECT COUNT(DISTINCT bl.Batch_Lot_ID) 
     FROM Batch_Lot bl 
     WHERE bl.Expiry_Date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)) AS Expiring_Soon;
```

### 2. En Kritik Ürünler
```sql
SELECT 
    p.Product_Name,
    bl.Expiry_Date,
    DATEDIFF(bl.Expiry_Date, CURDATE()) AS Days_Left,
    SUM(i.Quantity) AS Stock
FROM Batch_Lot bl
JOIN Product p ON bl.Product_ID = p.Product_ID
JOIN Inventory i ON bl.Batch_Lot_ID = i.Batch_Lot_ID
WHERE bl.Expiry_Date BETWEEN CURDATE() AND DATE_ADD(CURDATE(), INTERVAL 3 DAY)
GROUP BY p.Product_Name, bl.Expiry_Date
ORDER BY Days_Left ASC
LIMIT 5;
```

---

**Not:** Bu örnekleri MySQL terminalinde veya phpMyAdmin gibi araçlarda test edebilirsiniz.
