from pymongo import MongoClient
import time

client = MongoClient("mongodb://localhost:27017")
collection = client["performance_test"]["sales"]

print("Виконуємо пошук БЕЗ індексу...")
start_time = time.time()

# Шукаємо всі продажі абонементів на Йогу
results = list(collection.find({"category": "Yoga"}))

end_time = time.time()
print(f"Знайдено записів: {len(results)}")
print(f"Time taken: {end_time - start_time:.6f} seconds")