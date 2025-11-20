# Agricultural AI System - Database Commands

This document provides commands to view and analyze the data stored in your MongoDB database for the Agricultural AI System.

## Database Connection

### MongoDB Atlas (Cloud)
```bash
mongo "mongodb+srv://lethaibinh1002:10022004@cluster0.b90uukt.mongodb.net/ai_nha_nong"
```

### Local MongoDB
```bash
mongo "mongodb://admin:password@localhost:27017/ai_nha_nong"
```

## Viewing Data Collections

### Check Document Counts
```javascript
db.products.count()
db.stores.count()
db.farmers.count()
db.crops.count()
db.locations.count()
```

### View Sample Documents
```javascript
// View first 5 products
db.products.find().limit(5).pretty()

// View first 5 stores
db.stores.find().limit(5).pretty()

// View first 5 farmers
db.farmers.find().limit(5).pretty()

// View all crops
db.crops.find().pretty()

// View all locations
db.locations.find().pretty()
```

## Crop-Specific Queries

### Find Products for a Specific Crop
```javascript
// Example: Find products for "Lúa" (Rice)
db.products.find({"cay_trong": "Lúa"}).limit(5).pretty()

// Example: Find products for "Cà phê" (Coffee)
db.products.find({"cay_trong": "Cà phê"}).limit(5).pretty()
```

### Find Farmers for a Specific Crop
```javascript
// Example: Find farmers for "Cà phê" (Coffee)
db.farmers.find({"cay_trong_vung.cay_trong": "Cà phê"}).limit(5).pretty()

// Example: Find farmers for "Hồ tiêu" (Pepper)
db.farmers.find({"cay_trong_vung.cay_trong": "Hồ tiêu"}).limit(5).pretty()
```

### Find Stores in a Specific Location
```javascript
// Example: Find stores in "Hà Nội"
db.stores.find({"location": "Hà Nội"}).limit(5).pretty()

// Example: Find stores in "Đắk Lắk"
db.stores.find({"location": "Đắk Lắk"}).limit(5).pretty()
```

## Data Analysis Commands

### Count Farmers per Crop
```javascript
db.farmers.aggregate([
  { $unwind: "$cay_trong_vung" },
  { $group: { _id: "$cay_trong_vung.cay_trong", count: { $sum: 1 } } },
  { $sort: { count: 1 } }
])
```

### Count Products per Crop
```javascript
db.products.aggregate([
  { $group: { _id: "$cay_trong", count: { $sum: 1 } } },
  { $sort: { count: 1 } }
])
```

### Find Crops with Low Coverage
```javascript
// First get all crops
var crops = db.crops.find().toArray();

// Count farmers for each crop
crops.forEach(function(crop) {
  var farmerCount = db.farmers.count({
    "cay_trong_vung.cay_trong": crop.name
  });
  if (farmerCount < 3) {
    print("Low coverage crop: " + crop.name + " - " + farmerCount + " farmers");
  }
});
```

## Python Scripts for Data Analysis

### Basic Data Statistics
Create a file called `check_data_coverage.py`:

```python
import os
from dotenv import load_dotenv
from pymongo import MongoClient

# Load environment variables
load_dotenv()

# Connect to MongoDB
client = MongoClient(os.getenv("MONGO_URI"))
db = client[os.getenv("MONGO_DB_NAME")]

print("=== Database Statistics ===")
print(f"Products: {db.products.count_documents({})}")
print(f"Stores: {db.stores.count_documents({})}")
print(f"Farmers: {db.farmers.count_documents({})}")
print(f"Crops: {db.crops.count_documents({})}")
print(f"Locations: {db.locations.count_documents({})}")
```

Run with:
```bash
python check_data_coverage.py
```

### View Data in Table Format
Create a file called `view_data_tables.py`:

```python
import os
import pandas as pd
from dotenv import load_dotenv
from pymongo import MongoClient

# Load environment variables
load_dotenv()

# Connect to MongoDB
client = MongoClient(os.getenv("MONGO_URI"))
db = client[os.getenv("MONGO_DB_NAME")]

print("=== Products ===")
products = list(db.products.find().limit(10))
df_products = pd.DataFrame(products)
if not df_products.empty:
    print(df_products[['ten_sp', 'cay_trong', 'benh_lien_quan']].to_string(index=False))

print("\n=== Farmers ===")
farmers = list(db.farmers.find().limit(10))
df_farmers = pd.DataFrame(farmers)
if not df_farmers.empty:
    print(df_farmers[['ten', 'dia_diem']].to_string(index=False))

print("\n=== Stores ===")
stores = list(db.stores.find().limit(10))
df_stores = pd.DataFrame(stores)
if not df_stores.empty:
    print(df_stores[['ten_cua_hang', 'location']].to_string(index=False))
```

Run with:
```bash
python view_data_tables.py
```

## Current Data Status

As of the last update, the database contains:
- **124 crops** with full coverage
- **2,248 products** with 3-5 keywords each
- **300 farmers** with expertise in various crops
- **743 stores** with crop-specific products
- **64 locations** with coordinates for distance calculations

All crops have:
- ✅ At least 3-4 product recommendations
- ✅ At least 3-4 expert farmers
- ✅ At least 3-4 nearby stores

## System Features

1. **Product Recommendations**: Each product has 3-5 keywords stored in MongoDB
2. **Location-Based Services**: All location data is stored in MongoDB rather than hardcoded
3. **Real Database Integration**: No mock data - all information comes from MongoDB
4. **Complete Coverage**: Every crop has sufficient recommendations for farmers, products, and stores