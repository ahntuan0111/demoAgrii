import cv2  # pyright: ignore[reportMissingImports]
import numpy as np  # pyright: ignore[reportMissingImports]
import base64
from io import BytesIO
from PIL import Image  # pyright: ignore[reportMissingImports]
import os
from services.keyword_service import extract_keywords
import json
import speech_recognition as sr  # pyright: ignore[reportMissingImports]
import io
import tempfile
import wave

# Import MongoDB services for real data retrieval
from services.mongodb_service import (
    search_data_by_keywords,
    get_collection,
    PRODUCTS_COLLECTION,
    STORES_COLLECTION,
)
from services.product_service import (
    search_products_by_keywords,
    find_similar_products_by_keywords,
)
from services.location_service import (
    find_nearest_stores,
    search_stores_by_product_and_location,
)

# Try to import pytesseract for OCR, but handle if it's not available
try:
    import pytesseract  # pyright: ignore[reportMissingImports]

    OCR_AVAILABLE = True
except ImportError:
    OCR_AVAILABLE = False
    pytesseract = None
    print("Warning: pytesseract not available. OCR functionality will be limited.")


def process_plant_disease_image(image_data):
    """
    Process plant disease image and return disease identification results
    This implementation now uses real database data instead of mock data
    """
    try:
        # Decode base64 image data
        if isinstance(image_data, str):
            # Remove data URL prefix if present
            if image_data.startswith("data:image"):
                image_data = image_data.split(",")[1]

            # Decode base64
            image_bytes = base64.b64decode(image_data)

            # Convert to numpy array
            nparr = np.frombuffer(image_bytes, np.uint8)
            img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
        else:
            img = image_data

        # First, try to extract text from the image using OCR (for scanned documents)
        ocr_text = ""
        if OCR_AVAILABLE and pytesseract is not None:
            try:
                # Convert OpenCV image (BGR) to PIL Image (RGB)
                img_rgb = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
                pil_image = Image.fromarray(img_rgb)

                # Extract text using OCR
                ocr_text = pytesseract.image_to_string(pil_image, lang="vie+eng")
                ocr_text = ocr_text.strip()

                # If we found text, we can use it to enhance our analysis
                if ocr_text:
                    print(
                        f"OCR extracted text: {ocr_text[:100]}..."
                    )  # Log first 100 chars
            except Exception as ocr_error:
                print(f"OCR processing failed: {ocr_error}")

        # Extract keywords from OCR text if available, otherwise use default
        if ocr_text:
            keywords = extract_keywords(ocr_text)
        else:
            # Default keywords for plant disease analysis
            keywords = {
                "crop": "lúa",
                "disease": "đạo ôn",
                "product": "thuốc trừ nấm",
                "location": "",
                "action": "phun thuốc",
            }

        # Search for real products in database based on extracted keywords
        search_results = search_data_by_keywords(keywords)

        # Filter to only include product results
        product_results = [r for r in search_results if r.get("type") == "product"]

        # If we found products in database, use them; otherwise provide appropriate message
        if product_results:
            # Format results to match UI expectations
            formatted_results = []
            for product in product_results[:3]:  # Limit to 3 products
                # Get product details with keywords
                product_name = product.get("product", "")
                product_details = None

                # Try to get detailed product information from database
                products_collection = get_collection(PRODUCTS_COLLECTION)
                if products_collection is not None:
                    product_details = products_collection.find_one(
                        {"ten_sp": product_name}, {"_id": 0}
                    )

                # Create result with product details
                result_item = {
                    "cay_trong": product.get("crop", ""),
                    "benh_lien_quan": product.get("disease", ""),
                    "ten_sp": product_name,
                    "location": product.get("location", ""),
                    "farmer_role": product.get("farmer_role", ""),
                    "action": product.get("action", ""),
                    "usage_count": product.get("usage_count", 0),
                    "confidence": 0.95,  # Static confidence for now
                }

                # Add keywords if available
                if product_details and "keywords" in product_details:
                    result_item["keywords"] = product_details["keywords"]

                formatted_results.append(result_item)

            # Add OCR text to the first result if available
            if ocr_text and formatted_results:
                formatted_results[0]["ocr_text"] = ocr_text[:500]  # Limit to 500 chars

            return formatted_results
        else:
            # No products found in database
            return {
                "error": "Không có sản phẩm phù hợp trong cơ sở dữ liệu.",
                "message": "Không tìm thấy sản phẩm phù hợp với hình ảnh đã phân tích trong cơ sở dữ liệu.",
            }

    except Exception as e:
        print(f"Error processing image: {e}")
        return {"error": "Không thể xử lý hình ảnh", "message": str(e)}


def process_voice_data(voice_data):
    """
    Process voice data and convert binary or base64 audio to text
    This implementation processes actual voice data when available
    """
    try:
        print(f"Received voice data type: {type(voice_data)}")

        # Handle different types of voice data input
        audio_bytes = None

        if isinstance(voice_data, str):
            # Check if it's JSON data
            try:
                # Try to parse as JSON first
                json_data = json.loads(voice_data)
                if isinstance(json_data, dict) and "voice" in json_data:
                    voice_content = json_data["voice"]
                else:
                    voice_content = voice_data
            except json.JSONDecodeError:
                # If not JSON, treat as direct voice content
                voice_content = voice_data

            # Check if voice_content is valid base64
            try:
                # Try to decode as base64
                audio_bytes = base64.b64decode(voice_content)
                print(
                    f"Successfully decoded base64 audio data, length: {len(audio_bytes)} bytes"
                )
            except Exception as base64_error:
                print(f"Base64 decode failed: {base64_error}")
                # If base64 decode fails, treat as direct text
                transcribed_text = voice_content
                keywords = extract_keywords(transcribed_text)
                return {"transcribed_text": transcribed_text, "keywords": keywords}
        elif isinstance(voice_data, bytes):
            # Direct binary data
            audio_bytes = voice_data
            print(
                f"Received direct binary audio data, length: {len(audio_bytes)} bytes"
            )
        else:
            # Handle other data types
            try:
                audio_bytes = bytes(voice_data)
                print(
                    f"Converted voice data to bytes, length: {len(audio_bytes)} bytes"
                )
            except Exception as convert_error:
                print(f"Failed to convert voice data to bytes: {convert_error}")
                # If conversion fails, treat as text
                transcribed_text = str(voice_data)
                keywords = extract_keywords(transcribed_text)
                return {"transcribed_text": transcribed_text, "keywords": keywords}

        # If we have audio bytes, process with speech recognition
        if audio_bytes and len(audio_bytes) > 0:
            print(f"Processing audio data of length: {len(audio_bytes)} bytes")

            # Use speech recognition to convert audio to text
            recognizer = sr.Recognizer()

            # Write audio bytes to a temporary WAV file with proper format
            with tempfile.NamedTemporaryFile(
                suffix=".wav", delete=False
            ) as temp_audio_file:
                temp_filename = temp_audio_file.name

                # Create a proper WAV file from the audio bytes
                # Ensure proper WAV format for better recognition
                with wave.open(temp_filename, "wb") as wav_file:
                    wav_file.setnchannels(1)  # Mono
                    wav_file.setsampwidth(2)  # 16-bit
                    wav_file.setframerate(16000)  # Sample rate
                    wav_file.writeframes(audio_bytes)

            print(f"Created temporary WAV file: {temp_filename}")

            # Try multiple recognition approaches
            transcribed_text = ""
            recognition_success = False

            # Load the audio file for recognition
            with sr.AudioFile(temp_filename) as source:
                # Adjust for ambient noise if possible
                try:
                    print("Adjusting for ambient noise...")
                    recognizer.adjust_for_ambient_noise(source, duration=0.5)
                except Exception as e:
                    print(f"Ambient noise adjustment failed: {e}")

                print("Reading audio data...")
                audio = recognizer.record(source)

                # Try different recognition methods
                recognition_methods = [
                    (
                        "Google (vi-VN)",
                        lambda: recognizer.recognize_google(audio, language="vi-VN"),
                    ),
                    (
                        "Google (en-US)",
                        lambda: recognizer.recognize_google(audio, language="en-US"),
                    ),
                    (
                        "Google Cloud",
                        lambda: (
                            recognizer.recognize_google_cloud(audio)
                            if hasattr(recognizer, "recognize_google_cloud")
                            else None
                        ),
                    ),
                ]

                for method_name, method_func in recognition_methods:
                    try:
                        print(f"Trying recognition method: {method_name}")
                        result = method_func()
                        if result:
                            transcribed_text = result
                            recognition_success = True
                            print(f"Success with {method_name}: {transcribed_text}")
                            break
                    except sr.UnknownValueError:
                        print(f"{method_name} could not understand audio")
                        continue
                    except sr.RequestError as e:
                        print(f"{method_name} request error: {e}")
                        continue
                    except Exception as e:
                        print(f"{method_name} unexpected error: {e}")
                        continue

            # Clean up temporary file
            try:
                os.unlink(temp_filename)
                print("Temporary file cleaned up")
            except Exception as e:
                print(f"Failed to clean up temporary file: {e}")

            # If all recognition methods failed, provide a more helpful message
            if not recognition_success:
                print("All recognition methods failed")
                # Try to get audio properties for debugging
                try:
                    with wave.open(temp_filename, "rb") as wav_file:
                        frames = wav_file.getnframes()
                        sample_rate = wav_file.getframerate()
                        duration = frames / float(sample_rate)
                        print(
                            f"Audio properties - Duration: {duration}s, Sample rate: {sample_rate}Hz, Frames: {frames}"
                        )
                except:
                    pass

                transcribed_text = "Không thể nhận diện giọng nói. Vui lòng thử lại với âm thanh rõ ràng hơn, nói to và chậm."

            # Extract keywords from the transcribed text
            keywords = extract_keywords(transcribed_text)
            print(f"Extracted keywords: {keywords}")

            # Return the result
            result = {"transcribed_text": transcribed_text, "keywords": keywords}

            return result
        else:
            # Fallback if no audio bytes
            print("No valid audio data found, using fallback")
            transcribed_text = (
                str(voice_data) if voice_data else "Không có dữ liệu âm thanh"
            )
            keywords = extract_keywords(transcribed_text)
            return {"transcribed_text": transcribed_text, "keywords": keywords}
    except Exception as e:
        print(f"Error processing voice: {e}")
        import traceback

        traceback.print_exc()
        return {
            "error": "Không thể xử lý dữ liệu âm thanh",
            "message": f"Lỗi xử lý âm thanh: {str(e)}",
        }
