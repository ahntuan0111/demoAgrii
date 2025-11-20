import logging
from typing import Dict, List, Any
from services.mongodb_service import (
    get_collection,
    PRODUCTS_COLLECTION,
    STORES_COLLECTION,
    FARMERS_COLLECTION,
    get_all_crops,
    get_all_diseases,
)

# Set up logging
logger = logging.getLogger(__name__)

# Enforce the specific priority order as per user requirements
PRIORITY_CROPS = ["Bưởi", "Dừa", "Sầu riêng", "Dứa", "Lúa", "Cà phê"]

# Load other crops from database that are not in the priority list
priority_crops_data = get_all_crops()
other_crops = [
    crop["name"] for crop in priority_crops_data if crop["name"] not in PRIORITY_CROPS
]
ALL_CROPS = PRIORITY_CROPS + other_crops

# Disease keywords to identify - get from database
disease_keywords_data = get_all_diseases()
DISEASE_KEYWORDS = (
    list(set([disease["name"] for disease in disease_keywords_data]))
    if disease_keywords_data
    else []
)


def extract_priority_keywords(user_input: str) -> Dict[str, str]:
    """
    Extract priority crop keywords and disease keywords from user input
    Returns dict with keys: crop, disease
    """
    user_input_lower = user_input.lower()

    # Log the input for debugging
    print(f"Extracting priority keywords from: {user_input}")

    # Extract crop - prioritize the specified crops in order
    crop = ""
    for priority_crop in PRIORITY_CROPS:  # Now using the fixed priority order
        if priority_crop.lower() in user_input_lower:
            crop = priority_crop
            print(f"Found priority crop: {crop}")
            break

    # Extract disease keywords - look for disease-related terms
    disease = ""
    for disease_keyword in DISEASE_KEYWORDS:
        if disease_keyword in user_input_lower:
            disease = disease_keyword
            print(f"Found disease keyword: {disease}")
            break

    result = {"crop": crop, "disease": disease}
    print(f"Extracted priority keywords: {result}")
    return result


def search_suggestions_by_keywords(
    keywords: Dict[str, str],
) -> Dict[str, List[Dict[str, Any]]]:
    """
    Search for suggestions in all collections based on keywords
    Returns data for 4 tabs:
    1. Products (medicines/pesticides)
    2. Stores (VTNN)
    3. Farmers (Lão nông)
    4. Call center (Tổng đài)
    """
    print(f"Searching suggestions for keywords: {keywords}")

    if not keywords.get("crop") and not keywords.get("disease"):
        print("No crop or disease keywords found, returning empty suggestions")
        return {"products": [], "stores": [], "farmers": [], "call_center": []}

    try:
        # Get collections
        products_collection = get_collection(
            "products"
        )  # FIXED: Using products collection instead of medicines
        stores_collection = get_collection(STORES_COLLECTION)
        farmers_collection = get_collection(FARMERS_COLLECTION)

        print(f"Products collection: {products_collection}")
        print(f"Stores collection: {stores_collection}")
        print(f"Farmers collection: {farmers_collection}")

        results = {
            "products": [],
            "stores": [],
            "farmers": [],
            "call_center": [],  # Fixed data for call center tab
        }

        # Tab 4 - Call center (fixed data)
        results["call_center"] = [
            {
                "name": "Tổng đài hỗ trợ nông dân",
                "phone": "1900 1001",
                "hours": "24/7",
                "description": "Hỗ trợ tư vấn kỹ thuật và giải đáp thắc mắc",
            },
            {
                "name": "Dịch vụ khuyến nông tỉnh",
                "phone": "1900 1002",
                "hours": "8:00 - 17:00 (Thứ 2 - Thứ 7)",
                "description": "Tư vấn kỹ thuật canh tác và bảo vệ thực vật",
            },
        ]

        # Tab 1 - Products (medicines/pesticides)
        product_query = {}
        if keywords.get("crop"):
            product_query["$or"] = [
                {"crop_name": {"$regex": keywords["crop"], "$options": "i"}},  # FIXED: crop_name instead of cay_trong
                {"keywords": {"$regex": keywords["crop"], "$options": "i"}},
            ]
        
        # If we have a disease keyword, we need to find products that treat that disease
        if keywords.get("disease") and products_collection is not None:
            # First, find the disease ID that matches the disease name
            diseases_collection = get_collection("diseases")
            if diseases_collection is not None:
                disease_doc = diseases_collection.find_one({
                    "name": {"$regex": keywords["disease"], "$options": "i"}
                })
                if disease_doc:
                    disease_id = disease_doc["_id"]
                    # Now search for products that treat this disease
                    disease_query = {"diseases": disease_id}
                    # Combine with existing query if crop query exists
                    if product_query:
                        product_query = {"$and": [product_query, disease_query]}
                    else:
                        product_query = disease_query

        if product_query and products_collection is not None:
            print(f"Product query: {product_query}")
            product_results = list(
                products_collection.find(product_query, {"_id": 0}).limit(4)
            )
            results["products"] = product_results
            print(f"Found {len(product_results)} products")
        elif keywords.get("crop") and products_collection is not None:
            # If no specific query but we have a crop, get products for that crop
            crop_query = {"crop_name": {"$regex": keywords["crop"], "$options": "i"}}
            product_results = list(
                products_collection.find(crop_query, {"_id": 0}).limit(4)
            )
            results["products"] = product_results
            print(f"Found {len(product_results)} products for crop")

        # Tab 2 - Stores (VTNN)
        # Only add stores if we have store data
        if stores_collection is not None:
            store_count = stores_collection.count_documents({})
            if store_count > 0:
                store_query = {}  # For now, get all stores
                store_results = list(
                    stores_collection.find(store_query, {"_id": 0}).limit(4)
                )
                for store in store_results:
                    results["stores"].append(
                        {
                            "name": store.get("ten_cua_hang", ""),
                            "address": store.get("dia_chi", ""),
                            "distance": store.get("khoang_cach", "2.5 km"),
                            "hours": store.get("gio_mo_cua", "7:00 - 20:00"),
                            "phone": store.get("so_dien_thoai", "0123 456 789"),
                            "coordinates": store.get("coordinates", []),
                        }
                    )
                print(f"Found {len(results['stores'])} stores")

        # Tab 3 - Farmers (Lão nông)
        # Only add farmers if we have farmer data
        if farmers_collection is not None:
            farmer_count = farmers_collection.count_documents({})
            if farmer_count > 0:
                farmer_query = {}
                if keywords.get("crop"):
                    farmer_query["cay_trong_vung.cay_trong"] = {
                        "$regex": keywords["crop"],
                        "$options": "i",
                    }

                if farmer_query:
                    print(f"Farmer query: {farmer_query}")
                    farmer_results = list(
                        farmers_collection.find(farmer_query, {"_id": 0}).limit(4)
                    )
                else:
                    # Get general farmers if no specific crop
                    farmer_results = list(farmers_collection.find({}, {"_id": 0}).limit(4))

                for farmer in farmer_results:
                    # Get the first crop specialty
                    crop_specialty = ""
                    if farmer.get("cay_trong_vung"):
                        crop_specialty = (
                            farmer["cay_trong_vung"][0].get("cay_trong", "")
                            if farmer["cay_trong_vung"]
                            else ""
                        )

                    results["farmers"].append(
                        {
                            "name": farmer.get("ten", ""),
                            "specialty": crop_specialty,
                            "experience": farmer.get("kinh_nghiem", "10 năm"),
                            "distance": farmer.get("khoang_cach", "1.2 km"),
                            "phone": farmer.get("so_dien_thoai", "0987 654 321"),
                            "coordinates": farmer.get("coordinates", []),
                        }
                    )
                print(f"Found {len(results['farmers'])} farmers")

        print(f"Final suggestions results: {results}")
        return results
    except Exception as e:
        logger.error(f"Error searching suggestions by keywords: {e}")
        print(f"Error searching suggestions: {e}")
        return {"products": [], "stores": [], "farmers": [], "call_center": []}


def format_suggestions_for_frontend(
    suggestions: Dict[str, List[Dict[str, Any]]],
) -> Dict[str, List[Dict[str, Any]]]:
    """
    Format suggestions data for frontend display
    """
    formatted = {
        "products": [],
        "stores": [],
        "farmers": [],
        "call_center": suggestions.get("call_center", []),
    }

    # Format products for Tab 1 - Sản phẩm đề xuất
    for product in suggestions.get("products", []):
        formatted["products"].append(
            {
                "image": product.get("images", [""])[0] if product.get("images") else "",  # FIXED: images instead of hinh_anh
                "name": product.get("name", ""),  # FIXED: name instead of ten_thuoc/ten_sp
                "usage": product.get("description", ""),  # FIXED: description instead of cong_dung
                "dosage": "",  # Products don't have dosage field
                "price": product.get("price", 0),
            }
        )

    # Format stores for Tab 2 - Cửa hàng VTNN
    for store in suggestions.get("stores", []):
        formatted["stores"].append(
            {
                "name": store.get("name", ""),
                "distance": store.get("distance", ""),
                "hours": store.get("hours", ""),
                "address": store.get("address", ""),
                "phone": store.get("phone", ""),
            }
        )

    # Format farmers for Tab 3 - Lão nông gần bạn
    for farmer in suggestions.get("farmers", []):
        formatted["farmers"].append(
            {
                "image": farmer.get("hinh_anh", ""),
                "name": farmer.get("name", ""),
                "specialty": farmer.get("specialty", ""),
                "experience": farmer.get("experience", ""),
                "distance": farmer.get("distance", ""),
            }
        )

    return formatted
