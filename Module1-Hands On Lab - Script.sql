--STEP 1: Logging into Snowflake

--STEP 2: Create Snowflake Objects
CREATE DATABASE TRAINING_DB;

--No need to create the Schema, as the Database is created with 2 schemas by default (INFORMATION_SCHEMA, PUBLIC)

select current_database(), current_schema();

--CREATE TABLE
create or replace table emp_basic (
  first_name string ,
  last_name string ,
  email string ,
  streetaddress string ,
  city string ,
  start_date date
  );
  
--CREATE WAREHOUSE
create or replace warehouse TRAINING_WH with
  warehouse_size='X-SMALL'
  auto_suspend = 180
  auto_resume = true
  initially_suspended=true;
  
select current_warehouse();

--STEP 3: Stage the data files
/*Snowflake supports loading data from files that have been staged in either an internal (Snowflake) stage 
or external (Amazon S3, Google Cloud Storage, or Microsoft Azure) stage.
In this tutorial, we will upload (stage) the sample data files to an internal table stage. The command used to stage files is PUT.

--WINDOWS
put file://c:\temp\employees0*.csv @TRAINING_DB.PUBLIC.%EMP_BASIC;

--Linux or macOS
put file:///tmp/employees0*.csv @sf_tuts.public.%emp_basic;

file: specifies the full directory path and names of the files on your local machine to stage. Note that in filename system wildcards are allowed.

@<namespace>.%<table_name> indicates to use the stage for the specified table, in this case the emp_basic table.

*/
list @TRAINING_DB.PUBLIC.%EMP_BASIC;

--STEP 4: Copy Data into the Target Table
copy into emp_basic
  from @%emp_basic
  file_format = (type = csv field_optionally_enclosed_by='"')
  pattern = '.*employees0[1-5].csv.gz'
  on_error = 'skip_file';


--STEP 5: Query the loaded data
select * from emp_basic;

--Insert Additional Rows of Data
insert into emp_basic values
  ('Clementine','Adamou','cadamou@sf_tuts.com','10510 Sachs Road','Klenak','2017-9-22') ,
  ('Marlowe','De Anesy','madamouc@sf_tuts.co.uk','36768 Northfield Plaza','Fangshan','2017-1-26');

--Query Rows Based on Email Address
select email from emp_basic where email like '%.uk';

--Query Rows Based on Start Date
/*Add 90 days to employee start dates using the DATEADD function to calculate when certain employee benefits might start. 
Filter the list by employees whose start date occurred earlier than January 1, 2017*/
select first_name, last_name, dateadd('day',90,start_date) from emp_basic where start_date <= '2017-01-01'

--STEP 6: Quick Summary & Clean Up
--DROP DATABASE TRAINING_DB;
--DROP WAREHOUSE TRAINING_WH;

