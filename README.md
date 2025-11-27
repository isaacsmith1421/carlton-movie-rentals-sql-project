# carlton-movie-rentals-sql-project
A full end-to-end SQL project featuring a complete relational database, ER diagram, relational model, sample data inserts, and analytical SQL queries for a multi-store DVD rental business operating in Melbourne, Australia.


Business Overview:
Carlton Movie Rentals is a brick-and-mortar and online DVD/Blu-Ray rental business operating across several inner-Melbourne suburbs. The company maintains multiple stores (Carlton, Fitzroy, Richmond & Southbank) and provides customers with flexible membership plans and pay-per-rental options. The business requires a centralised database to manage customers, inventory, rentals, payments, staff and store operations.

Customer are able to:
- Sign up to membership plans (Standard, Premium, Family)
- Rent physical movie copies from any store location
- Accrue late fees depending on rental return time
- Make payments via Cash, Card, or Online methods

Each Movie Includes:
- Title, release year, rating (G/PG/M/MA15+) 
- One or more genres 
- Runtime, language
 - Rental price + replacement cost 

Each Store Includes: 
- Staff responsible for handling rentals and payments 
- Inventory of multiple movie copies 
- Stock status (Available / Rented) 
- Opening dates and operational status 

Project Goal 
To design and implement a full relational database and SQL analytics framework that allows Carlton Movie Rentals to:
- Analyse rental revenue across stores 
- Identify top customers and rental behaviours 
- Track movie popularity and genre performance 
- Monitor staff activity and store productivity 
- Evaluate late fees and inventory utilisation 
- Support future business intelligence needs 

What I Built 
- Designed a 10-table relational database schema (Customer, MembershipPlan, Store, Staff, Movie, Genre, MovieGenre, Inventory, Rental, RentalItem, Payment). 
- Created a full ER diagram and implemented the schema in MySQL. 
- Inserted 500+ rows of realistic sample data across all entities. 
Developed business-driven SQL queries to answer key analytics questions: 
- Store revenue performance, - High-value customer identification, - Most rented movies & genres, - Customer rental frequency, - Inventory usage and late-fee analysis, - Staff performance metrics.
- Ensured all data relationships, foreign keys, and constraints worked without conflict.

Business Rules:
Business Rule 1: A customer can have zero or one active membership plan at a time.

Business Rule 2: Each customer may nominate one preferred store, but can rent from any store.

Business Rule 3: Each membership plan can be assigned to many customers.

Business Rule 4: Each movie can be stocked in many stores, and each store can hold many copies of the same movie (tracked in Inventory).

Business Rule 5: Each physical copy in Inventory belongs to exactly one movie and one store.

Business Rule 6: Each rental transaction (Rental) is linked to one customer, one store, and one staff member who processed it.

Business Rule 7: Each rental can contain one or more rental items (RentalItem), each referring to a specific physical copy (Inventory).

Business Rule 8: A rental item must have at most one return date; if ReturnDateTime is NULL, the item is currently out.

Business Rule 9: Late fees are charged when ReturnDateTime is after ReturnDueDate; the amount is recorded in LateFeeAmount.

Business Rule 10: A movie can belong to multiple genres, and a genre can apply to many movies (managed via MovieGenre).

Business Rule 11: Each rental can have one or more payments, but the sum of all payments for a rental cannot exceed TotalAmount.

Business Rule 12: Each staff member is assigned to one store only, but a store can have many staff.


<img width="468" height="638" alt="image" src="https://github.com/user-attachments/assets/8628a1a1-2786-43aa-8637-cd56b29ed846" />
