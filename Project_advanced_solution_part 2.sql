Use Library_Project

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;

/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.
*/

SELECT 
    ist.issued_member_id,
    m.member_name,
    bk.book_title,
    ist.issued_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) as overdue_days
FROM issued_status ist
JOIN members m
    ON m.member_id = ist.issued_member_id
JOIN books bk
    ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status rs
    ON rs.issued_id = ist.issued_id
WHERE 
    rs.return_date IS NULL  -- The book has not been returned
    AND 
    DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30  -- More than 30 days overdue
ORDER BY ist.issued_member_id;



/*

Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table). */

-- Create the stored procedure
CREATE PROCEDURE add_return_records
    @p_return_id VARCHAR(10),
    @p_issued_id VARCHAR(10),
    @p_book_quality VARCHAR(10)
AS
BEGIN
    DECLARE @v_isbn VARCHAR(50);
    DECLARE @v_book_name VARCHAR(80);

    -- Insert a new record into the return_status table
    INSERT INTO return_status (return_id, issued_id, return_date, book_quality)
    VALUES (@p_return_id, @p_issued_id, GETDATE(), @p_book_quality);

    -- Retrieve the ISBN and book name from issued_status based on issued_id
    SELECT 
        @v_isbn = ist.issued_book_isbn,
        @v_book_name = ist.issued_book_name
    FROM 
        issued_status ist
    WHERE 
        ist.issued_id = @p_issued_id;

    -- Update the book status to 'yes' in the books table based on the ISBN
    UPDATE books
    SET status = 'yes'
    WHERE isbn = @v_isbn;

    -- Print a message to the user
    PRINT 'Thank you for returning the book: ' + @v_book_name;
END;
GO


-- Test the procedure with sample data
EXEC add_return_records 'RS138', 'IS135', 'Good';


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
*/

SELECT 
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS number_book_issued,
    COUNT(rs.return_id) AS number_of_book_return,
    SUM(bk.rental_price) AS total_revenue
INTO branch_reports
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
LEFT JOIN return_status AS rs
    ON rs.issued_id = ist.issued_id
JOIN books AS bk
    ON ist.issued_book_isbn = bk.isbn
GROUP BY b.branch_id, b.manager_id;

-- Query to retrieve data from the created table
SELECT * FROM branch_reports;



/* Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months. */

-- Create the active_members table based on members who issued a book in the last 2 months
SELECT * 
INTO active_members
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id   
    FROM issued_status
    WHERE issued_date >= DATEADD(MONTH, -2, GETDATE())
);

-- Query to retrieve data from the created active_members table
SELECT * FROM active_members;


/* Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch. */

SELECT 
    e.emp_name,
    b.branch_id,
    b.manager_id,
    COUNT(ist.issued_id) AS no_book_issued
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
    ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_id, b.manager_id;



/* Task 18: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.
*/

-- Table definitions assumed to be in place

-- Create stored procedure
CREATE OR ALTER PROCEDURE issue_book
    @p_issued_id VARCHAR(10),
    @p_issued_member_id VARCHAR(30),
    @p_issued_book_isbn VARCHAR(30),
    @p_issued_emp_id VARCHAR(10)
AS
BEGIN
    DECLARE @v_status VARCHAR(10);

    -- Checking if book is available 'yes'
    SELECT @v_status = status
    FROM books
    WHERE isbn = @p_issued_book_isbn;

    IF @v_status = 'yes'
    BEGIN
        INSERT INTO issued_status (issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
        VALUES (@p_issued_id, @p_issued_member_id, GETDATE(), @p_issued_book_isbn, @p_issued_emp_id);

        UPDATE books
        SET status = 'no'
        WHERE isbn = @p_issued_book_isbn;

        PRINT 'Book records added successfully for book isbn: ' + @p_issued_book_isbn;
    END
    ELSE
    BEGIN
        PRINT 'Sorry to inform you the book you have requested is unavailable book_isbn: ' + @p_issued_book_isbn;
    END
END;
GO

-- Query to display data from books
SELECT * FROM books;

-- Query to display data from issued_status
SELECT * FROM issued_status;

-- Execute stored procedure
EXEC issue_book 'IS155', 'C108', '978-0-553-29698-2', 'E104';

EXEC issue_book 'IS156', 'C108', '978-0-375-41398-8', 'E104';

-- Query to display data from books for a specific ISBN
SELECT * FROM books
WHERE isbn = '978-0-375-41398-8';
