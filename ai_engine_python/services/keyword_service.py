from openai import OpenAI  # pyright: ignore[reportMissingImports]
from dotenv import load_dotenv  # pyright: ignore[reportMissingImports]
import os
import json
from typing import Dict, List, Any  # Add Dict import
from services.mongodb_service import (
    get_all_keywords,
    get_all_diseases,
    get_all_crops,
    add_keyword,
    save_user_keywords,  # Add this import
)

load_dotenv()


# List of models to try in order (fallback mechanism)
# Start with faster, cheaper models first
def list_models():
    return ["gpt-3.5-turbo", "gpt-4", "gpt-4-turbo", "gpt-5-mini"]


def extract_keywords(user_input: str):
    """
    Extract keywords from user input using AI
    Returns dict with keys: crop, disease, product, location, action
    """
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        # If no API key, return fallback results immediately
        print("No OpenAI API key found, using fallback extraction")
        result = fallback_keyword_extraction(user_input)
        # Save keywords to database for learning
        save_user_keywords(user_input, result)
        return result

    try:
        client = OpenAI(api_key=api_key)
    except Exception as e:
        print(f"Failed to initialize OpenAI client: {e}")
        result = fallback_keyword_extraction(user_input)
        # Save keywords to database for learning
        save_user_keywords(user_input, result)
        return result

    # Get keywords from database for better prompting
    try:
        db_keywords = get_all_keywords()
        db_diseases = get_all_diseases()
        db_crops = get_all_crops()
    except Exception as e:
        print(f"Failed to get database keywords: {e}")
        db_keywords = []
        db_diseases = []
        db_crops = []

    # Priority crops list - get from database
    priority_crops_data = get_all_crops()
    PRIORITY_CROPS = (
        [crop["name"] for crop in priority_crops_data] if priority_crops_data else []
    )

    # Disease keywords to identify - get from database
    disease_keywords_data = get_all_diseases()
    DISEASE_KEYWORDS = (
        list(set([disease["name"] for disease in disease_keywords_data]))
        if disease_keywords_data
        else []
    )

    # Build lists for prompt with priority crops first
    disease_list = list(set([d["name"] for d in db_diseases]))[:50]  # Limit to 50

    # Prioritize the specified crops in the crop list
    priority_crop_names = [
        crop for crop in PRIORITY_CROPS if any(c["name"] == crop for c in db_crops)
    ]
    other_crop_names = [c["name"] for c in db_crops if c["name"] not in PRIORITY_CROPS]
    crop_list = priority_crop_names + other_crop_names
    crop_list = crop_list[:30]  # Limit to 30

    prompt = f"""
Phân tích câu hỏi của người dùng và trích xuất các từ khóa sau (chỉ trả về JSON, không giải thích):

Câu hỏi: "{user_input}"

Danh sách cây trồng: {', '.join(crop_list)}
Danh sách bệnh: {', '.join(disease_list)}

Quan trọng: Chỉ trích xuất từ khóa nếu chúng thực sự liên quan đến nông nghiệp. 
Nếu không tìm thấy từ khóa phù hợp, hãy để trống (chuỗi rỗng "").
Ví dụ: Nếu người dùng chỉ nói "Xin chào" thì tất cả các trường đều để trống.

Trả về kết quả theo định dạng JSON sau:
{{
  "crop": "[tên cây trồng từ danh sách trên nếu có]",
  "disease": "[tên bệnh từ danh sách trên nếu có]",
  "product": "[tên sản phẩm nếu có]",
  "location": "[địa điểm nếu có]",
  "action": "[hành động nếu có]"
}}
"""

    models_to_try = list_models()

    for model_name in models_to_try:
        try:
            response = client.chat.completions.create(
                model=model_name,
                messages=[{"role": "user", "content": prompt}],
                temperature=0.3,
                # Use max_tokens for compatibility
                max_tokens=500,
                timeout=30,  # Add timeout to prevent hanging
            )

            result = response.choices[0].message.content.strip()

            # Extract JSON from response
            if result.startswith("```json"):
                result = result.replace("```json", "").replace("```", "").strip()
            elif result.startswith("```"):
                result = result.replace("```", "").strip()

            keywords = json.loads(result)

            # Log the extracted keywords for debugging
            print(f"Extracted keywords: {keywords}")

            # Add model_used to result
            keywords["model_used"] = model_name

            # Filter out non-meaningful keywords (empty strings, whitespace, common greetings)
            exclude_values = [
                "",
                " ",
                "xin",
                "chào",
                "hello",
                "hi",
                "có",
                "là",
                "và",
                "các",
            ]
            for key in keywords:
                if key != "model_used":
                    value = str(keywords[key]).strip().lower()
                    if value in exclude_values or len(value) <= 1:
                        keywords[key] = ""

            # Check if this is a pure greeting with no meaningful content
            has_meaningful_content = any(
                value
                for key, value in keywords.items()
                if key != "model_used" and value.strip()
            )
            if not has_meaningful_content and any(
                greeting in user_input.lower()
                for greeting in ["xin chào", "chào", "hello", "hi"]
            ):
                keywords["model_used"] = "greeting"

            # Save keywords to database for learning
            save_user_keywords(user_input, keywords)
            return keywords

        except json.JSONDecodeError as e:
            print(f"⚠️ JSON parsing error with model {model_name}: {e}")
            continue
        except Exception as e:
            print(f"⚠️ Model {model_name} failed: {e}")
            continue

    # If all models failed, return fallback keywords
    print("All AI models failed, using fallback extraction")
    result = fallback_keyword_extraction(user_input)
    # Save keywords to database for learning
    save_user_keywords(user_input, result)
    return result


def fallback_keyword_extraction(user_input: str) -> Dict[str, str]:
    """
    Fallback method to extract keywords using simple pattern matching
    Returns dict with keys: crop, disease, product, location, action
    """
    print(f"Fallback extraction for: {user_input}")

    # Priority crops list - get from database
    priority_crops_data = get_all_crops()
    PRIORITY_CROPS = (
        [crop["name"] for crop in priority_crops_data] if priority_crops_data else []
    )

    # Disease keywords to identify - get from database
    disease_keywords_data = get_all_diseases()
    DISEASE_KEYWORDS = (
        list(set([disease["name"] for disease in disease_keywords_data]))
        if disease_keywords_data
        else []
    )

    user_input_lower = user_input.lower()

    # Extract crop - prioritize the specified crops in order
    crop = ""
    for priority_crop in PRIORITY_CROPS:
        if priority_crop.lower() in user_input_lower:
            crop = priority_crop
            break

    # Extract disease keywords - look for disease-related terms
    disease = ""
    for disease_keyword in DISEASE_KEYWORDS:
        if disease_keyword in user_input_lower:
            disease = disease_keyword
            break

    # Simple extraction for other keywords (basic pattern matching)
    product = ""
    location = ""
    action = ""

    # Look for common action verbs
    action_verbs = ["trồng", "bón", "phun", "tưới", "nhổ", "thu hoạch", "chăm sóc"]
    for verb in action_verbs:
        if verb in user_input_lower:
            action = verb
            break

    result = {
        "crop": crop,
        "disease": disease,
        "product": product,
        "location": location,
        "action": action,
        "model_used": "fallback",
    }

    print(f"Fallback extracted keywords: {result}")
    return result
