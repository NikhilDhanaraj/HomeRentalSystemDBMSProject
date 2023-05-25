--Procedure to insert new properties
create or replace procedure InsertPropertyRecord(uid in int, pid in int, avail_from in date, avail_till in date, rpm in int, yhr in int, t_area in int, p_area in int, floors in int, yoc in int, loc in varchar, address in varchar, nbr in number, ptype in varchar) as
begin
insert into owner_prop values(uid,pid,avail_from, avail_till, rpm, yhr, t_area, p_area, floors, yoc, loc, address);
IF (nbr is NULL) THEN
   	insert into comm_prop values(pid, ptype);
ELSE
 	insert into res_prop values(pid, nbr, ptype);
END IF;
dbms_output.put_line('Property Record inserted');
commit;
end;
/

--procedure to get property records
create or replace procedure GetPropertyRecord(uid in number) AS
v_pid owner_prop.pid%TYPE;
v_yhr owner_prop.yhr%TYPE;
v_rpm owner_prop.rpm%TYPE;
v_t_area owner_prop.t_area%TYPE;
v_p_area owner_prop.p_area%TYPE;
v_floors owner_prop.floors%TYPE;
v_yoc owner_prop.yoc%TYPE;
v_loc owner_prop.loc%TYPE;
v_address owner_prop.address%TYPE;
v_prop_type VARCHAR2(20);
v_rprop_type  res_prop.rprop_type%TYPE;
v_cprop_type  comm_prop.cprop_type%TYPE;


cursor GPR_Cursor IS
    SELECT op.pid, op.yhr, op.rpm, op.t_area, op.p_area, op.floors, op.yoc, op.loc, op.address,
    CASE WHEN rp.pid IS NOT NULL THEN 'Residential' ELSE 'Commercial' END AS prop_type, rp.rprop_type, cp.cprop_type
    FROM owner_prop op
    LEFT JOIN res_prop rp ON op.pid = rp.pid
    LEFT JOIN comm_prop cp ON op.pid = cp.pid
    WHERE uid = userid;

begin
open GPR_Cursor;
dbms_output.put_line('Properties of user with UID: '||uid||':');
DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
LOOP
FETCH GPR_cursor INTO v_pid, v_yhr, v_rpm, v_t_area, v_p_area, v_floors, v_yoc, v_loc, v_address, v_prop_type, v_rprop_type, v_cprop_type;
    EXIT WHEN GPR_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Property ID: ' || v_pid);
    DBMS_OUTPUT.PUT_LINE('Year of construction: ' || v_yhr);
    DBMS_OUTPUT.PUT_LINE('Rent per month: ' || v_rpm);
    DBMS_OUTPUT.PUT_LINE('Total area: ' || v_t_area);
    DBMS_OUTPUT.PUT_LINE('Property area: ' || v_p_area);
    DBMS_OUTPUT.PUT_LINE('Number of floors: ' || v_floors);
    DBMS_OUTPUT.PUT_LINE('Year of completion: ' || v_yoc);
    DBMS_OUTPUT.PUT_LINE('Locality: ' || v_loc);
    DBMS_OUTPUT.PUT_LINE('Address: ' || v_address);
    DBMS_OUTPUT.PUT_LINE('Property type: ' || v_prop_type);
    if (v_rprop_type is not null) then
    DBMS_OUTPUT.PUT_LINE('Residential type: ' || v_rprop_type);
    else
    DBMS_OUTPUT.PUT_LINE('Commercial type: ' || v_cprop_type);
    end if;
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
end loop;
close GPR_Cursor;
end;
/

--property to get tenant details
create or replace procedure GetTenantDetails(p_id in number) AS
    uid int;
    username varchar2(20);
    userAge int;
    doorno int;
    StreetNo varchar2(10);
    UCity varchar2(20);
    pincode number;
    user_name varchar2(20);
    pass_word varchar2(20);
BEGIN
    select u.userid, uname, age, dno, street, city, zip, username, password into uid, username, userAge, doorno, StreetNo, UCity, pincode, user_name, pass_word
    from users u where u.userid in (select userID from tenant_prop tp where p_id = tp.pid);
    dbms_output.put_line('Details of the tenant living in property number'||p_id|| ':' );
    dbms_output.put_line(uid || ' | ' || username || ' | ' || userAge || ' | ' || doorno || ' | ' || StreetNO || ' | ' || UCity || ' | ' || pincode || ' | ' || user_name || ' | ' || pass_word);
proc1(uid);
end;
/
create or replace procedure proc1(uid in int) is
    phn int;
    cursor proc1_Cursor IS
        select phone from contact where userID = uid;
BEGIN
    open proc1_Cursor;
    dbms_output.put_line('Contact details of the tenant are: ');
    LOOP
    fetch proc1_Cursor into phn;
    exit when proc1_Cursor%notfound;
    dbms_output.put_line(phn);
    end loop;
    close proc1_Cursor;
end;
/

--procedure to create new user
CREATE OR REPLACE PROCEDURE CreateNewUser (
    p_uid in users.userID%TYPE,
    p_uname IN users.uname%TYPE,
    p_age IN users.age%TYPE,
    p_dno IN users.dno%TYPE,
    p_street IN users.street%TYPE,
    p_city IN users.city%TYPE,
    p_zip IN users.zip%TYPE,
    p_username IN users.username%TYPE,
    p_password IN users.password%TYPE,
    p_phone IN contact.phone%TYPE,
    is_mgr int,
    is_dba int) IS
BEGIN
    INSERT INTO users
    VALUES (p_uid, p_uname, p_age, p_dno, p_street, p_city, p_zip, p_username, p_password);
   
    INSERT INTO contact VALUES(p_uid, p_phone);


    if (is_mgr is not NULL) THEN
        insert into manager values(p_uid);
    end if;
    if (is_dba is not null) THEN
        insert into dba values(p_uid);
    end if;
END;
/

--procedure to search properties available for rent
CREATE OR REPLACE PROCEDURE SearchPropertyForRent (p_locality IN VARCHAR2) IS
  CURSOR prop_cursor IS
    SELECT op.pid, op.yhr, op.rpm, op.t_area, op.p_area, op.floors, op.yoc, op.loc, op.address,
           CASE WHEN rp.pid IS NOT NULL THEN 'Residential' ELSE 'Commercial' END AS prop_type, rp.rprop_type, cp.cprop_type
    FROM owner_prop op
    LEFT JOIN res_prop rp ON op.pid = rp.pid
    LEFT JOIN comm_prop cp ON op.pid = cp.pid
    WHERE op.loc = p_locality
    AND op.pid NOT IN (SELECT pid FROM tenant_prop);
   
  v_pid owner_prop.pid%TYPE;
  v_yhr owner_prop.yhr%TYPE;
  v_rpm owner_prop.rpm%TYPE;
  v_t_area owner_prop.t_area%TYPE;
  v_p_area owner_prop.p_area%TYPE;
  v_floors owner_prop.floors%TYPE;
  v_yoc owner_prop.yoc%TYPE;
  v_loc owner_prop.loc%TYPE;
  v_address owner_prop.address%TYPE;
  v_prop_type VARCHAR2(20);
  v_rprop_type  res_prop.rprop_type%TYPE;
  v_cprop_type  comm_prop.cprop_type%TYPE;
BEGIN
  OPEN prop_cursor;
  DBMS_OUTPUT.PUT_LINE('Properties available in ' || p_locality || ':');
  DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
  LOOP
    FETCH prop_cursor INTO v_pid, v_yhr, v_rpm, v_t_area, v_p_area, v_floors, v_yoc, v_loc, v_address, v_prop_type, v_rprop_type, v_cprop_type;
    EXIT WHEN prop_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Property ID: ' || v_pid);
    DBMS_OUTPUT.PUT_LINE('Year of construction: ' || v_yhr);
    DBMS_OUTPUT.PUT_LINE('Rent per month: ' || v_rpm);
    DBMS_OUTPUT.PUT_LINE('Total area: ' || v_t_area);
    DBMS_OUTPUT.PUT_LINE('Property area: ' || v_p_area);
    DBMS_OUTPUT.PUT_LINE('Number of floors: ' || v_floors);
    DBMS_OUTPUT.PUT_LINE('Year of completion: ' || v_yoc);
    DBMS_OUTPUT.PUT_LINE('Locality: ' || v_loc);
    DBMS_OUTPUT.PUT_LINE('Address: ' || v_address);
    DBMS_OUTPUT.PUT_LINE('Property type: ' || v_prop_type);
    if (v_rprop_type is not null) then
    DBMS_OUTPUT.PUT_LINE('Residential type: ' || v_rprop_type);
    else
    DBMS_OUTPUT.PUT_LINE('Commercial type: ' || v_cprop_type);
    end if;
    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------------');
  END LOOP;
  CLOSE prop_cursor;
 
END;
/

--procedure to get rent history of a property
create or replace procedure GetRentHistory(p_id in int) AS
    user_id int;
    sdate date;
    edate date;
    rnt int;
    yhike int;
    cursor RH_Cursor IS
    select userID, st_date, end_date, rent, hike from history_prop where pid = p_id;
BEGIN
    open RH_Cursor;
    fetch RH_Cursor into user_id, sdate, edate, rnt, yhike;
    dbms_output.put_line('For the property with '|| p_id || ': the rent history is: ');
    LOOP
    dbms_output.put_line(user_id || ' | ' || sdate || ' | ' || edate ||' | ' || rnt ||' | ' || yhike);
    exit when RH_Cursor%notfound;
    close RH_Cursor;
end loop;
end;
/

--trigger for adding into history_prop table
create or replace trigger rent_history after update on tenant_prop
for each row
declare
    p_id int;
    user_id int;
    s_date date;
    e_date date;
    rnt int;
    yhike int;
BEGIN
    p_id := :old.pid;
    user_id := :old.userID;
    s_date := :old.st_date;
    e_date := :old.end_date;
    rnt := :old.rent;
    yhike := :old.hike;
   
    insert into history_prop values(p_id, user_id, s_date, e_date, rnt, yhike);


    dbms_output.put_line('history_prop table updated.');
end;
/
