from openai import OpenAI  # pyright: ignore[reportMissingImports]
from dotenv import load_dotenv  # pyright: ignore[reportMissingImports]
import os
import json
from services.mongodb_service import (
    get_all_keywords,
    get_all_diseases,
    get_all_crops,
    add_keyword,
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
        return fallback_keyword_extraction(user_input)

    client = OpenAI(api_key=api_key)

    # Get keywords from database for better prompting
    db_keywords = get_all_keywords()
    db_diseases = get_all_diseases()
    db_crops = get_all_crops()

    # Build lists for prompt
    disease_list = list(set([d["name"] for d in db_diseases]))[:50]  # Limit to 50
    crop_list = list(set([c["name"] for c in db_crops]))[:30]  # Limit to 30

    prompt = f"""
Phân tích câu hỏi của người dùng và trích xuất các từ khóa sau (chỉ trả về JSON, không giải thích):

Câu hỏi: "{user_input}"

Trích xuất các từ khóa:
- crop: cây trồng (các loại: {', '.join(crop_list)})
- disease: bệnh (các loại: {', '.join(disease_list)})
- product: sản phẩm (phân NPK, thuốc trừ sâu, chế phẩm sinh học, phân bón lá, thuốc diệt nấm, phân vi sinh, phân hữu cơ, thuốc trừ bệnh, thuốc trừ cỏ)
- location: địa điểm (tỉnh thành Việt Nam)
- action: hành động (tìm, mua, gợi ý, tư vấn, chọn, xem giá, đặt hàng, liên hệ, kiểm tra, so sánh, còn hàng không, mua ở đâu, dùng loại nào, so sánh cách chữa bệnh, cách điều trị, phương pháp khắc phục)

Quan trọng: Chỉ trích xuất từ khóa nếu chúng thực sự liên quan đến nông nghiệp. 
Nếu không tìm thấy từ khóa phù hợp, hãy để trống (chuỗi rỗng "").
Ví dụ: Nếu người dùng chỉ nói "Xin chào" thì tất cả các trường đều để trống.
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

            return keywords

        except json.JSONDecodeError as e:
            print(f"⚠️ JSON parsing error with model {model_name}: {e}")
            continue
        except Exception as e:
            print(f"⚠️ Model {model_name} failed: {e}")
            continue

    # If all models failed, return fallback keywords
    return fallback_keyword_extraction(user_input)


def fallback_keyword_extraction(user_input: str):
    """
    Fast fallback method when AI is not available
    Uses database lookup for keywords instead of hardcoded lists
    """
    user_input_lower = user_input.lower()

    # Get keywords from database
    db_keywords = get_all_keywords()
    db_diseases = get_all_diseases()
    db_crops = get_all_crops()

    # Extract crop
    crop = ""
    for crop_item in db_crops:
        crop_name = crop_item["name"].lower()
        if crop_name in user_input_lower:
            crop = crop_item["name"]
            break

    # Extract disease
    disease = ""
    for disease_item in db_diseases:
        disease_name = disease_item["name"].lower()
        if disease_name in user_input_lower:
            disease = disease_item["name"]
            break

    # Check if this is a pure greeting
    is_greeting = any(
        greeting in user_input_lower for greeting in ["xin chào", "chào", "hello", "hi"]
    )

    if is_greeting and not crop and not disease:
        return {
            "crop": "",
            "disease": "",
            "product": "",
            "location": "",
            "action": "",
            "model_used": "greeting",
        }

    return {
        "crop": crop,
        "disease": disease,
        "product": "",
        "location": "",
        "action": "",
        "model_used": "database_lookup",
    }
