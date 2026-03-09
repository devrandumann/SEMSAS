from flask import Flask, jsonify, request, render_template, redirect, url_for, session
from flask_cors import CORS
from flask_login import LoginManager, UserMixin, login_user, logout_user, login_required, current_user
import mysql.connector
from mysql.connector import Error
import os
import bcrypt

app = Flask(__name__, static_folder='static', template_folder='templates')
app.secret_key = os.environ.get('SECRET_KEY', 'your-secret-key-change-in-production')
CORS(app)

# Initialize Flask-Login
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'login_page'

# MySQL Database Configuration
DB_CONFIG = {
    'host': os.environ.get('DB_HOST', 'localhost'),
    'user': os.environ.get('DB_USER', 'root'),
    'password': os.environ.get('DB_PASSWORD', 'duman5252'),
    'database': os.environ.get('DB_NAME', 'StoreManagement'),
    'port': int(os.environ.get('DB_PORT', '3306'))
}

# Helper functions for MySQL
def row_to_dict(cursor, row):
    """Convert MySQL cursor row to dictionary"""
    if row is None:
        return None
    columns = [column[0] for column in cursor.description]
    return dict(zip(columns, row))

def rows_to_dict_list(cursor, rows):
    """Convert MySQL cursor rows to list of dictionaries"""
    if not rows:
        return []
    columns = [column[0] for column in cursor.description]
    return [dict(zip(columns, row)) for row in rows]

# User class for Flask-Login
class User(UserMixin):
    def __init__(self, user_id, username, role, store_id, full_name):
        self.id = user_id
        self.username = username
        self.role = role
        self.store_id = store_id
        self.full_name = full_name
    
    def is_admin(self):
        return self.role == 'admin'
    
    def is_manager(self):
        return self.role == 'manager'

@login_manager.user_loader
def load_user(user_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM Users WHERE User_ID = %s', (user_id,))
    user_data = row_to_dict(cursor, cursor.fetchone())
    cursor.close()
    conn.close()
    if user_data:
        return User(user_data['User_ID'], user_data['Username'], user_data['Role'], 
                   user_data['Store_ID'], user_data['Full_Name'])
    return None

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        raise

@app.route('/')
@login_required
def home():
    return render_template('index.html')

@app.route('/login')
def login_page():
    return render_template('login.html')

@app.route('/api/login', methods=['POST'])
def login():
    try:
        data = request.json
        username = data.get('username')
        password = data.get('password')
        
        if not username or not password:
            return jsonify({'success': False, 'message': 'Username and password required'}), 400
        
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM Users WHERE Username = %s', (username,))
        user_data = row_to_dict(cursor, cursor.fetchone())
        cursor.close()
        conn.close()
        
        if user_data and bcrypt.checkpw(password.encode('utf-8'), user_data['Password_Hash'].encode('utf-8')):
            user = User(user_data['User_ID'], user_data['Username'], user_data['Role'], 
                       user_data['Store_ID'], user_data['Full_Name'])
            login_user(user)
            
            # Get store name for managers
            store_name = None
            if user.is_manager():
                conn = get_db_connection()
                cursor = conn.cursor()
                cursor.execute('SELECT Name FROM Store WHERE Store_ID = %s', (user.store_id,))
                store = row_to_dict(cursor, cursor.fetchone())
                cursor.close()
                conn.close()
                if store:
                    store_name = store['Name']
            
            return jsonify({
                'success': True,
                'user': {
                    'username': user.username,
                    'role': user.role,
                    'full_name': user.full_name,
                    'store_id': user.store_id,
                    'store_name': store_name
                }
            })
        else:
            return jsonify({'success': False, 'message': 'Invalid username or password'}), 401
    except Exception as e:
        return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/logout', methods=['POST'])
@login_required
def logout():
    logout_user()
    return jsonify({'success': True})

@app.route('/api/current-user', methods=['GET'])
@login_required
def get_current_user():
    store_name = None
    if current_user.is_manager():
        conn = get_db_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT Name FROM Store WHERE Store_ID = %s', (current_user.store_id,))
        store = row_to_dict(cursor, cursor.fetchone())
        cursor.close()
        conn.close()
        if store:
            store_name = store['Name']
    
    return jsonify({
        'username': current_user.username,
        'role': current_user.role,
        'full_name': current_user.full_name,
        'store_id': current_user.store_id,
        'store_name': store_name
    })

@app.route('/api/reports/generate', methods=['GET'])
@login_required
def generate_report():
    try:
        from flask import make_response
        import csv
        from io import StringIO
        from datetime import datetime
        
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Build query based on user role
        query = """
        SELECT 
            s.Name as Store_Name,
            p.Product_Name,
            c.Category_Name,
            b.Brand_Name,
            p.Current_Price,
            COALESCE(SUM(i.Quantity), 0) as Total_Stock,
            bl.Expiry_Date,
            bl.Cost_Price,
            sh.Shelf_Location
        FROM Product p
        LEFT JOIN Category c ON p.Category_ID = c.Category_ID
        LEFT JOIN Brand b ON p.Brand_ID = b.Brand_ID
        LEFT JOIN Batch_Lot bl ON p.Product_ID = bl.Product_ID
        LEFT JOIN Inventory i ON bl.Batch_Lot_ID = i.Batch_Lot_ID
        LEFT JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
        LEFT JOIN Store s ON sh.Store_ID = s.Store_ID
        """
        
        # Filter by store for managers
        if current_user.is_manager():
            query += " WHERE s.Store_ID = %s"
            query += " GROUP BY p.Product_ID, p.Product_Name, c.Category_Name, b.Brand_Name, p.Current_Price, bl.Batch_Lot_ID, bl.Expiry_Date, bl.Cost_Price, sh.Shelf_Location, s.Name ORDER BY s.Name, p.Product_Name"
            cursor.execute(query, (current_user.store_id,))
        else:
            query += " GROUP BY p.Product_ID, p.Product_Name, c.Category_Name, b.Brand_Name, p.Current_Price, bl.Batch_Lot_ID, bl.Expiry_Date, bl.Cost_Price, sh.Shelf_Location, s.Name ORDER BY s.Name, p.Product_Name"
            cursor.execute(query)
        
        rows = rows_to_dict_list(cursor, cursor.fetchall())
        cursor.close()
        conn.close()
        
        # Create CSV
        si = StringIO()
        writer = csv.writer(si)
        
        # Write header
        writer.writerow(['Store', 'Product', 'Category', 'Brand', 'Price', 'Stock', 'Expiry Date', 'Cost Price', 'Shelf Location'])
        
        # Write data
        for row in rows:
            writer.writerow([
                row['Store_Name'] or 'N/A',
                row['Product_Name'],
                row['Category_Name'],
                row['Brand_Name'],
                row['Current_Price'],
                row['Total_Stock'],
                row['Expiry_Date'] or 'N/A',
                row['Cost_Price'] or 'N/A',
                row['Shelf_Location'] or 'N/A'
            ])
        
        # Create response
        output = make_response(si.getvalue())
        output.headers["Content-Disposition"] = f"attachment; filename=inventory_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.csv"
        output.headers["Content-type"] = "text/csv"
        
        return output
        
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/products')
@login_required
def products_page():
    return render_template('products.html')

@app.route('/stores')
@login_required
def stores_page():
    return render_template('stores.html')

@app.route('/promotions')
@login_required
def promotions_page():
    return render_template('promotions.html')

@app.route('/brands')
@login_required
def brands_page():
    return render_template('brands.html')

@app.route('/shelves')
@login_required
def shelves_page():
    return render_template('shelves.html')

@app.route('/alerts')
@login_required
def alerts_page():
    return render_template('alerts.html')

@app.route('/api/dashboard/summary', methods=['GET'])
@login_required
def get_dashboard_summary():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Check if user is manager
        if current_user.is_manager():
            # Manager sees only their store
            # 1. Total Stores (always 1 for manager)
            total_stores = 1
            
            # 2. Total Products in their store
            cursor.execute("""
                SELECT COUNT(DISTINCT p.Product_ID) 
                FROM Product p
                JOIN Batch_Lot bl ON p.Product_ID = bl.Product_ID
                JOIN Inventory i ON bl.Batch_Lot_ID = i.Batch_Lot_ID
                JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
                WHERE sh.Store_ID = %s
            """, (current_user.store_id,))
            total_products = cursor.fetchone()[0]
            
            # 3. Critical Stock (Low Stock) in their store
            cursor.execute("""
                SELECT COUNT(*) 
                FROM Alert a
                JOIN Employee e ON a.Employee_ID = e.Employee_ID
                WHERE e.Store_ID = %s 
                AND a.Alert_Type = 'Low Stock' 
                AND a.Status != 'Resolved'
            """, (current_user.store_id,))
            low_stock_alerts = cursor.fetchone()[0]
            
            # 4. Expiring Soon in their store
            cursor.execute("""
                SELECT COUNT(DISTINCT bl.Batch_Lot_ID)
                FROM Batch_Lot bl
                JOIN Inventory i ON bl.Batch_Lot_ID = i.Batch_Lot_ID
                JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
                WHERE sh.Store_ID = %s 
                AND bl.Expiry_Date <= DATE_ADD(NOW(), INTERVAL 7 DAY)
            """, (current_user.store_id,))
            expiring_soon = cursor.fetchone()[0]
        else:
            # Admin sees all stores
            # 1. Total Stores
            cursor.execute("SELECT COUNT(*) as count FROM Store")
            total_stores = cursor.fetchone()[0]
            
            # 2. Total Products
            cursor.execute("SELECT COUNT(*) as count FROM Product")
            total_products = cursor.fetchone()[0]
            
            # 3. Critical Stock (Low Stock)
            cursor.execute("SELECT COUNT(*) as count FROM Alert WHERE Alert_Type = 'Low Stock' AND Status != 'Resolved'")
            low_stock_alerts = cursor.fetchone()[0]
            
            # 4. Expiring Soon (within 7 days or expired)
            cursor.execute("SELECT COUNT(*) as count FROM Batch_Lot WHERE Expiry_Date <= DATE_ADD(NOW(), INTERVAL 7 DAY)")
            expiring_soon = cursor.fetchone()[0]
        
        cursor.close()
        conn.close()
        
        return jsonify({
            'total_stores': total_stores,
            'total_products': total_products,
            'low_stock_alerts': low_stock_alerts,
            'expiring_soon': expiring_soon
        })
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products', methods=['GET'])
@login_required
def get_products():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        p.Product_ID,
        p.Product_Name,
        p.Current_Price,
        c.Category_Name,
        b.Brand_Name
    FROM Product p
    LEFT JOIN Category c ON p.Category_ID = c.Category_ID
    LEFT JOIN Brand b ON p.Brand_ID = b.Brand_ID
    ORDER BY p.Product_ID
    """
    cursor.execute(query)
    products = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(products)

@app.route('/api/products', methods=['POST'])
@login_required
def add_product():
    try:
        data = request.json
        conn = get_db_connection()
        cursor = conn.cursor()
        
        # Get max ID
        cursor.execute("SELECT MAX(Product_ID) as max_id FROM Product")
        max_id = cursor.fetchone()[0] or 100
        new_id = max_id + 1
        
        cursor.execute("""
            INSERT INTO Product (Product_ID, Product_Name, Current_Price, Category_ID, Brand_ID)
            VALUES (%s, %s, %s, %s, %s)
        """, (new_id, data['product_name'], data['price'], data['category_id'], data['brand_id']))
        
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True, 'id': new_id}), 201
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/products/<int:product_id>', methods=['DELETE'])
@login_required
def delete_product(product_id):
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # First delete related records to avoid foreign key constraint issues
        cursor.execute("DELETE FROM Price_History WHERE Product_ID = %s", (product_id,))
        cursor.execute("DELETE FROM Promotion WHERE Product_ID = %s", (product_id,))
        cursor.execute("DELETE FROM Batch_Lot WHERE Product_ID = %s", (product_id,))
        cursor.execute("DELETE FROM Product WHERE Product_ID = %s", (product_id,))
        conn.commit()
        cursor.close()
        conn.close()
        return jsonify({'success': True}), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@app.route('/api/categories', methods=['GET'])
@login_required
def get_categories():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Category ORDER BY Category_Name")
    categories = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(categories)

@app.route('/api/brands', methods=['GET'])
@login_required
def get_brands():
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM Brand ORDER BY Brand_Name")
    brands = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(brands)

@app.route('/api/stores', methods=['GET'])
@login_required
def get_stores():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        s.*,
        COUNT(e.Employee_ID) as Employee_Count
    FROM Store s
    LEFT JOIN Employee e ON s.Store_ID = e.Store_ID
    """
    
    # Filter by store for managers
    if current_user.is_manager():
        query += " WHERE s.Store_ID = %s"
        query += " GROUP BY s.Store_ID, s.Name, s.Address, s.Contact_Info ORDER BY s.Name"
        cursor.execute(query, (current_user.store_id,))
    else:
        query += " GROUP BY s.Store_ID, s.Name, s.Address, s.Contact_Info ORDER BY s.Name"
        cursor.execute(query)
    
    stores = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(stores)

@app.route('/api/stores/<int:store_id>/employees', methods=['GET'])
def get_store_employees(store_id):
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT * FROM Employee
    WHERE Store_ID = %s
    ORDER BY Position, Name
    """
    cursor.execute(query, (store_id,))
    employees = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(employees)

@app.route('/api/promotions', methods=['GET'])
def get_promotions():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        pr.*,
        p.Product_Name,
        c.Category_Name,
        b.Brand_Name
    FROM Promotion pr
    LEFT JOIN Product p ON pr.Product_ID = p.Product_ID
    LEFT JOIN Category c ON pr.Category_ID = c.Category_ID
    LEFT JOIN Brand b ON pr.Brand_ID = b.Brand_ID
    WHERE pr.End_Date >= CURDATE()
    ORDER BY pr.End_Date ASC
    """
    cursor.execute(query)
    promotions = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(promotions)

@app.route('/api/shelves', methods=['GET'])
@login_required
def get_shelves():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        sh.*,
        s.Name as Store_Name,
        COALESCE(SUM(i.Quantity), 0) as Total_Stock
    FROM Shelf sh
    LEFT JOIN Store s ON sh.Store_ID = s.Store_ID
    LEFT JOIN Inventory i ON sh.Shelf_ID = i.Shelf_ID
    """
    
    # Filter by store for managers
    if current_user.is_manager():
        query += " WHERE sh.Store_ID = %s"
        query += " GROUP BY sh.Shelf_ID, sh.Store_ID, sh.Shelf_Location, sh.Capacity, sh.Temperature_Type, s.Name ORDER BY s.Name, sh.Shelf_Location"
        cursor.execute(query, (current_user.store_id,))
    else:
        query += " GROUP BY sh.Shelf_ID, sh.Store_ID, sh.Shelf_Location, sh.Capacity, sh.Temperature_Type, s.Name ORDER BY s.Name, sh.Shelf_Location"
        cursor.execute(query)
    
    shelves = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(shelves)

@app.route('/api/products/expiring', methods=['GET'])
@login_required
def get_expiring_products():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        p.Product_Name, 
        b.Expiry_Date, 
        b.Received_Quantity,
        s.Name as Store_Name,
        sh.Shelf_Location,
        i.Quantity as Current_Stock
    FROM Batch_Lot b
    JOIN Product p ON b.Product_ID = p.Product_ID
    LEFT JOIN Inventory i ON b.Batch_Lot_ID = i.Batch_Lot_ID
    LEFT JOIN Shelf sh ON i.Shelf_ID = sh.Shelf_ID
    LEFT JOIN Store s ON sh.Store_ID = s.Store_ID
    WHERE b.Expiry_Date <= DATE_ADD(NOW(), INTERVAL 30 DAY)
    """
    
    # Filter by store for managers
    if current_user.is_manager():
        query += " AND s.Store_ID = %s"
        query += " ORDER BY b.Expiry_Date ASC LIMIT 20"
        cursor.execute(query, (current_user.store_id,))
    else:
        query += " ORDER BY b.Expiry_Date ASC LIMIT 20"
        cursor.execute(query)
    
    products = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(products)

@app.route('/api/alerts', methods=['GET'])
@login_required
def get_alerts():
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    SELECT 
        a.Alert_Type, 
        a.Alert_Date, 
        a.Status,
        e.Name as Employee_Name,
        s.Name as Store_Name,
        p.Product_Name
    FROM Alert a
    JOIN Employee e ON a.Employee_ID = e.Employee_ID
    JOIN Store s ON e.Store_ID = s.Store_ID
    JOIN Batch_Lot b ON a.Batch_Lot_ID = b.Batch_Lot_ID
    JOIN Product p ON b.Product_ID = p.Product_ID
    """
    
    # Filter by store for managers
    if current_user.is_manager():
        query += " WHERE s.Store_ID = %s"
        query += " ORDER BY a.Alert_Date DESC LIMIT 10"
        cursor.execute(query, (current_user.store_id,))
    else:
        query += " ORDER BY a.Alert_Date DESC LIMIT 10"
        cursor.execute(query)
    
    alerts = rows_to_dict_list(cursor, cursor.fetchall())
    cursor.close()
    conn.close()
    return jsonify(alerts)

if __name__ == '__main__':
    app.run(debug=True, port=8000)

