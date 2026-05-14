from pymongo import MongoClient

client = MongoClient("mongodb://localhost:27017")
collection = client["performance_test"]["sales"]

# Створення індексу для поля category (1 означає за зростанням)
collection.create_index([("category", 1)])

print("Індекс для поля 'category' успішно створено!")