SELECT * 
FROM Artist;

SELECT Country, COUNT(*) AS Total_Customers
FROM Customer
GROUP BY Country;

SELECT COUNT(DISTINCT country) AS number_of_countries
FROM customer;

SELECT TrackId, Name, UnitPrice
FROM track
ORDER BY UnitPrice DESC
LIMIT 10;

SELECT
    CustomerId,
    FirstName,
    LastName,
    Fax,
    State
FROM Customer
WHERE Fax IS NULL
   OR State IS NULL;
   
   
SELECT
    SUM(Total) AS total_revenue,
    AVG(Total) AS average_invoice_value
FROM Invoice;

SELECT
    BillingCountry,
    SUM(Total) AS total_revenue
FROM Invoice
GROUP BY BillingCountry
ORDER BY SUM(total)  DESC;

SELECT
    EXTRACT(YEAR FROM InvoiceDate) AS invoice_year,
    SUM(Total) AS total_revenue
FROM Invoice
GROUP BY invoice_year
ORDER BY invoice_year ASC;


SELECT
    Genre.Name,
    SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS total_revenue
FROM InvoiceLine
JOIN Track ON InvoiceLine.TrackId = Track.TrackId
JOIN Genre ON Track.GenreId = Genre.GenreId
GROUP BY Genre.Name
ORDER BY total_revenue DESC;

SELECT
    Customer.FirstName,
    Customer.LastName,
    SUM(Invoice.Total) AS total_spend,
    Employee.FirstName AS rep_first_name,
    Employee.LastName AS rep_last_name
FROM Invoice
JOIN Customer
    ON Invoice.CustomerId = Customer.CustomerId
JOIN Employee
    ON Customer.SupportRepId = Employee.EmployeeId
GROUP BY
    Customer.CustomerId,
    Customer.FirstName,
    Customer.LastName,
    Employee.EmployeeId,
    Employee.FirstName,
    Employee.LastName
ORDER BY total_spend DESC
LIMIT 5;


SELECT
    Artist.Name AS artist,
    COUNT(DISTINCT Track.TrackId) AS total_tracks,
    SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity) AS total_revenue
FROM Artist
JOIN Album
    ON Artist.ArtistId = Album.ArtistId
JOIN Track
    ON Album.AlbumId = Track.AlbumId
LEFT JOIN InvoiceLine
    ON Track.TrackId = InvoiceLine.TrackId
GROUP BY Artist.ArtistId, Artist.Name
ORDER BY total_tracks DESC;

SELECT
    Artist.Name AS artist,
    COUNT(DISTINCT Track.TrackId) AS total_tracks,
    COALESCE(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity), 0) AS total_revenue,
    COALESCE(SUM(InvoiceLine.UnitPrice * InvoiceLine.Quantity), 0)
        / COUNT(DISTINCT Track.TrackId) AS revenue_per_track
FROM Artist
JOIN Album
    ON Artist.ArtistId = Album.ArtistId
JOIN Track
    ON Album.AlbumId = Track.AlbumId
LEFT JOIN InvoiceLine
    ON Track.TrackId = InvoiceLine.TrackId
GROUP BY Artist.ArtistId, Artist.Name
ORDER BY total_tracks DESC
LIMIT 10;


SELECT
    Customer.CustomerId,
    Customer.FirstName,
    Customer.LastName,
    SUM(Invoice.Total) AS total_spend
FROM Customer
JOIN Invoice
    ON Customer.CustomerId = Invoice.CustomerId
GROUP BY
    Customer.CustomerId,
    Customer.FirstName,
    Customer.LastName
HAVING SUM(Invoice.Total) > (
    SELECT AVG(total_spend)
    FROM (
        SELECT SUM(Total) AS total_spend
        FROM Invoice
        GROUP BY CustomerId
    ) AS customer_spending
)
ORDER BY total_spend DESC;

SELECT
    CustomerId,
    MIN(InvoiceDate) AS first_purchase_date,
    MAX(InvoiceDate) AS most_recent_purchase_date
FROM Invoice
GROUP BY CustomerId
ORDER BY CustomerId;


SELECT DISTINCT
    c.CustomerId,
    c.FirstName,
    c.LastName
FROM Customer AS c
JOIN Invoice AS i2023
    ON c.CustomerId = i2023.CustomerId
    AND YEAR(i2023.InvoiceDate) = 2023
LEFT JOIN Invoice AS i2024
    ON c.CustomerId = i2024.CustomerId
    AND YEAR(i2024.InvoiceDate) = 2024
WHERE i2024.CustomerId IS NULL;

SELECT
    e.EmployeeId,
    e.FirstName,
    e.LastName,
    SUM(i.Total) AS total_revenue,
    RANK() OVER (ORDER BY SUM(i.Total) DESC) AS sales_rank
FROM Employee AS e
JOIN Customer AS c
    ON e.EmployeeId = c.SupportRepId
JOIN Invoice AS i
    ON c.CustomerId = i.CustomerId
GROUP BY
    e.EmployeeId,
    e.FirstName,
    e.LastName
ORDER BY sales_rank;

SELECT
    c.CustomerId,
    CONCAT(c.FirstName, ' ', c.LastName) AS full_name,
    i.InvoiceId,
    i.InvoiceDate,
    i.Total,
    SUM(i.Total) OVER (
        PARTITION BY c.CustomerId
        ORDER BY i.InvoiceDate, i.InvoiceId
    ) AS running_spend
FROM Customer AS c
JOIN Invoice AS i
    ON c.CustomerId = i.CustomerId
ORDER BY c.CustomerId, i.InvoiceDate, i.InvoiceId;

WITH monthly_revenue AS (
    SELECT
        DATE_FORMAT(InvoiceDate, '%Y-%m') AS month,
        SUM(Total) AS revenue
    FROM Invoice
    GROUP BY DATE_FORMAT(InvoiceDate, '%Y-%m')
)

SELECT
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS previous_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month))
        / LAG(revenue) OVER (ORDER BY month) * 100,
        2
    ) AS growth_rate
FROM monthly_revenue
ORDER BY month;