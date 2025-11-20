from fastapi import FastAPI, HTTPException  # pyright: ignore[reportMissingImports]
from pydantic import BaseModel  # pyright: ignore[reportMissingImports]
from typing import Dict, Any, Optional, List
import os
import sys
import logging

# Add the current directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Import services
from services.keyword_service import extract_keywords
from services.mongodb_service import (
    search_data_by_keywords,
    save_prompt,
    search_treatments,
    get_all_suggestions,
    get_collection,
    FARMERS_COLLECTION,
    STORES_COLLECTION,
    load_mock_data,
    get_all_keywords,
    get_all_diseases,
    get_all_crops,
    save_suggestion_data,
)

# Import the suggestion service
from services.suggestion_service import (
    extract_priority_keywords,
    search_suggestions_by_keywords,
    format_suggestions_for_frontend,
)

# Set up logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Create FastAPI app
app = FastAPI(
    title="Agricultural AI System API",
    description="API for the Agricultural AI System with MongoDB integration",
    version="1.0.0",
)


# Pydantic models for request/response
class UserInput(BaseModel):
    text: str


class KeywordResponse(BaseModel):
    crop: str
    disease: str
    product: str
    location: str
    action: str
    model_used: str


class SearchRequest(BaseModel):
    keywords: Dict[str, str]


class TreatmentRequest(BaseModel):
    crop: str
    disease: str
    location: Optional[str] = ""


# Add new Pydantic models for the missing endpoints
class SearchDataRequest(BaseModel):
    prompt: str


class ProcessVoiceRequest(BaseModel):
    voice: str


class AnalyzePlantImageRequest(BaseModel):
    image: str


class ProcessFileRequest(BaseModel):
    fileName: str
    fileContent: str
    fileType: str
    prompt: Optional[str] = None


class AddCropRequest(BaseModel):
    name: str


class AddDiseaseRequest(BaseModel):
    name: str
    crop: str


class AddKeywordRequest(BaseModel):
    keyword: str
    type: str


class ProductCreateRequest(BaseModel):
    ten_sp: str
    cay_trong: str
    benh_lien_quan: str
    mo_ta: str
    gia: Optional[float] = None
    don_vi_tinh: str
    nha_cung_cap: str
    dia_diem: str
    keywords: Optional[List[str]] = []


class ProductSearchRequest(BaseModel):
    keywords: List[str]
    limit: Optional[int] = 10


class FindNearestStoresRequest(BaseModel):
    location: str
    limit: Optional[int] = 5


class SearchStoresByProductLocationRequest(BaseModel):
    product_name: str
    location: str
    limit: Optional[int] = 5


# Add new Pydantic model for AI with data request
class AIWithDataRequest(BaseModel):
    prompt: str
    location: Optional[Dict[str, Any]] = None


class SuggestionRequest(BaseModel):
    prompt: str


# API routes
@app.get("/")
async def root():
    return {"message": "Agricultural AI System API", "version": "1.0.0"}


@app.post("/extract-keywords", response_model=KeywordResponse)
async def extract_keywords_endpoint(user_input: UserInput):
    """Extract keywords from user input"""
    try:
        keywords = extract_keywords(user_input.text)
        # Ensure all required fields are present
        required_fields = [
            "crop",
            "disease",
            "product",
            "location",
            "action",
            "model_used",
        ]
        for field in required_fields:
            if field not in keywords:
                keywords[field] = ""
        return KeywordResponse(**keywords)
    except Exception as e:
        logger.error(f"Error extracting keywords: {e}")
        # Return a default response instead of raising an exception
        return KeywordResponse(
            crop="", disease="", product="", location="", action="", model_used="error"
        )


# Add the missing /ai-with-data endpoint
from openai import OpenAI  # pyright: ignore[reportMissingImports]


@app.post("/ai-with-data")
async def ai_with_data_endpoint(request: AIWithDataRequest):
    try:
        user_input = UserInput(text=request.prompt)
        keywords = extract_keywords(user_input.text)
        crop = keywords.get("crop", "")
        disease = keywords.get("disease", "")

        # Save the prompt and keywords for learning
        save_prompt(request.prompt, keywords)

        # Extract priority keywords for suggestions
        priority_keywords = extract_priority_keywords(user_input.text)

        # Step 1: search DB
        search_results = search_data_by_keywords(keywords)

        # Step 2: Format search results for AI context
        formatted_results = ""
        if search_results:
            formatted_results = "\nThông tin từ cơ sở dữ liệu:\n"
            for i, result in enumerate(search_results[:5], 1):  # Limit to 5 results
                if result.get("type") == "product":
                    formatted_results += f"{i}. Sản phẩm: {result.get('product', '')} cho cây {result.get('crop', '')} bệnh {result.get('disease', '')}\n"
                elif result.get("type") == "store":
                    formatted_results += f"{i}. Cửa hàng: {result.get('product', '')} tại {result.get('location', '')}\n"
                elif result.get("type") == "farmer":
                    formatted_results += f"{i}. Lão nông: {result.get('product', '')} tại {result.get('location', '')} chuyên về {result.get('crop', '')}\n"

        # Initialize OpenAI client inside the function
        try:
            client = OpenAI()
        except Exception as e:
            logger.error(f"Failed to initialize OpenAI client: {e}")
            # Return a response without AI enhancement if OpenAI is not available
            formatted_results = []
            if search_results:
                for result in search_results:
                    formatted_results.append(
                        {
                            "crop": result.get("crop", ""),
                            "disease": result.get("disease", ""),
                            "product": result.get("product", ""),
                            "location": result.get("location", ""),
                            "farmer_role": result.get("farmer_role", ""),
                            "action": result.get("action", ""),
                        }
                    )

            return {
                "answer": "Hiện tại dịch vụ AI không khả dụng. Dưới đây là thông tin từ cơ sở dữ liệu của chúng tôi.",
                "keywords": keywords,
                "csvResults": formatted_results,
                "modelUsed": "unavailable",
                "totalFound": len(formatted_results),
                "showSuggestions": bool(crop or disease),
                "suggestions": {
                    "products": [],
                    "stores": [],
                    "farmers": [],
                    "call_center": [],
                },
            }

        # Step 3: Create a more natural prompt for AI that combines database results with AI knowledge
        if crop or disease:
            # For agricultural queries with specific keywords
            ai_prompt = f"""
Người dùng hỏi: {request.prompt}

Hãy trả lời câu hỏi một cách tự nhiên, chi tiết và chuyên nghiệp như một chuyên gia nông nghiệp dày dặn kinh nghiệm. 
Câu trả lời cần thân thiện, dễ hiểu và cung cấp thông tin hữu ích cho người dùng.

Dựa trên thông tin từ cơ sở dữ liệu:
{formatted_results}

Yêu cầu:
1. Trả lời câu hỏi của người dùng một cách tự nhiên và chuyên nghiệp
2. Sử dụng kiến thức nông nghiệp của bạn để bổ sung thông tin chi tiết
3. **Highlight từ khóa quan trọng bằng cách bao quanh chúng với dấu **bold** như ví dụ sau: **sâu đục thân**, **bón phân**, **tưới nước**.**
4. Cung cấp lời khuyên thực tế và hữu ích cho người dùng
5. Luôn luôn làm nổi bật tên cây trồng và bệnh cây bằng cách đặt trong dấu **bold**, ví dụ: **lúa**, **đạo ôn**
"""
        else:
            # For general queries or greetings
            ai_prompt = f"""
Người dùng hỏi: {request.prompt}

Hãy trả lời câu hỏi một cách tự nhiên, thân thiện và chuyên nghiệp như một chuyên gia nông nghiệp dày dặn kinh nghiệm. 
Câu trả lời cần dễ hiểu và cung cấp thông tin hữu ích cho người dùng.

Yêu cầu:
1. Trả lời câu hỏi của người dùng một cách tự nhiên và chuyên nghiệp
2. Sử dụng kiến thức nông nghiệp của bạn để cung cấp thông tin
3. **Highlight từ khóa quan trọng bằng cách bao quanh chúng với dấu **bold** như ví dụ sau: **sâu đục thân**, **bón phân**, **tưới nước**.**
4. Cung cấp lời khuyên thực tế và hữu ích cho người dùng
"""

        # Try different models in order of preference
        models_to_try = ["gpt-3.5-turbo", "gpt-4", "gpt-5-mini"]

        response = None
        final_model = None

        for model in models_to_try:
            try:
                # Try with temperature 0.7 first (for most models)
                try:
                    response = client.chat.completions.create(
                        model=model,
                        messages=[{"role": "user", "content": ai_prompt}],
                        temperature=0.7,
                    )
                    final_model = model
                    break
                except Exception as e:
                    # If temperature 0.7 fails, try with default temperature (1.0)
                    if "temperature" in str(e):
                        response = client.chat.completions.create(
                            model=model,
                            messages=[{"role": "user", "content": ai_prompt}],
                        )
                        final_model = model
                        break
                    else:
                        raise e  # Re-raise if it's not a temperature error
            except Exception as e:
                print(f"Lỗi với {model}: {e}")
                continue

        if response is None:
            raise Exception("Không thể kết nối với bất kỳ model nào.")

        answer = response.choices[0].message.content

        # Format search results for frontend
        formatted_results = []
        if search_results:
            for result in search_results:
                formatted_results.append(
                    {
                        "crop": result.get("crop", ""),
                        "disease": result.get("disease", ""),
                        "product": result.get("product", ""),
                        "location": result.get("location", ""),
                        "farmer_role": result.get("farmer_role", ""),
                        "action": result.get("action", ""),
                    }
                )

        # Filter out empty or meaningless keywords for suggestion display
        meaningful_keywords = {
            k: v
            for k, v in keywords.items()
            if k != "model_used"
            and v
            and str(v).strip()
            and len(str(v).strip()) > 1
            and str(v).strip().lower()
            not in [
                "",
                " ",
                "có",
                "là",
                "và",
                "các",
                "có thể",
                "nên",
                "cần",
                "muốn",
                "giúp",
                "hỗ trợ",
                "chào",
                "xin",
                "hello",
                "hi",
            ]
        }

        # Only show suggestions button when there are meaningful agricultural terms
        # Check if we have crop or disease keywords from our priority list
        show_suggestions = bool(meaningful_keywords) and bool(crop or disease)

        # Log the decision for debugging
        print(f"Meaningful keywords: {meaningful_keywords}")
        print(f"Crop: {crop}, Disease: {disease}")
        print(f"Show suggestions: {show_suggestions}")

        # Get suggestions data if needed
        suggestions_data = {}
        if show_suggestions:
            suggestions = search_suggestions_by_keywords(priority_keywords)
            suggestions_data = format_suggestions_for_frontend(suggestions)
            print(f"Suggestions data: {suggestions_data}")
        else:
            # Even if we don't show suggestions button, prepare empty data structure
            suggestions_data = {
                "products": [],
                "stores": [],
                "farmers": [],
                "call_center": [],
            }

        return {
            "answer": answer,
            "keywords": keywords,
            "csvResults": formatted_results,
            "modelUsed": final_model,
            "totalFound": len(formatted_results),
            "showSuggestions": show_suggestions,
            "suggestions": suggestions_data,
        }

    except Exception as e:
        logger.error(f"Error in AI with data endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search-data")
async def search_data_endpoint(request: SearchDataRequest):
    """Search data based on prompt"""
    try:
        # Extract keywords from the prompt
        keywords = extract_keywords(request.prompt)

        # Search for data based on extracted keywords
        search_results = search_data_by_keywords(keywords)

        # Format results
        formatted_results = []
        if search_results:
            for result in search_results:
                formatted_results.append(
                    {
                        "crop": result.get("crop", ""),
                        "disease": result.get("disease", ""),
                        "product": result.get("product", ""),
                        "location": result.get("location", ""),
                        "farmer_role": result.get("farmer_role", ""),
                        "action": result.get("action", ""),
                    }
                )

        return {"results": formatted_results}
    except Exception as e:
        logger.error(f"Error searching data: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search-by-keywords")
async def search_by_keywords_endpoint(request: SearchRequest):
    """Search data by keywords in all collections"""
    try:
        results = search_data_by_keywords(request.keywords)
        return {"results": results}
    except Exception as e:
        logger.error(f"Error searching by keywords: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/search-treatments")
async def search_treatments_endpoint(request: TreatmentRequest):
    """Search for treatment comparisons"""
    try:
        # Convert None to empty string for location parameter
        location = request.location if request.location is not None else ""
        treatment = search_treatments(request.crop, request.disease, location)
        if treatment:
            return {"treatment": treatment}
        else:
            return {
                "treatment": None,
                "message": "No treatment found for the specified criteria",
            }
    except Exception as e:
        logger.error(f"Error searching treatments: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# Add the missing endpoints
@app.post("/process-voice")
async def process_voice_endpoint(request: ProcessVoiceRequest):
    """Process voice data"""
    try:
        # Import required modules for voice processing
        from services.image_service import process_voice_data
        from services.keyword_service import extract_keywords

        # Process the voice data
        voice_result = process_voice_data(request.voice)

        # Check if we got an error
        if "error" in voice_result:
            return {
                "transcribed_text": voice_result.get(
                    "message", "Không thể nhận diện giọng nói"
                ),
                "model_used": "voice-model",
                "error": voice_result["error"],
            }

        # Extract transcribed text and keywords
        transcribed_text = voice_result.get("transcribed_text", "")
        keywords = voice_result.get("keywords", {})

        # If we have transcribed text, we can provide an AI response
        if transcribed_text:
            return {
                "transcribed_text": transcribed_text,
                "keywords": keywords,
                "model_used": "voice-model",
            }
        else:
            return {
                "transcribed_text": "Không thể nhận diện giọng nói. Vui lòng thử lại.",
                "model_used": "voice-model",
            }
    except Exception as e:
        logger.error(f"Error processing voice: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/analyze-plant-image")
async def analyze_plant_image_endpoint(request: AnalyzePlantImageRequest):
    """Analyze plant disease from image"""
    try:
        # Import required modules for image processing
        from services.image_service import process_plant_disease_image
        from services.keyword_service import extract_keywords

        # Process the image data
        result = process_plant_disease_image(request.image)

        # Check if we got an error
        if isinstance(result, dict) and "error" in result:
            return {
                "error": result["error"],
                "message": result.get("message", "Không thể phân tích hình ảnh"),
                "model_used": "image-analysis-model",
            }

        # If we got a proper result (list of products), format it
        if isinstance(result, list) and len(result) > 0:
            # Take the first result for basic information
            first_result = result[0] if len(result) > 0 else {}

            return {
                "crop": first_result.get("cay_trong", "Không xác định"),
                "disease": first_result.get("benh_lien_quan", "Không xác định"),
                "confidence": first_result.get("confidence", 0.85),
                "model_used": "image-analysis-model",
                "products_found": len(result),
                "results": result,
            }
        else:
            # Handle case where no products were found
            return {
                "crop": "Không xác định",
                "disease": "Không xác định",
                "confidence": 0.0,
                "model_used": "image-analysis-model",
                "products_found": 0,
                "results": [],
                "message": "Không tìm thấy sản phẩm phù hợp trong cơ sở dữ liệu",
            }

    except Exception as e:
        logger.error(f"Error analyzing plant image: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/process-file")
async def process_file_endpoint(request: ProcessFileRequest):
    """Process uploaded file"""
    try:
        # Import required modules for file processing
        import base64
        import json
        from services.image_service import process_plant_disease_image
        from services.keyword_service import extract_keywords
        from services.mongodb_service import search_data_by_keywords

        # Handle different file types
        file_type = request.fileType.lower()
        file_content = request.fileContent
        file_name = request.fileName

        # Process based on file type
        if file_type.startswith("image/"):
            # Handle image files
            result = process_plant_disease_image(file_content)

            # If we got a proper result, format it for the frontend
            if isinstance(result, list) and len(result) > 0:
                # Extract keywords from the first result
                first_result = result[0]
                prompt_text = f"Cây trồng: {first_result.get('cay_trong', '')}, Bệnh: {first_result.get('benh_lien_quan', '')}"
                keywords = extract_keywords(prompt_text)

                # Search for additional data based on keywords
                search_results = search_data_by_keywords(keywords)

                # Format search results
                formatted_results = []
                if search_results:
                    for res in search_results:
                        formatted_results.append(
                            {
                                "crop": res.get("crop", ""),
                                "disease": res.get("disease", ""),
                                "product": res.get("product", ""),
                                "location": res.get("location", ""),
                                "farmer_role": res.get("farmer_role", ""),
                                "action": res.get("action", ""),
                            }
                        )

                return {
                    "answer": f"Đã phân tích hình ảnh và tìm thấy {len(result)} sản phẩm phù hợp.",
                    "file_type": file_type,
                    "modelUsed": "image-analysis-model",
                    "csvResults": formatted_results,
                    "keywords": keywords,
                    "totalFound": len(formatted_results),
                }
            else:
                # Handle error case
                return {
                    "answer": "Không thể phân tích hình ảnh hoặc không tìm thấy sản phẩm phù hợp.",
                    "file_type": file_type,
                    "modelUsed": "image-analysis-model",
                    "csvResults": [],
                    "keywords": {},
                    "totalFound": 0,
                    "error": (
                        result.get("error", "Unknown error")
                        if isinstance(result, dict)
                        else "Unknown error"
                    ),
                }

        elif file_type == "application/pdf" or file_name.lower().endswith(".pdf"):
            # Handle PDF files (basic implementation)
            # For now, we'll just acknowledge receipt
            return {
                "answer": f"Đã nhận file PDF '{file_name}'. Chức năng xử lý PDF sẽ được cập nhật trong phiên bản tiếp theo.",
                "file_type": file_type,
                "modelUsed": "pdf-model",
                "csvResults": [],
                "keywords": {},
                "totalFound": 0,
            }

        elif file_type.startswith("text/") or file_name.lower().endswith(
            (".txt", ".csv")
        ):
            # Handle text files
            try:
                # Decode base64 content
                decoded_content = base64.b64decode(file_content).decode("utf-8")

                # Extract keywords from text content
                keywords = extract_keywords(decoded_content)

                # Search for data based on keywords
                search_results = search_data_by_keywords(keywords)

                # Format search results
                formatted_results = []
                if search_results:
                    for res in search_results:
                        formatted_results.append(
                            {
                                "crop": res.get("crop", ""),
                                "disease": res.get("disease", ""),
                                "product": res.get("product", ""),
                                "location": res.get("location", ""),
                                "farmer_role": res.get("farmer_role", ""),
                                "action": res.get("action", ""),
                            }
                        )

                # For CSV files, we could parse and search
                if file_name.lower().endswith(".csv"):
                    # Basic CSV handling - in a real implementation, we would parse the CSV
                    return {
                        "answer": f"Đã nhận file CSV '{file_name}' với {len(decoded_content.splitlines())} dòng. Đang phân tích dữ liệu...",
                        "file_type": file_type,
                        "modelUsed": "csv-model",
                        "csvResults": formatted_results,
                        "keywords": keywords,
                        "totalFound": len(formatted_results),
                    }
                else:
                    # For regular text files
                    return {
                        "answer": f"Đã phân tích nội dung file văn bản '{file_name}'.",
                        "file_type": file_type,
                        "modelUsed": "text-model",
                        "csvResults": formatted_results,
                        "keywords": keywords,
                        "totalFound": len(formatted_results),
                    }
            except Exception as e:
                return {
                    "answer": f"Không thể xử lý nội dung file văn bản.",
                    "file_type": file_type,
                    "modelUsed": "text-model",
                    "csvResults": [],
                    "keywords": {},
                    "totalFound": 0,
                    "error": str(e),
                }

        else:
            # Handle unknown file types
            return {
                "answer": f"Đã nhận file '{file_name}' (loại: {file_type}). Chức năng xử lý cho loại file này sẽ được cập nhật trong tương lai.",
                "file_type": file_type,
                "modelUsed": "generic-model",
                "csvResults": [],
                "keywords": {},
                "totalFound": 0,
            }

    except Exception as e:
        logger.error(f"Error processing file: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/add-crop")
async def add_crop_endpoint(request: AddCropRequest):
    """Add new crop to database"""
    try:
        # For now, just return a mock response
        return {"success": True, "message": f"Mock added crop: {request.name}"}
    except Exception as e:
        logger.error(f"Error adding crop: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/add-disease")
async def add_disease_endpoint(request: AddDiseaseRequest):
    """Add new disease to database"""
    try:
        # For now, just return a mock response
        return {
            "success": True,
            "message": f"Mock added disease: {request.name} for crop {request.crop}",
        }
    except Exception as e:
        logger.error(f"Error adding disease: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/add-keyword")
async def add_keyword_endpoint(request: AddKeywordRequest):
    """Add new keyword to database"""
    try:
        # For now, just return a mock response
        return {
            "success": True,
            "message": f"Mock added keyword: {request.keyword} of type {request.type}",
        }
    except Exception as e:
        logger.error(f"Error adding keyword: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/get-suggestions")
async def get_suggestions_endpoint():
    """Get all suggestions"""
    try:
        suggestions = get_all_suggestions()
        return {"suggestions": suggestions}
    except Exception as e:
        logger.error(f"Error loading suggestions: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/farmers")
async def get_farmers_endpoint():
    """Get all farmers"""
    try:
        # Get farmers collection
        farmers_collection = get_collection(FARMERS_COLLECTION)
        if farmers_collection is None:
            return {"success": True, "farmers": []}

        # Fetch all farmers from MongoDB
        farmers = list(farmers_collection.find({}, {"_id": 0}))
        return {"success": True, "farmers": farmers}
    except Exception as e:
        logger.error(f"Error loading farmers: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/stores")
async def get_stores_endpoint():
    """Get all stores"""
    try:
        # Get stores collection
        stores_collection = get_collection(STORES_COLLECTION)
        if stores_collection is None:
            return {"success": True, "stores": []}

        # Fetch all stores from MongoDB
        stores = list(stores_collection.find({}, {"_id": 0}))
        return {"success": True, "stores": stores}
    except Exception as e:
        logger.error(f"Error loading stores: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/products/create")
async def create_product_endpoint(request: ProductCreateRequest):
    """Create a new product"""
    try:
        # For now, just return a mock response
        return {"success": True, "message": f"Mock created product: {request.ten_sp}"}
    except Exception as e:
        logger.error(f"Error creating product: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/products/search-by-keywords")
async def search_products_by_keywords_endpoint(request: ProductSearchRequest):
    """Search products by keywords"""
    try:
        # For now, just return empty list
        return {"products": []}
    except Exception as e:
        logger.error(f"Error searching products by keywords: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/products/search-similar-by-keywords")
async def search_similar_products_by_keywords_endpoint(request: ProductSearchRequest):
    """Find similar products by keywords"""
    try:
        # For now, just return empty list
        return {"products": []}
    except Exception as e:
        logger.error(f"Error finding similar products by keywords: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/stores/find-nearest")
async def find_nearest_stores_endpoint(request: FindNearestStoresRequest):
    """Find nearest stores"""
    try:
        # For now, just return empty list
        return {"stores": []}
    except Exception as e:
        logger.error(f"Error finding nearest stores: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/stores/search-by-product-location")
async def search_stores_by_product_location_endpoint(
    request: SearchStoresByProductLocationRequest,
):
    """Search stores by product and location"""
    try:
        # For now, just return empty list
        return {"stores": []}
    except Exception as e:
        logger.error(f"Error searching stores by product and location: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/data")
async def get_mock_data():
    """Get mock data"""
    try:
        df = load_mock_data()
        return {"data": df.to_dict("records") if not df.empty else []}
    except Exception as e:
        logger.error(f"Error loading mock data: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/keywords")
async def get_keywords():
    """Get all keywords"""
    try:
        keywords = get_all_keywords()
        return {"keywords": keywords}
    except Exception as e:
        logger.error(f"Error loading keywords: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/diseases")
async def get_diseases():
    """Get all diseases"""
    try:
        diseases = get_all_diseases()
        return {"diseases": diseases}
    except Exception as e:
        logger.error(f"Error loading diseases: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/crops")
async def get_crops():
    """Get all crops"""
    try:
        crops = get_all_crops()
        return {"crops": crops}
    except Exception as e:
        logger.error(f"Error loading crops: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/save-prompt")
async def save_prompt_endpoint(prompt: str, keywords: Optional[Dict[str, Any]] = None):
    """Save user prompt"""
    try:
        success = save_prompt(prompt, keywords)
        return {"success": success}
    except Exception as e:
        logger.error(f"Error saving prompt: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/save-suggestion")
async def save_suggestion_endpoint(data: Dict[str, Any]):
    """Save suggestion data"""
    try:
        success = save_suggestion_data(data)
        return {"success": success}
    except Exception as e:
        logger.error(f"Error saving suggestion: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.get("/suggestions")
async def get_suggestions():
    """Get all suggestions"""
    try:
        suggestions = get_all_suggestions()
        return {"suggestions": suggestions}
    except Exception as e:
        logger.error(f"Error loading suggestions: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@app.post("/get-suggestions-data")
async def get_suggestions_data_endpoint(request: SuggestionRequest):
    """Get suggestion data based on user prompt"""
    try:
        # Extract priority keywords from the prompt
        priority_keywords = extract_priority_keywords(request.prompt)

        # Search for suggestions based on keywords
        suggestions = search_suggestions_by_keywords(priority_keywords)

        # Format suggestions for frontend
        formatted_suggestions = format_suggestions_for_frontend(suggestions)

        return {"success": True, "suggestions": formatted_suggestions}
    except Exception as e:
        logger.error(f"Error getting suggestions data: {e}")
        raise HTTPException(status_code=500, detail=str(e))


if __name__ == "__main__":
    import uvicorn  # pyright: ignore[reportMissingImports]

    uvicorn.run(app, host="127.0.0.1", port=8000)
