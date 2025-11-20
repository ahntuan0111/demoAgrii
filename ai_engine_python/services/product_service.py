import logging
from typing import List, Dict, Any
from services.mongodb_service import get_collection, PRODUCTS_COLLECTION

logger = logging.getLogger(__name__)


def add_keywords_to_product(product_id: str, keywords: List[str]):
    """
    Add keywords to a product in the database
    """
    try:
        products_collection = get_collection(PRODUCTS_COLLECTION)
        if products_collection is None:
            return False

        # Update the product with keywords
        result = products_collection.update_one(
            {"_id": product_id}, {"$set": {"keywords": keywords}}
        )

        return result.modified_count > 0
    except Exception as e:
        logger.error(f"Error adding keywords to product: {e}")
        return False


def create_product_with_keywords(product_data: Dict[str, Any]):
    """
    Create a new product with keywords
    """
    try:
        products_collection = get_collection(PRODUCTS_COLLECTION)
        if products_collection is None:
            return None

        # Insert the new product
        result = products_collection.insert_one(product_data)
        product_data["_id"] = str(result.inserted_id)

        return product_data
    except Exception as e:
        logger.error(f"Error creating product with keywords: {e}")
        return None


def search_products_by_keywords(keywords: List[str], limit: int = 10):
    """
    Search for products that match the given keywords
    """
    try:
        products_collection = get_collection(PRODUCTS_COLLECTION)
        if products_collection is None:
            return []

        # Search for products with matching keywords
        query = {"keywords": {"$in": keywords}}
        products = list(products_collection.find(query, {"_id": 0}).limit(limit))

        return products
    except Exception as e:
        logger.error(f"Error searching products by keywords: {e}")
        return []


def calculate_keyword_similarity(
    product_keywords: List[str], search_keywords: List[str]
) -> float:
    """
    Calculate similarity between product keywords and search keywords
    Returns a score between 0 and 1
    """
    if not product_keywords or not search_keywords:
        return 0.0

    # Convert to sets for easier comparison
    product_set = set(product_keywords)
    search_set = set(search_keywords)

    # Calculate intersection
    intersection = product_set.intersection(search_set)

    # Calculate similarity score (Jaccard similarity)
    union = product_set.union(search_set)
    if len(union) == 0:
        return 0.0

    similarity = len(intersection) / len(union)
    return similarity


def find_similar_products_by_keywords(search_keywords: List[str], limit: int = 10):
    """
    Find products with similar keywords to the search keywords
    """
    try:
        products_collection = get_collection(PRODUCTS_COLLECTION)
        if products_collection is None:
            return []

        # Get all products with keywords
        products = list(
            products_collection.find({"keywords": {"$exists": True}}, {"_id": 0})
        )

        # Calculate similarity scores for each product
        scored_products = []
        for product in products:
            product_keywords = product.get("keywords", [])
            similarity = calculate_keyword_similarity(product_keywords, search_keywords)

            # Only include products with some similarity
            if similarity > 0:
                product["similarity_score"] = similarity
                scored_products.append(product)

        # Sort by similarity score (descending)
        scored_products.sort(key=lambda x: x["similarity_score"], reverse=True)

        # Return top products
        return scored_products[:limit]
    except Exception as e:
        logger.error(f"Error finding similar products by keywords: {e}")
        return []
