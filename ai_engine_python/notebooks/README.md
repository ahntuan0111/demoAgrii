# Agricultural AI System Notebooks

This directory contains a series of Jupyter notebooks that implement a complete Agricultural AI System. The notebooks are organized in a logical sequence to guide you through the entire development process.

## Notebooks Overview

1. **[01_setup_and_data_exploration.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/01_setup_and_data_exploration.ipynb)** - Initial setup and data exploration
   - Connects to MongoDB Atlas
   - Explores collections (crops, diseases, products, farmers, stores)
   - Performs statistical analysis of agricultural data

2. **[02_ai_integration.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/02_ai_integration.ipynb)** - AI integration
   - Integrates OpenAI API for LLM capabilities
   - Implements basic AI functions for disease diagnosis and product recommendations

3. **[03_complete_consultation_system.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/03_complete_consultation_system.ipynb)** - Complete consultation system
   - Combines database queries with AI capabilities
   - Implements end-to-end consultation workflow
   - Saves consultation results to JSON files

4. **[04_advanced_analytics.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/04_advanced_analytics.ipynb)** - Advanced analytics
   - Performs in-depth analysis of agricultural data
   - Identifies patterns and relationships between collections
   - Generates insights report

5. **[05_data_visualization_dashboard.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/05_data_visualization_dashboard.ipynb)** - Data visualization dashboard
   - Creates interactive visualizations with Plotly
   - Builds comprehensive dashboard with multiple charts
   - Provides visualization insights

6. **[06_model_training_and_evaluation.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/06_model_training_and_evaluation.ipynb)** - Model training and evaluation
   - Trains machine learning models for disease prediction
   - Trains models for product recommendations
   - Evaluates model performance

7. **[07_production_deployment.ipynb](file:///d:/Test_AI/ai_engine_python/notebooks/07_production_deployment.ipynb)** - Production deployment
   - Creates production-ready FastAPI application
   - Generates deployment files (Dockerfile, docker-compose.yml)
   - Creates startup scripts and documentation

## Usage Instructions

### Prerequisites
- Python 3.10+
- Jupyter Notebook
- MongoDB Atlas account
- OpenAI API key (for AI features)

### Setup
1. Ensure your `.env` file in the parent directory contains:
   ```
   MONGO_URI=your_mongodb_atlas_uri
   MONGO_DB_NAME=ai_nha_nong
   OPENAI_API_KEY=your_openai_api_key
   ```

2. Install required packages:
   ```bash
   pip install -r ../requirements.txt
   ```

### Running the Notebooks
1. Start Jupyter Notebook:
   ```bash
   jupyter notebook
   ```

2. Run the notebooks in sequential order (01, 02, 03, etc.) for best results

3. Each notebook builds upon the previous ones

## System Features

### Data Management
- Real-time connection to MongoDB Atlas
- Comprehensive data exploration
- Statistical analysis and reporting

### AI Capabilities
- Crop disease diagnosis
- Product recommendations
- Local expert connections
- LLM-powered insights

### Analytics
- Advanced data analysis
- Pattern recognition
- Relationship mapping
- Insights generation

### Visualization
- Interactive dashboards
- Multiple chart types
- Geographic analysis
- Correlation visualization

### Machine Learning
- Disease prediction models
- Product recommendation engines
- Farmer expertise matching
- Model evaluation and comparison

### Production Deployment
- FastAPI backend
- Docker containerization
- Deployment scripts
- API testing tools

## Directory Structure
```
notebooks/
├── 01_setup_and_data_exploration.ipynb
├── 02_ai_integration.ipynb
├── 03_complete_consultation_system.ipynb
├── 04_advanced_analytics.ipynb
├── 05_data_visualization_dashboard.ipynb
├── 06_model_training_and_evaluation.ipynb
├── 07_production_deployment.ipynb
└── README.md
```

## Next Steps

After running all notebooks:
1. The production deployment notebook will generate all necessary files
2. Follow the deployment instructions in the generated `DEPLOYMENT.md`
3. Deploy the system using Docker or directly with Python
4. Test the API endpoints with the provided test script

## Support

For issues or questions, please check the individual notebooks for detailed documentation and error handling.