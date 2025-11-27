USE carlton_movie_rentals;

------ Business Questions-----

Q1. Which stores generate the most rental revenue?

SELECT s.StoreName,
       SUM(p.Amount) AS TotalRevenue
FROM Payment p
JOIN Rental r      ON p.RentalID = r.RentalID
JOIN Store s       ON r.StoreID = s.StoreID
GROUP BY s.StoreID, s.StoreName
ORDER BY TotalRevenue DESC;

Q2. Who are the top 10 highest-spending customers?

SELECT c.CustomerID,
       CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
       SUM(p.Amount) AS TotalSpend
FROM Customer c
JOIN Rental r  ON c.CustomerID = r.CustomerID
JOIN Payment p ON r.RentalID = p.RentalID
GROUP BY c.CustomerID, CustomerName
ORDER BY TotalSpend DESC
LIMIT 10;

Q3. What are the most popular genres by number of rentals?

SELECT g.GenreName,
       COUNT(*) AS RentalCount
FROM RentalItem ri
JOIN Inventory i   ON ri.InventoryID = i.InventoryID
JOIN Movie m       ON i.MovieID = m.MovieID
JOIN MovieGenre mg ON m.MovieID = mg.MovieID
JOIN Genre g       ON mg.GenreID = g.GenreID
GROUP BY g.GenreID, g.GenreName
ORDER BY RentalCount DESC;

Q4. Which movies are most frequently rented?

SELECT m.MovieID,
       m.Title,
       COUNT(*) AS TimesRented
FROM RentalItem ri
JOIN Inventory i ON ri.InventoryID = i.InventoryID
JOIN Movie m     ON i.MovieID = m.MovieID
GROUP BY m.MovieID, m.Title
ORDER BY TimesRented DESC
LIMIT 15;



Q5. How much late fee revenue is generated, by store?

SELECT s.StoreName,
       SUM(ri.LateFeeAmount) AS LateFeeRevenue
FROM RentalItem ri
JOIN Rental r ON ri.RentalID = r.RentalID
JOIN Store s  ON r.StoreID = s.StoreID
GROUP BY s.StoreID, s.StoreName
ORDER BY LateFeeRevenue DESC;

Q6. What is the utilisation of inventory (copies actually rented) by store?

SELECT s.StoreName,
       COUNT(DISTINCT i.InventoryID) AS TotalCopies,
       COUNT(DISTINCT CASE WHEN ri.RentalID IS NOT NULL THEN i.InventoryID END) AS CopiesEverRented,
       ROUND(
         COUNT(DISTINCT CASE WHEN ri.RentalID IS NOT NULL THEN i.InventoryID END) * 100.0 /
         COUNT(DISTINCT i.InventoryID),
         1
       ) AS UtilisationPercent
FROM Inventory i
JOIN Store s ON i.StoreID = s.StoreID
LEFT JOIN RentalItem ri ON i.InventoryID = ri.InventoryID
GROUP BY s.StoreID, s.StoreName
ORDER BY UtilisationPercent DESC;

Q7. How productive is each staff member in terms of rentals processed?

SELECT s.StaffID,
       CONCAT(s.FirstName, ' ', s.LastName) AS StaffName,
       st.StoreName,
       COUNT(r.RentalID) AS RentalsProcessed
FROM Staff s
LEFT JOIN Rental r ON s.StaffID = r.StaffID
JOIN Store st      ON s.StoreID = st.StoreID
GROUP BY s.StaffID, StaffName, st.StoreName
ORDER BY RentalsProcessed DESC;

Q8. Do membership customers rent more than non-members?

SELECT CASE WHEN c.MembershipID IS NULL THEN 'No Membership'
            ELSE 'Has Membership'
       END AS MembershipStatus,
       COUNT(DISTINCT r.RentalID) AS TotalRentals,
       ROUND(AVG(r.TotalAmount), 2) AS AvgRentalValue
FROM Customer c
LEFT JOIN Rental r ON c.CustomerID = r.CustomerID
GROUP BY MembershipStatus;

Q9. Which membership plans generate the highest total revenue?

SELECT mp.PlanName,
       COUNT(DISTINCT c.CustomerID) AS MemberCount,
       ROUND(SUM(p.Amount), 2) AS RentalRevenueFromMembers
FROM MembershipPlan mp
JOIN Customer c ON mp.MembershipID = c.MembershipID
JOIN Rental r   ON c.CustomerID = r.CustomerID
JOIN Payment p  ON r.RentalID = p.RentalID
GROUP BY mp.MembershipID, mp.PlanName
ORDER BY RentalRevenueFromMembers DESC;


Q10. How many rentals are currently overdue?

SELECT COUNT(*) AS OverdueItems
FROM RentalItem ri
JOIN Rental r ON ri.RentalID = r.RentalID
WHERE ri.ReturnDateTime IS NULL
  AND NOW() > r.ReturnDueDate;

Q11. Top 5 highest-spending customers per store 

WITH CustomerStoreSpend AS (
    SELECT
        s.StoreID,
        s.StoreName,
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        SUM(p.Amount) AS TotalSpendAtStore
    FROM Payment p
    JOIN Rental r   ON p.RentalID = r.RentalID
    JOIN Store s    ON r.StoreID = s.StoreID
    JOIN Customer c ON r.CustomerID = c.CustomerID
    GROUP BY s.StoreID, s.StoreName, c.CustomerID, CustomerName
),
Ranked AS (
    SELECT
        StoreID,
        StoreName,
        CustomerID,
        CustomerName,
        TotalSpendAtStore,
        ROW_NUMBER() OVER (
            PARTITION BY StoreID
            ORDER BY TotalSpendAtStore DESC
        ) AS rn
    FROM CustomerStoreSpend
)
SELECT
    StoreName,
    CustomerID,
    CustomerName,
    TotalSpendAtStore
FROM Ranked
WHERE rn <= 5
ORDER BY StoreName, TotalSpendAtStore DESC;

Q12. Monthly revenue trend per store with running total

WITH RevenueByMonth AS (
    SELECT
        s.StoreID,
        s.StoreName,
        DATE_FORMAT(r.RentalDateTime, '%Y-%m-01') AS MonthStart,
        SUM(p.Amount) AS MonthlyRevenue
    FROM Payment p
    JOIN Rental r ON p.RentalID = r.RentalID
    JOIN Store s  ON r.StoreID = s.StoreID
    GROUP BY s.StoreID, s.StoreName, MonthStart
)
SELECT
    StoreName,
    MonthStart,
    MonthlyRevenue,
    SUM(MonthlyRevenue) OVER (
        PARTITION BY StoreID
        ORDER BY MonthStart
    ) AS RunningRevenue
FROM RevenueByMonth
ORDER BY StoreName, MonthStart;

Q13. Late-fee behaviour by membership tier

SELECT
    COALESCE(mp.PlanName, 'No Membership') AS PlanName,
    COUNT(*) AS RentalItems,
    SUM(CASE WHEN ri.LateFeeAmount > 0 THEN 1 ELSE 0 END) AS LateItems,
    ROUND(
        SUM(CASE WHEN ri.LateFeeAmount > 0 THEN 1 ELSE 0 END) * 100.0 /
        COUNT(*),
        2
    ) AS LateRatePercent,
    ROUND(AVG(ri.LateFeeAmount), 2) AS AvgLateFeePerItem,
    ROUND(SUM(ri.LateFeeAmount), 2) AS TotalLateFees
FROM RentalItem ri
JOIN Rental r      ON ri.RentalID = r.RentalID
JOIN Customer c    ON r.CustomerID = c.CustomerID
LEFT JOIN MembershipPlan mp ON c.MembershipID = mp.MembershipID
GROUP BY mp.PlanName
ORDER BY TotalLateFees DESC;

Q14. Inventory turnover: how hard each movie per store is working

WITH CopiesAndRentals AS (
    SELECT
        s.StoreName,
        m.MovieID,
        m.Title,
        COUNT(DISTINCT i.InventoryID) AS CopiesInStore,
        COUNT(ri.RentalItemID) AS TotalRentals
    FROM Inventory i
    JOIN Store s      ON i.StoreID = s.StoreID
    JOIN Movie m      ON i.MovieID = m.MovieID
    LEFT JOIN RentalItem ri ON i.InventoryID = ri.InventoryID
    GROUP BY s.StoreName, m.MovieID, m.Title
)
SELECT
    StoreName,
    Title,
    CopiesInStore,
    TotalRentals,
    ROUND(
        TotalRentals / NULLIF(CopiesInStore, 0),
        2
    ) AS RentalsPerCopy
FROM CopiesAndRentals
ORDER BY StoreName, RentalsPerCopy DESC, Title;







Q15. Preferred-store vs “other stores” spend per customer

WITH CustomerSpend AS (
    SELECT
        c.CustomerID,
        CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
        ps.StoreName AS PreferredStoreName,
        SUM(
            CASE WHEN r.StoreID = c.PreferredStoreID THEN p.Amount ELSE 0 END
        ) AS SpendAtPreferredStore,
        SUM(
            CASE WHEN r.StoreID <> c.PreferredStoreID THEN p.Amount ELSE 0 END
        ) AS SpendAtOtherStores
    FROM Customer c
    LEFT JOIN Store ps   ON c.PreferredStoreID = ps.StoreID
    LEFT JOIN Rental r   ON c.CustomerID = r.CustomerID
    LEFT JOIN Payment p  ON r.RentalID = p.RentalID
    GROUP BY c.CustomerID, CustomerName, PreferredStoreName
)
SELECT
    CustomerName,
    PreferredStoreName,
    SpendAtPreferredStore,
    SpendAtOtherStores,
    ROUND(
        SpendAtPreferredStore * 100.0 /
        NULLIF(SpendAtPreferredStore + SpendAtOtherStores, 0),
        1
    ) AS PercentAtPreferredStore
FROM CustomerSpend
ORDER BY PercentAtPreferredStore DESC;  

