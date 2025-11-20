import requests
import json


def chat_with_ai():
    print("Trò chuyện với AI (gõ 'thoát' để kết thúc)")
    print("-" * 40)

    while True:
        # Get user input
        user_input = input("\nBạn: ")

        # Check if user wants to exit
        if user_input.lower() in ["thoát", "exit", "quit"]:
            print("Tạm biệt!")
            break

        # Prepare the request to the AI endpoint
        url = "http://127.0.0.1:8000/ai-with-data"
        payload = {"prompt": user_input}

        try:
            # Send request to the AI
            response = requests.post(url, json=payload)

            if response.status_code == 200:
                data = response.json()
                ai_response = data.get(
                    "answer", "Xin lỗi, tôi không thể trả lời câu hỏi đó."
                )
                print(f"\nAI: {ai_response}")

                # Show keywords if available
                keywords = data.get("keywords", {})
                if keywords:
                    print(f"\nTừ khóa được phát hiện: {keywords}")

            else:
                print(
                    f"\nLỗi: Không thể kết nối với AI (Status code: {response.status_code})"
                )
                print(f"Chi tiết lỗi: {response.text}")

        except requests.exceptions.ConnectionError:
            print(
                "\nLỗi: Không thể kết nối với server. Vui lòng đảm bảo server đang chạy."
            )
            break
        except Exception as e:
            print(f"\nLỗi: {str(e)}")


if __name__ == "__main__":
    chat_with_ai()
