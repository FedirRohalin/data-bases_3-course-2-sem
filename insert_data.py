from pymongo import MongoClient
import random
import datetime

# Підключення до локальної бази
client = MongoClient("mongodb://localhost:27017")
db = client["performance_test"]
collection = db["sales"]

# Видаляємо старі дані (якщо скрипт запускається не вперше)
collection.delete_many({})

# Категорії для Фітнес-клубу (Варіант 9)
categories = ["Yoga", "CrossFit", "Pilates", "Personal Training", "Gym Pass"]

print("Починаємо генерацію 100 000 записів...")

documents = [
    {
        "customer_id": random.randint(1, 1000),
        "category": random.choice(categories),
        "amount": random.uniform(10, 1500), # Сума покупки
        "timestamp": datetime.datetime(2024, random.randint(1, 12), random.randint(1, 28))
    }
    for _ in range(100000)
]

# Масова вставка
collection.insert_many(documents)
print("Успішно додано 100 000 документів!")