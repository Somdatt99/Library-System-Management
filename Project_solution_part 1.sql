Use Library_Project

SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM return_status;
SELECT * FROM members;
-- Project TASK

-- ### 2. CRUD Operations


-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
Insert into books
values
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')

-- Task 2: Update an Existing Member's Address
Update members
set member_address = '125 Main St'
where member_id = 'C101'

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS104' from the issued_status table.
Delete from issued_status
WHERE issued_id = 'IS121';


-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
-- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT 
    ist.issued_emp_id,
    e.emp_name,
    COUNT(ist.issued_id) AS counts
FROM issued_status AS ist
JOIN employees AS e
    ON e.emp_id = ist.issued_emp_id
GROUP BY 
    ist.issued_emp_id,
    e.emp_name
HAVING COUNT(ist.issued_id) > 1;


-- ### 3. CTAS (Create Table As Select)

-- Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_cnts (
    isbn VARCHAR(20),  -- Adjust data types as necessary
    book_title VARCHAR(255),
    no_issued INT
);


INSERT INTO book_cnts (isbn, book_title, no_issued)
SELECT 
    b.isbn,
    b.book_title,
    COUNT(ist.issued_id) AS no_issued
FROM books AS b
JOIN issued_status AS ist
    ON ist.issued_book_isbn = b.isbn
GROUP BY 
    b.isbn,
    b.book_title;

SELECT * FROM book_cnts;



-- ### 4. Data Analysis & Findings

-- Task 7. **Retrieve All Books in a Specific Category:

 select * from books
 WHERE category = 'Fiction'


-- Task 8: Find Total Rental Income by Category:

SELECT
    b.category,
    SUM(b.rental_price) as Rental_Income,
    COUNT(*)
FROM books as b
JOIN
issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY category


-- Task 9. **List Members Who Registered in the Last 180 Days**:

SELECT *
FROM members
WHERE reg_date >= DATEADD(DAY, -180, GETDATE());



-- Task 10: List Employees with Their Branch Manager's Name and their branch details**:
SELECT 
    e1.*,
    b.manager_id,
    e2.emp_name as manager
FROM employees as e1
JOIN  
branch as b
ON b.branch_id = e1.branch_id
JOIN
employees as e2
ON b.manager_id = e2.emp_id


-- Task 11. Create a Table of Books with Rental Price Above a Certain Threshold
SELECT *
INTO books_price_greater_than_five
FROM Books
WHERE rental_price > 5;

select * from books_price_greater_than_five


-- Task 12: Retrieve the List of Books Not Yet Returned
SELECT 
    DISTINCT ist.issued_book_name
FROM issued_status as ist
LEFT JOIN
return_status as rs
ON ist.issued_id = rs.issued_id
WHERE rs.return_id IS NULL

SELECT * FROM return_status
    