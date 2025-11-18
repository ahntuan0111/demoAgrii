Agricultural AI System - Jupyter Notebook MVP
============================================

This notebook provides a complete MVP for an agricultural AI system with the following features:

1. Data Exploration
   - Connects to MongoDB Atlas
   - Explores collections (crops, diseases, products, farmers, stores)
   - Performs statistical analysis

2. AI-Powered Features
   - Crop disease diagnosis
   - Product recommendations
   - Local expert connections
   - LLM-powered insights

3. Usage
   - Open agricultural_ai_complete_mvp.ipynb in Jupyter Notebook
   - Run all cells to see the complete system in action
   - Modify the example consultations to test with your own data

4. Requirements
   - Python 3.10+
   - Jupyter Notebook
   - MongoDB Atlas connection (configured in .env)
   - OpenAI API key (configured in .env)

5. Features
   - Real-time data from MongoDB
   - AI-powered recommendations
   - Results saving and export
   - Comprehensive data analysis

To run:
1. Ensure your .env file has MONGO_URI and OPENAI_API_KEY
2. Install requirements: pip install -r requirements.txt
3. Start Jupyter: jupyter notebook
4. Open agricultural_ai_complete_mvp.ipynb
5. Run all cells