/*
 * Stored Procedures
 * 
 * A named transaction that can be invoked when called like a function
 * A few characteristics
 * 
 * Syntax:
 * 
 * CREATE [OR REPLACE] procedure_name
 * IS
 * 		-- Section to declare variables
 * BEGIN
 * 		-- This is where you can write all of your logic
 * 		-- And you can even utilize other transactions
 * 
 * [EXCEPTION]
 * 		-- This is where you would perform exception handling
 * END;
 * 
 * How you would invoke stored procedures:
 * 
 * BEGIN
 * 		procedure_name();
 * END;
 * 
 * --or--
 * 
 * call procedure_name();
 */

CREATE OR REPLACE PROCEDURE hello_world_procedure
IS
BEGIN
	DBMS_OUTPUT.PUT_LINE('Hello World!');
	-- This is the equivalent to Java's System.out.println() method
	-- It utilizes the DB console
END;

BEGIN
	hello_world_procedure();
END;

/*
 * Procedures can allow us to define executions (transactions).
 * Most actions can be taken against a table in a procedure
 * 
 * Parameters in stored procedures are a bit unique
 * You have the following types (keywords):
 * IN
 * OUT
 * IN OUT
 * 
 * IN parameters: Whatever is passed as input during the procedure call
 * OUT parameters: Whatever is effectively returned from the procedure
 * IN OUT parameters: A variable that is used as input and then transformed
 * 		as output.
 * 
 * -- syntax: varname IN/OUT/IN OUT DATATYPE
 */

CREATE OR REPLACE PROCEDURE insert_into_temp_employees(FIRST IN VARCHAR2,
	LAST IN VARCHAR2, email IN VARCHAR2, salary IN NUMBER, title IN VARCHAR2)
IS
BEGIN
	INSERT INTO TEMPEMPLOYEES emp (first_name, last_name, email, salary, title)
		VALUES (FIRST, LAST, email, salary, title);
	COMMIT;
END;

CALL insert_into_temp_employees('Michelle', 'Ogg', 'oggalicious@gmail.com',
		250000, 'PR Manager');
SELECT * FROM TEMPEMPLOYEES t2;

CREATE OR REPLACE PROCEDURE get_full_name(
	id IN NUMBER, full_name OUT VARCHAR2)
IS
BEGIN
	SELECT first_name || ' ' || last_name
		INTO full_name
		FROM TEMPEMPLOYEES t2
		WHERE EMPLOYEE_ID = id;
END;

DECLARE -- Declare block for local variables
		-- Similar to the IS block
	INPUT NUMBER;
	RESULT VARCHAR2(220);
BEGIN
	INPUT := 202; -- This is how assignment works in PL/SQL
	get_full_name(INPUT, result);
	DBMS_OUTPUT.PUT_LINE(result);
END;

-- IN parameters are pass by value
-- OUT & IN OUT parameters are pass by reference

/*
 * A cursor is like a pointer (such as from traditional programming languages)
 * 	to a ResultSet (or query result). It points to a table or a view.
 * We can use cursors to iterate through queries/tables row by row
 * In general, if we want to pass through entire tables/queries in PL/SQL
 * we need to use a cursor
 * 
 * PL/SQL has a specific kind of cursor type called SYS_REFCURSOR
 * Cursors are uni-directional
 * 
 * The SYS_REFCURSOR is allowed to be passed outside of the scope of the
 * procedure that it is in. A normal cursor must be created and die within the scope
 * of the procedure that it was created in.
 */
CREATE OR REPLACE PROCEDURE get_all_emps(cursor_param OUT SYS_REFCURSOR)
IS
BEGIN
	OPEN cursor_param FOR
		SELECT * FROM TEMPEMPLOYEES t2;
END;

DECLARE -- A block used to declare local variables
	-- varname TYPE
	my_cursor SYS_REFCURSOR;
	emp_id tempemployees.employee_id%TYPE; -- Declare this local variable
	-- with the same type as the employee_id column on the tempemployees table
	emp_first tempemployees.first_name%TYPE;
	emp_last tempemployees.last_name%TYPE;
	emp_email tempemployees.email%TYPE;
	emp_salary tempemployees.salary%TYPE;
	emp_title tempemployees.title%TYPE;
BEGIN
	get_all_emps(my_cursor);

	LOOP -- Effectively a do-while loop
	-- This particular example functions as a for-loop
		FETCH my_cursor INTO
		emp_id, emp_first, emp_last, emp_email, emp_salary, emp_title;
		EXIT WHEN my_cursor%NOTFOUND; -- NOTFOUND does not exist until there are
		-- no records left
		DBMS_OUTPUT.PUT_LINE(emp_id || ' ' || emp_first || ' '
			|| emp_last || ' ' || emp_email || ' ' || emp_salary
			|| ' ' || emp_title);
	END LOOP;
END;

/*
 * There are both EXPLICIT and IMPLICIT cursors. You do not always need to open
 * a cursor with a specific SYS_REFCURSOR variable. If you do, that is referred to
 * as an EXPLCIIT cursor, otherwise all DQL statements return a cursor, which are
 * referred to as IMPLICIT cursors.
 */

-- User Defined Functions
/*
 * Functions =/= Stored Procedures
 * Key Differences:
 * Stored Procedures
 * 		- Does not return anything
 * 		- CAN have as many IN/OUT parameters as we want
 * 		- CAN alter the database with most DML statements
 * 		- CANNOT be called mid-query
 * 		- CAN invoke other stored procedures within
 * 		- CAN invoke functions
 * 
 * Functions
 * 		- MUST return EXACTLY one resource
 * 		- CAN have OUT parameters, but it is frowned upon
 * 		- CANNOT perform DML
 * 		- CAN be called mid-query
 * 		- CAN call other functions
 * 		- CANNOT invoke stored procedures
 */

CREATE OR REPLACE FUNCTION get_max_id
RETURN NUMBER
IS
	max_id NUMBER;
BEGIN
	SELECT MAX(employee_id) INTO max_id FROM TEMPEMPLOYEES;
	RETURN max_id;
END;

DECLARE
	max_id NUMBER;
BEGIN
	max_id := get_max_id();
	DBMS_OUTPUT.PUT_LINE('The max ID found: ' || max_id);
END;

-- EXCEPTION HANDLING
CREATE OR REPLACE PROCEDURE exception_example
IS
	temp NUMBER;
	CURSOR bad_cursor IS
		SELECT * FROM TEMPEMPLOYEES;
	emp_id NUMBER;
	emp_first VARCHAR2(100);
	emp_last VARCHAR2(100);
	emp_email VARCHAR2(100);
	emp_salary NUMBER;
	emp_title VARCHAR2(100);
BEGIN
	--temp := 1 / 0; -- Causes exception
	OPEN bad_cursor;
	LOOP
		FETCH bad_cursor
			INTO emp_id, emp_first, emp_last, emp_email,
			emp_salary, emp_title;
		EXIT WHEN bad_cursor%NOTFOUND;
	END LOOP;
	DBMS_OUTPUT.PUT_LINE('Continued?');
	CLOSE bad_cursor;
	EXCEPTION
		WHEN zero_divide THEN
			DBMS_OUTPUT.PUT_LINE('Division by zero!');
		WHEN invalid_cursor THEN
			DBMS_OUTPUT.PUT_LINE('BAD CURSOR!');
END;

BEGIN
	exception_example();
END;

