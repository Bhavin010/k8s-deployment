FROM python:3.11-slim 
 
WORKDIR /app 
 
# Copy application files 
COPY app.py requirements.txt ./ 
 
# Install dependencies 
RUN pip install --no-cache-dir -r requirements.txt 
 
# Expose port 
EXPOSE 5000 
 
# Run application 
CMD ["python", "app.py"] 
